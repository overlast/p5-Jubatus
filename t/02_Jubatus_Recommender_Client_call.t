use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Recommender::Client;

use YAML;

my $server_name_suffix = "recommender";
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

subtest "Test to connect to the Recommender" => sub {
    my $guard = $setup->();
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
    subtest "Give hostname & ort number" => sub {
        is ("Jubatus::Recommender::Client", ref $reco_client, "Get Jubatus::Recommender::Client object");
    };
    subtest "Test Jubatus::Recommender::Client->get_client()" => sub {
        my $msg_client = $reco_client->get_client();
        is ("AnyEvent::MPRPC::Client", ref $msg_client, "Get AnyEvent::MPRPC::Client object");
    };
};

subtest 'Test JSON config file reader' => sub {
    subtest 'Test get_config() using null character string name (for standalone user)' => sub {
        my $guard = $setup->();
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
        my $con = $reco_client->get_config("");
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
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
        my $con = $reco_client->get_config("");
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
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
        my $status = $reco_client->get_status("");
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
    my $guard = $setup->($name);
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
    my $row_name = "jubatus recommender test";
    subtest 'call clear()' => sub {
        my $is_clear = $reco_client->clear($name);
        is (1, $is_clear, "Call clear()");
    };

    my $string_values = [["key1", "val1"], ["key2", "val2"],];
    my $num_values = [["key1", 1.0], ["key2", 2.0],];

    my $datum;
    subtest 'test Jubatus::Recommender::Datum->new()' => sub {
        $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        is("Jubatus::Recommender::Datum", ref $datum, "Get Jubatus::Recommender::Datum object");
        is(1, exists $datum->{string_values}, "Datum object has string_values field");
        is(1, exists $datum->{num_values}, "Datum object has num_values field");
        is("val1", $datum->{string_values}->[0]->[1], "Check value of string_values field of Datum object");
        is("1", $datum->{num_values}->[0]->[1], "Check value of num_values field of Datum object");
    };

    subtest 'test update_row()' => sub {
        my $is_update = $reco_client->update_row($name, $row_name, $datum);
        is (1, $is_update, "Call update_row()");
    };

    subtest 'test get_all_rows()' => sub {
        my $result_rows = $reco_client->get_all_rows($name);
        my $answer_rows = [$row_name];
        is_deeply($answer_rows, $result_rows, "Check the row name is same as '$row_name' which input by update_row()");
    };
};

subtest 'Test all model data cleaner' => sub {
    subtest 'test clear()' => sub {
        my $name = "cpan module test";
        my $guard = $setup->($name);
        my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});
        my $row_name = "jubatus recommender test";
        my $is_clear = $reco_client->clear($name);
        is (1, $is_clear, "Call clear()");
        my $result_rows = $reco_client->get_all_rows($name);
        my $answer_rows = [];
        is_deeply($answer_rows, $result_rows, "Check the all row are cleared");
    };
};





=pod

  def test_clear(self):
    self.cli.clear("name")



=cut


done_testing();


sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}

#ok(1);

=pod

  def tearDown(self):
    TestUtil.kill_process(self.srv)

  def test_complete_row(self):
    self.cli.clear_row("name", "complete_row")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "complete_row", d)
    d1 = self.cli.complete_row_from_id("name", "complete_row")
    d2 = self.cli.complete_row_from_datum("name", d)

  def test_similar_row(self):
    self.cli.clear_row("name", "similar_row")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "similar_row", d)
    s1 = self.cli.similar_row_from_id("name", "similar_row", 10)
    s2 = self.cli.similar_row_from_datum("name", d, 10)

  def test_decode_row(self):
    self.cli.clear_row("name", "decode_row")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "decode_row", d)
    decoded_row = self.cli.decode_row("name", "decode_row")
    self.assertEqual(d.string_values, decoded_row.string_values)
    self.assertEqual(d.num_values, decoded_row.num_values)

  def test_calcs(self):
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.assertAlmostEqual(self.cli.calc_similarity("name", d, d), 1, 6)
    self.assertAlmostEqual(self.cli.calc_l2norm("name", d), sqrt(1*1 + 1*1+ 1*1 + 2*2), 6)

  def test_clear(self):
    self.cli.clear("name")

  def test_save(self):
    self.assertEqual(self.cli.save("name", "recommender.save_test.model"), True)

  def test_load(self):
    model_name = "recommender.load_test.model"
    self.cli.save("name", model_name)
    self.assertEqual(self.cli.load("name", model_name), True)




if __name__ == '__main__':
  test_suite = unittest.TestLoader().loadTestsFromTestCase(RecommenderTest)
  unittest.TextTestRunner().run(test_suite)
=cut
