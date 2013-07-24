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

=pod

subtest 'Test node creater' => sub {
    subtest 'Test create_node()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        for (my $i = 0; $i < 10; $i++) {
            my $is_create_node = $anom_client->create_node($name);
            is ($i, $is_create_node, "Make check on to create node : $i");
        }
    };
};

subtest 'Test node remover' => sub {
    subtest 'Test remove_node()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        for (my $i = 0; $i < 10; $i++) {
            my $node_id = $anom_client->create_node($name);
            my $is_delete_node = $anom_client->remove_node($name, $node_id);
            is (1, $is_delete_node, "Make check on to delete node : $node_id");

            # if remove a node which is not there, Jubatus down by error.
            # my $is_there_node = $anom_client->remove_node($name, $node_id);
            # is (0, $is_there_node, "Make check on to finish to delete node : $node_id");

        }
        for (my $i = 10; $i < 20; $i++) {
            my $is_create_node = $anom_client->create_node($name);
            is ($i, $is_create_node, "Make check on to create node : $i (Can't use deleted ids)");
        }
    };
};

subtest 'Test node getter' => sub {
    subtest 'Test get_node()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        for (my $i = 0; $i < 10; $i++) {
            my $node_id = $anom_client->create_node($name);
            my $node = $anom_client->get_node($name, $node_id,);
            is(ref $node, "Jubatus::Anomaly::Node", "Make check on to get Jubatus::Anomaly::Node object");
            is_deeply($node->{in_edges}, [], "Make check on to get in_edges field");
            is_deeply($node->{out_edges}, [], "Make check on to get out_edges field");
            is_deeply($node->{property}, {}, "Make check on to get property field");
        }
    };
};

subtest 'Test node updater' => sub {
    subtest 'Test update_node()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        for (my $i = 0; $i < 10; $i++) {
            my $node_id = $anom_client->create_node($name);
            {
                my $property = {"key1" => "val1", "key2" => "val2", };
                my $is_update_node = $anom_client->update_node($name, $node_id, $property);
                is (1, $is_update_node, "Make check on to update node : $i");
            }
            {
                my $property = {"key3" => "val3", "key4" => "val4", };
                my $is_update_node = $anom_client->update_node($name, $node_id, $property);
                is (1, $is_update_node, "Make check on to update node : $i");
            }
            {
                my $node_34 = $anom_client->get_node($name, $node_id);
                my $new_node_id = $anom_client->create_node($name);
                my $property = {"key3" => "val3", "key4" => "val4", };
                my $is_update_node = $anom_client->update_node($name, $new_node_id, $property);
                my $new_node = $anom_client->get_node($name, $new_node_id);
                is_deeply ($new_node->{property}, $node_34->{property}, "Make check on to update node are same as new node using same property");
            }
        }
    };
};

subtest 'Test constructer of Jubatus::Anomaly::Edge' => sub {
    subtest 'Test Jubatus::Anomaly::Edge->new()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $node_id_1 = $anom_client->create_node($name);
        my $node_id_2 = $anom_client->create_node($name);
        my $edge12 = Jubatus::Anomaly::Edge->new({}, $node_id_1, $node_id_2);
        is(ref $edge12, "Jubatus::Anomaly::Edge", "Make check on to get Jubatus::Anomaly::Edge object");
        is_deeply($edge12->{property}, {}, "Make check on to get property field");
        is($edge12->{source}, 0, "Make check on to get source node id field");
        is($edge12->{target}, 1, "Make check on to get target node id field");
    };
};

subtest 'Test edge creater' => sub {
    subtest 'Test create_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $node_id_1 = $anom_client->create_node($name);
        my $node_id_2 = $anom_client->create_node($name);
        my $edge12 = Jubatus::Anomaly::Edge->new({}, $node_id_1, $node_id_2);
        my $edge21 = Jubatus::Anomaly::Edge->new({}, $node_id_2, $node_id_1);
        my $edge_id = $anom_client->create_edge($name, $node_id_1, $edge12);
        is (2, $edge_id, "Make check on to create edge");
    };
};

subtest 'Test edge remover' => sub {
    subtest 'Test remove_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        {
            my $node_id_1 = $anom_client->create_node($name);
            my $node_id_2 = $anom_client->create_node($name);
            my $edge12 = Jubatus::Anomaly::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Anomaly::Edge->new({}, $node_id_2, $node_id_1);
            my $edge_id = $anom_client->create_edge($name, $node_id_1, $edge12);
            my $is_remove_edge = $anom_client->remove_edge($name, $node_id_1, $edge_id);
            is (1, $is_remove_edge, "Make check on to delete edge : $edge_id");
        }
#        {
            # if remove a node which is not there, Jubatus down by error.
            # my $is_there_node = $anom_client->remove_node($name, $node_id);
            # is (0, $is_there_node, "Make check on to finish to delete node : $node_id");
 #       }
        {
            my $node_id_1 = $anom_client->create_node($name);
            my $node_id_2 = $anom_client->create_node($name);
            my $edge12 = Jubatus::Anomaly::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Anomaly::Edge->new({}, $node_id_2, $node_id_1);
            my $edge_id = $anom_client->create_edge($name, $node_id_1, $edge12);
            is (5, $edge_id, "Make check on to create edge which has unrecycled id");
        }
    };
};

