use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus;

my $config_path = $FindBin::Bin."/../conf/";
my $FORMAT = "%-6s %-10s %-8s %-24s %s\n";
my $host = "localhost";

my $server;
my $setup = sub {
    my ($name, $suffix) = @_;
    my $server_name = "juba".$suffix;
    my $json_path = $config_path."/boot_".$suffix.".json";

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


{
    my $name = "cpan module test";
    my $client_suffix = "recommender";
    subtest "Test to connect to the jubarecommender using Jubatus.pm" => sub {
        my $guard = $setup->($name, $client_suffix);
        {
            my $recommender_client = Jubatus->get_recommender_client($host, $server->{port});
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Recommender::Client", ref $recommender_client, "Get Jubatus::Recommender::Client object");
            };
            subtest "Test Jubatus->get_recommender_client()" => sub {
                my $msg_client = $recommender_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
        {
            my $recommender_client = Jubatus->get_client($host, $server->{port}, 'recommender');
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Recommender::Client", ref $recommender_client, "Get Jubatus::Recommender::Client object");
            };
            subtest "Test Jubatus::Recommender::Client->get_client()" => sub {
                my $msg_client = $recommender_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
    };
}
{
    my $name = "cpan module test";
    my $client_suffix = "regression";
    subtest "Test to connect to the jubaregression using Jubatus.pm" => sub {
        my $guard = $setup->($name, $client_suffix);
        {
            my $regression_client = Jubatus->get_regression_client($host, $server->{port});
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Regression::Client", ref $regression_client, "Get Jubatus::Regression::Client object");
            };
            subtest "Test Jubatus->get_regression_client()" => sub {
                my $msg_client = $regression_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
        {
            my $regression_client = Jubatus->get_client($host, $server->{port}, 'regression');
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Regression::Client", ref $regression_client, "Get Jubatus::Regression::Client object");
            };
            subtest "Test Jubatus::Regression::Client->get_client()" => sub {
                my $msg_client = $regression_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
    };
}
{
    my $name = "cpan module test";
    my $client_suffix = "classifier";
    subtest "Test to connect to the jubaclassifier using Jubatus.pm" => sub {
        my $guard = $setup->($name, $client_suffix);
        {
            my $classifier_client = Jubatus->get_classifier_client($host, $server->{port});
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Classifier::Client", ref $classifier_client, "Get Jubatus::Classifier::Client object");
            };
            subtest "Test Jubatus->get_classifier_client()" => sub {
                my $msg_client = $classifier_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
        {
            my $classifier_client = Jubatus->get_client($host, $server->{port}, 'classifier');
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Classifier::Client", ref $classifier_client, "Get Jubatus::Classifier::Client object");
            };
            subtest "Test Jubatus::Classifier::Client->get_client()" => sub {
                my $msg_client = $classifier_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
    };
}
{
    my $name = "cpan module test";
    my $client_suffix = "stat";
    subtest "Test to connect to the jubastat using Jubatus.pm" => sub {
        my $guard = $setup->($name, $client_suffix);
        {
            my $stat_client = Jubatus->get_stat_client($host, $server->{port});
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Stat::Client", ref $stat_client, "Get Jubatus::Stat::Client object");
            };
            subtest "Test Jubatus->get_stat_client()" => sub {
                my $msg_client = $stat_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
        {
            my $stat_client = Jubatus->get_client($host, $server->{port}, 'stat');
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Stat::Client", ref $stat_client, "Get Jubatus::Stat::Client object");
            };
            subtest "Test Jubatus::Stat::Client->get_client()" => sub {
                my $msg_client = $stat_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
    };
}
{
    my $name = "cpan module test";
    my $client_suffix = "graph";
    subtest "Test to connect to the jubagraph using Jubatus.pm" => sub {
        my $guard = $setup->($name, $client_suffix);
        {
            my $graph_client = Jubatus->get_graph_client($host, $server->{port});
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Graph::Client", ref $graph_client, "Get Jubatus::Graph::Client object");
            };
            subtest "Test Jubatus->get_graph_client()" => sub {
                my $msg_client = $graph_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
        {
            my $graph_client = Jubatus->get_client($host, $server->{port}, 'graph');
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Graph::Client", ref $graph_client, "Get Jubatus::Graph::Client object");
            };
            subtest "Test Jubatus::Graph::Client->get_client()" => sub {
                my $msg_client = $graph_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
    };
}
{
    my $name = "cpan module test";
    my $client_suffix = "anomaly";
    subtest "Test to connect to the jubaanomaly using Jubatus.pm" => sub {
        my $guard = $setup->($name, $client_suffix);
        {
            my $anom_client = Jubatus->get_anomaly_client($host, $server->{port});
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Anomaly::Client", ref $anom_client, "Get Jubatus::Anomaly::Client object");
            };
            subtest "Test Jubatus->get_anomaly_client()" => sub {
                my $msg_client = $anom_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
        {
            my $anom_client = Jubatus->get_client($host, $server->{port}, 'anomaly');
            subtest "Give hostname & ort number" => sub {
                is ("Jubatus::Anomaly::Client", ref $anom_client, "Get Jubatus::Anomaly::Client object");
            };
            subtest "Test Jubatus::Anomaly::Client->get_client()" => sub {
                my $msg_client = $anom_client->get_client();
                is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
            };
        }
    };
}

=pod


subtest "Test to connect to the Anomaly" => sub {
    my $guard = $setup->();
    my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is ("Jubatus::Anomaly::Client", ref $anom_client, "Get Jubatus::Anomaly::Client object");
    };
    subtest "Test Jubatus::Anomaly::Client->get_client()" => sub {
        my $msg_client = $anom_client->get_client();
        is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $con = $anom_client->get_config("");
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
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $con = $anom_client->get_config("");
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
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $status = $anom_client->get_status("");
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

subtest 'Test row creater' => sub {
    subtest 'Test add()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
        {
            my $add_result = $anom_client->add($name, $datum);
            is($add_result->[0], 0, "Make check on to create first row : 0");
            is($add_result->[1], "inf", "Make check on to get score of first row : inf");
        }
        {
            my $add_result = $anom_client->add($name, $datum);
            is($add_result->[0], 1, "Make check on to create first row : 1");
            is($add_result->[1], 1, "Make check on to get score of second row : 1");
        }

    };
};

subtest 'Test all rows getter' => sub {
    subtest 'Test get_all_rows()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        for (1..10) {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
            my $add_result = $anom_client->add($name, $datum);
        }
        my $get_all_rows_result = $anom_client->get_all_rows($name);
        my @result = sort {$a <=> $b} @{$get_all_rows_result};
        my @answer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
        is_deeply(\@result, \@answer, "Make check on to get ids od all rows");
    };
};

subtest 'Test all rows updater' => sub {
    subtest 'Test update()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $row_id;
        for (1..10) {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
            my $add_result = $anom_client->add($name, $datum);
            $row_id = $add_result->[0];
        }
        {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 5.0]]);
            my $update_result = $anom_client->update($name, "9", $datum);
            is($update_result, "inf", "Make check on to update score of 9th row : inf");
        }
    };
};

subtest 'Test score calculator' => sub {
    subtest 'Test calc_score()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        for (1..9) {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
            my $add_result = $anom_client->add($name, $datum);
        }
        {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 5.0]]);
            my $calc_result = $anom_client->calc_score($name, $datum);
            is($calc_result, "inf", "Make check on to update score of 10th row : inf");
        }
    };
};

subtest 'Test row deleter' => sub {
    subtest 'Test clear_row()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        for (1..10) {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
            my $add_result = $anom_client->add($name, $datum);
        }

        my $is_clear = $anom_client->clear_row($name, "9");
        is (1, $is_clear, "Make check on to call clear()");

        my $get_all_rows_result = $anom_client->get_all_rows($name);
        my @result = sort {$a <=> $b} @{$get_all_rows_result};
        my @answer = (0, 1, 2, 3, 4, 5, 6, 7, 8);
        is_deeply(\@result, \@answer, "Make check on to clear 10th row");
    };
};

