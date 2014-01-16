package Jubatus;

use v5.12.1;
use strict;
use warnings;

our $VERSION = "0.0.1_02";

use Jubatus::NearestNeighbor::Client;
use Jubatus::Regression::Client;
use Jubatus::Common::Client;
use Jubatus::Recommender::Client;
use Jubatus::Classifier::Client;
use Jubatus::Stat::Client;
use Jubatus::Clustering::Client;
use Jubatus::Graph::Client;
use Jubatus::Anomaly::Client;
use Jubatus::Common::Datum;

sub get_nearestneighbor_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::NearestNeighbor::Client->new($host, $port, $name, $timeout);
    return $client;
}

sub get_regression_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::Regression::Client->new($host, $port, $name, $timeout);
    return $client;
}

sub get_common_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::Common::Client->new($host, $port, $name, $timeout);
    return $client;
}

sub get_recommender_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::Recommender::Client->new($host, $port, $name, $timeout);
    return $client;
}

sub get_classifier_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::Classifier::Client->new($host, $port, $name, $timeout);
    return $client;
}

sub get_stat_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::Stat::Client->new($host, $port, $name, $timeout);
    return $client;
}

sub get_clustering_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::Clustering::Client->new($host, $port, $name, $timeout);
    return $client;
}

sub get_graph_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::Graph::Client->new($host, $port, $name, $timeout);
    return $client;
}

sub get_anomaly_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = Jubatus::Anomaly::Client->new($host, $port, $name, $timeout);
    return $client;
}


sub get_client {
    my ($self, $param, $host, $port, $name, $timeout) = @_;
    my $client;
    given ($param) {
        when (/^NearestNeighbor|nearestneighbor$/) {
            $client = Jubatus->get_nearestneighbor_client($host, $port, $name, $timeout);
        }
        when (/^Regression|regression$/) {
            $client = Jubatus->get_regression_client($host, $port, $name, $timeout);
        }
        when (/^Common|common$/) {
            $client = Jubatus->get_common_client($host, $port, $name, $timeout);
        }
        when (/^Recommender|recommender$/) {
            $client = Jubatus->get_recommender_client($host, $port, $name, $timeout);
        }
        when (/^Classifier|classifier$/) {
            $client = Jubatus->get_classifier_client($host, $port, $name, $timeout);
        }
        when (/^Stat|stat$/) {
            $client = Jubatus->get_stat_client($host, $port, $name, $timeout);
        }
        when (/^Clustering|clustering$/) {
            $client = Jubatus->get_clustering_client($host, $port, $name, $timeout);
        }
        when (/^Graph|graph$/) {
            $client = Jubatus->get_graph_client($host, $port, $name, $timeout);
        }
        when (/^Anomaly|anomaly$/) {
            $client = Jubatus->get_anomaly_client($host, $port, $name, $timeout);
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

=head1 DESCRIPTION

This module provide a interface of Jubatus by TCP-based MessagePack RPC protocol using L<AnyEvent::MPRPC::Client>
Jubatus is a distributed processing framework and streaming machine learning library.

L<Jubatus> provide you a couple of export functions that are shortcut of
 L<Jubatus::Recommender::Client> and L<Jubatus::Regression::Client>,
 L<Jubatus::Classifier::Client>, L<Jubatus::Stat::Client>,
 L<Jubatus::Graph::Client>, L<Jubatus::Anomaly::Client>,
 L<Jubatus:;NearestNeighbor::Client>, L<Jubatus:;Clustering::Client>,

One is C<get_client> to get Client object by specifying client type.
Another is C<get_recommender_client> and C<get_regression_client>,
 C<get_classifier_client>, C<get_stst_client>, C<get_graph_client>,
 C<get_anomaly_client>, C<get_nearestneighbor_client>,
C<get_clustering_client>,  to get a specific Client object explicitly.

=head1 FUNCTIONS

=head2 get_client $juba_client_type, $host, $port, $process_name, $timeout_sec

$juba_client_type is a value to specify the client type of jubatus.
You can select from (recommender | regression | classifier | stat | graph | anomaly | "nearestneighbor" | clustering).
You can also use (Recommender | Regression | Classifier | Stat | Graph | Anomaly | NearestNeighbor | Clustering).

If you select 'stat', you can get L<Jubatus::Stat::Client> object.

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

Because default value of $timeout_seconds_of_juba_process is 10.

If you are not distributed environment user, you can write as following.

    my $juba_client_type = 'stat';
    my $host = 'localhost';
    my $port = '13714';
    my $stat_client = Jubatus->get_client($juba_client_type, $host, $port);

Because default value of $cluster_name is ""(null string).

=head2 get_recommender_client $host, $port, ($cluster_name, $timeout_seconds,)

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

See L<Jubatus::Recommender::Client> for more detail.

=head2 get_regression_client $host, $port, ($cluster_name, $timeout_seconds,)

See L<Jubatus::Regression::Client> for more detail.

=head2 get_classifier_client $host, $port, ($cluster_name, $timeout_seconds,)

See L<Jubatus::Classifier::Client> for more detail.

=head2 get_stat_client $host, $port, ($cluster_name, $timeout_seconds,)

See L<Jubatus::Stat::Client> for more detail.

=head2 get_graph_client $host, $port, ($cluster_name, $timeout_seconds,)

See L<Jubatus::Graph::Client> for more detail.

=head2 get_anomaly_client $host, $port, ($cluster_name, $timeout_seconds,)

See L<Jubatus::Anomaly::Client> for more detail.

=head2 get_nearestneighbor_client $host, $port, ($cluster_name, $timeout_seconds,)

See L<Jubatus::NearestNeighbor::Client> for more detail.

=head2 get_clustering_client $host, $port, ($cluster_name, $timeout_seconds,)

See L<Jubatus::Clustering::Client> for more detail.

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

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut
