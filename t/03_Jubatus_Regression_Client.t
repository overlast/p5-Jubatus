use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Regression::Client;

my $server_name_suffix = "regression";
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

subtest "Test to connect to the Regression" => sub {
    my $guard = $setup->();
    my $regr_client = Jubatus::Regression::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is ("Jubatus::Regression::Client", ref $regr_client, "Get Jubatus::Regression::Client object");
    };
    subtest "Test Jubatus::Regression::Client->get_client()" => sub {
        my $msg_client = $regr_client->get_client();
        is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $regr_client = Jubatus::Regression::Client->new($host, $server->{port});
        my $con = $regr_client->get_config();
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
        my $timeout = 10;
        my $guard = $setup->($name);
        my $regr_client = Jubatus::Regression::Client->new($host, $server->{port}, $name, $timeout);
        my $con = $regr_client->get_config();
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
        my $name = "cpan module test";
        my $timeout = 10;
        my $guard = $setup->($name);
        my $regr_client = Jubatus::Regression::Client->new($host, $server->{port}, $name, $timeout);
        my $status = $regr_client->get_status();
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
    my $timeout = 10;
    my $guard = $setup->($name);
    my $regr_client = Jubatus::Regression::Client->new($host, $server->{port}, $name, $timeout);

    subtest 'call clear()' => sub {
        my $is_clear = $regr_client->clear();
        is (1, $is_clear, "Call clear()");
    };

    my $weight = 1.0;
    my $values = [["key1", "val1"], ["key2", "val2"], ["key1", 1.0], ["key2", 2.0],];

    my $datum;
    subtest 'test Jubatus::Common::Datum->new()' => sub {
        $datum = Jubatus::Common::Datum->new($values);
        is("Jubatus::Common::Datum", ref $datum, "Get Jubatus::Regression::ScoredDatum");
        is(1, exists $datum->{string_values}, "Datum object has string_value field");
        is(1, exists $datum->{num_values}, "Datum object has num_values field");
        is("val1", $datum->{string_values}->[0]->[1], "Check value of string_values field of Datum object");
        is("1", $datum->{num_values}->[0]->[1], "Check value of num_values field of Datum object");
    };

    subtest 'test train()' => sub {
        my $single_data = [[$weight, $datum]];
        my $is_train_one_data = $regr_client->train($single_data);
        is (1, $is_train_one_data, "Call train() with one training data");
        my $two_data = [[$weight, $datum], [$weight, $datum]];
        my $is_train_two_data = $regr_client->train($two_data);
        is (2, $is_train_two_data, "Call train() with two training data");
        my $zero_data = [];
        my $is_train_zero_data = $regr_client->train($zero_data);
        is (0, $is_train_zero_data, "Call train() with zero training data");
    };
};

