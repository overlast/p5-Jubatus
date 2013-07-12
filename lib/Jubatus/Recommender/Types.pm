# This file is auto-generated from recommender.idl
# *** DO NOT EDIT ***


package Jubatus::Recommender::SimilarResult;

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

package Jubatus::Recommender::Datum;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

sub new {
  my ($self, $string_values, $num_values) = @_;
  my $mp = Data::MessagePack->new();
  my %hash = (
    'mp' => $mp,
    'string_values' => $string_values,
    'num_values' => $num_values,
  );
  bless $self, \%hash;
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
  my $datum = Jubatus::Recommender::Datum->new([ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[0] } ], [ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[1] } ]);
  return $datum;
}

1;

package Jubatus::Recommender::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1;

