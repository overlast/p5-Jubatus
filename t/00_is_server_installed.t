use strict;
use Test::More tests => 6;

my @server_name_suffix = (
    "regression",
    "recommender",
    "classifier",
    "stat",
    "graph",
    "anomaly",
);

foreach my $suffix (@server_name_suffix) {
    subtest "Check the install path of $suffix" => sub {
        my $server_name = "juba".$suffix;
        my $is_there = system("which $server_name"); # there => 0
        is($is_there, 0, "Is $server_name there ?");
    };
}
