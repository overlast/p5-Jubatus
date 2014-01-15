use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Anomaly::Client;

my $server_name_suffix = "anomaly";
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

subtest "Test to connect to the Anomaly" => sub {
    my $guard = $setup->();
    my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is (ref $anom_client, "Jubatus::Anomaly::Client", "Get Jubatus::Anomaly::Client object");
    };
    subtest "Test Jubatus::Anomaly::Client->get_client()" => sub {
        my $msg_client = $anom_client->get_client();
        is (ref $msg_client, "AnyEvent::MPRPC::Client", "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $con = $anom_client->get_config();
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
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
        my $con = $anom_client->get_config();
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
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
        my $status = $anom_client->get_status();
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

subtest 'Test row creater' => sub {
    subtest 'Test add()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
        my $datum = Jubatus::Common::Datum->new([['val', 1.0]]);
        {
            my $add_result = $anom_client->add($datum);
            is($add_result->{"id"}, 0, "Make check on to create first row : 0");
            is($add_result->{"score"}, "inf", "Make check on to get score of first row : inf");
        }
        {
            my $add_result = $anom_client->add($datum);
            is($add_result->{"id"}, 1, "Make check on to create first row : 1");
            is($add_result->{"score"}, 1, "Make check on to get score of second row : 1");
        }

    };
};

subtest 'Test all rows getter' => sub {
    subtest 'Test get_all_rows()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
        for (1..10) {
            my $datum = Jubatus::Common::Datum->new([['val', 1.0]]);
            my $add_result = $anom_client->add($datum);
        }
        my $get_all_rows_result = $anom_client->get_all_rows();
        my @result = sort {$a <=> $b} @{$get_all_rows_result};
        my @answer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
        is_deeply(\@result, \@answer, "Make check on to get ids od all rows");
    };
};

subtest 'Test all rows updater' => sub {
    subtest 'Test update()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
        my $row_id;
        for (1..10) {
            my $datum = Jubatus::Common::Datum->new([['val', 1.0]]);
            my $add_result = $anom_client->add($datum);
            $row_id = $add_result->{"id"};
        }
        {
            my $datum = Jubatus::Common::Datum->new([['val', 5.0]]);
            my $update_result = $anom_client->update("9", $datum);
            is($update_result, "inf", "Make check on to update score of 9th row : inf");
        }
    };
};

subtest 'Test score calculator' => sub {
    subtest 'Test calc_score()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
        for (1..9) {
            my $datum = Jubatus::Common::Datum->new([['val', 1.0]]);
            my $add_result = $anom_client->add($datum);
        }
        {
            my $datum = Jubatus::Common::Datum->new([['val', 5.0]]);
            my $calc_result = $anom_client->calc_score($datum);
            is($calc_result, "inf", "Make check on to update score of 10th row : inf");
        }
    };
};

subtest 'Test row deleter' => sub {
    subtest 'Test clear_row()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
        for (1..10) {
            my $datum = Jubatus::Common::Datum->new([['val', 1.0]]);
            my $add_result = $anom_client->add($datum);
        }

        my $is_clear = $anom_client->clear_row("9");
        is ($is_clear, 1, "Make check on to call clear()");

        my $get_all_rows_result = $anom_client->get_all_rows();
        my @result = sort {$a <=> $b} @{$get_all_rows_result};
        my @answer = (0, 1, 2, 3, 4, 5, 6, 7, 8);
        is_deeply(\@result, \@answer, "Make check on to clear 10th row");
    };
};

subtest 'Test model data clearer' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $timeout = 10;
    my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
    subtest 'call clear()' => sub {
        my $is_clear = $anom_client->clear();
        is (1, $is_clear, "Call clear()");
    };
};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);

        my $is_clear = $anom_client->clear();

        for (1..10) {
            my $datum = Jubatus::Common::Datum->new([['val', 1.0]]);
            my $add_result = $anom_client->add($datum);
        }

        subtest 'Does model file dump ?' => sub {
            my $model_name = "stat_test";

            my $is_save = $anom_client->save($model_name);
            is ($is_save, 1, "Call save()");

            my $datadir;
            my $status = $anom_client->get_status();
            foreach my $key (keys %{$status}) {
                foreach my $item (keys %{$status->{$key}}) {
                    if ($item eq 'datadir') {
                        $datadir = $status->{$key}->{$item};
                        last;
                    }
                }
            }
            is ($datadir, '/tmp', "Get default data directory from get_status()");
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
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);

        my $is_clear = $anom_client->clear();

        for (1..10) {
            my $datum = Jubatus::Common::Datum->new([['val', 1.0]]);
            my $add_result = $anom_client->add($datum);
        }

        my $model_name = "anom_test";
        my $is_save = $anom_client->save($model_name);
        my $datadir;
        my $status = $anom_client->get_status();
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

        subtest 'test get_all_rows() using learned model' => sub {
            my $get_all_rows_result = $anom_client->get_all_rows();
            my @result = sort {$a <=> $b} @{$get_all_rows_result};
            my @answer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
            is_deeply(\@result, \@answer, "Make check on to get ids od all rows");
        };

        subtest 'test clear()' => sub {
            my $is_clear = $anom_client->clear();
            is($is_clear, 1, "Call clear()");
        };

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $anom_client->load($model_name);
            is ($is_save, 1, "Call load()");

            my $get_all_rows_result = $anom_client->get_all_rows();
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
        my $timeout = 10;
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port}, $name, $timeout);
        for (1..10) {
            my $datum = Jubatus::Common::Datum->new([['val', 1.0]]);
            my $add_result = $anom_client->add($datum);
        }
        my $val = 5.0;
        my @result = ();
        for (1..10) {
            my $datum = Jubatus::Common::Datum->new([['val', $val]]);
            my $add_result = $anom_client->add($datum);
            push @result, $add_result->{"score"};
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

done_testing();
