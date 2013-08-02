use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::NearestNeighbor::Client;

my $server_name_suffix = "nearest_neighbor";
my $config_path = $FindBin::Bin."/../conf/";
my $server_name = "juba".$server_name_suffix;
my $json_path = $config_path."/boot_".$server_name_suffix.".json";
my $FORMAT = "%-6s %-10s %-8s %-24s %s\n";
my $host = "localhost";

my $server;
my $setup = sub {
    my ($name) = @_;
    my $pid = "";
    if (defined $name) {
        $server = Test::TCP->new(
            code => sub {
                my $port = shift;
                my $is_boot = exec ("$server_name -p $port -f $json_path -n '$name' 1>/dev/null 2>/dev/null \&");
            },
        );
    }
    else {
        $server = Test::TCP->new(
            code => sub {
                my $port = shift;
                my $is_boot = exec ("$server_name -p $port -f $json_path 1>/dev/null 2>/dev/null \&");
            },
        );
    }

    my $bt = Proc::ProcessTable->new();
    foreach my $p ( @{$bt->table} ){
        if ($p->cmndline =~ m|$json_path|) {
            $pid = $p->pid;
            last;
        }
    }
    return Scope::Guard->new(
        sub {
            &kill_process($pid);
        }
    );
};

subtest "Test to connect to the NearestNeighbor" => sub {
    my $guard = $setup->();
    my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is ("Jubatus::NearestNeighbor::Client", ref $near_client, "Get Jubatus::NearestNeighbor::Client object");
    };
    subtest "Test Jubatus::NearestNeighbor::Client->get_client()" => sub {
        my $msg_client = $near_client->get_client();
        is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
    };
};

=pod
subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});
        my $con = $near_client->get_config("");
        use YAML; print Dump $con;
        open my $in, '<', $json_path;
        my $content;
        {
            local $/ = undef;
            $content = <$in>;
        }
        close $in;
        is($con, $content, "Result is same as input configure file");
    };
    subtest 'test get_config() using not null character string name (for zookeeper user)' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});
        my $con = $near_client->get_config("");
        open my $in, '<', $json_path;
        my $content;
        {
            local $/ = undef;
            $content = <$in>;
            }
        close $in;
        is($con, $content, "Result is same as input configure file");
    };
};
=cut

subtest 'Test server status reader' => sub {
    subtest 'Test get_status()' => sub {
        my $guard = $setup->();
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});
        my $status = $near_client->get_status("");
        my $program_name = "";
        foreach my $key (keys %{$status}) {
            foreach my $item (keys %{$status->{$key}}) {
                if ($item eq 'PROGNAME') {
                    $program_name = $server_name;
                    last;
                }
            }
        }
        is($server_name, $program_name, "PROGNAME(server_name) is $server_name");
    };
};

subtest 'Test model data updator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});

 # jubanearest_neighbor is not implemented the clear().
 #   subtest 'call clear()' => sub {
 #       my $is_clear = $near_client->clear($name);
 #       is ($is_clear, 1, "Call clear()");
 #   };

    my $string_values = [["key1", "val1"], ["key2", "val2"],];
    my $num_values = [["key1", 1.0], ["key2", 2.0],];

    my $datum;
    subtest 'test Jubatus::NearestNeighbor::Datum->new()' => sub {
        $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        is("Jubatus::NearestNeighbor::Datum", ref $datum, "Get Jubatus::NearestNeighbor::Datum object");
        is(1, exists $datum->{string_values}, "Datum object has string_values field");
        is(1, exists $datum->{num_values}, "Datum object has num_values field");
        is("val1", $datum->{string_values}->[0]->[1], "Check value of string_values field of Datum object");
        is("1", $datum->{num_values}->[0]->[1], "Check value of num_values field of Datum object");
    };

    my $row_id = "jubatus recommender test";
    subtest 'test set_row()' => sub {
        my $is_update = $near_client->set_row($name, $row_id, $datum);

 # jubanearest_neighbor->set_row() always return 0.
        is ($is_update, 0, "Call set_row()");
    };
};

 # jubanearest_neighbor is not implemented the clear().
