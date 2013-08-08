package Jubatus::Recommender;

use strict;
use warnings;
use utf8;
use autodie;

use Jubatus::Recommender::Client;
use Jubatus::Common::Datum;

sub new {
  my ($class, $host, $port) = @_;
  my $client = Jubatus::Recommender::Client->new($host, $port);
  my %hash = ('client' => $client);
  bless \%hash, $class;
}

sub get_client {
  my ($self) = @_;
  return $self->{client};
}

sub get_config {
  my ($self, $name) = @_;
  my $retval = $self->{client}->get_config($name);
  return $retval;
}

sub clear_row {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->clear_row($name, $id);
  return $retval;
}

sub update_row {
  my ($self, $name, $id, $str_hash_ref, $num_hash_ref) = @_;
  $str_hash_ref = {} unless (defined $str_hash_ref);
  $num_hash_ref = {} unless (defined $num_hash_ref);
  my $row = Jubatus::Common::Datum->new($str_hash_ref, $num_hash_ref);
  my $retval = $self->{client}->update_row($name, $id, $row);
  return $retval;
}

sub clear {
  my ($self, $name) = @_;
  my $retval = $self->{client}->clear($name);
  return $retval;
}

sub complete_row_from_id {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->call('complete_row_from_id' => [ $name,
       $id ] )->recv;
  return Jubatus::Common::Datum->from_msgpack($retval);
}

sub complete_row_from_datum {
  my ($self, $name, $str_hash_ref, $num_hash_ref) = @_;
  $str_hash_ref = {} unless (defined $str_hash_ref);
  $num_hash_ref = {} unless (defined $num_hash_ref);
  my $row = Jubatus::Common::Datum->new($str_hash_ref, $num_hash_ref);
  my $retval = $self->{client}->complete_row_from_datum($name, $row);
  return $retval;
}

sub similar_row_from_id {
  my ($self, $name, $id, $size) = @_;
  my $retval = $self->{client}->similar_row_from_id($name, $id, $size);
  return $retval;
}

sub similar_row_from_datum {
  my ($self, $name, $str_hash_ref, $num_hash_ref, $size) = @_;
  $str_hash_ref = {} unless (defined $str_hash_ref);
  $num_hash_ref = {} unless (defined $num_hash_ref);
  my $row = Jubatus::Common::Datum->new($str_hash_ref, $num_hash_ref);
  my $retval = $self->{client}->similar_row_from_datum($name, $row, $size);
  return $retval;
}

sub decode_row {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->decode_row($name, $id);
  return $retval;
}

sub get_all_rows {
  my ($self, $name) = @_;
  my $retval = $self->{client}->get_all_rows($name);
  return $retval;
}

sub calc_similarity {
  my ($self, $name, $lhs, $rhs) = @_;
  $lhs->[0] = {} unless (defined $lhs->[0]);
  $lhs->[1] = {} unless (defined $lhs->[1]);
  my $lrow = Jubatus::Common::Datum->new($lhs->[0], $lhs->[1]);
  $rhs->[0] = {} unless (defined $rhs->[0]);
  $rhs->[1] = {} unless (defined $rhs->[1]);
  my $rrow = Jubatus::Common::Datum->new($rhs->[0], $rhs->[1]);
  my $retval = $self->{client}->calc_similarity($name, $lrow, $rrow);
  return $retval;
}

sub calc_l2norm {
  my ($self, $name, $str_hash_ref, $num_hash_ref) = @_;
  $str_hash_ref = {} unless (defined $str_hash_ref);
  $num_hash_ref = {} unless (defined $num_hash_ref);
  my $row = Jubatus::Common::Datum->new($str_hash_ref, $num_hash_ref);
  my $retval = $self->{client}->calc_l2norm($name, $row);
  return $retval;
}

sub save {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->save($name, $id);
  return $retval;
}

sub load {
  my ($self, $name, $id) = @_;
  my $retval = $self->{client}->load($name, $id);
  return $retval;
}

