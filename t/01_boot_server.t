use strict;

use Proc::ProcessTable;
use Test::TCP;
use FindBin;
use Test::More;

my @server_name_suffix = (
    "anomaly",
    "classifier",
    "clustering",
    "graph",
    "nearest_neighbor",
    "recommender",
    "regression",
    "stat",
);
my $config_path = $FindBin::Bin."/../conf";

foreach my $suffix (@server_name_suffix) {
    subtest "Check server process control of $suffix" => sub {
        my $boot_port = "";
        my $json_path = $config_path."/boot_".$suffix.".json";
        my $server_name = "juba".$suffix;
        my $port;
        my $juba = Test::TCP->new(
            code => sub {
                $port = shift;
                my $is_boot = exec ("$server_name -p $port -f $json_path 1>/dev/null 2>/dev/null \&");
                is($is_boot, 0, "Boot $server_name");
            },
        );
        my $FORMAT = "%-6s %-10s %-8s %-24s %s\n";
        my $bt = new Proc::ProcessTable;
        my $bpid = "";
        foreach my $p ( @{$bt->table} ){
            if (($p->cmndline =~ m|$port|) && ($p->cmndline =~ m|$json_path|)) {
                ok(1, "Get PID of $server_name");
                $bpid = $p->pid;
                last;
            }
        }
        my $is_killed = system("kill -9 $bpid");
        is($is_killed, 0, "Kill process of $server_name");

        my $kt = new Proc::ProcessTable;
        my $kpid = "";
        foreach my $p ( @{$kt->table} ){
            if (($p->cmndline =~ m|$port|) && ($p->cmndline =~ m|$server_name|)) {
                $kpid = $p->pid;
            }
        }
        is((($kpid eq "") || $kpid ne $port), 1, "Check $server_name was killed");
    };
};

done_testing;