subtest 'Test edge getter' => sub {
    subtest 'Test get_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        {
            my $node_id_1 = $anom_client->create_node($name);
            my $node_id_2 = $anom_client->create_node($name);
            my $edge12 = Jubatus::Anomaly::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Anomaly::Edge->new({}, $node_id_2, $node_id_1);
            my $edge_id = $anom_client->create_edge($name, $node_id_1, $edge12);
            my $edge = $anom_client->get_edge($name, $node_id_1, $edge_id);

            is(ref $edge, "Jubatus::Anomaly::Edge", "Make check on to get Jubatus::Anomaly::Edge object");
            is_deeply($edge->{property}, $edge12->{property}, "Make check on to get property field which is same as input edge's field");
            is($edge->{source}, $edge12->{source}, "Make check on to get source node id field which is same as input edge's field");
            is($edge->{target}, $edge12->{target}, "Make check on to get target node id field which is same as inout edge's field");
        }
    };
};

subtest 'Test edge updater' => sub {
    subtest 'Test update_edge()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        {
            my $node_id_1 = $anom_client->create_node($name);
            my $node_id_2 = $anom_client->create_node($name);
            my $node_id_3 = $anom_client->create_node($name);

            my $edge12 = Jubatus::Anomaly::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Anomaly::Edge->new({}, $node_id_2, $node_id_1);
            my $edge13 = Jubatus::Anomaly::Edge->new({}, $node_id_1, $node_id_3);

            my $edge_id_1 = $anom_client->create_edge($name, $node_id_1, $edge12);
            my $edge_id_2 = $anom_client->create_edge($name, $node_id_2, $edge21);
            my $is_update = $anom_client->update_edge($name, $node_id_1, $edge_id_1, $edge13);
            is($is_update, 1, "Make check on to call update_edge()");

            my $edge = $anom_client->get_edge($name, $node_id_1, $edge_id_1);

            #
            # Jubatus don't allow update edge . ummm.
            #
        }
    };
};

subtest 'Test constructer of Jubatus::Anomaly::PresetQuery' => sub {
    subtest 'Test Jubatus::Anomaly::PresetQuery->new()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $edge_query = [];
        my $node_query = [];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        is(ref $pq, "Jubatus::Anomaly::PresetQuery", "Make check on to get Jubatus::Anomaly::PresetQuery object");
        is_deeply($pq->{edge_query}, [], "Make check on to get edge_query field");
        is_deeply($pq->{node_query}, [], "Make check on to get node_query field");
    };
};

subtest 'Test shotest path query inserter' => sub {
    subtest 'Test add_shortest_path_query()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $edge_query = [];
        my $node_query = [];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        my $is_add = $anom_client->add_shortest_path_query($name, $pq);
        is($is_add, 1, "Make check on to call add_shortest_path_query()");
    };
};

subtest 'Test shotest path query initializer' => sub {
    subtest 'Test remove_shortest_path_query()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $edge_query = [];
        my $node_query = [];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        my $is_add = $anom_client->add_shortest_path_query($name, $pq);
        my $is_remove = $anom_client->add_shortest_path_query($name, $pq);
        is($is_add, 1, "Make check on to call remove_shortest_path_query()");
    };
};

subtest 'Test constructer of Jubatus::Anomaly::ShortestPathQuery' => sub {
    subtest 'Test Jubatus::Anomaly::ShortestPathQuery->new()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $source = 0;
        my $target = 1;
        my $max_hop = 2;
        my $edge_query = [];
        my $node_query = [];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        my $sq = Jubatus::Anomaly::ShortestPathQuery->new($target, $source, $max_hop, $pq);
        is(ref $sq, "Jubatus::Anomaly::ShortestPathQuery", "Make check on to get Jubatus::Anomaly::ShortestPathQuery object");
        is($sq->{target}, 0, "Make check on to get target field");
        is($sq->{source}, 1, "Make check on to get source field");
        is($sq->{max_hop}, 2, "Make check on to get max_hop field");
        is(ref $sq->{query}, "Jubatus::Anomaly::PresetQuery", "Make check on to get query field which include Jubatus::Anomaly::PresetQuery object");
        is_deeply($sq->{query}->{edge_query}, [], "Make check on to get edge_query field");
        is_deeply($sq->{query}->{node_query}, [], "Make check on to get node_query field");
    };
};

my $shortestpath_sample_tsv = << "__YAMANOTE__";
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

