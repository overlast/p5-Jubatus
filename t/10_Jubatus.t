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

done_testing();

sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}
