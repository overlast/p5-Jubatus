use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Recommender::Client;

my $server_name_suffix = "recommender";
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

subtest "Test to connect to the Recommender" => sub {
    my $guard = $setup->();
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is ("Jubatus::Recommender::Client", ref $reco_client, "Get Jubatus::Recommender::Client object");
    };
    subtest "Test Jubatus::Recommender::Client->get_client()" => sub {
        my $msg_client = $reco_client->get_client();
        is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
        my $con = $reco_client->get_config("");
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
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
        my $con = $reco_client->get_config("");
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

subtest 'Test server status reader' => sub {
    subtest 'Test get_status()' => sub {
        my $guard = $setup->();
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
        my $status = $reco_client->get_status("");
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
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
    subtest 'call clear()' => sub {
        my $is_clear = $reco_client->clear($name);
        is (1, $is_clear, "Call clear()");
    };

    my $string_values = [["key1", "val1"], ["key2", "val2"],];
    my $num_values = [["key1", 1.0], ["key2", 2.0],];

    my $datum;
    subtest 'test Jubatus::Recommender::Datum->new()' => sub {
        $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        is("Jubatus::Recommender::Datum", ref $datum, "Get Jubatus::Recommender::Datum object");
        is(1, exists $datum->{string_values}, "Datum object has string_values field");
        is(1, exists $datum->{num_values}, "Datum object has num_values field");
        is("val1", $datum->{string_values}->[0]->[1], "Check value of string_values field of Datum object");
        is("1", $datum->{num_values}->[0]->[1], "Check value of num_values field of Datum object");
    };

    my $row_id = "jubatus recommender test";
    subtest 'test update_row()' => sub {
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
        is (1, $is_update, "Call update_row()");
    };

    subtest 'test get_all_rows()' => sub {
        my $result_ids = $reco_client->get_all_rows($name);
        my $answer_ids = [$row_id];
        is_deeply($answer_ids, $result_ids, "Check the row ids which are same as '$row_id' which input by update_row()");
    };
};

subtest 'Test all model data cleaner' => sub {
    subtest 'test clear()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
        my $is_clear = $reco_client->clear($name);
        is (1, $is_clear, "Call clear()");
        my $result_rows = $reco_client->get_all_rows($name);
        my $answer_rows = [];
        is_deeply($answer_rows, $result_rows, "Check the all row ids are cleared");
    };
};

subtest 'Test model data updator by write multi row ids' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

    my $is_clear = $reco_client->clear($name);

    {
        my $row_id = "Jubatus Recommender Test A";
        my $string_values = [["key1", "val1"], ["key2", "val2"],];
        my $num_values = [["key1", 1.0], ["key2", 2.0],];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "Jubatus Recommender Test B";
        my $string_values = [["key1", "val1"], ["key2", "val2"],];
        my $num_values = [["key1", 1.0], ["key2", 2.0],];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "Jubatus Recommender Test C";
        my $string_values = [["key1", "val1"], ["key2", "val2"],];
        my $num_values = [["key1", 1.0], ["key2", 2.0],];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }

    subtest 'test get_all_rows()' => sub {
        my $result_ids = $reco_client->get_all_rows($name);
        my $answer_ids = [
            "Jubatus Recommender Test A",
            "Jubatus Recommender Test B",
            "Jubatus Recommender Test C",
        ];
        is_deeply($answer_ids, $result_ids, "Check the row ids which are same as answer_ids which input by update_row()");
    };
};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

        my $is_clear = $reco_client->clear($name);

        {
            my $row_id = "Jubatus Recommender Test A";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
            my $is_update = $reco_client->update_row($name, $row_id, $datum);
        }
        {
            my $row_id = "Jubatus Recommender Test B";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
            my $is_update = $reco_client->update_row($name, $row_id, $datum);
        }
        {
            my $row_id = "Jubatus Recommender Test C";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
            my $is_update = $reco_client->update_row($name, $row_id, $datum);
        }

        subtest 'Does the rows inpute ?' => sub {
            my $result_ids = $reco_client->get_all_rows($name);
            my $answer_ids = [
                "Jubatus Recommender Test A",
                "Jubatus Recommender Test B",
                "Jubatus Recommender Test C",
            ];
            is_deeply($answer_ids, $result_ids, "Check the row ids which are same as answer_ids which input by update_row()");
        };

        subtest 'Does model file dump ?' => sub {
            my $model_name = "recommender_test";
            my $is_save = $reco_client->save($name, $model_name);
            is (1, $is_save, "Call save()");

            my $datadir;
            my $status = $reco_client->get_status($name);
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
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

        {
            my $row_id = "Jubatus Recommender Test A";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
            my $is_update = $reco_client->update_row($name, $row_id, $datum);
        }
        {
            my $row_id = "Jubatus Recommender Test B";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
            my $is_update = $reco_client->update_row($name, $row_id, $datum);
        }
        {
            my $row_id = "Jubatus Recommender Test C";
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
            my $is_update = $reco_client->update_row($name, $row_id, $datum);
        }

        my $model_name = "recommender_test";
        my $is_save = $reco_client->save($name, $model_name);
        my $datadir;
        my $status = $reco_client->get_status($name);
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

        my $is_clear = $reco_client->clear($name);
        subtest 'Does the saved rows delete ?' => sub {
            my $result_ids = $reco_client->get_all_rows($name);
            my $answer_ids = [];
            is_deeply($answer_ids, $result_ids, "Check the row ids which are deleted by clear()");
        };

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $reco_client->load($name, $model_name);
            is (1, $is_save, "Call load()");


            my $result_ids = $reco_client->get_all_rows($name);
            my $answer_ids = [
                "Jubatus Recommender Test A",
                "Jubatus Recommender Test B",
                "Jubatus Recommender Test C",
            ];
            is_deeply($answer_ids, $result_ids, "Check the row ids which are same as answer_ids which are loaded by load()");
        };
    };
};