# Origin of this sample data is https://raw.github.com/jubatus/jubatus-example/master/rent/dat/rent-data.csv
my @sample = (
    "7.1 10.0 22.34 6.0 2.0 E",
    "8.0 10.0 38.29 45.0 4.0 SE",
    "4.5 26.0 18.23 24.0 2.0 W",
    "4.75 7.0 15.0 24.0 3.0 SW",
    "7.3 15.0 20.13 14.0 8.0 S",
    "8.6 22.0 36.54 9.0 2.0 E",
    "6.3 11.0 20.1 30.0 7.0 SE",
    "9.6 10.0 30.03 0.0 5.0 SW",
    "9.0 10.0 30.03 0.0 2.0 SE",
    "9.0 10.0 30.03 0.0 2.0 SE",
    "8.4 16.0 30.91 9.0 9.0 SE",
    "9.2 12.0 30.03 0.0 2.0 SE",
    "9.2 12.0 30.03 0.0 2.0 SE",
    "9.2 12.0 30.03 0.0 2.0 SE",
    "9.2 12.0 30.03 0.0 2.0 SE",
    "8.8 10.0 30.03 0.0 1.0 W",
    "5.05 7.0 15.0 24.0 10.0 E",
    "5.05 7.0 15.0 24.0 10.0 E",
    "5.05 7.0 15.0 24.0 10.0 E",
    "5.05 7.0 15.0 24.0 10.0 E",
    "6.0 15.0 29.48 24.0 4.0 NW",
    "9.7 3.0 36.94 11.0 5.0 NW",
    "9.22 10.0 30.03 0.0 2.0 SE",
    "4.7 9.0 14.62 28.0 5.0 E",
    "6.6 5.0 22.26 22.0 5.0 E",
    "5.9 8.0 21.56 23.0 4.0 NE",
    "5.9 8.0 21.56 23.0 4.0 NE",
    "4.7 9.0 14.62 28.0 5.0 NE",
    "12.3 8.0 40.12 9.0 7.0 SE",
    "4.5 20.0 16.25 23.0 3.0 SW",
    "9.2 10.0 30.03 0.0 4.0 SE",
    "6.9 7.0 22.83 25.0 4.0 SW",
    "5.8 2.0 17.24 29.0 9.0 E",
    "6.1 5.0 20.43 22.0 3.0 SE",
    "9.6 35.0 35.39 6.0 2.0 SW",
    "9.6 10.0 30.03 0.0 5.0 SE",
    "9.5 6.0 31.1 7.0 8.0 SW",
    "7.8 15.0 23.37 5.0 10.0 NW",
    "6.3 7.0 24.39 25.0 7.0 SE",
    "4.7 1.0 16.35 21.0 4.0 SE",
    "9.4 12.0 30.03 0.0 4.0 SE",
    "9.4 10.0 30.03 0.0 4.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "9.3 10.0 30.03 0.0 3.0 SE",
    "5.8 1.0 17.16 29.0 9.0 E",
    "4.85 7.0 15.0 24.0 8.0 E",
    "4.85 7.0 15.0 24.0 8.0 E",
    "4.85 7.0 15.0 24.0 8.0 E",
    "4.85 7.0 15.0 24.0 8.0 E",
    "4.85 7.0 15.0 24.0 8.0 E",
    "6.4 9.0 28.3 28.0 6.0 E",
    "7.3 15.0 20.13 14.0 8.0 SE",
    "7.8 5.0 25.03 6.0 2.0 SW",
    "7.8 5.0 25.03 6.0 2.0 SW",
    "7.2 25.0 25.33 23.0 3.0 SE",
    "7.67 7.0 30.0 24.0 9.0 E",
    "7.67 7.0 30.0 24.0 9.0 E",
    "7.67 7.0 30.0 24.0 9.0 E",
    "6.5 7.0 24.39 25.0 7.0 SE",
    "4.75 7.0 15.0 24.0 3.0 W",
    "7.5 25.0 22.82 23.0 4.0 SE",
    "7.5 25.0 22.82 23.0 4.0 SE",
    "5.3 7.0 18.07 25.0 06.0 SE",
    "9.0 11.0 31.8 12.0 3.0 SE",
    "7.3 12.0 23.09 12.0 3.0 S",
    "5.5 1.0 17.59 29.0 8.0 S",
    "9.2 10.0 30.03 0.0 2.0 SW",
    "9.2 10.0 30.03 0.0 2.0 SW",
    "6.3 8.0 21.56 23.0 2.0 N",
    "8.8 10.0 30.03 0.0 1.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "9.2 10.0 30.03 0.0 2.0 SE",
    "7.7 10.0 21.02 5.0 1.0 E",
    "7.2 10.0 18.75 5.0 1.0 SW",
    "7.2 10.0 18.75 5.0 1.0 SW",
    "7.2 10.0 18.75 5.0 1.0 SW",
    "7.7 10.0 18.75 5.0 1.0 W",
    "4.75 7.0 15.0 24.0 3.0 E",
    "4.75 7.0 15.0 24.0 3.0 E",
    "4.75 7.0 15.0 24.0 3.0 E",
    "4.75 7.0 15.0 24.0 3.0 E",
    "4.75 7.0 15.0 24.0 3.0 E",
    "5.6 20.0 21.14 7.0 3.0 SW",
    "12.0 10.0 40.12 9.0 7.0 SE",
    "10.6 3.0 37.18 11.0 9.0 NW",
    "4.95 7.0 15.0 24.0 10.0 E",
    "4.85 7.0 15.0 24.0 10.0 E",
    "4.85 7.0 15.0 24.0 10.0 E",
    "4.85 7.0 15.0 24.0 10.0 E",
    "5.05 7.0 15.0 24.0 10.0 SW",
    "9.5 5.0 30.0 13.0 8.0 NE",
    "7.7 10.0 18.75 5.0 1.0 SW",
    "9.3 12.0 30.03 0.0 3.0 SE",
    "9.3 12.0 30.03 0.0 3.0 SE",
    "9.3 12.0 30.03 0.0 3.0 SE",
    "9.3 12.0 30.03 0.0 3.0 SE",
    "9.3 12.0 30.03 0.0 3.0 SE",
    "4.7 10.0 14.62 28.0 5.0 E",
    "9.0 10.0 30.03 0.0 1.0 S",
    "9.0 10.0 30.03 0.0 1.0 S",
    "8.2 10.0 23.56 6.0 3.0 E",
    "7.2 4.0 16.0 5.0 2.0 S",
    "7.2 4.0 16.0 5.0 2.0 S",
    "4.85 7.0 15.0 24.0 9.0 SE",
    "6.6 5.0 22.26 22.0 5.0 SE",
    "9.0 10.0 30.03 0.0 1.0 SE",
    "9.0 10.0 30.03 0.0 1.0 SE",
    "9.0 10.0 30.03 0.0 1.0 SE",
    "9.0 10.0 30.03 0.0 1.0 SE",
    "9.0 10.0 30.03 0.0 1.0 SE",
    "8.3 9.0 32.18 24.0 3.0 S",
    "7.8 10.0 21.02 5.0 4.0 W",
    "6.8 25.0 25.33 23.0 3.0 SE",
    "9.1 10.0 30.03 0.0 3.0 SE",
    "9.1 10.0 30.03 0.0 3.0 SE",
    "7.5 10.0 21.02 5.0 4.0 SW",
    "8.3 9.0 32.18 24.0 3.0 E",
    "10.3 3.0 36.94 11.0 7.0 SE",
    "4.3 15.0 16.25 23.0 1.0 SW",
    "25.0 15.0 74.96 10.0 15.0 E",
    "4.6 17.0 16.32 18.0 4.0 SE",
    "4.2 15.0 16.94 26.0 4.0 SW",
    "6.5 5.0 22.83 25.0 4.0 NE",
    "5.9 8.0 21.56 23.0 4.0 SW",
);

