use strict;
use Test::More;

my @server_name_suffix = (
    "anomaly",
    "anomaly_proxy",
    "classifier",
    "classifier_proxy",
    "clustering",
    "clustering_proxy",
    "graph",
    "graph_proxy",
    "nearest_neighbor",
    "nearest_neighbor_proxy",
    "recommender",
    "recommender_proxy",
    "regression",
    "regression_proxy",
    "stat",
    "stat_proxy",
);

foreach my $suffix (@server_name_suffix) {
    subtest "Check the install path of $suffix" => sub {
        my $server_name = "juba".$suffix;
        my $is_there = system("which $server_name"); # there => 0
        is($is_there, 0, "Is $server_name there ? and did you install Jubatus version >= 0.5 ?");
    };
}

done_testing;
