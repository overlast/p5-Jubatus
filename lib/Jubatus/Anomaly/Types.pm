# This file is auto-generated from anomaly.idl
# *** DO NOT EDIT ***


package Jubatus::Anomaly::Datum;

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
  my $datum = Jubatus::Anomaly::Datum->new([ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[0] } ], [ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[1] } ]);
  return $datum;
}

1;

package Jubatus::Anomaly::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1;

