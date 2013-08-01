# This file is auto-generated from nearest_neighbor.idl
# *** DO NOT EDIT ***

package Jubatus::NearestNeighbor::NeighborResult;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

sub from_msgpack {
  my ($self, $arg) = @_;
  return [ map {  [ $_->[0], $_->[1] ] } @{ $arg } ]
}

1;

package Jubatus::NearestNeighbor::Datum;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

sub new {
  my ($self, $string_values, $num_values) = @_;
  my %hash = (
    'string_values' => $string_values,
    'num_values' => $num_values,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return [ 
        $self->{string_values},
        $self->{num_values},
   ];
}

sub from_msgpack {
  my ($self, $arg) = @_;
  my $datum = Jubatus::NearestNeighbor::Datum->new([ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[0] } ], [ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[1] } ]);
  return $datum;
}

1;

package Jubatus::NearestNeighbor::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1;

