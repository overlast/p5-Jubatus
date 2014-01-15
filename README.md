# NAME

Jubatus - Perl extension for interfacing with Jubatus, a distributed processing framework and streaming machine learning library.

# SYNOPSIS

    use Jubatus;

    my $cluster_name = "jubatus_perl_doc"; # even if it isn't in a distributed environment using ZooKeeper and Jubatus keepers.
    my $host_name_or_ip_address = "localhost"; # master node's
    my $port_number_of_juba_process = 13714; # meanless
    my $timeout_seconds_of_juba_process = 10; # 10 sec is default parameter

    my $juba_client_type = "stat"; # you can select from (recommender|regression|classifier|stat|graph|anomaly|nearestneighbor|clustering)
    my $graph_client = Jubatus->get_client($juba_client_type, $host_name_or_ip_address, $port_number_of_juba_process, $cluster_name, $timeout_seconds_of_juba_process); # got Jubatus::Stat::Client object

    # In the following example, get maximum value from sample array using Jubatus::Stat::Client object
    my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
    my $key = "sum";
    foreach my $val (@sample) {
        my $is_push = $stat_client->push($key, $val);
    }
    my $result = $stat_client->sum($key);

    # $result is 15.0

# DESCRIPTION

This module provide a interface of Jubatus by TCP-based MessagePack RPC protocol using [AnyEvent::MPRPC::Client](http://search.cpan.org/perldoc?AnyEvent::MPRPC::Client)
Jubatus is a distributed processing framework and streaming machine learning library.

[Jubatus](http://search.cpan.org/perldoc?Jubatus) provide you a couple of export functions that are shortcut of
 [Jubatus::Recommender::Client](http://search.cpan.org/perldoc?Jubatus::Recommender::Client) and [Jubatus::Regression::Client](http://search.cpan.org/perldoc?Jubatus::Regression::Client),
 [Jubatus::Classifier::Client](http://search.cpan.org/perldoc?Jubatus::Classifier::Client), [Jubatus::Stat::Client](http://search.cpan.org/perldoc?Jubatus::Stat::Client),
 [Jubatus::Graph::Client](http://search.cpan.org/perldoc?Jubatus::Graph::Client), [Jubatus::Anomaly::Client](http://search.cpan.org/perldoc?Jubatus::Anomaly::Client),
 [Jubatus:;NearestNeighbor::Client](Jubatus:;NearestNeighbor::Client), [Jubatus:;Clustering::Client](Jubatus:;Clustering::Client),

One is `get_client` to get Client object by specifying client type.
Another is `get_recommender_client` and `get_regression_client`,
 `get_classifier_client`, `get_stst_client`, `get_graph_client`,
 `get_anomaly_client`, `get_nearestneighbor_client`,
`get_clustering_client`,  to get a specific Client object explicitly.

# FUNCTIONS

## get\_client $juba\_client\_type, $host, $port, $process\_name, $timeout\_sec

$juba\_client\_type is a value to specify the client type of jubatus.
You can select from (recommender | regression | classifier | stat | graph | anomaly | "nearestneighbor" | clustering).
You can also use (Recommender | Regression | Classifier | Stat | Graph | Anomaly | NearestNeighbor | Clustering).

If you select 'stat', you can get [Jubatus::Stat::Client](http://search.cpan.org/perldoc?Jubatus::Stat::Client) object.

    my $juba_client_type = 'stat';
    my $host = 'localhost';
    my $port = '13714';
    my $cluster_name = "jubatus_perl_doc";
    my $timeout_seconds_of_juba_process = 10;
    my $stat_client = Jubatus->get_client($juba_client_type, $host, $port, $cluster_name, $timeout_seconds_of_juba_process);

This code will create Jubatus::Stat::Client object and return it.
You should set $host and $port in agreement to running jubastat server application.

The above code is equivalent to:

    use Jubatus::Stat::Client;
    my $host = 'localhost';
    my $port = '13714';
    my $cluster_name = "jubatus_perl_doc";
    Jubatus::Stat::Client->new($host, $port, $cluster_name);

Because default value of $timeout\_seconds\_of\_juba\_process is 10.

If you are not distributed environment user, you can write as following.

    my $juba_client_type = 'stat';
    my $host = 'localhost';
    my $port = '13714';
    my $stat_client = Jubatus->get_client($juba_client_type, $host, $port);

Because default value of $cluster\_name is ""(null string).

## get\_recommender\_client $host, $port, ($cluster\_name, $timeout\_seconds,)

This code will create Jubatus::Recommener::Client object and return it.
You should set $host and $port in agreement to running jubarecommender server application.

    my $host = 'localhost';
    my $port = '13714';
    my $stat_client = Jubatus->get_recommender_client($host, $port);

This code isn't write cluster name and timeout seconds parameter.
But Jubatus.pm use default cluster name("") and default timeout parameter(10).

The above code is equivalent to:

    use Jubatus::Recommender::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::Recommender::Client->new($host, $port);

If you are distributed environment user and
you want to set the parameter of timeout secondes of jubatus server,
you can write same as following code.

    my $host = 'localhost';
    my $port = '13714';
    my $cluster_name = "jubatus_perl_doc";
    my $timeout_seconds = 10;
    my $stat_client = Jubatus->get_recommender_client($host, $port, $cluster_name, $timeout_seconds);

See [Jubatus::Recommender::Client](http://search.cpan.org/perldoc?Jubatus::Recommender::Client) for more detail.

## get\_regression\_client $host, $port, ($cluster\_name, $timeout\_seconds,)

See [Jubatus::Regression::Client](http://search.cpan.org/perldoc?Jubatus::Regression::Client) for more detail.

## get\_classifier\_client $host, $port, ($cluster\_name, $timeout\_seconds,)

See [Jubatus::Classifier::Client](http://search.cpan.org/perldoc?Jubatus::Classifier::Client) for more detail.

## get\_stat\_client $host, $port, ($cluster\_name, $timeout\_seconds,)

See [Jubatus::Stat::Client](http://search.cpan.org/perldoc?Jubatus::Stat::Client) for more detail.

## get\_graph\_client $host, $port, ($cluster\_name, $timeout\_seconds,)

See [Jubatus::Graph::Client](http://search.cpan.org/perldoc?Jubatus::Graph::Client) for more detail.

## get\_anomaly\_client $host, $port, ($cluster\_name, $timeout\_seconds,)

See [Jubatus::Anomaly::Client](http://search.cpan.org/perldoc?Jubatus::Anomaly::Client) for more detail.

## get\_nearestneighbor\_client $host, $port, ($cluster\_name, $timeout\_seconds,)

See [Jubatus::NearestNeighbor::Client](http://search.cpan.org/perldoc?Jubatus::NearestNeighbor::Client) for more detail.

## get\_clustering\_client $host, $port, ($cluster\_name, $timeout\_seconds,)

See [Jubatus::Clustering::Client](http://search.cpan.org/perldoc?Jubatus::Clustering::Client) for more detail.

# SEE ALSO

[http://jubat.us/](http://jubat.us/)
[https://github.com/jubatus](https://github.com/jubatus)

[AnyEvent::MPRPC](http://search.cpan.org/perldoc?AnyEvent::MPRPC)
[AnyEvent::MPRPC::Client](http://search.cpan.org/perldoc?AnyEvent::MPRPC::Client)
[http://msgpack.org/](http://msgpack.org/)
[http://wiki.msgpack.org/display/MSGPACK/RPC+specification](http://wiki.msgpack.org/display/MSGPACK/RPC+specification)

[https://github.com/overlast/p5-Jubatus](https://github.com/overlast/p5-Jubatus)

# LICENSE

Copyright (C) 2013 by Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Toshinori Sato (@overlast) <overlasting@gmail.com>
