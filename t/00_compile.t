use strict;
use Test::More;

use_ok $_ for qw(
    Jubatus
    Jubatus::Anomaly::Client
    Jubatus::Classifier::Client
    Jubatus::Clustering::Client
    Jubatus::Common::Client
    Jubatus::Graph::Client
    Jubatus::NearestNeighbor::Client
    Jubatus::Regression::Client
    Jubatus::Recommender::Client
    Jubatus::Stat::Client
);

done_testing;
