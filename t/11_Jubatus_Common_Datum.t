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

# Origin of this test is http://d.hatena.ne.jp/echizen_tm/20110721/1311253494
subtest 'Test Jubatus::Common::Datum using Jubatus::Recommender::Client' => sub {
    my $name = "cpan module test";
    my $guard = $setup->($name);
    my $timeout = 10;
    my $reco_client = Jubatus::Recommender::Client->new($host, $server->{port}, $name, $timeout);

    my $is_clear = $reco_client->clear();

    {
        my $row_id = "red";
        my %hash = (
            "name" => "red",
            "image" => "warm",
            "R" => 255.0,
            "G" => 0.0,
            "B" => 0.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%hash);
        is(ref $datum, "Jubatus::Common::Datum", "Make check on to return Jubatus::Common::Datum object");
        my $is_update = $reco_client->update_row($row_id, $datum);
        is($is_update, 1, "Make check on to update using Jubatus::Common::Datum object")
    }
    {
        my $row_id = "blue";
        my %hash = (
            "name" => "blue",
            "image" => "cold",
            "R" => 0.0,
            "G" => 0.0,
            "B" => 255.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%hash);
        my $is_update = $reco_client->update_row($row_id, $datum);
    }
    {
        my $row_id = "cyan";
        my %hash = (
            "name" => "cyan",
            "image" => "cold",
            "R" => 0.0,
            "G" => 255.0,
            "B" => 0.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%hash);
        my $is_update = $reco_client->update_row($row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my %hash = (
            "name" => "magenta",
            "image" => "warm",
            "R" => 255.0,
            "G" => 0.0,
            "B" => 255.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%hash);
        my $is_update = $reco_client->update_row($row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my %hash = (
            "name" => "yellow",
            "image" => "warm",
            "R" => 255.0,
            "G" => 255.0,
            "B" => 0.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%hash);
        my $is_update = $reco_client->update_row($row_id, $datum);
    }
    {
        my $row_id = "green";
        my %hash = (
            "name" => "green",
            "image" => "cold",
            "R" => 0.0,
            "G" => 255.0,
            "B" => 0.0,
        );
        my $datum = Jubatus::Common::Datum->new(\%hash);

        my $max_result_num = 10;
        subtest 'test similar_row_from_datum()' => sub {
            my $similarity = $reco_client->similar_row_from_datum($datum, $max_result_num);
            is ("cyan", $similarity->[0]->{"id"}, "cyan is most similar than other colors");
            is ("yellow", $similarity->[1]->{"id"}, "yellow is more similar than blue");
            is ("blue", $similarity->[2]->{"id"}, "blue is more similar than red");
        };

        my $is_update = $reco_client->update_row($row_id, $datum);

        subtest 'test similar_row_from_id()' => sub {
            my $similarity = $reco_client->similar_row_from_id("green", $max_result_num);
            is ("green", $similarity->[0]->{"id"}, "green is itself");
            is ("cyan", $similarity->[1]->{"id"}, "cyan is most similar than other colors");
            is ("yellow", $similarity->[2]->{"id"}, "yellow is more similar than blue");
            is ("blue", $similarity->[3]->{"id"}, "blue is more similar than red");
        };
    }
};

done_testing();
