# NAME

Jubatus - Perl extension for interfacing with Jubatus, a distributed processing framework and streaming machine learning library.

# SYNOPSIS

    use Jubatus;

    my $cluster_name = "jubatus_perl_doc"; # even if it isn't in a distributed environment using ZooKeeper and Jubatus keepers.
    my $host_name_or_ip_address = "localhost"; # master node's
    my $port_number_of_juba_process = 13714; # meanless

    my $juba_client_type = "stat"; # you can select from (recommender|regression|classifier|stat|graph|anomaly)
    my $graph_client = Jubatus->get_client($host_name_or_ip_address, $port_number_of_juba_process, $juba_client_type); # got Jubatus::Stat::Client object

    # In the following example, get maximum value from sample array using Jubatus::Stat::Client object
    my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
    my $key = "sum";
    foreach my $val (@sample) {
        my $is_push = $stat_client->push($cluster_name, $key, $val);
    }
    my $result = $stat_client->sum($cluster_name, $key);

    # $result is 15.0

# DESCRIPTION

This module provide a interface of Jubatus by TCP-based MessagePack RPC protocol using [AnyEvent::MPRPC::Client](http://search.cpan.org/perldoc?AnyEvent::MPRPC::Client)
Jubatus is a distributed processing framework and streaming machine learning library.

[Jubatus](http://search.cpan.org/perldoc?Jubatus) provide you a couple of export functions that are shortcut of
 [Jubatus::Recommender::Client](http://search.cpan.org/perldoc?Jubatus::Recommender::Client) and [Jubatus::Regression::Client](http://search.cpan.org/perldoc?Jubatus::Regression::Client),
 [Jubatus::Classifier::Client](http://search.cpan.org/perldoc?Jubatus::Classifier::Client), [Jubatus::Stat::Client](http://search.cpan.org/perldoc?Jubatus::Stat::Client),
 [Jubatus::Graph::Client](http://search.cpan.org/perldoc?Jubatus::Graph::Client), [Jubatus::Anomaly::Client](http://search.cpan.org/perldoc?Jubatus::Anomaly::Client),
 [Jubatus:;NearestNeighbor::Client](Jubatus:;NearestNeighbor::Client),

One is `get_client` to get Client object by specifying client type.
Another is `get_recommender_client` and `get_regression_client`,
 `get_classifier_client`, `get_stst_client`, `get_graph_client`,
 `get_anomaly_client`, `get_nearestneighbor_client` to get a specific Client
  object explicitly.

# FUNCTIONS

## get\_client $host, $port, $juba\_client\_type

$juba\_client\_type is a value to specify the client type of jubatus.
You can select from (recommender|regression|classifier|stat|graph|anomaly).
You can also use (Recommender|Regression|Classifier|Stat|Graph|Anomaly).

If you select 'stat', you can get [Jubatus::Stat::Client](http://search.cpan.org/perldoc?Jubatus::Stat::Client) object.

    my $host = 'localhost';
    my $port = '13714';
    my $juba_client_type = 'stat';
    my $stat_client = Jubatus->get_client($host, $port, $juba_client_type);

This code will create Jubatus::Stat::Client object and return it.
You should set $host and $port in agreement to running jubastat server application.

The above code is equivalent to:

    use Jubatus::Stat::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::Stat::Client->new($host, $port);

## get\_recommender\_client $host, $port

This code will create Jubatus::Recommener::Client object and return it.
You should set $host and $port in agreement to running jubarecommender server application.

    my $host = 'localhost';
    my $port = '13714';
    my $stat_client = Jubatus->get_recommender_client($host, $port);

The above code is equivalent to:

    use Jubatus::Recommender::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::Recommender::Client->new($host, $port);

See [Jubatus::Recommender::Client](http://search.cpan.org/perldoc?Jubatus::Recommender::Client) for more detail.

## get\_regression\_client $host, $port

This code will create Jubatus::Regression::Client object and return it.
You should set $host and $port in agreement to running jubaregression server application.

    my $host = 'localhost';
    my $port = '13714';
    my $stat_client = Jubatus->get_regression_client($host, $port);

The above code is equivalent to:

    use Jubatus::Regression::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::Regression::Client->new($host, $port);

See [Jubatus::Regression::Client](http://search.cpan.org/perldoc?Jubatus::Regression::Client) for more detail.

## get\_classifier\_client $host, $port

This code will create Jubatus::Classifier::Client object and return it.
You should set $host and $port in agreement to running jubaclassifier server application.

    my $host = 'localhost';
    my $port = '13714';
    my $stat_client = Jubatus->get_classifier_client($host, $port);

The above code is equivalent to:

    use Jubatus::Classifier::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::Classifier::Client->new($host, $port);

See [Jubatus::Classifier::Client](http://search.cpan.org/perldoc?Jubatus::Classifier::Client) for more detail.

## get\_stat\_client $host, $port

This code will create Jubatus::Stat::Client object and return it.
You should set $host and $port in agreement to running jubastat server application.

    my $host = 'localhost';
    my $port = '13714';
    my $stat_client = Jubatus->get_stat_client($host, $port);

The above code is equivalent to:

    use Jubatus::Stat::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::Stat::Client->new($host, $port);

See [Jubatus::Stat::Client](http://search.cpan.org/perldoc?Jubatus::Stat::Client) for more detail.

## get\_graph\_client $host, $port

This code will create Jubatus::Graph::Client object and return it.
You should set $host and $port in agreement to running jubagraph server application.

    my $host = 'localhost';
    my $port = '13714';
    my $graph_client = Jubatus->get_graph_client($host, $port);

The above code is equivalent to:

    use Jubatus::Graph::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::Graph::Client->new($host, $port);

See [Jubatus::Graph::Client](http://search.cpan.org/perldoc?Jubatus::Graph::Client) for more detail.

## get\_anomaly\_client $host, $port

This code will create Jubatus::Anomaly::Client object and return it.
You should set $host and $port in agreement to running jubaanomaly server application.

    my $host = 'localhost';
    my $port = '13714';
    my $anomaly_client = Jubatus->get_anomaly_client($host, $port);

The above code is equivalent to:

    use Jubatus::Anomaly::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::Anomaly::Client->new($host, $port);

See [Jubatus::Anomaly::Client](http://search.cpan.org/perldoc?Jubatus::Anomaly::Client) for more detail.

## get\_nearestneighbor\_client $host, $port

This code will create Jubatus::NearestNeighbor::Client object and return it.
You should set $host and $port in agreement to running jubanearest\_neighbor server application.

    my $host = 'localhost';
    my $port = '13714';
    my $nearest_neighbor_client = Jubatus->get_nearestneighbor_client($host, $port);

The above code is equivalent to:

    use Jubatus::NearestNeighbor::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::NearestNeighbor::Client->new($host, $port);

See [Jubatus::NearestNeighbor::Client](http://search.cpan.org/perldoc?Jubatus::NearestNeighbor::Client) for more detail.



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

The licence of Jubatus is LGPL 2.1.

    Jubatus: Online machine learning framework for distributed environment
    Copyright (C) 2011,2012 Preferred Infrastructure and Nippon Telegraph and Telephone Corporation.

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License version 2.1 as published by the Free Software Foundation.

However Jubatus.pm and Jubatus::\*.pm is the pure Perl modules.
Therefor the licence of Jubatus.pm and Jubatus::\*.pm is the Perl's licence.

# AUTHOR

Toshinori Sato (@overlast) <overlasting@gmail.com>