sub get_status {
  my ($self, $name) = @_;
  my $retval = $self->{client}->get_status($name);
  return $retval;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Recommender - Perl interface of Jubatus::Recommender::Client

=head1 SYNOPSIS

    use Jubatus;

    my $cluster_name = "jubatus_perl_doc";
    # even if it isn't in a distributed environment using ZooKeeper and Jubatus keepers.

    my $host_name_or_ip_address = "localhost"; # master node's
    my $port_number_of_juba_process = 13714; # meanless

    my $juba_client_type = "recommender";
    # you can select from (recommender|regression|classifier|stat|graph|anomaly|nearestneighbor)

    my $reco_client = Jubatus->get_client($host_name_or_ip_address, $port_number_of_juba_process, $juba_client_type);
    # got Jubatus::Recommender::Client object

    # In the following example, get maximum value from sample array using Jubatus::Recommender::Client object

    my $is_clear = $reco_client->clear($cluster_name);

    {
        my $row_id = "red";
        my $string_values = [["name", "red"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($cluster_name, $row_id, $datum);
    }
    {
        my $row_id = "blue";
        my $string_values = [["name", "blue"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($cluster_name, $row_id, $datum);
    }
    {
        my $row_id = "cyan";
        my $string_values = [["name", "cyan"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($cluster_name, $row_id, $datum);
    }
    {
        my $row_id = "magenta";
        my $string_values = [["name", "magenta"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 0.0], ["B", 255.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($cluster_name, $row_id, $datum);
    }
    {
        my $row_id = "yellow";
        my $string_values = [["name", "yellow"], ["image", "warm"],];
        my $num_values = [["R", 255.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);
        my $is_update = $reco_client->update_row($cluster_name, $row_id, $datum);
    }
    {
        my $row_id = "green";
        my $string_values = [["name", "green"], ["image", "cold"],];
        my $num_values = [["R", 0.0], ["G", 255.0], ["B", 0.0]];
        my $datum = Jubatus::Recommender::Datum->new($string_values, $num_values);

        my $max_result_num = 10;
        my $similar_row = $reco_client->similar_row_from_datum($cluster_name, $datum, $max_result_num);
        # return cyan, yellow, blue

        my $is_update = $reco_client->update_row($cluster_name, $row_id, $datum);
    }
    {
        my $similar_row = $reco_client->similar_row_from_id($cluster_name, "green", $max_result_num);
        # return green, cyan, yellow, blue
    }

=head1 DESCRIPTION

This module provide a interface of recommendation server 'jubarecommender' by TCP-based MessagePack RPC protocol using L<AnyEvent::MPRPC::Client>

=head1 METHODS

Jubatus::Recommender::Client provide many methods.

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Recommender::Client->new($host, $port);

This code will create Jubatus::Recommender::Client object and return it.
You should set $host and $port in agreement to running jubastat server application.

    use Jubatus::Recommender::Client;
    my $host = 'localhost';
    my $port = '13714';
    my $obj = Jubatus::Recommender::Client->new($host, $port);

The above code is equivalent to:

    use Jubatus;
    my $host = 'localhost';
    my $port = '13714';
    my $juba_client_type = 'recommender';
    my $reco_client = Jubatus->get_client($host, $port, $juba_client_type);

See L<Jubatus> for more detail.

=head1 FUNCTIONS

=head3 get_client()

Returns the reference to the Jubatus::Recommender::Client object which has a "client"
field. This field is a reference of AnyEvent::MPRPC::Client object to call a raw
MessagePack-RPC client instance which is used by Jubatus client libraries. The
functions of Jubatus::Recommender::Client are wrapper of AnyEvent::MPRPC::Client.

Input:

    - None

Output:

    - Jubatus::Recommender::Client object - Return a Jubatus::Recommender::Client object
      Which is used ad MessagePack-RPC client instance of jubarecommender server.

=head3 get_config($cluster_name)

Returns a server configuration from a server which is belonging to the
cluster which execute the $cluster_name tasks.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

Output:

    - JSON file formated string - Returns a server configuration from a server.
      This configuration is same as the configuration file which was assigned
      when you start the jubarecommender server.

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