subtest 'Test estimater' => sub {
    my $name = "cpan module test";
    my $timeout = 10;
    my $guard = $setup->($name);
    my $regr_client = Jubatus::Regression::Client->new($host, $server->{port}, $name, $timeout);
    subtest 'call clear()' => sub {
        my $is_clear = $regr_client->clear();
        is (1, $is_clear, "Call clear()");
    };

    my @data_arr = ();
    foreach my $data (@sample) {
        my @vals = split / /, $data;
        my $values = [["direction", "$vals[5]"], ["walk_n_min", 0.0 + $vals[1]], ["area", 0.0 + $vals[2]], ["age", 0.0 + $vals[3]], ["floor", 0.0 + $vals[4]],];
        my $datum = Jubatus::Common::Datum->new($values);
        my $rent = 0.0 + $vals[0];
        my $data = [$rent, $datum];
        push @data_arr, $data;
    }
    subtest 'test train()' => sub {
        my $is_train = $regr_client->train(\@data_arr);
        is($is_train, 145, "train all samples (145 samples)")
    };

    subtest 'test estimate()' => sub {
        my $values = [["walk_n_min", 5.0], ["area", 32.0], ["age", 15.0]];
        my $datum = Jubatus::Common::Datum->new($values);
        my $data = [$datum];
        my $estimate_result = $regr_client->estimate($data);
        is($estimate_result > 8, 1, "Get estimate rent value");
    };
};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $timeout = 10;
        my $guard = $setup->($name);
        my $regr_client = Jubatus::Regression::Client->new($host, $server->{port}, $name, $timeout);

        my $is_clear = $regr_client->clear();

        my @data_arr = ();
        foreach my $data (@sample) {
            my @vals = split / /, $data;
            my $values = [["direction", "$vals[5]"], ["walk_n_min", 0.0 + $vals[1]], ["area", 0.0 + $vals[2]], ["age", 0.0 + $vals[3]], ["floor", 0.0 + $vals[4]],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $rent = 0.0 + $vals[0];
            my $data = [$rent, $datum];
            push @data_arr, $data;
        }
        my $is_train = $regr_client->train(\@data_arr);

        subtest 'Does model file dump ?' => sub {
            my $model_name = "regression_test";
            my $is_save = $regr_client->save($model_name);
            is ($is_save, 1, "Call save()");

            my $datadir;
            my $status = $regr_client->get_status();
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
        my $timeout = 10;
        my $guard = $setup->($name);
        my $regr_client = Jubatus::Regression::Client->new($host, $server->{port}, $name, $timeout);

        my @data_arr = ();
        foreach my $data (@sample) {
            my @vals = split / /, $data;
            my $values = [["direction", "$vals[5]"], ["walk_n_min", 0.0 + $vals[1]], ["area", 0.0 + $vals[2]], ["age", 0.0 + $vals[3]], ["floor", 0.0 + $vals[4]],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $rent = 0.0 + $vals[0];
            my $data = [$rent, $datum];
            push @data_arr, $data;
        }
        my $is_train = $regr_client->train(\@data_arr);

        my $model_name = "regression_test";
        my $is_save = $regr_client->save($model_name);
        my $datadir;
        my $status = $regr_client->get_status();
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

        subtest 'test estimate() using learned model' => sub {
            my $values = [["walk_n_min", 5.0], ["area", 32.0], ["age", 15.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $data = [$datum];
            my $estimate_result = $regr_client->estimate($data);
            is($estimate_result > 8, 1, "Get estimate rent value");
        };

        my $is_clear = $regr_client->clear();

        subtest 'test estimate() for empty model' => sub {
            my $values = [["walk_n_min", 5.0], ["area", 32.0], ["age", 15.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $data = [$datum];
            my $estimate_result = $regr_client->estimate($data);
            is_deeply($estimate_result, [0], "Can't get estimate rent value");
        };

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $regr_client->load($model_name);
            is ($is_save, 1, "Call load()");

            my $values = [["walk_n_min", 5.0], ["area", 32.0], ["age", 15.0],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $data = [$datum];
            my $estimate_result = $regr_client->estimate($data);
            is($estimate_result > 8, 1, "Get estimate rent value from dumped model");
        };
    };
};

done_testing();
