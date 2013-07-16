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

