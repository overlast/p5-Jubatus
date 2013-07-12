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
  return { map { $_->[0] => { map { $_->[0] => $_->[1] } @{ $_->[1] } } } @{ $retval } };
}

1;

