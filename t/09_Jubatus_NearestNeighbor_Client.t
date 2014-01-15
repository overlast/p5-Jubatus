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
    my $port;
    if (defined $name) {
        $server = Test::TCP->new(
            code => sub {
                $port = shift;
                my $is_boot = exec ("$server_name -p $port -f $json_path -n '$name' 1>/dev/null 2>/dev/null \&");
            },
        );
    }
    else {
        $server = Test::TCP->new(
            code => sub {
                $port = shift;
                my $is_boot = exec ("$server_name -p $port -f $json_path 1>/dev/null 2>/dev/null \&");
            },
        );
    }
    if (exists $server->{port}) {
        my $bt = Proc::ProcessTable->new();
        foreach my $p ( @{$bt->table} ){
            if (($p->cmndline =~ m|$server->{port}|) && ($p->cmndline =~ m|$json_path|)) {
                $pid = $p->pid;
                last;
            }
        }
        unless ($pid) { die "Can't get PID"; }
    } else {
        die "Can't get server->{port}";
    }
    return Scope::Guard->new(
        sub {
            &kill_process($pid);
        }
    );
};

sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}

subtest "Test to connect to the NearestNeighbor" => sub {
    my $guard = $setup->();
    my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is (ref $near_client, "Jubatus::NearestNeighbor::Client", "Get Jubatus::NearestNeighbor::Client object");
    };
    subtest "Test Jubatus::NearestNeighbor::Client->get_client()" => sub {
        my $msg_client = $near_client->get_client();
        is (ref $msg_client, "AnyEvent::MPRPC::Client", "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});
        my $con = $near_client->get_config();
        open my $in, '<', $json_path;
        my $content;
        {
            local $/ = undef;
            $content = <$in>;
        }
        close $in;
        is($content, $con, "Result is same as input configure file");
    };
    subtest 'test get_config() using not null character string name (for zookeeper user)' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port}, $name, $timeout);
        my $con = $near_client->get_config();
        open my $in, '<', $json_path;
        my $content;
        {
            local $/ = undef;
            $content = <$in>;
            }
        close $in;
        is($content, $con, "Result is same as input configure file");
    };
};

subtest 'Test server status reader' => sub {
    subtest 'Test get_status()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port}, $name, $timeout);
        my $status = $near_client->get_status();
        my $program_name = "";
        foreach my $key (keys %{$status}) {
            foreach my $item (keys %{$status->{$key}}) {
                if ($item eq 'PROGNAME') {
                    $program_name = $server_name;
                    last;
                }
            }
        }
        is($program_name, $server_name, "PROGNAME(server_name) is $server_name");
    };
};

subtest 'Test model data updator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $timeout = 10;
    my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port}, $name, $timeout);

 # jubanearest_neighbor is not implemented the clear().
 #   subtest 'call clear()' => sub {
 #       my $is_clear = $near_client->clear();
 #       is ($is_clear, 1, "Call clear()");
 #   };

    my $values = [["key1", "val1"], ["key2", "val2"], ["key1", 1.0], ["key2", 2.0],];

    my $datum;
    subtest 'test Jubatus::Common::Datum->new()' => sub {
        $datum = Jubatus::Common::Datum->new($values);
        is(ref $datum, "Jubatus::Common::Datum", "Get Jubatus::Common::Datum object");
        is(exists $datum->{string_values}, 1, "Datum object has string_values field");
        is(exists $datum->{num_values}, 1, "Datum object has num_values field");
        is($datum->{string_values}->[0]->[1], "val1", "Check value of string_values field of Datum object");
        is($datum->{num_values}->[0]->[1], "1", "Check value of num_values field of Datum object");
    };

    my $row_id = "jubatus recommender test";
    subtest 'test set_row()' => sub {
        my $is_update = $near_client->set_row($row_id, $datum);

 # jubanearest_neighbor->set_row() always return 0.
        is ($is_update, 1, "Call set_row()");
    };
};

 # jubanearest_neighbor is not implemented the clear().
