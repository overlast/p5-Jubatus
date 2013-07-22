use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Graph::Client;
use List::Util;

use YAML;

my $server_name_suffix = "graph";
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

subtest "Test to connect to the Graph" => sub {
    my $guard = $setup->();
    my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is ("Jubatus::Graph::Client", ref $graph_client, "Get Jubatus::Graph::Client object");
    };
    subtest "Test Jubatus::Graph::Client->get_client()" => sub {
        my $msg_client = $graph_client->get_client();
        is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my $con = $graph_client->get_config("");
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
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my $con = $graph_client->get_config("");
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
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my $status = $graph_client->get_status("");
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

my $sample_tsv = << "__YAMANOTE__";
1130229	1130201	品川	大崎	35.62876	139.738999	35.619772	139.728439
1130228	1130229	田町	品川	35.645736	139.747575	35.62876	139.738999
1130227	1130228	浜松町	田町	35.655391	139.757135	35.645736	139.747575
1130226	1130227	新橋	浜松町	35.666195	139.758587	35.655391	139.757135
1130225	1130226	有楽町	新橋	35.675441	139.763806	35.666195	139.758587
1130224	1130225	東京	有楽町	35.681391	139.766103	35.675441	139.763806
1130223	1130224	神田	東京	35.691173	139.770641	35.681391	139.766103
1130222	1130223	秋葉原	神田	35.698619	139.773288	35.691173	139.770641
1130221	1130222	御徒町	秋葉原	35.707282	139.774727	35.698619	139.773288
1130220	1130221	上野	御徒町	35.71379	139.777043	35.707282	139.774727
1130219	1130220	鶯谷	上野	35.721484	139.778015	35.71379	139.777043
1130218	1130219	日暮里	鶯谷	35.727908	139.771287	35.721484	139.778015
1130217	1130218	西日暮里	日暮里	35.731954	139.766857	35.727908	139.771287
1130216	1130217	田端	西日暮里	35.737781	139.761229	35.731954	139.766857
1130215	1130216	駒込	田端	35.736825	139.748053	35.737781	139.761229
1130214	1130215	巣鴨	駒込	35.733445	139.739303	35.736825	139.748053
1130213	1130214	大塚	巣鴨	35.731412	139.728584	35.733445	139.739303
1130212	1130213	池袋	大塚	35.730256	139.711086	35.731412	139.728584
1130211	1130212	目白	池袋	35.720476	139.706228	35.730256	139.711086
1130210	1130211	高田馬場	目白	35.712677	139.703715	35.720476	139.706228
1130209	1130210	新大久保	高田馬場	35.700875	139.700261	35.712677	139.703715
1130208	1130209	新宿	新大久保	35.689729	139.700464	35.700875	139.700261
1130207	1130208	代々木	新宿	35.683061	139.702042	35.689729	139.700464
1130206	1130207	原宿	代々木	35.670646	139.702592	35.683061	139.702042
1130205	1130206	渋谷	原宿	35.658871	139.701238	35.670646	139.702592
1130204	1130205	恵比寿	渋谷	35.646685	139.71007	35.658871	139.701238
1130203	1130204	目黒	恵比寿	35.633923	139.715775	35.646685	139.71007
1130202	1130203	五反田	目黒	35.625974	139.723822	35.633923	139.715775
1130201	1130202	大崎	五反田	35.619772	139.728439	35.625974	139.723822
__YAMANOTE__

subtest 'Test node creater' => sub {
    subtest 'Test create_node()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        for (my $i = 0; $i < 10; $i++) {
            my $is_create_node = $graph_client->create_node($name);
            is ($i, $is_create_node, "Make check on to create node : $i");
        }
    };
};

