# This file is auto-generated from regression.idl(0.4.5-347-g86989a6) with jenerator version 0.4.5-532-g61b108e/develop
# *** DO NOT EDIT ***

package Jubatus::Regression::ScoredDatum;

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
  my ($self, $score, $data) = @_;
  my %hash = (
    'score' => $score,
    'data' => $data,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{score}, $self->{data}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $scored_datum = Jubatus::Regression::ScoredDatum->new(
      @{ $TYPE->from_msgpack($args) });
  return $scored_datum;
}

sub to_s {
  my ($self, $score, $data) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("scored_datum");
  $gen->add("score", $self->{score});
  $gen->add("data", $self->{data});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Regression::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1; # Jubatus::Regression::Types;

