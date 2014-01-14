use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Classifier::Client;

my $server_name_suffix = "classifier";
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

subtest "Test to connect to the Classifier" => sub {
    my $guard = $setup->();
    my $clas_client = Jubatus::Classifier::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is (ref $clas_client, "Jubatus::Classifier::Client", "Get Jubatus::Classifier::Client object");
    };
    subtest "Test Jubatus::Classifier::Client->get_client()" => sub {
        my $msg_client = $clas_client->get_client();
        is (ref $msg_client, "AnyEvent::MPRPC::Client", "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $clas_client = Jubatus::Classifier::Client->new($host, $server->{port});
        my $con = $clas_client->get_config();
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
        my $timeout = 10;
        my $clas_client = Jubatus::Classifier::Client->new($host, $server->{port}, $name, $timeout);
        my $con = $clas_client->get_config();
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
        my $guard = $setup->($name);
        my $timeout = 10;
        my $clas_client = Jubatus::Classifier::Client->new($host, $server->{port}, $name, $timeout);
        my $status = $clas_client->get_status();
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
    my $clas_client = Jubatus::Classifier::Client->new($host, $server->{port}, $name, $timeout);
    subtest 'call clear()' => sub {
        my $is_clear = $clas_client->clear();
        is ($is_clear, 1, "Call clear()");
    };

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

    subtest 'test train()' => sub {
        my $label = "label";
        my $one_data = [[$label, $datum]];
        my $is_train_one_data = $clas_client->train($one_data);
        is ($is_train_one_data, 1, "Call train() with one training data");
        my $two_data = [[$label, $datum], [$label, $datum],];
        my $is_train_two_data = $clas_client->train($two_data);
        is ($is_train_two_data, 2, "Call train() with two training data");
        my $zero_data = [];
        my $is_train_zero_data = $clas_client->train($zero_data);
        is ($is_train_zero_data, 0, "Call train() with zero training data");
    };
};

# Origin of this sample data is http://jubat.us/ja/tutorial/classifier_python.html#id2
my @sample = (
    ["徳川",  Jubatus::Common::Datum->new([["name", "家康"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "秀忠"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家光"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家綱"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "綱吉"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家宣"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家継"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "吉宗"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家重"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家治"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家斉"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家慶"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家定"]])],
    ["徳川",  Jubatus::Common::Datum->new([["name", "家茂"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "尊氏"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義詮"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義満"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義持"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義量"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義教"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義勝"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義政"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義尚"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義稙"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義澄"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義稙"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義晴"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義輝"]])],
    ["足利",  Jubatus::Common::Datum->new([["name", "義栄"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "時政"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "義時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "泰時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "経時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "時頼"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "長時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "政村"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "時宗"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "貞時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "師時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "宗宣"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "煕時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "基時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "高時"]])],
    ["北条",  Jubatus::Common::Datum->new([["name", "貞顕"]])],
);

@sample = List::Util::shuffle @sample;

subtest 'Test classifier' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $timeout = 10;
    my $clas_client = Jubatus::Classifier::Client->new($host, $server->{port}, $name, $timeout);
    subtest 'call clear()' => sub {
        my $is_clear = $clas_client->clear();
        is ($is_clear, 1, "Call clear()");
    };
    subtest 'test train()' => sub {
        my $is_train = $clas_client->train(\@sample);
        is($is_train, 44, "train all samples (44 samples)")
    };

    subtest 'test classifier()' => sub {
        my @answer_arr = (
            ["徳川", Jubatus::Common::Datum->new([["name", "慶喜"]])],
            ["足利", Jubatus::Common::Datum->new([["name", "義昭"]])],
            ["北条", Jubatus::Common::Datum->new([["name", "守時"]])],
        );
        foreach my $answer (@answer_arr) {
            my $data = [$answer->[1]];
            my $classified_result = $clas_client->classify($data);
            my $max_att = 0;
            for (my $i = 1; $i <= $#{$classified_result->[0]}; $i++) {
                if ($classified_result->[0]->[$i - 1]->{score} < $classified_result->[0]->[$i]->{score}) {
                    $max_att = $i;
                }
            }
            is($classified_result->[0]->[$max_att]->{label}, $answer->[0], "Get result of classifyer (is $answer->[0])");
        }
    };
};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $clas_client = Jubatus::Classifier::Client->new($host, $server->{port}, $name, $timeout);
        my $is_clear = $clas_client->clear();
        my $is_train = $clas_client->train(\@sample);

        subtest 'Does model file dump ?' => sub {
            my $model_name = "classifier_test";
            my $is_save = $clas_client->save($model_name);
            is ($is_save, 1, "Call save()");

            my $datadir;
            my $status = $clas_client->get_status();
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
        my $clas_client = Jubatus::Classifier::Client->new($host, $server->{port}, $name, $timeout);

        my $is_train = $clas_client->train(\@sample);
        my $model_name = "classifier_test";
        my $is_save = $clas_client->save($model_name);
        my $datadir;
        my $status = $clas_client->get_status();
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

        subtest 'test estimate() using learned model' => sub {
            my @answer_arr = (
                ["徳川", Jubatus::Common::Datum->new([["name", "慶喜"]])],
                ["足利", Jubatus::Common::Datum->new([["name", "義昭"]])],
                ["北条", Jubatus::Common::Datum->new([["name", "守時"]])],
            );

            foreach my $answer (@answer_arr) {
                my $data = [$answer->[1]];
                my $classified_result = $clas_client->classify($data);
                my $max_att = 0;
                for (my $i = 1; $i <= $#{$classified_result->[0]}; $i++) {
                    if ($classified_result->[0]->[$i - 1]->{score} < $classified_result->[0]->[$i]->{score}) {
                        $max_att = $i;
                    }
                }
                is($classified_result->[0]->[$max_att]->{label}, $answer->[0], "Get result of classifyer (is $answer->[0])");
            }
        };

        my $is_clear = $clas_client->clear();

        subtest 'test estimate() for empty model' => sub {
            my @answer_arr = (
                ["徳川", Jubatus::Common::Datum->new([["name", "慶喜"]])],
                ["足利", Jubatus::Common::Datum->new([["name", "義昭"]])],
                ["北条", Jubatus::Common::Datum->new([["name", "守時"]])],
            );

            foreach my $answer (@answer_arr) {
                my $data = [$answer->[1]];
                my $classified_result = $clas_client->classify($name, $data);
                my $max_att = 0;
                for (my $i = 1; $i <= $#{$classified_result->[0]}; $i++) {
                    if ($classified_result->[0]->[$i - 1]->{score} < $classified_result->[0]->[$i]->{score}) {
                        $max_att = $i;
                    }
                }
                is_deeply($classified_result->[0], [], "Get result of classifyer (is $answer->[0]) from empty model");
            }
        };

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $clas_client->load($model_name);
            is (1, $is_save, "Call load()");

            my @answer_arr = (
                ["徳川", Jubatus::Common::Datum->new([["name", "慶喜"]])],
                ["足利", Jubatus::Common::Datum->new([["name", "義昭"]])],
                ["北条", Jubatus::Common::Datum->new([["name", "守時"]])],
            );

            foreach my $answer (@answer_arr) {
                my $data = [$answer->[1]];
                my $classified_result = $clas_client->classify($data);
                my $max_att = 0;
                for (my $i = 1; $i <= $#{$classified_result->[0]}; $i++) {
                    if ($classified_result->[0]->[$i - 1]->{score} < $classified_result->[0]->[$i]->{score}) {
                        $max_att = $i;
                    }
                }
                is($classified_result->[0]->[$max_att]->{label}, $answer->[0], "Get result of classifyer (is $answer->[0]) from dumped model");
            }
        };
    };
};

done_testing();
