# This file is auto-generated from regression.idl
# *** DO NOT EDIT ***

package Jubatus::Regression::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Regression::Types;

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
  my ($self, $name, $train_data) = @_;
  my $retval = $self->{client}->call('train' => [ $name, $train_data ] )->recv;
  return $retval;
}

sub estimate {
  my ($self, $name, $estimate_data) = @_;
  my $retval = $self->{client}->call('estimate' => [ $name,
       $estimate_data ] )->recv;
  return [ map { $_} @{ $retval } ];
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
1
__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Regression::Client - Perl extension for interfacing with linear
 regression server 'jubaregression'

=head1 SYNOPSIS

    use Jubatus;

    my $cluster_name = "jubatus_perl_doc";
    # even if it isn't in a distributed environment using ZooKeeper and Jubatus keepers.

    my $host_name_or_ip_address = "localhost"; # master node's
    my $port_number_of_juba_process = 13714; # meanless

    my $juba_client_type = "regression";
    # you can select from (recommender|regression|classifier|stat|graph|anomaly|nearestneighbor)

    my $regr_client = Jubatus->get_client($host_name_or_ip_address, $port_number_of_juba_process, $juba_client_type);
    # got Jubatus::Regression::Client object

    # In the following example, get maximum value from sample array using Jubatus::Regression::Client object

    my $is_clear = $regr_client->clear($cluster_name);

    # Origin of this sample data is https://raw.github.com/jubatus/jubatus-example/master/rent/dat/rent-data.csv
    my @sample = (
        "7.1 10.0 22.34 6.0 2.0 E",
        "8.0 10.0 38.29 45.0 4.0 SE",
        "4.5 26.0 18.23 24.0 2.0 W",
        "4.75 7.0 15.0 24.0 3.0 SW",
        "7.3 15.0 20.13 14.0 8.0 S",
        "8.6 22.0 36.54 9.0 2.0 E",
        "6.3 11.0 20.1 30.0 7.0 SE",
        "9.6 10.0 30.03 0.0 5.0 SW",
        "9.0 10.0 30.03 0.0 2.0 SE",
        "9.0 10.0 30.03 0.0 2.0 SE",
        "8.4 16.0 30.91 9.0 9.0 SE",
        "9.2 12.0 30.03 0.0 2.0 SE",
        "9.2 12.0 30.03 0.0 2.0 SE",
        "9.2 12.0 30.03 0.0 2.0 SE",
        "9.2 12.0 30.03 0.0 2.0 SE",
        "8.8 10.0 30.03 0.0 1.0 W",
        "5.05 7.0 15.0 24.0 10.0 E",
        "5.05 7.0 15.0 24.0 10.0 E",
        "5.05 7.0 15.0 24.0 10.0 E",
        "5.05 7.0 15.0 24.0 10.0 E",
        "6.0 15.0 29.48 24.0 4.0 NW",
        "9.7 3.0 36.94 11.0 5.0 NW",
        "9.22 10.0 30.03 0.0 2.0 SE",
        "4.7 9.0 14.62 28.0 5.0 E",
        "6.6 5.0 22.26 22.0 5.0 E",
        "5.9 8.0 21.56 23.0 4.0 NE",
        "5.9 8.0 21.56 23.0 4.0 NE",
        "4.7 9.0 14.62 28.0 5.0 NE",
        "12.3 8.0 40.12 9.0 7.0 SE",
        "4.5 20.0 16.25 23.0 3.0 SW",
        "9.2 10.0 30.03 0.0 4.0 SE",
        "6.9 7.0 22.83 25.0 4.0 SW",
        "5.8 2.0 17.24 29.0 9.0 E",
        "6.1 5.0 20.43 22.0 3.0 SE",
        "9.6 35.0 35.39 6.0 2.0 SW",
        "9.6 10.0 30.03 0.0 5.0 SE",
        "9.5 6.0 31.1 7.0 8.0 SW",
        "7.8 15.0 23.37 5.0 10.0 NW",
        "6.3 7.0 24.39 25.0 7.0 SE",
        "4.7 1.0 16.35 21.0 4.0 SE",
        "9.4 12.0 30.03 0.0 4.0 SE",
        "9.4 10.0 30.03 0.0 4.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "9.3 10.0 30.03 0.0 3.0 SE",
        "5.8 1.0 17.16 29.0 9.0 E",
        "4.85 7.0 15.0 24.0 8.0 E",
        "4.85 7.0 15.0 24.0 8.0 E",
        "4.85 7.0 15.0 24.0 8.0 E",
        "4.85 7.0 15.0 24.0 8.0 E",
        "4.85 7.0 15.0 24.0 8.0 E",
        "6.4 9.0 28.3 28.0 6.0 E",
        "7.3 15.0 20.13 14.0 8.0 SE",
        "7.8 5.0 25.03 6.0 2.0 SW",
        "7.8 5.0 25.03 6.0 2.0 SW",
        "7.2 25.0 25.33 23.0 3.0 SE",
        "7.67 7.0 30.0 24.0 9.0 E",
        "7.67 7.0 30.0 24.0 9.0 E",
        "7.67 7.0 30.0 24.0 9.0 E",
        "6.5 7.0 24.39 25.0 7.0 SE",
        "4.75 7.0 15.0 24.0 3.0 W",
        "7.5 25.0 22.82 23.0 4.0 SE",
        "7.5 25.0 22.82 23.0 4.0 SE",
        "5.3 7.0 18.07 25.0 06.0 SE",
        "9.0 11.0 31.8 12.0 3.0 SE",
        "7.3 12.0 23.09 12.0 3.0 S",
        "5.5 1.0 17.59 29.0 8.0 S",
        "9.2 10.0 30.03 0.0 2.0 SW",
        "9.2 10.0 30.03 0.0 2.0 SW",
        "6.3 8.0 21.56 23.0 2.0 N",
        "8.8 10.0 30.03 0.0 1.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "9.2 10.0 30.03 0.0 2.0 SE",
        "7.7 10.0 21.02 5.0 1.0 E",
        "7.2 10.0 18.75 5.0 1.0 SW",
        "7.2 10.0 18.75 5.0 1.0 SW",
        "7.2 10.0 18.75 5.0 1.0 SW",
        "7.7 10.0 18.75 5.0 1.0 W",
        "4.75 7.0 15.0 24.0 3.0 E",
        "4.75 7.0 15.0 24.0 3.0 E",
        "4.75 7.0 15.0 24.0 3.0 E",
        "4.75 7.0 15.0 24.0 3.0 E",
        "4.75 7.0 15.0 24.0 3.0 E",
        "5.6 20.0 21.14 7.0 3.0 SW",
        "12.0 10.0 40.12 9.0 7.0 SE",
        "10.6 3.0 37.18 11.0 9.0 NW",
        "4.95 7.0 15.0 24.0 10.0 E",
        "4.85 7.0 15.0 24.0 10.0 E",
        "4.85 7.0 15.0 24.0 10.0 E",
        "4.85 7.0 15.0 24.0 10.0 E",
        "5.05 7.0 15.0 24.0 10.0 SW",
        "9.5 5.0 30.0 13.0 8.0 NE",
        "7.7 10.0 18.75 5.0 1.0 SW",
        "9.3 12.0 30.03 0.0 3.0 SE",
        "9.3 12.0 30.03 0.0 3.0 SE",
        "9.3 12.0 30.03 0.0 3.0 SE",
        "9.3 12.0 30.03 0.0 3.0 SE",
        "9.3 12.0 30.03 0.0 3.0 SE",
        "4.7 10.0 14.62 28.0 5.0 E",
        "9.0 10.0 30.03 0.0 1.0 S",
        "9.0 10.0 30.03 0.0 1.0 S",
        "8.2 10.0 23.56 6.0 3.0 E",
        "7.2 4.0 16.0 5.0 2.0 S",
        "7.2 4.0 16.0 5.0 2.0 S",
        "4.85 7.0 15.0 24.0 9.0 SE",
        "6.6 5.0 22.26 22.0 5.0 SE",
        "9.0 10.0 30.03 0.0 1.0 SE",
        "9.0 10.0 30.03 0.0 1.0 SE",
        "9.0 10.0 30.03 0.0 1.0 SE",
        "9.0 10.0 30.03 0.0 1.0 SE",
        "9.0 10.0 30.03 0.0 1.0 SE",
        "8.3 9.0 32.18 24.0 3.0 S",
        "7.8 10.0 21.02 5.0 4.0 W",
        "6.8 25.0 25.33 23.0 3.0 SE",
        "9.1 10.0 30.03 0.0 3.0 SE",
        "9.1 10.0 30.03 0.0 3.0 SE",
        "7.5 10.0 21.02 5.0 4.0 SW",
        "8.3 9.0 32.18 24.0 3.0 E",
        "10.3 3.0 36.94 11.0 7.0 SE",
        "4.3 15.0 16.25 23.0 1.0 SW",
        "25.0 15.0 74.96 10.0 15.0 E",
        "4.6 17.0 16.32 18.0 4.0 SE",
        "4.2 15.0 16.94 26.0 4.0 SW",
        "6.5 5.0 22.83 25.0 4.0 NE",
        "5.9 8.0 21.56 23.0 4.0 SW",
    );

    my @data_arr = ();
    foreach my $data (@sample) {
        my @vals = split / /, $data;
        my $string_values = [["direction", "$vals[5]"],];
        my $num_values = [["walk_n_min", 0.0 + $vals[1]], ["area", 0.0 + $vals[2]], ["age", 0.0 + $vals[3]], ["floor", 0.0 + $vals[4]],];
        my $datum = Jubatus::Regression::Datum->new($string_values, $num_values);
        my $rent = 0.0 + $vals[0];
        my $data = [$rent, $datum->to_msgpack()];
        push @data_arr, $data;
    }

    my $is_train = $regr_client->train($cluster_name, \@data_arr);

    {
        my $string_values = [];
        my $num_values = [["walk_n_min", 5.0], ["area", 32.0], ["age", 15.0],];
        my $datum = Jubatus::Regression::Datum->new($string_values, $num_values);
        my $data = [$datum->to_msgpack()];
        my $estimate_result = $regr_client->estimate($cluster_name, $data);

        # $estimate_result is more than 8 or 9
    }

=head1 DESCRIPTION

This module provide a interface of recommendation server 'jubaregression' by TCP-based MessagePack RPC protocol using L<AnyEvent::MPRPC::Client>

=head1 METHODS

Jubatus::Regression::Client provide many methods.

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Regression::Client->new($host, $port);

This code will create Jubatus::Regression::Client object and return it.
You should set $host and $port in agreement to running jubastat server application.

    use Jubatus::Regression::Client;
    my $host = 'localhost';
    my $port = '13714';
    my $obj = Jubatus::Regression::Client->new($host, $port);

The above code is equivalent to:

    use Jubatus;
    my $host = 'localhost';
    my $port = '13714';
    my $juba_client_type = 'regression';
    my $regr_client = Jubatus->get_client($host, $port, $juba_client_type);

See L<Jubatus> for more detail.

=head1 FUNCTIONS

=head3 get_client()

Returns the reference to the Jubatus::Regression::Client object which has a "client"
field. This field is a reference of AnyEvent::MPRPC::Client object to call a raw
MessagePack-RPC client instance which is used by Jubatus client libraries. The
functions of Jubatus::Regression::Client are wrapper of AnyEvent::MPRPC::Client.

Input:

    - None

Output:

    - Jubatus::Regression::Client object - Return a Jubatus::Regression::Client object
      Which is used ad MessagePack-RPC client instance of jubaregression server.

=head3 get_config($cluster_name)

Returns a server configuration from a server which is belonging to the
cluster which execute the $cluster_name tasks.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

Output:

    - JSON file formated string - Returns a server configuration from a server.
      This configuration is same as the configuration file which was assigned
      when you start the jubaregression server.

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

