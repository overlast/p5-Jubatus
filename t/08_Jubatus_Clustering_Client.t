use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Clustering::Client;

my $server_name_suffix = "clustering";
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

subtest "Test to connect to the Clustering" => sub {
    my $guard = $setup->();
    my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is (ref $clus_client, "Jubatus::Clustering::Client", "Get Jubatus::Clustering::Client object");
    };
    subtest "Test Jubatus::Clustering::Client->get_client()" => sub {
        my $msg_client = $clus_client->get_client();
        is (ref $msg_client, "AnyEvent::MPRPC::Client", "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port});
        my $con = $clus_client->get_config();
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
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);
        my $con = $clus_client->get_config();
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
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);
        my $status = $clus_client->get_status();
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

subtest 'Test server revision reader' => sub {
    subtest 'Test get_revision()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);
        my $revision = $clus_client->get_revision();
        is($revision == 0, 1, "Make check to get a revision number of server");
    };
};

subtest 'Test model data updator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $timeout = 10;
    my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);

    my $values = [["key1", 1.0], ["key2", 2.0],];
    my $datum;
    subtest 'test Jubatus::Common::Datum->new()' => sub {
        $datum = Jubatus::Common::Datum->new($values);
        is(ref $datum, "Jubatus::Common::Datum", "Get Jubatus::Common::Datum object");
        is(exists $datum->{string_values}, 1, "Datum object has string_values field");
        is(exists $datum->{num_values}, 1, "Datum object has num_values field");
        is($#{$datum->{string_values}}, -1, "Check value of string_values field of Datum object");
        is($datum->{num_values}->[0]->[1], "1", "Check value of num_values field of Datum object");
    };
    subtest 'test push()' => sub {
        my $is_push = $clus_client->push([$datum]);
        my $revision = $clus_client->get_revision();
        is($is_push, 1, "Make check to call push()");
        is($revision, 1, "Make check to get a revision number of server after push()");
    };
};

subtest 'Test coreset getter' => sub {
    subtest 'test get_core_members()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);
        my $values = [["key1", 1.0], ["key2", 2.0],];
        my $datum = Jubatus::Common::Datum->new($values);
        my $is_push = $clus_client->push([$datum]);
        is($is_push, 1, "Make check to call push()");

        my $res = $clus_client->get_core_members();
        is(ref $res, "ARRAY", "Make check to get coreset");
        is(ref $res->[0]->[0], "Jubatus::Clustering::WeightedDatum", "Make check a response is Jubatus::Clustering::WeightedDatum object");
        is($#{$res}, 9, "Make check a response which has 10 elements");
    };
};

subtest 'Test k-center getter' => sub {
    subtest 'test get_k_center()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);

        for (my $i = 0; $i <= 100; $i++) {
            my $values = [["key1", $i], ["key2", -1.0 * $i],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_push = $clus_client->push([$datum]);
        }

        my $res = $clus_client->get_k_center();
        is(ref $res, "ARRAY", "Make check to get coreset");
        is(ref $res->[0], "Jubatus::Common::Datum", "Make check a response is Jubatus::Common::Datum object");
        is($#{$res}, 9, "Make check a response which has 10 elements");
    };
};

subtest 'Test nearest center getter' => sub {
    subtest 'test get_nearest_center()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);

        for (my $i = 0; $i <= 100; $i++) {
            my $values = [["key1", $i], ["key2", -1.0 * $i],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_push = $clus_client->push([$datum]);
        }

        my $query_values = [["key1", 2.0], ["key2", 1.0],];
        my $query = Jubatus::Common::Datum->new($query_values);
        my $res = $clus_client->get_nearest_center($query);
        is(ref $res, "Jubatus::Common::Datum", "Make check a response is Jubatus::Common::Datum object");
    };
};


subtest 'Test nearest members getter' => sub {
    subtest 'test get_nearest_members()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);

        for (my $i = 0; $i <= 100; $i++) {
            my $values = [["key1", $i * 10], ["key2", $i * 10],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_push = $clus_client->push([$datum]);
        }

        my $query_values = [["key1", 1.0], ["key2", 1.0],];
        my $query = Jubatus::Common::Datum->new($query_values);
        my $res = $clus_client->get_nearest_members($query);
        is(ref $res, "ARRAY", "Make check to get coreset");
        is(ref $res->[0], "Jubatus::Clustering::WeightedDatum", "Make check a response is Jubatus::Clustering::WeightedDatum object");
    };
};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $timeout = 10;
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);

        for (my $i = 0; $i <= 100; $i++) {
            my $values = [["key1", $i * 10], ["key2", $i * 10],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_push = $clus_client->push([$datum]);
        }

        subtest 'Does model file dump ?' => sub {
            my $model_name = "clustering_test";
            my $is_save = $clus_client->save($model_name);
            is (1, $is_save, "Call save()");

            my $datadir;
            my $status = $clus_client->get_status();
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
        my $clus_client = Jubatus::Clustering::Client->new($host, $server->{port}, $name, $timeout);

        for (my $i = 0; $i <= 100; $i++) {
            my $values = [["key1", $i * 10], ["key2", $i * 10],];
            my $datum = Jubatus::Common::Datum->new($values);
            my $is_push = $clus_client->push([$datum]);
        }

        my $model_name = "clustering_test";
        my $is_save = $clus_client->save($model_name);
        my $datadir;
        my $status = $clus_client->get_status();
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

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $clus_client->load($model_name);
            is ($is_load, 1, "Call load()");
        };
    };
};


done_testing();
