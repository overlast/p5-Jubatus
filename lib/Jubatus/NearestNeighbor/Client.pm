# This file is auto-generated from nearest_neighbor.idl(0.4.5-347-g86989a6) with jenerator version 0.4.5-532-g61b108e/develop
# *** DO NOT EDIT ***

package Jubatus::NearestNeighbor::Client;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use parent 'Jubatus::Common::Client';
require Jubatus::NearestNeighbor::Types;

sub clear {
  my ($self) = @_;
  return $self->_call("clear", Jubatus::Common::TBool->new(), [], []);
}

sub set_row {
  my ($self, $id, $d) = @_;
  return $self->_call("set_row", Jubatus::Common::TBool->new(), [$id, $d],
      [Jubatus::Common::TString->new(), Jubatus::Common::TDatum->new()]);
}

sub neighbor_row_from_id {
  my ($self, $id, $size) = @_;
  return $self->_call("neighbor_row_from_id", Jubatus::Common::TList->new(
      Jubatus::Common::TUserDef->new(Jubatus::NearestNeighbor::IdWithScore->new(
      ))), [$id, $size], [Jubatus::Common::TString->new(),
      Jubatus::Common::TInt->new(0, 4)]);
}

sub neighbor_row_from_data {
  my ($self, $query, $size) = @_;
  return $self->_call("neighbor_row_from_data", Jubatus::Common::TList->new(
      Jubatus::Common::TUserDef->new(Jubatus::NearestNeighbor::IdWithScore->new(
      ))), [$query, $size], [Jubatus::Common::TDatum->new(),
      Jubatus::Common::TInt->new(0, 4)]);
}

sub similar_row_from_id {
  my ($self, $id, $ret_num) = @_;
  return $self->_call("similar_row_from_id", Jubatus::Common::TList->new(
      Jubatus::Common::TUserDef->new(Jubatus::NearestNeighbor::IdWithScore->new(
      ))), [$id, $ret_num], [Jubatus::Common::TString->new(),
      Jubatus::Common::TInt->new(1, 4)]);
}

sub similar_row_from_data {
  my ($self, $query, $ret_num) = @_;
  return $self->_call("similar_row_from_data", Jubatus::Common::TList->new(
      Jubatus::Common::TUserDef->new(Jubatus::NearestNeighbor::IdWithScore->new(
      ))), [$query, $ret_num], [Jubatus::Common::TDatum->new(),
      Jubatus::Common::TInt->new(1, 4)]);
}

1;

1; # Jubatus::NearestNeighbor::Client;

