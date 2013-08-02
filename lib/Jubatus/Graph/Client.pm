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

__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Graph::Client - Perl extension for interfacing with graph mining server 'jubagraph'

=head1 SYNOPSIS

    use Jubatus;

    my $cluster_name = "jubatus_perl_doc";
    # even if it isn't in a distributed environment using ZooKeeper and Jubatus keepers.

    my $host_name_or_ip_address = "localhost"; # master node's
    my $port_number_of_juba_process = 13714; # meanless

    my $juba_client_type = "graph";
    # you can select from (recommender|regression|classifier|stat|graph|anomaly|nearestneighbor)

    my $graph_client = Jubatus->get_client($host_name_or_ip_address, $port_number_of_juba_process, $juba_client_type);
    # got Jubatus::Graph::Client object

    # In the following example, get maximum value from sample array using Jubatus::Graph::Client object

    my $is_clear = $graph_client->clear($cluster_name);

    my $centality_sample_tsv = << "__PAGERANK__";
    1	2	3	4	5	7
    2	1
    3	1	2
    4	2	3	5
    5	1	3	4	6
    6	1	5
    7	5
    __PAGERANK__

    my $graph_client = Jubatus::Graph::Client->new($host, $server->{port});

    my @sample_tsv_lines = split /\n/, $centality_sample_tsv;
    my %nid2sid = ();
    my %sid2nid = ();
    my %sid2eid = ();

    my $edge_query = [];
    my $node_query = [];
    my $pq = Jubatus::Graph::PresetQuery->new($edge_query, $node_query);
    my $is_add = $graph_client->add_centrality_query($cluster_name, $pq);

    foreach my $tsv_line (@sample_tsv_lines) {
        my @colmuns = split /\t/, $tsv_line;
        my $id = $colmuns[0];
        my $node_id;
        if (exists $sid2nid{$id}) {
            $node_id = $sid2nid{$id};
        }
        else {
            $node_id = $graph_client->create_node($cluster_name);
            $graph_client->update_node($cluster_name, $node_id, {});
            $nid2sid{$node_id} = $id;
            $sid2nid{$id} = $node_id;
        }

        for (my $i = 1; $i <= $#colmuns; $i++) {
            my $target_node_id;
            my $out_id = $colmuns[$i];
            if (exists $sid2nid{$out_id}) {
                $target_node_id = $sid2nid{$out_id};
            }
            else {
                $target_node_id = $graph_client->create_node($cluster_name);
                $graph_client->update_node($cluster_name, $target_node_id, {});
                $nid2sid{$target_node_id} = $out_id;
                $sid2nid{$out_id} = $target_node_id;
            }
            my $edge = Jubatus::Graph::Edge->new({}, $node_id, $target_node_id);
            my $edge_id = $graph_client->create_edge($cluster_name, $node_id, $edge);
            $sid2eid{$id}{$out_id} = $edge_id;
        }
        my $is_index = $graph_client->update_index($cluster_name);
    }
    my @result = (0, 2.1, 1.2, 0.96, 0.72, 1, 0.35, 0.54);
    for (my $qid = 1; $qid <= ($#sample_tsv_lines + 1); $qid++) {
        my $centrality_type = 0; # pagerank
        my $centrality = $graph_client->get_centrality($cluster_name, $sid2nid{$qid}, $centrality_type, $pq);

        # $centrality equal $result[$qid]
    }

=head1 DESCRIPTION

This module provide a interface of recommendation server 'jubagraph' by TCP-based MessagePack RPC protocol using L<AnyEvent::MPRPC::Client>

=head1 METHODS

Jubatus::Graph::Client provide many methods.

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Graph::Client->new($host, $port);

This code will create Jubatus::Graph::Client object and return it.
You should set $host and $port in agreement to running jubastat server application.

    use Jubatus::Graph::Client;
    my $host = 'localhost';
    my $port = '13714';
    my $obj = Jubatus::Graph::Client->new($host, $port);

The above code is equivalent to:

    use Jubatus;
    my $host = 'localhost';
    my $port = '13714';
    my $juba_client_type = 'graph';
    my $graph_client = Jubatus->get_client($host, $port, $juba_client_type);

See L<Jubatus> for more detail.

=head1 FUNCTIONS

=head3 get_client()

Returns the reference to the Jubatus::Graph::Client object which has a "client"
field. This field is a reference of AnyEvent::MPRPC::Client object to call a raw
MessagePack-RPC client instance which is used by Jubatus client libraries. The
functions of Jubatus::Graph::Client are wrapper of AnyEvent::MPRPC::Client.

Input:

    - None

Output:

    - Jubatus::Graph::Client object - Return a Jubatus::Graph::Client object
      Which is used ad MessagePack-RPC client instance of jubagraph server.

=head3 get_config($cluster_name)

Returns a server configuration from a server which is belonging to the
cluster which execute the $cluster_name tasks.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

Output:

    - JSON file formated string - Returns a server configuration from a server.
      This configuration is same as the configuration file which was assigned
      when you start the jubagraph server.

=head3 get_status($cluster_name)

Returns server status from all servers which are belonging to the cluster which
execute the $cluster_name tasks. Each server is represented by a pair of
a host name and a port number.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

=head3 save($cluster_name, $save_file_name)

Stores the learning model as $save_file_name to the local disk of all servers
which are belonging to the cluster which execute the $cluster_name tasks.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

    - $save_file_name - File name to save

Output:

    - binary(1 or 0) - Return integer value 1 if this function saves files
      successfully at all servers

=head3 load($cluster_name, $load_file_name)

Restores the saved model using $load_file_name at the local disk of all servers
which are belonging to the cluster which execute the $cluster_name tasks.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

    - $save_file_name - File name to restore

Output:

    - binary(1 or 0) - Return integer value 1 if this function restore saved
      model successfully at all servers

=head3 clear($cluster_name)

Completely clears the learning model on the memory of all servers which are
belonging to the cluster which execute the $cluster_name tasks.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

Output:

    - binary(1 or 0) - Return integer value 1 if this function clears the
      saved model successfully at all servers

Output:

    - Hash reference which have a hash reference value - Returns a server
      status from all servers which are belonging to the cluster which execute
      the $cluster_name tasks. Each server is represented by a pair of host name
      and a port number. This pair is used for a key of the return hash
      reference. The value of the return hash reference is hash reference. The
      keys of this hash reference are the server status name and each values are
      the server status informations.

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