subtest 'Test model data clearer' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
    subtest 'call clear()' => sub {
        my $is_clear = $anom_client->clear($name);
        is (1, $is_clear, "Call clear()");
    };
};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});

        my $is_clear = $anom_client->clear($name);

        for (1..10) {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
            my $add_result = $anom_client->add($name, $datum);
        }

        subtest 'Does model file dump ?' => sub {
            my $model_name = "stat_test";

            my $is_save = $anom_client->save($name, $model_name);
            is (1, $is_save, "Call save()");

            my $datadir;
            my $status = $anom_client->get_status($name);
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
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});

        my $is_clear = $anom_client->clear($name);

        for (1..10) {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
            my $add_result = $anom_client->add($name, $datum);
        }

        my $model_name = "anom_test";
        my $is_save = $anom_client->save($name, $model_name);
        my $datadir;
        my $status = $anom_client->get_status($name);
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

        subtest 'test get_all_rows() using learned model' => sub {
            my $get_all_rows_result = $anom_client->get_all_rows($name);
            my @result = sort {$a <=> $b} @{$get_all_rows_result};
            my @answer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
            is_deeply(\@result, \@answer, "Make check on to get ids od all rows");
        };

        subtest 'test clear()' => sub {
            my $is_clear = $anom_client->clear($name);
            is($is_clear, 1, "Call clear()");
        };

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $anom_client->load($name, $model_name);
            is (1, $is_save, "Call load()");

            my $get_all_rows_result = $anom_client->get_all_rows($name);
            my @result = sort {$a <=> $b} @{$get_all_rows_result};
            my @answer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
            is_deeply(\@result, \@answer, "Make check on to get ids od all rows using loaded model");
        };
    };
};

subtest 'Test anomaly detector' => sub {
    subtest 'Test anomaly detection()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        for (1..10) {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
            my $add_result = $anom_client->add($name, $datum);
        }
        my $val = 5.0;
        my @result = ();
        for (1..10) {
            my $datum = Jubatus::Anomaly::Datum->new([], [['val', $val]]);
            my $add_result = $anom_client->add($name, $datum);
            push @result, $add_result->[1];
            $val = 1.000001 + $val;
        }
        my @answer = (
            "inf",
            1,
            0.899999976158142,
            "inf",
            1,
            0.899999976158142,
            0.933333337306976,
            0.9375,
            0.950000047683716,
            0.954545438289642,
        );
        is_deeply(\@answer, \@result, "");
    };
};

=cut

done_testing();

sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}