#subtest 'Test all model data cleaner' => sub {
#    subtest 'test clear()' => sub {
#        my $name = "cpan module test";
#        my $guard = $setup->($name);
#        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});
#        my $is_clear = $near_client->clear($name);
#        is (1, $is_clear, "Call clear()");
#    };
#};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});

        my $is_clear = $near_client->clear($name);

        {
            my $row_id = "Jubatus NearestNeighbor Test A";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
            my $is_update = $near_client->set_row($name, $row_id, $datum);
        }
        {
            my $row_id = "Jubatus NearestNeighbor Test B";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
            my $is_update = $near_client->set_row($name, $row_id, $datum);
        }
        {
            my $row_id = "Jubatus NearestNeighbor Test C";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
            my $is_update = $near_client->set_row($name, $row_id, $datum);
        }

        subtest 'Does model file dump ?' => sub {
            my $model_name = "recommender_test";
            my $is_save = $near_client->save($name, $model_name);
            is (1, $is_save, "Call save()");

            my $datadir;
            my $status = $near_client->get_status($name);
            foreach my $key (keys %{$status}) {
                foreach my $item (keys %{$status->{$key}}) {
                    if ($item eq 'datadir') {
                        $datadir = $status->{$key}->{$item};
                        last;
                    }
                }
            }
            is ('/tmp', $datadir, "Get default data directory from get_status()");
            my $port = $server->{port};
            my $model_file_name_suffix = "_".$port."_jubatus_".$model_name.".js";
            my $is_there = system("ls -al /tmp|grep $model_file_name_suffix 1>/dev/null 2>/dev/null");
            is (0, $is_there, "Check the suffix of file name in $datadir is '$model_file_name_suffix'");
        };
    };

    subtest 'test load()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});

        {
            my $row_id = "Jubatus NearestNeighbor Test A";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
            my $is_update = $near_client->set_row($name, $row_id, $datum);
        }
        {
            my $row_id = "Jubatus NearestNeighbor Test B";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
            my $is_update = $near_client->set_row($name, $row_id, $datum);
        }
        {
            my $row_id = "Jubatus NearestNeighbor Test C";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
            my $is_update = $near_client->set_row($name, $row_id, $datum);
        }

        my $model_name = "recommender_test";
        my $is_save = $near_client->save($name, $model_name);
        my $datadir;
        my $status = $near_client->get_status($name);
        foreach my $key (keys %{$status}) {
            foreach my $item (keys %{$status->{$key}}) {
                if ($item eq 'datadir') {
                    $datadir = $status->{$key}->{$item};
                    last;
                }
            }
        }
        my $port = $server->{port};
        my $model_file_name_suffix = "_".$port."_jubatus_".$model_name.".js";
        my $is_there = system("ls -al /tmp|grep $model_file_name_suffix 1>/dev/null 2>/dev/null");

        my $is_clear = $near_client->clear($name);

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $near_client->load($name, $model_name);
            is (1, $is_save, "Call load()");
        };
    };
};

subtest 'Test similarity caluculator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});

    my $is_clear = $near_client->clear($name);

    {
        my $row_id = "red";
        my $string_values = [["name", "red"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 0.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "blue";
        my $string_values = [["name", "blue"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "cyan";
        my $string_values = [["name", "cyan"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 255.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my $string_values = [["name", "magenta"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my $string_values = [["name", "yellow"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "green";
        my $string_values = [["name", "green"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);

        my $max_result_num = 10;
        subtest 'test similar_row_from_data()' => sub {
            my $similarity = $near_client->similar_row_from_data($name, $datum, $max_result_num);
            is ("cyan", $similarity->[0]->[0], "cyan is most similar than other colors");
            is ("yellow", $similarity->[1]->[0], "yellow is more similar than red");
            is ("red", $similarity->[2]->[0], "red is more similar than blue");
        };

        my $is_update = $near_client->set_row($name, $row_id, $datum);

        subtest 'test similar_row_from_id()' => sub {
            my $similarity = $near_client->similar_row_from_id($name, "green", $max_result_num);
            is ("green", $similarity->[0]->[0], "green is itself");
            is ("cyan", $similarity->[1]->[0], "cyan is most similar than other colors");
            is ("yellow", $similarity->[2]->[0], "yellow is more similar than red");
            is ("red", $similarity->[3]->[0], "blue is more similar than blue");
        };
    }
};

subtest 'Test nearest neighbor caluculator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});

    my $is_clear = $near_client->clear($name);

    {
        my $row_id = "red";
        my $string_values = [["name", "red"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 0.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "blue";
        my $string_values = [["name", "blue"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "cyan";
        my $string_values = [["name", "cyan"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 255.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my $string_values = [["name", "magenta"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my $string_values = [["name", "yellow"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);
        my $is_update = $near_client->set_row($name, $row_id, $datum);
    }
    {
        my $row_id = "green";
        my $string_values = [["name", "green"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::NearestNeighbor::Datum->new($string_values, $num_values);

        my $max_result_num = 10;
        subtest 'test neighbor_row_from_data()' => sub {
            my $similarity = $near_client->neighbor_row_from_data($name, $datum, $max_result_num);
            is ("cyan", $similarity->[0]->[0], "cyan is most similar than other colors");
            is ("yellow", $similarity->[1]->[0], "yellow is more similar than red");
            is ("red", $similarity->[2]->[0], "red is more similar than blue");
        };

        my $is_update = $near_client->set_row($name, $row_id, $datum);

        subtest 'test neighbor_row_from_id()' => sub {
            my $similarity = $near_client->neighbor_row_from_id($name, "green", $max_result_num);
            is ("green", $similarity->[0]->[0], "green is itself");
            is ("cyan", $similarity->[1]->[0], "cyan is most similar than other colors");
            is ("yellow", $similarity->[2]->[0], "yellow is more similar than red");
            is ("red", $similarity->[3]->[0], "blue is more similar than blue");
        };
    }
};

done_testing();

sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}