subtest 'Test node remover' => sub {
    subtest 'Test remove_node()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        for (my $i = 0; $i < 10; $i++) {
            my $node_id = $graph_client->create_node($name);
            my $is_delete_node = $graph_client->remove_node($name, $node_id);
            is (1, $is_delete_node, "Make check on to delete node : $node_id");

            # if remove a node which is not there, Jubatus down by error.
            # my $is_there_node = $graph_client->remove_node($name, $node_id);
            # is (0, $is_there_node, "Make check on to finish to delete node : $node_id");

        }
        for (my $i = 10; $i < 20; $i++) {
            my $is_create_node = $graph_client->create_node($name);
            is ($i, $is_create_node, "Make check on to create node : $i (Can't use deleted ids)");
        }
    };
};

subtest 'Test node getter' => sub {
    subtest 'Test get_node()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        for (my $i = 0; $i < 10; $i++) {
            my $node_id = $graph_client->create_node($name);
            my $node = $graph_client->get_node($name, $node_id,);
            is(ref $node, "Jubatus::Graph::Node", "Make check on to get Jubatus::Graph::Node object");
            is_deeply($node->{in_edges}, [], "Make check on to get in_edges field");
            is_deeply($node->{out_edges}, [], "Make check on to get out_edges field");
            is_deeply($node->{property}, {}, "Make check on to get property field");
        }
    };
};

subtest 'Test node updater' => sub {
    subtest 'Test update_node()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        for (my $i = 0; $i < 10; $i++) {
            my $node_id = $graph_client->create_node($name);
            {
                my $property = {"key1" => "val1", "key2" => "val2", };
                my $is_update_node = $graph_client->update_node($name, $node_id, $property);
                is (1, $is_update_node, "Make check on to update node : $i");
            }
            {
                my $property = {"key3" => "val3", "key4" => "val4", };
                my $is_update_node = $graph_client->update_node($name, $node_id, $property);
                is (1, $is_update_node, "Make check on to update node : $i");
            }
            {
                my $node_34 = $graph_client->get_node($name, $node_id);
                my $new_node_id = $graph_client->create_node($name);
                my $property = {"key3" => "val3", "key4" => "val4", };
                my $is_update_node = $graph_client->update_node($name, $new_node_id, $property);
                my $new_node = $graph_client->get_node($name, $new_node_id);
                is_deeply ($new_node->{property}, $node_34->{property}, "Make check on to update node are same as new node using same property");
            }
        }
    };
};

subtest 'Test constructer of Jubatus::Graph::Edge' => sub {
    subtest 'Test create_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my $node_id_1 = $graph_client->create_node($name);
        my $node_id_2 = $graph_client->create_node($name);
        my $edge12 = Jubatus::Graph::Edge->new({}, $node_id_1, $node_id_2);
        is(ref $edge12, "Jubatus::Graph::Edge", "Make check on to get Jubatus::Graph::Edge object");
        is_deeply($edge12->{property}, {}, "Make check on to get property field");
        is($edge12->{source}, 0, "Make check on to get source node id field");
        is($edge12->{target}, 1, "Make check on to get target node id field");
    };
};

subtest 'Test edge creater' => sub {
    subtest 'Test create_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my $node_id_1 = $graph_client->create_node($name);
        my $node_id_2 = $graph_client->create_node($name);
        my $edge12 = Jubatus::Graph::Edge->new({}, $node_id_1, $node_id_2);
        my $edge21 = Jubatus::Graph::Edge->new({}, $node_id_2, $node_id_1);
        my $edge_id = $graph_client->create_edge($name, $node_id_1, $edge12);
        is (2, $edge_id, "Make check on to create edge");
    };
};

subtest 'Test edge remover' => sub {
    subtest 'Test remove_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        {
            my $node_id_1 = $graph_client->create_node($name);
            my $node_id_2 = $graph_client->create_node($name);
            my $edge12 = Jubatus::Graph::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Graph::Edge->new({}, $node_id_2, $node_id_1);
            my $edge_id = $graph_client->create_edge($name, $node_id_1, $edge12);
            my $is_remove_edge = $graph_client->remove_edge($name, $node_id_1, $edge_id);
            is (1, $is_remove_edge, "Make check on to delete edge : $edge_id");
        }