subtest 'Test data deleter' => sub {
    subtest 'test clear_row()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

        my $is_clear = $reco_client->clear($name);

        my @row_ids_arr = (
            "Jubatus Recommender TestA",
            "Jubatus Recommender TestB",
            "Jubatus Recommender TestC",
        );

        foreach my $row_id (@row_ids_arr) {
            my $string_values = [["key1", "val1"], ["key2", "val2"],];
            my $num_values = [["key1", 1.0], ["key2", 2.0],];
            my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
            my $is_update = $reco_client->update_row($name, $row_id, $datum);
        }

        {
            my $result_ids = $reco_client->get_all_rows($name);
            my $answer_ids = [
                @row_ids_arr,
            ];
            is_deeply($answer_ids, $result_ids, "Check the row ids which are same as answer_ids which input by update_row()");
        }

        # my $is_not_clear_row = $reco_client->clear_row($name, $row_ids_arr[0]."noize");
        # is ($is_not_clear_row, 0, "Call clear_row() with uninputted key");
        my $is_clear_row = $reco_client->clear_row($name, $row_ids_arr[0]);
        is (1, $is_clear_row, "Call clear_row() (It is meanless test. Because recommender is always return true. delete_row() in storage/sparse_matrix_storage.cpp not return the error !!!)");

        {
            my $result_ids = $reco_client->get_all_rows($name);
            my $answer_ids = [
                $row_ids_arr[1],
                $row_ids_arr[2],
            ];
        #    is_deeply($result_ids, $answer_ids, "Check row_id is deleted by clear_row()");
        }
    };

};

subtest 'Test data decoder' => sub {
    subtest 'test decode_row()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

        my $is_clear = $reco_client->clear($name);

        my @row_ids_arr = (
            "Jubatus Recommender TestA",
            "Jubatus Recommender TestB",
            "Jubatus Recommender TestC",
        );

        my $string_values = [["key1", "val1"], ["key2", "val2"],];
        my $num_values = [["key1", 1.0], ["key2", 2.0],];
        foreach my $row_id (@row_ids_arr) {
            my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
            my $is_update = $reco_client->update_row($name, $row_id, $datum);
        }

        {
            my $result_ids = $reco_client->get_all_rows($name);
            my $answer_ids = [
                @row_ids_arr,
            ];
            is_deeply($answer_ids, $result_ids, "Check the row ids which are same as answer_ids which input by update_row()");
        }

        foreach my $row_id (@row_ids_arr) {
            my $datum = $reco_client->decode_row($name, $row_id);
            is (ref $datum, "Jubatus::Recommender::Datum", "Call decode_row() and get Jubatus::Recommender::Datum object");
            is(exists $datum->{string_values}, 1, "Datum object 'datum' has string_values field");
            is(exists $datum->{num_values}, 1, "Datum object 'datum' has num_values field");
            is_deeply($datum->{string_values}, $string_values, "string_values field of Datum object is same as imput data structure");
            is_deeply($datum->{num_values}, $num_values, "num_values field of Datum object is same as imput data structure");
        }
    };
};

