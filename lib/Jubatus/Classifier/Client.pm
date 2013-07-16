# This file is auto-generated from classifier.idl
# *** DO NOT EDIT ***

package Jubatus::Classifier::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Classifier::Types;

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

sub train {
  my ($self, $name, $data) = @_;
  my $retval = $self->{client}->call('train' => [ $name, $data ] )->recv;
  return $retval;
}

sub classify {
  my ($self, $name, $data) = @_;
  my $retval = $self->{client}->call('classify' => [ $name, $data ] )->recv;
  return [ map { [ map { Jubatus::Classifier::EstimateResult->from_msgpack(
      $_)} @{ $_ } ]} @{ $retval } ];
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

