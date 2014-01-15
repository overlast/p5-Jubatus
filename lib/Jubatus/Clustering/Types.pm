# This file is auto-generated from clustering.idl(0.4.5-350-g9c67807) with jenerator version 0.4.5-532-g61b108e/develop
# *** DO NOT EDIT ***


package Jubatus::Clustering::WeightedDatum;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;
use Jubatus::Common::Datum;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([Jubatus::Common::TFloat->new(),
    Jubatus::Common::TDatum->new()]);

sub new {
  my ($self, $weight, $point) = @_;
  my %hash = (
    'weight' => $weight,
    'point' => $point,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{weight}, $self->{point}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $weighted_datum = Jubatus::Clustering::WeightedDatum->new(
      @{ $TYPE->from_msgpack($args) });
  return $weighted_datum;
}

sub to_s {
  my ($self, $weight, $point) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("weighted_datum");
  $gen->add("weight", $self->{weight});
  $gen->add("point", $self->{point});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Clustering::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1; # Jubatus::Clustering::Types;

