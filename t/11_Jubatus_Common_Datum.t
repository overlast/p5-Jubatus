use strict;

use Test::TCP;
use FindBin;
use Test::More;# tests => 1;
use Proc::ProcessTable;
use Scope::Guard;

use Jubatus::Recommender::Client;
use Jubatus::Common::Datum;

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

# Origin of this test is http://d.hatena.ne.jp/echizen_tm/20110721/1311253494
subtest 'Test Jubatus::Common::Datum using Jubatus::Recommender::Client' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port});

    my $is_clear = $reco_client->clear($name);

    {
        my $row_id = "red";
        my %string_hash = (
            "name" => "red",
            "image" => "warm",
        );
        my %num_hash = (
            "R" => 255.0,
            "G" => 0.0,
            "B" => 0.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%string_hash, \%num_hash);
        is(ref $datum, "Jubatus::Common::Datum", "Make check on to return Jubatus::Common::Datum object");
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
        is($is_update, 1, "Make check on to update using Jubatus::Common::Datum object")
    }
    {
        my $row_id = "blue";
        my %string_hash = (
            "name" => "blue",
            "image" => "cold",
        );
        my %num_hash = (
            "R" => 0.0,
            "G" => 0.0,
            "B" => 255.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%string_hash, \%num_hash);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "cyan";
                my %string_hash = (
            "name" => "cyan",
            "image" => "cold",
        );
        my %num_hash = (
            "R" => 0.0,
            "G" => 255.0,
            "B" => 0.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%string_hash, \%num_hash);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my %string_hash = (
            "name" => "magenta",
            "image" => "warm",
        );
        my %num_hash = (
            "R" => 255.0,
            "G" => 0.0,
            "B" => 255.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%string_hash, \%num_hash);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my %string_hash = (
            "name" => "yellow",
            "image" => "warm",
        );
        my %num_hash = (
            "R" => 255.0,
            "G" => 255.0,
            "B" => 0.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%string_hash, \%num_hash);
        my $is_update = $reco_client->update_row($name, $row_id, $datum);
    }
    {
        my $row_id = "green";
        my %string_hash = (
            "name" => "green",
            "image" => "cold",
        );
        my %num_hash = (
            "R" => 0.0,
            "G" => 255.0,
            "B" => 0.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%string_hash, \%num_hash);

        my $max_result_num = 10;
        subtest 'test similar_row_from_datum()' => sub {
            my $similarity = $reco_client->similar_row_from_datum($name, $datum, $max_result_num);
            is ("cyan", $similarity->[0]->[0], "cyan is most similar than other colors");
            is ("yellow", $similarity->[1]->[0], "yellow is more similar than blue");
            is ("blue", $similarity->[2]->[0], "blue is more similar than red");
        };

        my $is_update = $reco_client->update_row($name, $row_id, $datum);

        subtest 'test similar_row_from_id()' => sub {
            my $similarity = $reco_client->similar_row_from_id($name, "green", $max_result_num);
            is ("green", $similarity->[0]->[0], "green is itself");
            is ("cyan", $similarity->[1]->[0], "cyan is most similar than other colors");
            is ("yellow", $similarity->[2]->[0], "yellow is more similar than blue");
            is ("blue", $similarity->[3]->[0], "blue is more similar than red");
        };
    }
};

done_testing();

sub kill_process {
    my ($pid) = @_;
    my $is_killed = system("kill -9 $pid"); # if success = 0 ,if fail > 0
    return  ($is_killed - 1) * -1; # i
}
