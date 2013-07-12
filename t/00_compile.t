use strict;
use Test::More;

use_ok $_ for qw(
    Jubatus
    Jubatus::Regression::Client
    Jubatus::Recommender::Client
    Jubatus::Classifier::Client
    Jubatus::Stat::Client
    Jubatus::Graph::Client
    Jubatus::Anomaly::Client
);

done_testing;