#        {
            # if remove a node which is not there, Jubatus down by error.
            # my $is_there_node = $graph_client->remove_node($name, $node_id);
            # is (0, $is_there_node, "Make check on to finish to delete node : $node_id");
 #       }
        {
            my $node_id_1 = $graph_client->create_node($name);
            my $node_id_2 = $graph_client->create_node($name);
            my $edge12 = Jubatus::Graph::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Graph::Edge->new({}, $node_id_2, $node_id_1);
            my $edge_id = $graph_client->create_edge($name, $node_id_1, $edge12);
            is (5, $edge_id, "Make check on to create edge which has unrecycled id");
        }
    };
};

subtest 'Test edge getter' => sub {
    subtest 'Test get_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        {
            my $node_id_1 = $graph_client->create_node($name);
            my $node_id_2 = $graph_client->create_node($name);
            my $edge12 = Jubatus::Graph::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Graph::Edge->new({}, $node_id_2, $node_id_1);
            my $edge_id = $graph_client->create_edge($name, $node_id_1, $edge12);
            my $edge = $graph_client->get_edge($name, $node_id_1, $edge_id);

            is(ref $edge, "Jubatus::Graph::Edge", "Make check on to get Jubatus::Graph::Edge object");
            is_deeply($edge->{property}, $edge12->{property}, "Make check on to get property field which is same as input edge's field");
            is($edge->{source}, $edge12->{source}, "Make check on to get source node id field which is same as input edge's field");
            is($edge->{target}, $edge12->{target}, "Make check on to get target node id field which is same as inout edge's field");
        }
    };
};

subtest 'Test edge updater' => sub {
    subtest 'Test update_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        {
            my $node_id_1 = $graph_client->create_node($name);
            my $node_id_2 = $graph_client->create_node($name);
            my $node_id_3 = $graph_client->create_node($name);

            my $edge12 = Jubatus::Graph::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Graph::Edge->new({}, $node_id_2, $node_id_1);
            my $edge13 = Jubatus::Graph::Edge->new({}, $node_id_1, $node_id_3);

            my $edge_id_1 = $graph_client->create_edge($name, $node_id_1, $edge12);
            my $edge_id_2 = $graph_client->create_edge($name, $node_id_2, $edge21);
            my $is_update = $graph_client->update_edge($name, $node_id_1, $edge_id_1, $edge13);
            is($is_update, 1, "Make check on to call update_edge()");

            my $edge = $graph_client->get_edge($name, $node_id_1, $edge_id_1);

            #
            # Jubatus don't allow update edge . ummm.
            #
        }
    };
};




=pod

  def test_node_info
    edge_query = [["a", "b"], ["c", "d"], ["e", "f"]]
    node_query = [["0", "1"], ["2", "3"]]
    p = Jubatus::Graph::Preset_query.new(edge_query, node_query)
    in_edges = [0, 0]
    out_edges = [0, 0]
    Jubatus::Graph::Node.new(p, in_edges, out_edges)
  end

  def test_create_edge
    name = "name"
    @cli.clear(name)
    src = @cli.create_node(name)
    tgt = @cli.create_node(name)
    prop = {"key1" => "val1", "key2" => "val2"}
    ei = Jubatus::Graph::Edge.new(prop, src, tgt)
    eid = @cli.create_edge("name", tgt, ei)
  end

  def test_create_edge
    name = "name"
    @cli.clear(name)
    src = @cli.create_node(name)
    tgt = @cli.create_node(name)
    prop = {"key1" => "val1", "key2" => "val2"}
    ei = Jubatus::Graph::Edge.new(prop, src, tgt)
    eid = @cli.create_edge(src, tgt, ei)
  end


