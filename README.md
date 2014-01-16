# NAME

Jubatus - Perl extension for interfacing with Jubatus, a distributed processing
 framework and streaming machine learning library.

# SYNOPSIS

    use Jubatus;

    # you can use recommender or regression, classifier, stat, graph, anomaly,
    # nearestneighbor, clustering
    my $client_type = "stat";

    # distributed environment user must define cluster name of Jubatus/Zookeeper
    my $name = "jubatus_perl_doc";

    # hostname or ip address of master node
    my $host = "localhost";

    # port number of your juba* process
    my $port = 13714; # meanless

    # default parameter of Jubatus.pm is 10 seconds
    my $timeout = 15;

    # get Jubatus::Stat::Client object
    my $graph_client = Jubatus->get_client(
       $client_type, $host, $port, $name, $timeout
    );

    # In the following example, get maximum value from sample array using
    # Jubatus::Stat::Client object
    my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
    my $key = "sum";
    foreach my $val (@sample) {
        my $is_push = $stat_client->push($key, $val);
    }

    my $result = $stat_client->sum($key);
    # $result is 15.0

# DESCRIPTION

This module provide a interface of Jubatus by TCP-based MessagePack RPC protocol
 using [AnyEvent::MPRPC::Client](http://search.cpan.org/perldoc?AnyEvent::MPRPC::Client)
Jubatus is a distributed processing framework and streaming machine learning
 library.

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

# METHODS

- get\_client($client\_type, $host, $port, $name, $timeout)

    Input:
        String  $client\_type (indispensable)
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::$client\_type::Client $object

    Indispensable arguments are $client\_type, $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

    $client\_type is a value to specify the client type of jubatus server.
    You can select recommender or regression, classifier, stat, graph, anomal,
     nearestneighbor, clustering.
    You can also select Recommender or Regression, Classifier, Stat, Graph,
     Anomaly, NearestNeighbor, Clustering.

    $host is hostname or ip address of master node of juba\* process.

    $port is a port number of your juba\* process

    $name is a cluster name.
    Default value of $name parameter is ""(null string).
    If you are user of distributed environment of Jubatus/Zookeeper,
     you must set $name.

    $timeout is a seconds value of timeout when you access to jubatus server.
    Default value is 10 seconds.
    You should set $timeout if you want to change other seconds value.

    Example:
    If you select 'stat', you can get [Jubatus::Stat::Client](http://search.cpan.org/perldoc?Jubatus::Stat::Client) object.

        use Jubatus;
        my $client_type = 'stat';
        my $host = 'localhost';
        my $port = '13714';
        my $name = 'jubatus_perl_doc';
        my $client = Jubatus->get_client($client_type, $host, $port, $name);

    $client will get Jubatus::Stat::Client object.

    The above code is equivalent to:

        use Jubatus::Stat::Client;
        my $host = 'localhost';
        my $port = '13714';
        my $name = 'jubatus_perl_doc';
        my $client = Jubatus::Stat::Client->new($host, $port, $name);

    If you are not distributed environment user, you can write code ad follow.

        use Jubatus;
        my $client_type = 'stat';
        my $host = 'localhost';
        my $port = '13714';
        my $client = Jubatus->get_client($client_type, $host, $port);

- get\_recommender\_client($host, $port, $name, $timeout)

    Input:
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::Recommender::Client $object

    Indispensable arguments are $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

    Example:
        use Jubatus;
        my $host = 'localhost';
        my $port = '13714';
        my $client = Jubatus->get\_recommender\_client($host, $port);

    This code will create Jubatus::Recommener::Client object and return it.
    You should set $host and $port in agreement to
     running jubarecommender server application.

    This code isn't write cluster name and timeout seconds parameter.
    But Jubatus.pm use default cluster name("")
     and default timeout parameter(10).

    The above code is equivalent to:

        use Jubatus::Recommender::Client;
        my $host = 'localhost';
        my $port = '13714';
        my $client = Jubatus::Recommender::Client->new($host, $port);

    If you are distributed environment user and
    you want to set the parameter of timeout secondes of jubatus server,
    you can write same as following code.

        use Jubatus;
        my $host = 'localhost';
        my $port = '13714';
        my $cluster_name = "jubatus_perl_doc";
        my $timeout_seconds = 3;
        my $client = Jubatus->get_recommender_client(
            $host, $port, $name, $timeout
        );

    See [Jubatus::Recommender::Client](http://search.cpan.org/perldoc?Jubatus::Recommender::Client) for more detail.

- get\_regression\_client($host, $port, $name, $timeout)

    Input:
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::Regression::Client $object

    Indispensable arguments are $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

    See [Jubatus::Regression::Client](http://search.cpan.org/perldoc?Jubatus::Regression::Client) for more detail.

- get\_classifier\_client($host, $port, $name, $timeout)

    Input:
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::Clasifier::Client $object

    Indispensable arguments are $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

    See [Jubatus::Classifier::Client](http://search.cpan.org/perldoc?Jubatus::Classifier::Client) for more detail.

- get\_stat\_client($host, $port, $name, $timeout)

    Input:
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::Stat::Client $object

    Indispensable arguments are $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

    See [Jubatus::Stat::Client](http://search.cpan.org/perldoc?Jubatus::Stat::Client) for more detail.

- get\_graph\_client($host, $port, $name, $timeout)

    Input:
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::Graph::Client $object

    Indispensable arguments are $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

    See [Jubatus::Graph::Client](http://search.cpan.org/perldoc?Jubatus::Graph::Client) for more detail.

- get\_anomaly\_client($host, $port, $name, $timeout)

    Input:
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::Anomaly::Client $object

    Indispensable arguments are $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

    See [Jubatus::Anomaly::Client](http://search.cpan.org/perldoc?Jubatus::Anomaly::Client) for more detail.

- get\_nearestneighbor\_client($host, $port, $name, $timeout)

    Input:
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::NearestNeighbor::Client $object

    Indispensable arguments are $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

    See [Jubatus::NearestNeighbor::Client](http://search.cpan.org/perldoc?Jubatus::NearestNeighbor::Client) for more detail.

- get\_clustering\_client($host, $port, $name, $timeout)

    Input:
        String  $host (indispensable)
        Integer $port (indispensable)
        String  $name
        Integer $timeout

    Output:
        Jubatus::Clustering::Client $object

    Indispensable arguments are $host, $port.
    Distributed environment user must be set $name.
    Default value of $timeout parameter is 10(seconds).
    If you want change the value of $timeout, you should set $timeout.

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
