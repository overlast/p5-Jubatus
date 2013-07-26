# This file is auto-generated from stat.idl
# *** DO NOT EDIT ***

package Jubatus::Stat::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Stat::Types;

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

sub push {
  my ($self, $name, $key, $value) = @_;
  my $retval = $self->{client}->call('push' => [ $name, $key, $value ] )->recv;
  return $retval;
}

sub sum {
  my ($self, $name, $key) = @_;
  my $retval = $self->{client}->call('sum' => [ $name, $key ] )->recv;
  return $retval;
}

sub stddev {
  my ($self, $name, $key) = @_;
  my $retval = $self->{client}->call('stddev' => [ $name, $key ] )->recv;
  return $retval;
}

sub max {
  my ($self, $name, $key) = @_;
  my $retval = $self->{client}->call('max' => [ $name, $key ] )->recv;
  return $retval;
}

sub min {
  my ($self, $name, $key) = @_;
  my $retval = $self->{client}->call('min' => [ $name, $key ] )->recv;
  return $retval;
}

sub entropy {
  my ($self, $name, $key) = @_;
  my $retval = $self->{client}->call('entropy' => [ $name, $key ] )->recv;
  return $retval;
}

sub moment {
  my ($self, $name, $key, $degree, $center) = @_;
  my $retval = $self->{client}->call('moment' => [ $name, $key, $degree,
       $center ] )->recv;
  return $retval;
}

sub clear {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('clear' => [ $name ] )->recv;
  return $retval;
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

Jubatus::Stat::Client - Perl extension for interfacing with statistical analysis server 'jubastat'

=head1 SYNOPSIS

    use Jubatus;

    my $cluster_name = "jubatus_perl_doc";
    # even if it isn't in a distributed environment using ZooKeeper and Jubatus keepers.

    my $host_name_or_ip_address = "localhost"; # master node's
    my $port_number_of_juba_process = 13714; # meanless

    my $juba_client_type = "stat";
    # you can select from (recommender|regression|clasifier|stat|graph|anomaly)

    my $reco_client = Jubatus->get_client($host_name_or_ip_address, $port_number_of_juba_process, $juba_client_type);
    # got Jubatus::Stat::Client object

    # In the following example, get maximum value from sample array using Jubatus::Stat::Client object

    my $is_clear = $reco_client->clear($cluster_name);

    my @sample = (1.0, 2.0, 3.0, 4.0, 5.0);
    my $key = "sum";
    foreach my $val (@sample) {
        my $is_push = $stat_client->push($cluster_name, $key, $val);
    }
    my $result = $stat_client->sum($cluster_name, $key);

    # $result equal 15.0

=head1 DESCRIPTION

This module provide a interface of recommendation server 'jubastat' by TCP-based MessagePack RPC protocol using L<AnyEvent::MPRPC::Client>

=head1 METHODS

Jubatus::Stat::Client provide many methods.

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Stat::Client->new($host, $port);

This code will create Jubatus::Stat::Client object and return it.
You should set $host and $port in agreement to running jubastat server apprication.

    use Jubatus::Stat::Client;
    my $host = 'localhost';
    my $port = '13714';
    my $obj = Jubatus::Stat::Client->new($host, $port);

The above code is equivalent to:

    use Jubatus;
    my $host = 'localhost';
    my $port = '13714';
    my $juba_client_type = 'stat';
    my $reco_client = Jubatus->get_client($host, $port, $juba_client_type);

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