#subtest 'Test all model data cleaner' => sub {
#    subtest 'test clear()' => sub {
#        my $name = "cpan module test";
#        my $guard = $setup->($name);
#        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port});
#        my $is_clear = $near_client->clear();
#        is (1, $is_clear, "Call clear()");
#    };
#};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port}, $name, $timeout);

        my $is_clear = $near_client->clear();

        {
            my $row_id = "Jubatus NearestNeighbor Test A";
            my $values = [["key1", "val1"], ["key2", "val2"], ["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_update = $near_client->set_row($row_id, $datum);
        }
        {
            my $row_id = "Jubatus NearestNeighbor Test B";
            my $values = [["key1", "val1"], ["key2", "val2"], ["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_update = $near_client->set_row($row_id, $datum);
        }
        {
            my $row_id = "Jubatus NearestNeighbor Test C";
            my $values = [["key1", "val1"], ["key2", "val2"], ["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_update = $near_client->set_row($row_id, $datum);
        }

        subtest 'Does model file dump ?' => sub {
            my $model_name = "recommender_test";
            my $is_save = $near_client->save($model_name);
            is (1, $is_save, "Call save()");

            my $datadir;
            my $status = $near_client->get_status();
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
            my $model_file_name_suffix = "_".$port."_jubatus_".$model_name.".jubatus";
            my $is_there = system("ls -al /tmp|grep $model_file_name_suffix 1>/dev/null 2>/dev/null");
            is ($is_there, 0, "Check the suffix of file name in $datadir is '$model_file_name_suffix'");
        };
    };

    subtest 'test load()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port}, $name, $timeout);

        {
            my $row_id = "Jubatus NearestNeighbor Test A";
            my $values = [["key1", "val1"], ["key2", "val2"], ["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_update = $near_client->set_row($row_id, $datum);
        }
        {
            my $row_id = "Jubatus NearestNeighbor Test B";
            my $values = [["key1", "val1"], ["key2", "val2"], ["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_update = $near_client->set_row($row_id, $datum);
        }
        {
            my $row_id = "Jubatus NearestNeighbor Test C";
            my $values = [["key1", "val1"], ["key2", "val2"], ["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_update = $near_client->set_row($row_id, $datum);
        }

        my $model_name = "recommender_test";
        my $is_save = $near_client->save($model_name);
        my $datadir;
        my $status = $near_client->get_status();
        foreach my $key (keys %{$status}) {
            foreach my $item (keys %{$status->{$key}}) {
                if ($item eq 'datadir') {
                    $datadir = $status->{$key}->{$item};
                    last;
                }
            }
        }
        my $port = $server->{port};
        my $model_file_name_suffix = "_".$port."_jubatus_".$model_name.".jubatus";
        my $is_there = system("ls -al /tmp|grep $model_file_name_suffix 1>/dev/null 2>/dev/null");

        my $is_clear = $near_client->clear();

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $near_client->load($model_name);
            is ($is_save, 1, "Call load()");
        };
    };
};

subtest 'Test similarity caluculator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $timeout = 10;
    my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port}, $name, $timeout);

    my $is_clear = $near_client->clear();

    {
        my $row_id = "red";
        my $values = [["name", "red"], ["image", "warm"], ["R", 255.0], ["G", 0.0], ["B", 0.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "blue";
        my $values = [["name", "blue"], ["image", "cold"], ["R", 0.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "cyan";
        my $values = [["name", "cyan"], ["image", "cold"], ["R", 0.0], ["G", 255.0], ["B", 255.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my $values = [["name", "magenta"], ["image", "warm"], ["R", 255.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my $values = [["name", "yellow"], ["image", "warm"], ["R", 255.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "green";
        my $values = [["name", "green"], ["image", "cold"], ["R", 0.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Common::Datum->new($values);

        my $max_result_num = 10;
        subtest 'test similar_row_from_data()' => sub {
            my $similarity = $near_client->similar_row_from_data($datum, $max_result_num);
            is ("cyan", $similarity->[0]->{"id"}, "cyan is most similar than other colors");
            is ("yellow", $similarity->[1]->{"id"}, "yellow is more similar than red");
            is ("red", $similarity->[2]->{"id"}, "red is more similar than blue");
        };

        my $is_update = $near_client->set_row($row_id, $datum);

        subtest 'test similar_row_from_id()' => sub {
            my $similarity = $near_client->similar_row_from_id("green", $max_result_num);
            is ("green", $similarity->[0]->{"id"}, "green is itself");
            is ("cyan", $similarity->[1]->{"id"}, "cyan is most similar than other colors");
            is ("yellow", $similarity->[2]->{"id"}, "yellow is more similar than red");
            is ("red", $similarity->[3]->{"id"}, "blue is more similar than blue");
        };
    }
};

subtest 'Test nearest neighbor caluculator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $timeout = 10;
    my $near_client = Jubatus::NearestNeighbor::Client->new($host, $server->{port}, $name, $timeout);

    my $is_clear = $near_client->clear();

    {
        my $row_id = "red";
        my $values = [["name", "red"], ["image", "warm"], ["R", 255.0], ["G", 0.0], ["B", 0.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "blue";
        my $values = [["name", "blue"], ["image", "cold"], ["R", 0.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "cyan";
        my $values = [["name", "cyan"], ["image", "cold"], ["R", 0.0], ["G", 255.0], ["B", 255.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my $values = [["name", "magenta"], ["image", "warm"], ["R", 255.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my $values = [["name", "yellow"], ["image", "warm"], ["R", 255.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_update = $near_client->set_row($row_id, $datum);
    }
    {
        my $row_id = "green";
        my $values = [["name", "green"], ["image", "cold"], ["R", 0.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Common::Datum->new($values);

        my $max_result_num = 10;
        subtest 'test neighbor_row_from_data()' => sub {
            my $similarity = $near_client->neighbor_row_from_data($datum, $max_result_num);
            is ("cyan", $similarity->[0]->{"id"}, "cyan is most similar than other colors");
            is ("yellow", $similarity->[1]->{"id"}, "yellow is more similar than red");
            is ("red", $similarity->[2]->{"id"}, "red is more similar than blue");
        };

        my $is_update = $near_client->set_row($row_id, $datum);

        subtest 'test neighbor_row_from_id()' => sub {
            my $similarity = $near_client->neighbor_row_from_id("green", $max_result_num);
            is ("green", $similarity->[0]->{"id"}, "green is itself");
            is ("cyan", $similarity->[1]->{"id"}, "cyan is most similar than other colors");
            is ("yellow", $similarity->[2]->{"id"}, "yellow is more similar than red");
            is ("red", $similarity->[3]->{"id"}, "blue is more similar than blue");
        };
    }
};

done_testing();
