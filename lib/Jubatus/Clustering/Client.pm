# This file is auto-generated from clustering.idl(0.4.5-350-g9c67807) with jenerator version 0.4.5-532-g61b108e/develop
# *** DO NOT EDIT ***

package Jubatus::Clustering::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use parent 'Jubatus::Common::Client';
require Jubatus::Clustering::Types;

sub push {
  my ($self, $points) = @_;
  return $self->_call("push", Jubatus::Common::TBool->new(), [$points],
      [Jubatus::Common::TList->new(Jubatus::Common::TDatum->new())]);
}

sub get_revision {
  my ($self) = @_;
  return $self->_call("get_revision", Jubatus::Common::TInt->new(0, 4), [], []);
}

sub get_core_members {
  my ($self) = @_;
  return $self->_call("get_core_members", Jubatus::Common::TList->new(
      Jubatus::Common::TList->new(Jubatus::Common::TUserDef->new(
      Jubatus::Clustering::WeightedDatum->new()))), [], []);
}

sub get_k_center {
  my ($self) = @_;
  return $self->_call("get_k_center", Jubatus::Common::TList->new(
      Jubatus::Common::TDatum->new()), [], []);
}

sub get_nearest_center {
  my ($self, $point) = @_;
  return $self->_call("get_nearest_center", Jubatus::Common::TDatum->new(),
      [$point], [Jubatus::Common::TDatum->new()]);
}

sub get_nearest_members {
  my ($self, $point) = @_;
  return $self->_call("get_nearest_members", Jubatus::Common::TList->new(
      Jubatus::Common::TUserDef->new(Jubatus::Clustering::WeightedDatum->new(
      ))), [$point], [Jubatus::Common::TDatum->new()]);
}

1;

1; # Jubatus::Clustering::Client;

