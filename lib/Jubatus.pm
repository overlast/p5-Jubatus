package Jubatus;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Jubatus::Regression::Client;
use Jubatus::Recommender::Client;
use Jubatus::Classifier::Client;
use Jubatus::Stat::Client;
use Jubatus::Graph::Client;
use Jubatus::Anomaly::Client;

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


1;
__END__

=encoding utf-8

=head1 NAME

Jubatus - It's new $module

=head1 SYNOPSIS

    use Jubatus;

=head1 DESCRIPTION

Jubatus is ...

=head1 LICENSE

Copyright (C) Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut
