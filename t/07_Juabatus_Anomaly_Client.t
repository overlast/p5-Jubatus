use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Anomaly::Client;
use List::Util;

use YAML;

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

=pod

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});

        my $is_clear = $anom_client->clear($name);

        my @sample_tsv_lines = split /\n/, $centality_sample_tsv;
        my %nid2sid = ();
        my %sid2nid = ();
        my %sid2eid = ();

        my $edge_query = [];
        my $node_query = [];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        my $is_add = $anom_client->add_centrality_query($name, $pq);

        foreach my $tsv_line (@sample_tsv_lines) {
            my @colmuns = split /\t/, $tsv_line;
            my $id = $colmuns[0];
            my $node_id;
            if (exists $sid2nid{$id}) {
                $node_id = $sid2nid{$id};
            }
            else {
                $node_id = $anom_client->create_node($name);
                $anom_client->update_node($name, $node_id, {});
                $nid2sid{$node_id} = $id;
                $sid2nid{$id} = $node_id;
            }

            for (my $i = 1; $i <= $#colmuns; $i++) {
                my $target_node_id;
                my $out_id = $colmuns[$i];
                if (exists $sid2nid{$out_id}) {
                    $target_node_id = $sid2nid{$out_id};
                }
                else {
                    $target_node_id = $anom_client->create_node($name);
                    $anom_client->update_node($name, $target_node_id, {});
                    $nid2sid{$target_node_id} = $out_id;
                    $sid2nid{$out_id} = $target_node_id;
                }
                my $edge = Jubatus::Anomaly::Edge->new({}, $node_id, $target_node_id);
                my $edge_id = $anom_client->create_edge($name, $node_id, $edge);
                $sid2eid{$id}{$out_id} = $edge_id;
            }
            my $is_index = $anom_client->update_index($name);
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

        my @sample_tsv_lines = split /\n/, $centality_sample_tsv;
        my %nid2sid = ();
        my %sid2nid = ();
        my %sid2eid = ();

        my $edge_query = [];
        my $node_query = [];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        my $is_add = $anom_client->add_centrality_query($name, $pq);

        foreach my $tsv_line (@sample_tsv_lines) {
            my @colmuns = split /\t/, $tsv_line;
            my $id = $colmuns[0];
            my $node_id;
            if (exists $sid2nid{$id}) {
                $node_id = $sid2nid{$id};
            }
            else {
                $node_id = $anom_client->create_node($name);
                $anom_client->update_node($name, $node_id, {});
                $nid2sid{$node_id} = $id;
                $sid2nid{$id} = $node_id;
            }

            for (my $i = 1; $i <= $#colmuns; $i++) {
                my $target_node_id;
                my $out_id = $colmuns[$i];
                if (exists $sid2nid{$out_id}) {
                    $target_node_id = $sid2nid{$out_id};
                }
                else {
                    $target_node_id = $anom_client->create_node($name);
                    $anom_client->update_node($name, $target_node_id, {});
                    $nid2sid{$target_node_id} = $out_id;
                    $sid2nid{$out_id} = $target_node_id;
                }
                my $edge = Jubatus::Anomaly::Edge->new({}, $node_id, $target_node_id);
                my $edge_id = $anom_client->create_edge($name, $node_id, $edge);
                $sid2eid{$id}{$out_id} = $edge_id;
            }
            my $is_index = $anom_client->update_index($name);
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

        subtest 'test estimate() using learned model' => sub {
            my @result = (0, 2.1, 1.2, 0.96, 0.72, 1, 0.35, 0.54);
            for (my $qid = 1; $qid <= ($#sample_tsv_lines + 1); $qid++) {
                my $centrality_type = 0; # pagerank
                my $centrality = $anom_client->get_centrality($name, $sid2nid{$qid}, $centrality_type, $pq);
                is ($centrality > $result[$qid], 1, "Make check on to get centrality value of node $qid");
            }
        };

        subtest 'test clear()' => sub {
            my $is_clear = $anom_client->clear($name);
            is($is_clear, 1, "Call clear()");
        };

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $anom_client->load($name, $model_name);
            is (1, $is_save, "Call load()");

            my @result = (0, 2.1, 1.2, 0.96, 0.72, 1, 0.35, 0.54);
            for (my $qid = 1; $qid <= ($#sample_tsv_lines + 1); $qid++) {
                my $centrality_type = 0; # pagerank
                my $centrality = $anom_client->get_centrality($name, $sid2nid{$qid}, $centrality_type, $pq);
                is ($centrality > $result[$qid], 1, "Make check on to get centrality value of node $qid");
            }
        };
    };
};

=cut

done_testing();

sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}
