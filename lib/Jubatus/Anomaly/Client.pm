# This file is auto-generated from anomaly.idl
# *** DO NOT EDIT ***

package Jubatus::Anomaly::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Anomaly::Types;

sub new {
  my ($class, $host, $port) = @_;
  my $client = AnyEvent::MPRPC::Client->new(
    'host' => $host,
    'port' => $port,
  );
  my %hash = ('client' => $client);
  bless \%hash, $class;
}

sub get_client {
  my ($self) = @_;
  return $self->{client};
}

sub get_config {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('get_config' => [ $name ] )->recv;
  return $retval;
}

sub clear_row {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->call('clear_row' => [ $name, $id ] )->recv;
  return $retval;
}

sub add {
  my ($self, $name, $row) = @_;
  my $retval = $self->{client}->call('add' => [ $name, $row->to_msgpack(
      ) ] )->recv;
  return  [ $retval->[0], $retval->[1] ] ;
}

sub update {
  my ($self, $name, $id, $row) = @_;
  my $retval = $self->{client}->call('update' => [ $name, $id, $row->to_msgpack(
      ) ] )->recv;
  return $retval;
}

sub clear {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('clear' => [ $name ] )->recv;
  return $retval;
}

sub calc_score {
  my ($self, $name, $row) = @_;
  my $retval = $self->{client}->call('calc_score' => [ $name, $row->to_msgpack(
      ) ] )->recv;
  return $retval;
}

sub get_all_rows {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('get_all_rows' => [ $name ] )->recv;
  return [ map { $_} @{ $retval } ];
}

sub save {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->call('save' => [ $name, $id ] )->recv;
  return $retval;
}

sub load {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->call('load' => [ $name, $id ] )->recv;
  return $retval;
}

sub get_status {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('get_status' => [ $name ] )->recv;
  return $retval;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Anomaly::Client - Perl extension for interfacing with recommendation server 'jubaanomaly'

=head1 SYNOPSIS

    use Jubatus;

    my $cluster_name = "jubatus_perl_doc";
    # even if it isn't in a distributed environment using ZooKeeper and Jubatus keepers.

    my $host_name_or_ip_address = "localhost"; # master node's
    my $port_number_of_juba_process = 13714; # meanless

    my $juba_client_type = "anomaly";
    # you can select from (recommender|regression|clasifier|stat|graph|anomaly)

    my $anom_client = Jubatus->get_client($host_name_or_ip_address, $port_number_of_juba_process, $juba_client_type);
    # got Jubatus::Anomaly::Client object

    # In the following example, get maximum value from sample array using Jubatus::Anomaly::Client object

    my $is_clear = $anom_client->clear($cluster_name);

    for (1..10) {
        my $datum = Jubatus::Anomaly::Datum->new([], [['val', 1.0]]);
        my $add_result = $anom_client->add($cluster_name, $datum);
    }
    my $val = 5.0;
    my @result = ();

    for (1..10) {
        my $datum = Jubatus::Anomaly::Datum->new([], [['val', $val]]);
        my $add_result = $anom_client->add($cluster_name, $datum);
        push @result, $add_result->[1];
        $val = 1.000001 + $val;
    }

    # The values in the @answer may be following values.
    #my @answer = (
    #    "inf",
    #    1,
    #    0.899999976158142,
    #    "inf",
    #    1,
    #    0.899999976158142,
    #    0.933333337306976,
    #    0.9375,
    #    0.950000047683716,
    #    0.954545438289642,
    #);

=head1 DESCRIPTION

This module provide a interface of recommendation server 'jubaanomaly' by TCP-based MessagePack RPC protocol using L<AnyEvent::MPRPC::Client>

=head1 METHODS

Jubatus::Anomaly::Client provide many methods.

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Anomaly::Client->new($host, $port);

This code will create Jubatus::Anomaly::Client object and return it.
You should set $host and $port in agreement to running jubastat server apprication.

    use Jubatus::Anomaly::Client;
    my $host = 'localhost';
    my $port = '13714';
    my $obj = Jubatus::Anomaly::Client->new($host, $port);

The above code is equivalent to:

    use Jubatus;
    my $host = 'localhost';
    my $port = '13714';
    my $juba_client_type = 'anomaly';
    my $anom_client = Jubatus->get_client($host, $port, $juba_client_type);

See L<Jubatus> for more detail.

=head1 FUNCTIONS

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

