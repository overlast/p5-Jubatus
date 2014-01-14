use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Stat::Client;

use YAML;

my $server_name_suffix = "stat";
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

subtest "Test to connect to the Stat" => sub {
    my $guard = $setup->();
    my $stat_client = Jubatus::Stat::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is (ref $stat_client, "Jubatus::Stat::Client", "Get Jubatus::Stat::Client object");
    };
    subtest "Test Jubatus::Stat::Client->get_client()" => sub {
        my $msg_client = $stat_client->get_client();
        is (ref $msg_client, "AnyEvent::MPRPC::Client", "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port});
        my $con = $stat_client->get_config();
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
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my $con = $stat_client->get_config();
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
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my $status = $stat_client->get_status();
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

subtest 'Test data writer' => sub {
    subtest 'Test get_status()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my $is_push = $stat_client->push("stddev", 1.0);
        is($is_push, 1, "Data is pushed");
    };
};

subtest 'Test model data updator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $timeout = 10;
    my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
    subtest 'call clear()' => sub {
        my $is_clear = $stat_client->clear();
        is (1, $is_clear, "Call clear()");
    };
};

subtest 'Test standard deviation culculator' => sub {
    subtest 'Test stddev()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "stddev";
        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }
        my $result = $stat_client->stddev($key);
        is($result, sqrt(2), "Get standard deviation");
    };
};

subtest 'Test Connection by same item' => sub {
    subtest 'Test a lot of push()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my $max_push = 10000;
        my $key = "stddev";
        for (my $i = 0; $i <= $max_push; $i++) {
            my $val = 1.0;
            my $is_push = $stat_client->push($key, $val);
        }
        my $result = $stat_client->stddev($key);
        is($result, 0, "Get standard deviation");
    };
};

subtest 'Test Connection by many keys' => sub {
    subtest 'Test a lot of push()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my $max_row = 100;
        my $max_colmun = 100;
        for (my $i = 0; $i <= $max_colmun; $i++) {
            for (my $j = 0; $j <= $max_row; $j++) {
                my $val = 1.0;
                my $is_push = $stat_client->push("$j", $val);
            }
        }
        my $result = $stat_client->stddev("$max_row");
        is($result, 0, "Get standard deviation");
    };
};

subtest 'Test standard deviation culculator' => sub {
    subtest 'Test stddev()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        {
            my @sample = (10.0, 20.0, 30.0, 40.0, 50.0);
            my $key = "stddev-noise";
            foreach my $val (@sample) {
                my $is_push = $stat_client->push($key, $val);
            }
        }
        {
            my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
            my $key = "stddev";
            foreach my $val (@sample) {
                my $is_push = $stat_client->push($key, $val);
            }
            my $result = $stat_client->stddev($key);
            is($result, sqrt(2), "Get standard deviation");
        }
    };
};

subtest 'Test standard deviation culculator' => sub {
    subtest 'Test stddev()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);

        {
            my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
            my $key = "stddev";
            foreach my $val (@sample) {
                my $is_push = $stat_client->push($key, $val);
            }
        }
        {
            my @sample = (10.0, 20.0, 30.0, 40.0, 50.0);
            my $key = "stddev-noise";
            foreach my $val (@sample) {
                my $is_push = $stat_client->push($key, $val);
            }
        }
        {
            my $key = "stddev";
            my $result = $stat_client->stddev($key);
            is($result, sqrt(2), "Get standard deviation");
        }
    };
};

subtest 'Test standard deviation culculator' => sub {
    subtest 'Test stddev()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);

        {
            my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
            my $key = "1111";
            foreach my $val (@sample) {
                my $is_push = $stat_client->push($key, $val);
            }
        }
        {
            my @sample = (10.0, 20.0, 30.0, 40.0, 50.0);
            my $key = "stddev-noise";
            foreach my $val (@sample) {
                my $is_push = $stat_client->push($key, $val);
            }
        }
        {
            my $key = "1111";
            my $result = $stat_client->stddev($key);
            is($result, sqrt(2), "Get standard deviation");
        }
    };
};

subtest 'Test standard deviation culculator' => sub {
    subtest 'Test stddev()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my @sample = (61.0, 74.0, 55.0, 85.0, 68.0, 72.0, 64.0, 80.0, 82.0, 59.0);
        my $key = "stddev";
        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }
        my $result = $stat_client->stddev($key);
        is($result, 9.77752524926427, "Get standard deviation");
    };
};

subtest 'Test summuation culculator' => sub {
    subtest 'Test sum()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "sum";
        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }
        my $result = $stat_client->sum($key);
        is($result, 15.0, "Get summuation");
    };
};

subtest 'Test max value searcher' => sub {
    subtest 'Test max()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "max";
        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }
        my $result = $stat_client->max($key);
        is($result, 5.0, "Get max value");
    };
};

subtest 'Test min value searcher' => sub {
    subtest 'Test min()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "min";
        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }
        my $result = $stat_client->min($key);
        is($result, 1.0,  "Get min value");
    };
};

subtest 'Test entoropy calculator' => sub {
    subtest 'Test entropy()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "entropy";
        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }
        my $result = $stat_client->min($key);
        is($result, 1.0, "Get entropy value");
    };
};

subtest 'Test moment calculator' => sub {
    subtest 'Test moment()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "moment";
        my $degree = 3;
        my $center = 0.0;
        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }
        my $result = $stat_client->moment($key, $degree, $center);
        is($result, 45.0, "Get moment value");
    };
};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);

        my $is_clear = $stat_client->clear($name);
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "moment";
        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }

        subtest 'Does model file dump ?' => sub {
            my $model_name = "stat_test";

            my $is_save = $stat_client->save($model_name);
            is (1, $is_save, "Call save()");

            my $datadir;
            my $status = $stat_client->get_status($name);
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
            is (0, $is_there, "Check the suffix of file name in $datadir is '$model_file_name_suffix'");
        };
    };

    subtest 'test load()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $stat_client = Jubatus::Stat::Client->new($host, $server->{port}, $name, $timeout);

        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "moment";

        foreach my $val (@sample) {
            my $is_push = $stat_client->push($key, $val);
        }

        my $model_name = "stat_test";
        my $is_save = $stat_client->save($model_name);
        my $datadir;
        my $status = $stat_client->get_status($name);
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
            my $degree = 3;
            my $center = 0.0;
            my $result = $stat_client->moment($key, $degree, $center);
            is($result, 45.0, "Get result of moment");
        };

        subtest 'test clear()' => sub {
            my $is_clear = $stat_client->clear($name);
            is($is_clear, 1, "Call clear()");
        };

# Jubatus::Stas::Client is not return result of moment() using empty model
#        subtest 'test estimate() for empty model' => sub {
#            my $degree = 3;
#            my $center = 0.0;
#            my $result = $stat_client->moment($key, $degree, $center);
#            print Dump $result;
#            is($result," min", "Get result of moment from empty model");
#        };

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $stat_client->load($model_name);
            is (1, $is_save, "Call load()");

            my $degree = 3;
            my $center = 0.0;
            my $result = $stat_client->moment($key, $degree, $center);
            is($result, 45.0, "Get result of moment from empty model from dumped model");
        };
    };
};

done_testing();
