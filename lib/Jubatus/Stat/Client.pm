# This file is auto-generated from stat.idl(0.4.5-347-g86989a6) with jenerator version 0.4.5-532-g61b108e/develop
# *** DO NOT EDIT ***

package Jubatus::Stat::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use parent 'Jubatus::Common::Client';
require Jubatus::Stat::Types;

sub push {
  my ($self, $key, $value) = @_;
  return $self->_call("push", Jubatus::Common::TBool->new(), [$key, $value],
      [Jubatus::Common::TString->new(), Jubatus::Common::TFloat->new()]);
}

sub sum {
  my ($self, $key) = @_;
  return $self->_call("sum", Jubatus::Common::TFloat->new(), [$key],
      [Jubatus::Common::TString->new()]);
}

sub stddev {
  my ($self, $key) = @_;
  return $self->_call("stddev", Jubatus::Common::TFloat->new(), [$key],
      [Jubatus::Common::TString->new()]);
}

sub max {
  my ($self, $key) = @_;
  return $self->_call("max", Jubatus::Common::TFloat->new(), [$key],
      [Jubatus::Common::TString->new()]);
}

sub min {
  my ($self, $key) = @_;
  return $self->_call("min", Jubatus::Common::TFloat->new(), [$key],
      [Jubatus::Common::TString->new()]);
}

sub entropy {
  my ($self, $key) = @_;
  return $self->_call("entropy", Jubatus::Common::TFloat->new(), [$key],
      [Jubatus::Common::TString->new()]);
}

sub moment {
  my ($self, $key, $degree, $center) = @_;
  return $self->_call("moment", Jubatus::Common::TFloat->new(), [$key, $degree,
      $center], [Jubatus::Common::TString->new(), Jubatus::Common::TInt->new(1,
      4), Jubatus::Common::TFloat->new()]);
}

sub clear {
  my ($self) = @_;
  return $self->_call("clear", Jubatus::Common::TBool->new(), [], []);
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
    # you can select from (recommender|regression|classifier|stat|graph|anomaly|nearestneighbor)

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
You should set $host and $port in agreement to running jubastat server application.

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

=head3 get_client()

Returns the reference to the Jubatus::Stat::Client object which has a "client"
field. This field is a reference of AnyEvent::MPRPC::Client object to call a raw
MessagePack-RPC client instance which is used by Jubatus client libraries. The
functions of Jubatus::Stat::Client are wrapper of AnyEvent::MPRPC::Client.

Input:

    - None

Output:

    - Jubatus::Stat::Client object - Return a Jubatus::Stat::Client object
      Which is used ad MessagePack-RPC client instance of jubastat server.

=head3 get_config($cluster_name)

Returns a server configuration from a server which is belonging to the
cluster which execute the $cluster_name tasks.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

Output:

    - JSON file formated string - Returns a server configuration from a server.
      This configuration is same as the configuration file which was assigned
      when you start the jubastat server.

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

1; # Jubatus::Stat::Client;

