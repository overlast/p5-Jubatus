use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Recommender::Client;

use YAML;

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

=pod

=cut


done_testing();


sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}

#ok(1);

=pod

  def tearDown(self):
    TestUtil.kill_process(self.srv)

  def test_complete_row(self):
    self.cli.clear_row("name", "complete_row")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "complete_row", d)
    d1 = self.cli.complete_row_from_id("name", "complete_row")
    d2 = self.cli.complete_row_from_datum("name", d)

  def test_similar_row(self):
    self.cli.clear_row("name", "similar_row")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "similar_row", d)
    s1 = self.cli.similar_row_from_id("name", "similar_row", 10)
    s2 = self.cli.similar_row_from_datum("name", d, 10)

  def test_calcs(self):
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.assertAlmostEqual(self.cli.calc_similarity("name", d, d), 1, 6)
    self.assertAlmostEqual(self.cli.calc_l2norm("name", d), sqrt(1*1 + 1*1+ 1*1 + 2*2), 6)



if __name__ == '__main__':
  test_suite = unittest.TestLoader().loadTestsFromTestCase(RecommenderTest)
  unittest.TextTestRunner().run(test_suite)
=cut
