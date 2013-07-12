use strict;

use Proc::ProcessTable;
use Test::TCP;
use FindBin;
use Test::More tests => 24;

my @server_name_suffix = (
    "regression",
    "recommender",
    "classifier",
    "stat",
    "graph",
    "anomaly",
);
my $config_path = $FindBin::Bin."/../conf";

foreach my $suffix (@server_name_suffix) {
    my $server_name = "juba".$suffix;
    my $boot_port = "";
    print $suffix."\n";
    my $json_path = $config_path."/boot_".$suffix.".json";
    my $juba = Test::TCP->new(
        code => sub {
            my $port = shift;
            my $is_boot = system ("$server_name -p $port -f $json_path \&");
            is($is_boot, 0, "boot $server_name");
        },
    );
    my $FORMAT = "%-6s %-10s %-8s %-24s %s\n";
    my $bt = new Proc::ProcessTable;
    my $bpid = "";
    foreach my $p ( @{$bt->table} ){
        if ($p->cmndline =~ m|$json_path|) {
            ok(1, "get pid of $server_name");
            $bpid = $p->pid;
            last;
        }
    }
    my $is_killed = system("kill -9 $bpid");
    is($is_killed, 0, "kill $server_name");

    my $kt = new Proc::ProcessTable;
    my $kpid = "";
    foreach my $p ( @{$kt->table} ){
        if ($p->cmndline =~ m|$server_name|) {
            $kpid = $p->pid;
        }
    }
    is($kpid, "", "killed $server_name");
}