subtest 'Test shotest path getter' => sub {
    subtest 'Test get_shortest_path()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});

        my @sample_tsv_lines = split /\n/, $shortestpath_sample_tsv;
        my %nid2sid = ();
        my %sid2nid = ();
        my %sname2sid = ();
        my %sname2nid = ();
        my %sid2sname = ();
        my %sname2eid = ();

        my $edge_query = [];
        my $node_query = [["name", "yamanote"]];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        my $is_add = $anom_client->add_shortest_path_query($name, $pq);

        foreach my $tsv_line (@sample_tsv_lines) {
            my @colmuns = split /\t/, $tsv_line;
            my $node_id_1;
            if (exists $sid2nid{$colmuns[0]}) {
                $node_id_1 = $sid2nid{$colmuns[0]};
            }
            else {
                $node_id_1 = $anom_client->create_node($name);
                $anom_client->update_node($name, $node_id_1, {"name" => "yamanote"});
                $nid2sid{$node_id_1} = $colmuns[0];
                $sid2nid{$colmuns[0]} = $node_id_1;
            }

            my $node_id_2;
            if (exists $sid2nid{$colmuns[1]}) {
                $node_id_2 = $sid2nid{$colmuns[1]};
            }
            else {
                $node_id_2 = $anom_client->create_node($name);
                $anom_client->update_node($name, $node_id_2, {"name" => "yamanote"});
                $nid2sid{$node_id_2} = $colmuns[1];
                $sid2nid{$colmuns[1]} = $node_id_2;
            }

            $sid2sname{$colmuns[0]} = $colmuns[2];
            $sname2sid{$colmuns[2]} = $colmuns[0];
            $sname2nid{$colmuns[2]} = $node_id_1;
            $sid2sname{$colmuns[1]} = $colmuns[3];
            $sname2sid{$colmuns[3]} = $colmuns[1];
            $sname2nid{$colmuns[3]} = $node_id_2;

            my $edge12 = Jubatus::Anomaly::Edge->new({}, $node_id_1, $node_id_2);
            my $edge21 = Jubatus::Anomaly::Edge->new({}, $node_id_2, $node_id_1);

            my $edge_id_1 = $anom_client->create_edge($name, $node_id_1, $edge12);
            my $edge_id_2 = $anom_client->create_edge($name, $node_id_2, $edge21);
            $sname2eid{$colmuns[2]}{1} = $edge_id_1;
            $sname2eid{$colmuns[3]}{2} = $edge_id_2;

            my $is_index = $anom_client->update_index($name);
        }

        my $source = $sname2nid{'渋谷'};
        my $target = $sname2nid{'新宿'};
        my $max_hop = 100;
        my $is_index = $anom_client->update_index($name);

        my $sq = Jubatus::Anomaly::ShortestPathQuery->new($target, $source, $max_hop, $pq);
        is(ref $sq, "Jubatus::Anomaly::ShortestPathQuery", "Make check on to get Jubatus::Anomaly::ShortestPathQuery object");
        is($sq->{source}, 64, "Make check on to get source field");
        is($sq->{target}, 73, "Make check on to get target field");
        is($sq->{max_hop}, 100, "Make check on to get max_hop field");

        my $shortest_path = $anom_client->get_shortest_path($name, $sq);

        is($sid2sname{$nid2sid{$shortest_path->[0]}}, "新宿", "Make check on to get node ID");
        is($sid2sname{$nid2sid{$shortest_path->[1]}}, "代々木", "Make check on to get node ID");
        is($sid2sname{$nid2sid{$shortest_path->[2]}}, "原宿", "Make check on to get node ID");
        is($sid2sname{$nid2sid{$shortest_path->[3]}}, "渋谷", "Make check on to get node ID");
    };
};

subtest 'Test centrality query inserter' => sub {
    subtest 'Test add_centrality_query()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $edge_query = [];
        my $node_query = [];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        my $is_add = $anom_client->add_centrality_query($name, $pq);
        is($is_add, 1, "Make check on to call add_centrality_query()");
    };
};

subtest 'Test centrality query initializer' => sub {
    subtest 'Test remove_centrality_query()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $anom_client = Jubatus::Anomaly::Client->new($host, $server->{port});
        my $edge_query = [];
        my $node_query = [];
        my $pq = Jubatus::Anomaly::PresetQuery->new($edge_query, $node_query);
        my $is_add = $anom_client->add_centrality_query($name, $pq);
        my $is_remove = $anom_client->add_centrality_query($name, $pq);
        is($is_add, 1, "Make check on to call remove_centrality_query()");
    };
};

my $centality_sample_tsv = << "__PAGERANK__";
1	2	3	4	5	7
2	1
3	1	2
4	2	3	5
5	1	3	4	6
6	1	5
7	5
__PAGERANK__

subtest 'Test centrality getter' => sub {
    subtest 'Test get_centrality()' => sub {
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
        my @result = (0, 2.1, 1.2, 0.96, 0.72, 1, 0.35, 0.54);
        for (my $qid = 1; $qid <= ($#sample_tsv_lines + 1); $qid++) {
            my $centrality_type = 0; # pagerank
            my $centrality = $anom_client->get_centrality($name, $sid2nid{$qid}, $centrality_type, $pq);
            is ($centrality > $result[$qid], 1, "Make check on to get centrality value of node $qid");
        }
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