subtest 'Test model data updator' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
    subtest 'call clear()' => sub {
        my $is_clear = $graph_client->clear($name);
        is (1, $is_clear, "Call clear()");
    };
};

subtest 'Test standard deviation culculator' => sub {
    subtest 'Test stddev()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "stddev";
        foreach my $val (@sample) {
            my $is_push = $graph_client->push($name, $key, $val);
        }
        my $result = $graph_client->stddev($name, $key);
        is(sqrt(2), $result, "Get standard deviation");
    };
};

subtest 'Test summuation culculator' => sub {
    subtest 'Test sum()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "sum";
        foreach my $val (@sample) {
            my $is_push = $graph_client->push($name, $key, $val);
        }
        my $result = $graph_client->sum($name, $key);
        is(15.0, $result, "Get summuation");
    };
};

subtest 'Test max value searcher' => sub {
    subtest 'Test max()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "max";
        foreach my $val (@sample) {
            my $is_push = $graph_client->push($name, $key, $val);
        }
        my $result = $graph_client->max($name, $key);
        is(5.0, $result, "Get max value");
    };
};

subtest 'Test min value searcher' => sub {
    subtest 'Test min()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "min";
        foreach my $val (@sample) {
            my $is_push = $graph_client->push($name, $key, $val);
        }
        my $result = $graph_client->min($name, $key);
        is(1.0, $result, "Get min value");
    };
};

subtest 'Test entoropy calculator' => sub {
    subtest 'Test entropy()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "entropy";
        foreach my $val (@sample) {
            my $is_push = $graph_client->push($name, $key, $val);
        }
        my $result = $graph_client->min($name, $key);
        is($result, 1.0, "Get entropy value");
    };
};

subtest 'Test moment calculator' => sub {
    subtest 'Test moment()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->();
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "moment";
        my $degree = 3;
        my $center = 0.0;
        foreach my $val (@sample) {
            my $is_push = $graph_client->push($name, $key, $val);
        }
        my $result = $graph_client->moment($name, $key, $degree, $center);
        is($result, 45.0, "Get moment value");
    };
};

subtest 'Test data dumper and data loader of model' => sub {
    subtest 'test save()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});

        my $is_clear = $graph_client->clear($name);
        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "moment";
        foreach my $val (@sample) {
            my $is_push = $graph_client->push($name, $key, $val);
        }

        subtest 'Does model file dump ?' => sub {
            my $model_name = "stat_test";

            my $is_save = $graph_client->save($name, $model_name);
            is (1, $is_save, "Call save()");

            my $datadir;
            my $status = $graph_client->get_status($name);
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
        my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});

        my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
        my $key = "moment";

        foreach my $val (@sample) {
            my $is_push = $graph_client->push($name, $key, $val);
        }

        my $model_name = "stat_test";
        my $is_save = $graph_client->save($name, $model_name);
        my $datadir;
        my $status = $graph_client->get_status($name);
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
            my $degree = 3;
            my $center = 0.0;
            my $result = $graph_client->moment($name, $key, $degree, $center);
            is($result, 45.0, "Get result of moment");
        };

        subtest 'test clear()' => sub {
            my $is_clear = $graph_client->clear($name);
            is($is_clear, 1, "Call clear()");
        };

# Jubatus::Stas::Client is not return result of moment() using empty model
#        subtest 'test estimate() for empty model' => sub {
#            my $degree = 3;
#            my $center = 0.0;
#            my $result = $graph_client->moment($name, $key, $degree, $center);
#            print Dump $result;
#            is($result," min", "Get result of moment from empty model");
#        };

        subtest 'Does the saved rows load ?' => sub {
            my $is_load = $graph_client->load($name, $model_name);
            is (1, $is_save, "Call load()");

            my $degree = 3;
            my $center = 0.0;
            my $result = $graph_client->moment($name, $key, $degree, $center);
            is($result, 45.0, "Get result of moment from empty model from dumped model");
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
