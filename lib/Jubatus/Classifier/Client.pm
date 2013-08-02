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

__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Classifier::Client - Perl extension for interfacing with classification server 'jubaclassifier'

=head1 SYNOPSIS

    use Jubatus;

    my $cluster_name = "jubatus_perl_doc";
    # even if it isn't in a distributed environment using ZooKeeper and Jubatus keepers.

    my $host_name_or_ip_address = "localhost"; # master node's
    my $port_number_of_juba_process = 13714; # meanless

    my $juba_client_type = "classifier";
    # you can select from (recommender|regression|classifier|stat|graph|anomaly|nearestneighbor)

    my $clas_client = Jubatus->get_client($host_name_or_ip_address, $port_number_of_juba_process, $juba_client_type);
    # got Jubatus::Classifier::Client object

    # In the following example, get maximum value from sample array using Jubatus::Classifier::Client object

    my $is_clear = $clas_client->clear($cluster_name);

    # Origin of this sample data is http://jubat.us/ja/tutorial/classifier_python.html#id2
    my @sample = (
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家康"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "秀忠"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家光"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家綱"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "綱吉"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家宣"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家継"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "吉宗"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家重"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家治"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家斉"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家慶"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家定"]], [])->to_msgpack()],
        ["徳川",  Jubatus::Classifier::Datum->new([["name", "家茂"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "尊氏"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義詮"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義満"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義持"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義量"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義教"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義勝"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義政"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義尚"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義稙"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義澄"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義稙"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義晴"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義輝"]], [])->to_msgpack()],
        ["足利",  Jubatus::Classifier::Datum->new([["name", "義栄"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "時政"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "義時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "泰時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "経時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "時頼"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "長時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "政村"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "時宗"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "貞時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "師時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "宗宣"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "煕時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "基時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "高時"]], [])->to_msgpack()],
        ["北条",  Jubatus::Classifier::Datum->new([["name", "貞顕"]], [])->to_msgpack()],
    );
    @sample = List::Util::shuffle @sample;

    my $is_train = $clas_client->train($cluster_name, \@sample);

    my @answer_arr = (
        ["徳川", Jubatus::Classifier::Datum->new([["name", "慶喜"]], [])->to_msgpack()],
        ["足利", Jubatus::Classifier::Datum->new([["name", "義昭"]], [])->to_msgpack()],
        ["北条", Jubatus::Classifier::Datum->new([["name", "守時"]], [])->to_msgpack()],
    );

    foreach my $answer (@answer_arr) {
        my $data = [$answer->[1]];
        my $classified_result = $clas_client->classify($cluster_name, $data);
        my $max_att = 0;
        for (my $i = 1; $i <= $#{$classified_result->[0]}; $i++) {
            if ($classified_result->[0][$i - 1]{score} < $classified_result->[0][$i]{score}) {
                $max_att = $i;
            }
        }

        # $answer->[0] equal $classified_result->[0][$max_att]{label}
    }


=head1 DESCRIPTION

This module provide a interface of recommendation server 'jubaclassifier' by TCP-based MessagePack RPC protocol using L<AnyEvent::MPRPC::Client>

=head1 METHODS

Jubatus::Classifier::Client provide many methods.

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Classifier::Client->new($host, $port);

This code will create Jubatus::Classifier::Client object and return it.
You should set $host and $port in agreement to running jubastat server application.

    use Jubatus::Classifier::Client;
    my $host = 'localhost';
    my $port = '13714';
    my $obj = Jubatus::Classifier::Client->new($host, $port);

The above code is equivalent to:

    use Jubatus;
    my $host = 'localhost';
    my $port = '13714';
    my $juba_client_type = 'classifier';
    my $clas_client = Jubatus->get_client($host, $port, $juba_client_type);

See L<Jubatus> for more detail.

=head1 FUNCTIONS

=head3 get_client()

Returns the reference to the Jubatus::Classifier::Client object which has a "client"
field. This field is a reference of AnyEvent::MPRPC::Client object to call a raw
MessagePack-RPC client instance which is used by Jubatus client libraries. The
functions of Jubatus::Classifier::Client are wrapper of AnyEvent::MPRPC::Client.

Input:

    - None

Output:

    - Jubatus::Classifier::Client object - Return a Jubatus::Classifier::Client object
      Which is used ad MessagePack-RPC client instance of jubaclassifier server.

=head3 get_config($cluster_name)

Returns a server configuration from a server which is belonging to the
cluster which execute the $cluster_name tasks.

Input:

    - $cluster_name - String value to uniquely identify a task in the ZooKeeper
      cluster

Output:

    - JSON file formated string - Returns a server configuration from a server.
      This configuration is same as the configuration file which was assigned
      when you start the jubaclassifier server.

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

