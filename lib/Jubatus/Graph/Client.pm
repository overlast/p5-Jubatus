# This file is auto-generated from graph.idl
# *** DO NOT EDIT ***

package Jubatus::Graph::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Graph::Types;

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

sub create_node {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('create_node' => [ $name ] )->recv;
  return $retval;
}

sub remove_node {
  my ($self, $name, $node_id) = @_;
  my $retval = $self->{client}->call('remove_node' => [ $name,
       $node_id ] )->recv;
  return $retval;
}

sub update_node {
  my ($self, $name, $node_id, $property) = @_;
  my $retval = $self->{client}->call('update_node' => [ $name, $node_id,
       $property ] )->recv;
  return $retval;
}

sub create_edge {
  my ($self, $name, $node_id, $e) = @_;
  my $retval = $self->{client}->call('create_edge' => [ $name, $node_id,
       $e->to_msgpack() ] )->recv;
  return $retval;
}

sub update_edge {
  my ($self, $name, $node_id, $edge_id, $e) = @_;
  my $retval = $self->{client}->call('update_edge' => [ $name, $node_id,
       $edge_id, $e->to_msgpack() ] )->recv;
  return $retval;
}

sub remove_edge {
  my ($self, $name, $node_id, $edge_id) = @_;
  my $retval = $self->{client}->call('remove_edge' => [ $name, $node_id,
       $edge_id ] )->recv;
  return $retval;
}

sub get_centrality {
  my ($self, $name, $node_id, $centrality_type,
     $query) = @_;
  my $retval = $self->{client}->call('get_centrality' => [ $name, $node_id,
       $centrality_type, $query->to_msgpack() ] )->recv;
  return $retval;
}

sub add_centrality_query {
  my ($self, $name, $query) = @_;
  my $retval = $self->{client}->call('add_centrality_query' => [ $name,
       $query->to_msgpack() ] )->recv;
  return $retval;
}

sub add_shortest_path_query {
  my ($self, $name, $query) = @_;
  my $retval = $self->{client}->call('add_shortest_path_query' => [ $name,
       $query->to_msgpack() ] )->recv;
  return $retval;
}

sub remove_centrality_query {
  my ($self, $name, $query) = @_;
  my $retval = $self->{client}->call('remove_centrality_query' => [ $name,
       $query->to_msgpack() ] )->recv;
  return $retval;
}

sub remove_shortest_path_query {
  my ($self, $name, $query) = @_;
  my $retval = $self->{client}->call('remove_shortest_path_query' => [ $name,
       $query->to_msgpack() ] )->recv;
  return $retval;
}

sub get_shortest_path {
  my ($self, $name, $query) = @_;
  my $retval = $self->{client}->call('get_shortest_path' => [ $name,
       $query->to_msgpack() ] )->recv;
  return [ map { $_} @{ $retval } ];
}

sub update_index {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('update_index' => [ $name ] )->recv;
  return $retval;
}

sub clear {
  my ($self, $name) = @_;
  my $retval = $self->{client}->call('clear' => [ $name ] )->recv;
  return $retval;
}

sub get_node {
  my ($self, $name, $node_id) = @_;
  my $retval = $self->{client}->call('get_node' => [ $name, $node_id ] )->recv;
  return Jubatus::Graph::Node->from_msgpack($retval);
}

sub get_edge {
  my ($self, $name, $node_id, $edge_id) = @_;
  my $retval = $self->{client}->call('get_edge' => [ $name, $node_id,
       $edge_id ] )->recv;
  return Jubatus::Graph::Edge->from_msgpack($retval);
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

sub create_node_here {
  my ($self, $name, $node_id) = @_;
  my $retval = $self->{client}->call('create_node_here' => [ $name,
       $node_id ] )->recv;
  return $retval;
}

sub remove_global_node {
  my ($self, $name, $node_id) = @_;
  my $retval = $self->{client}->call('remove_global_node' => [ $name,
       $node_id ] )->recv;
  return $retval;
}

sub create_edge_here {
  my ($self, $name, $edge_id, $e) = @_;
  my $retval = $self->{client}->call('create_edge_here' => [ $name, $edge_id,
       $e->to_msgpack() ] )->recv;
  return $retval;
}

1;