subtest 'Test caluculator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

    my $is_clear = $reco_client->clear($name);

    my $string_values = [["key1", "val1"], ["key2", "val2"]];
    my $num_values = [["key1", 1.0], ["key2", 2.0],];
    my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);

    subtest 'test calc_l2norm()' => sub {
        my $l2norm = $reco_client->calc_l2norm($name, $datum);
        is (1, (($l2norm > (sqrt(7) - 0.000001)) && ($l2norm < (sqrt(7) + 0.000001))) , "Check error value of l2norm is less than 0.000001");
    };

    subtest 'test calc_similarity()' => sub {
        my $similarity = $reco_client->calc_similarity($name, $datum, $datum);
        is (1, (($similarity > 0.999999) && ($similarity < 1.000001)) , "Check error value of similarity of self vector is less than 0.000001");
    };
};

# Origin of this test is http://d.hatena.ne.jp/echizen_tm/20110721/1311253494
subtest 'Test similarity caluculator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

    my $is_clear = $reco_client->clear($name);

    {
        my $row_id = "red";
        my $string_values = [["name", "red"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "blue";
        my $string_values = [["name", "blue"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "cyan";
        my $string_values = [["name", "cyan"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my $string_values = [["name", "magenta"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my $string_values = [["name", "yellow"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "green";
        my $string_values = [["name", "green"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);

        my $max_result_num = 10;
        subtest 'test similar_row_from_datum()' => sub {
            my $similarity = $reco_client->similar_row_from_datum($name, $datum, $max_result_num);
            is ("cyan", $similarity->[0]->[0], "cyan is most similar than other colors");
            is ("yellow", $similarity->[1]->[0], "yellow is more similar than blue");
            is ("blue", $similarity->[2]->[0], "blue is more similar than red");
        };

        my $is_update = $reco_client->update_row($name, $row_id, $datum);

        subtest 'test similar_row_from_id()' => sub {
            my $similarity = $reco_client->similar_row_from_id($name, "green", $max_result_num);
            is ("green", $similarity->[0]->[0], "green is itself");
            is ("cyan", $similarity->[1]->[0], "cyan is most similar than other colors");
            is ("yellow", $similarity->[2]->[0], "yellow is more similar than blue");
            is ("blue", $similarity->[3]->[0], "blue is more similar than red");
        };
    }
};

subtest 'Test colmun data completer' => sub {

    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

    my $is_clear = $reco_client->clear($name);

    {
        my $row_id = "red";
        my $string_values = [["name", "red"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "blue";
        my $string_values = [["name", "blue"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "cyan";
        my $string_values = [["name", "cyan"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my $string_values = [["name", "magenta"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my $string_values = [["name", "yellow"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "green";
        my $string_values = [["name", "green"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 0.255], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);

        subtest 'test complete_row_from_datum()' => sub {
            my $completed = $reco_client->complete_row_from_datum($name, $datum);
            is (1, ($completed->{num_values}->[0]->[1] > 0), "R is completed using average of weighted value");
            is (1, ($completed->{num_values}->[1]->[1] > 0), "G is replace using average of weighted value");
            is (1, ($completed->{num_values}->[2]->[1] > 0), "B is completed using average of weighted value");
        };

        my $is_update = $reco_client->update_row($name, $row_id, $datum);

        subtest 'test similar_row_from_id()' => sub {
            my $completed = $reco_client->complete_row_from_id($name, "green");
            is (1, ($completed->{num_values}->[0]->[1] > 0), "R is completed using average of weighted value");
            is (1, ($completed->{num_values}->[1]->[1] > 0), "G is replace using average of weighted value");
            is (1, ($completed->{num_values}->[2]->[1] > 0), "B is completed using average of weighted value");
          };
    }
};

done_testing();

sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}
