# This file is auto-generated from nearest_neighbor.idl
# *** DO NOT EDIT ***

package Jubatus::NearestNeighbor::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::NearestNeighbor::Types;

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

sub init_table {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('init_table' => [ $name ] )->recv;
  return $retval;
}

sub clear {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('clear' => [ $name ] )->recv;
  return $retval;
}

sub set_row {
  my ($self, $name, $id, $d) = @_;
  my $retval = $self->{client}->call('set_row' => [ $name, $id, $d->to_msgpack(
      ) ] )->recv;
  return $retval;
}

sub neighbor_row_from_id {
  my ($self, $name, $id, $size) = @_;
  my $retval = $self->{client}->call('neighbor_row_from_id' => [ $name, $id,
       $size ] )->recv;
  return Jubatus::NearestNeighbor::NeighborResult->from_msgpack($retval);
}

sub neighbor_row_from_data {
  my ($self, $name, $query, $size) = @_;
  my $retval = $self->{client}->call('neighbor_row_from_data' => [ $name,
       $query->to_msgpack(), $size ] )->recv;
  return Jubatus::NearestNeighbor::NeighborResult->from_msgpack($retval);
}

sub similar_row_from_id {
  my ($self, $name, $id, $ret_num) = @_;
  my $retval = $self->{client}->call('similar_row_from_id' => [ $name, $id,
       $ret_num ] )->recv;
  return Jubatus::NearestNeighbor::NeighborResult->from_msgpack($retval);
}

sub similar_row_from_data {
  my ($self, $name, $query, $ret_num) = @_;
  my $retval = $self->{client}->call('similar_row_from_data' => [ $name,
       $query->to_msgpack(), $ret_num ] )->recv;
  return Jubatus::NearestNeighbor::NeighborResult->from_msgpack($retval);
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

