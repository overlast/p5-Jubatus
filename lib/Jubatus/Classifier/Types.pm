# This file is auto-generated from classifier.idl
# *** DO NOT EDIT ***


package Jubatus::Classifier::Datum;

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
  my $datum = Jubatus::Classifier::Datum->new([ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[0] } ], [ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[1] } ]);
  return $datum;
}

1;

package Jubatus::Classifier::EstimateResult;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

sub new {
  my ($self, $label, $score) = @_;
  my $mp = Data::MessagePack->new();
  my %hash = (
    'mp' => $mp,
    'label' => $label,
    'score' => $score,
  );
  bless $self, \%hash;
}

sub to_msgpack {
  my ($self) = @_;
  return [ 
        $self->{label},
        $self->{score},
   ];
}

sub from_msgpack {
  my ($self, $arg) = @_;
  my $estimate_result = Jubatus::Classifier::EstimateResult->new($arg->[0],
       $arg->[1]);
  return $estimate_result;
}

1;

package Jubatus::Classifier::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1;

