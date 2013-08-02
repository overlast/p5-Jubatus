package Jubatus;

use v5.10.1;
use strict;
use warnings;

our $VERSION = "0.0.0_01";

use Jubatus::NearestNeighbor::Client;
use Jubatus::Regression::Client;
use Jubatus::Recommender::Client;
use Jubatus::Classifier::Client;
use Jubatus::Stat::Client;
use Jubatus::Graph::Client;
use Jubatus::Anomaly::Client;

sub get_nearestneighbor_client {
    my ($self, $host, $port) = @_;
    my $client = Jubatus::NearestNeighbor::Client->new($host, $port);
    return $client;
}

sub get_regression_client {
    my ($self, $host, $port) = @_;
    my $client = Jubatus::Regression::Client->new($host, $port);
    return $client;
}

sub get_recommender_client {
    my ($self, $host, $port) = @_;
    my $client = Jubatus::Recommender::Client->new($host, $port);
    return $client;
}

sub get_classifier_client {
    my ($self, $host, $port) = @_;
    my $client = Jubatus::Classifier::Client->new($host, $port);
    return $client;
}

sub get_stat_client {
    my ($self, $host, $port) = @_;
    my $client = Jubatus::Stat::Client->new($host, $port);
    return $client;
}

sub get_graph_client {
    my ($self, $host, $port) = @_;
    my $client = Jubatus::Graph::Client->new($host, $port);
    return $client;
}

sub get_anomaly_client {
    my ($self, $host, $port) = @_;
    my $client = Jubatus::Anomaly::Client->new($host, $port);
    return $client;
}


sub get_client {
    my ($self, $host, $port, $param) = @_;
    my $client;
    given ($param) {
        when (/^NearestNeighbor|nearestneighbor$/) {
            $client = Jubatus->get_nearestneighbor_client($host, $port);
        }
        when (/^Regression|regression$/) {
            $client = Jubatus->get_regression_client($host, $port);
        }
        when (/^Recommender|recommender$/) {
            $client = Jubatus->get_recommender_client($host, $port);
        }
        when (/^Classifier|classifier$/) {
            $client = Jubatus->get_classifier_client($host, $port);
        }
        when (/^Stat|stat$/) {
            $client = Jubatus->get_stat_client($host, $port);
        }
        when (/^Graph|graph$/) {
            $client = Jubatus->get_graph_client($host, $port);
        }
        when (/^Anomaly|anomaly$/) {
            $client = Jubatus->get_anomaly_client($host, $port);
        }
        default {
            die "Jubatus::".$param."::Client.pm is not install.\n Please see Jubatus.pm !\n";
        }
    }
    return $client;
}


1;

__END__

=encoding utf-8

=head1 NAME

Jubatus - Perl extension for interfacing with Jubatus, a distributed processing framework and streaming machine learning library.

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This module provide a interface of Jubatus by TCP-based MessagePack RPC protocol using L<AnyEvent::MPRPC::Client>
Jubatus is a distributed processing framework and streaming machine learning library.

L<Jubatus> provide you a couple of export functions that are shortcut of
 L<Jubatus::Recommender::Client> and L<Jubatus::Regression::Client>,
 L<Jubatus::Classifier::Client>, L<Jubatus::Stat::Client>,
 L<Jubatus::Graph::Client>, L<Jubatus::Anomaly::Client>,
 L<Jubatus:;NearestNeighbor::Client>,

One is C<get_client> to get Client object by specifying client type.
Another is C<get_recommender_client> and C<get_regression_client>,
 C<get_classifier_client>, C<get_stst_client>, C<get_graph_client>,
 C<get_anomaly_client>, C<get_nearestneighbor_client> to get a specific Client
  object explicitly.

=head1 FUNCTIONS

=head2 get_client $host, $port, $juba_client_type

$juba_client_type is a value to specify the client type of jubatus.
You can select from (recommender|regression|classifier|stat|graph|anomaly).
You can also use (Recommender|Regression|Classifier|Stat|Graph|Anomaly).

If you select 'stat', you can get L<Jubatus::Stat::Client> object.

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

=head2 get_recommender_client $host, $port

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

See L<Jubatus::Recommender::Client> for more detail.

=head2 get_regression_client $host, $port

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

See L<Jubatus::Regression::Client> for more detail.

=head2 get_classifier_client $host, $port

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

See L<Jubatus::Classifier::Client> for more detail.

=head2 get_stat_client $host, $port

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

See L<Jubatus::Stat::Client> for more detail.

=head2 get_graph_client $host, $port

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

See L<Jubatus::Graph::Client> for more detail.

=head2 get_anomaly_client $host, $port

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

See L<Jubatus::Anomaly::Client> for more detail.

=head2 get_nearestneighbor_client $host, $port

This code will create Jubatus::NearestNeighbor::Client object and return it.
You should set $host and $port in agreement to running jubanearest_neighbor server application.

    my $host = 'localhost';
    my $port = '13714';
    my $nearest_neighbor_client = Jubatus->get_nearestneighbor_client($host, $port);

The above code is equivalent to:

    use Jubatus::NearestNeighbor::Client;
    my $host = 'localhost';
    my $port = '13714';
    Jubatus::NearestNeighbor::Client->new($host, $port);

See L<Jubatus::NearestNeighbor::Client> for more detail.


=head1 SEE ALSO

L<http://jubat.us/>
L<https://github.com/jubatus>

L<AnyEvent::MPRPC>
L<AnyEvent::MPRPC::Client>
L<http://msgpack.org/>
L<http://wiki.msgpack.org/display/MSGPACK/RPC+specification>

L<https://github.com/overlast/p5-Jubatus>

=head1 LICENSE

Copyright (C) 2013 by Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

The licence of Jubatus is LGPL 2.1.

    Jubatus: Online machine learning framework for distributed environment
    Copyright (C) 2011,2012 Preferred Infrastructure and Nippon Telegraph and Telephone Corporation.

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License version 2.1 as published by the Free Software Foundation.

However Jubatus.pm and Jubatus::*.pm is the pure Perl modules.
Therefor the licence of Jubatus.pm and Jubatus::*.pm is the Perl's licence.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut
