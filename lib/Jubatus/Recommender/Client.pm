# This file is auto-generated from recommender.idl
# *** DO NOT EDIT ***

package Jubatus::Recommender::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Recommender::Types;

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

sub update_row {
  my ($self, $name, $id, $row) = @_;
  my $retval = $self->{client}->call('update_row' => [ $name, $id,
       $row->to_msgpack() ] )->recv;
  return $retval;
}

sub clear {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('clear' => [ $name ] )->recv;
  return $retval;
}

sub complete_row_from_id {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->call('complete_row_from_id' => [ $name,
       $id ] )->recv;
  return Jubatus::Recommender::Datum->from_msgpack($retval);
}

sub complete_row_from_datum {
  my ($self, $name, $row) = @_;
  my $retval = $self->{client}->call('complete_row_from_datum' => [ $name,
       $row->to_msgpack() ] )->recv;
  return Jubatus::Recommender::Datum->from_msgpack($retval);
}

sub similar_row_from_id {
  my ($self, $name, $id, $size) = @_;
  my $retval = $self->{client}->call('similar_row_from_id' => [ $name, $id,
       $size ] )->recv;
  return Jubatus::Recommender::SimilarResult->from_msgpack($retval);
}

sub similar_row_from_datum {
  my ($self, $name, $row, $size) = @_;
  my $retval = $self->{client}->call('similar_row_from_datum' => [ $name,
       $row->to_msgpack(), $size ] )->recv;
  return Jubatus::Recommender::SimilarResult->from_msgpack($retval);
}

sub decode_row {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->call('decode_row' => [ $name, $id ] )->recv;
  return Jubatus::Recommender::Datum->from_msgpack($retval);
}

sub get_all_rows {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('get_all_rows' => [ $name ] )->recv;
  return [ map { $_} @{ $retval } ];
}

sub calc_similarity {
  my ($self, $name, $lhs, $rhs) = @_;
  my $retval = $self->{client}->call('calc_similarity' => [ $name,
       $lhs->to_msgpack(), $rhs->to_msgpack() ] )->recv;
  return $retval;
}

sub calc_l2norm {
  my ($self, $name, $row) = @_;
  my $retval = $self->{client}->call('calc_l2norm' => [ $name, $row->to_msgpack(
      ) ] )->recv;
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

