# This file is auto-generated from anomaly.idl(0.4.5-347-g86989a6) with jenerator version 0.4.5-532-g61b108e/develop
# *** DO NOT EDIT ***

package Jubatus::Anomaly::IdWithScore;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;
use Jubatus::Common::Datum;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([Jubatus::Common::TString->new(),
    Jubatus::Common::TFloat->new()]);

sub new {
  my ($self, $id, $score) = @_;
  my %hash = (
    'id' => $id,
    'score' => $score,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{id}, $self->{score}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $id_with_score = Jubatus::Anomaly::IdWithScore->new(
      @{ $TYPE->from_msgpack($args) });
  return $id_with_score;
}

sub to_s {
  my ($self, $id, $score) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("id_with_score");
  $gen->add("id", $self->{id});
  $gen->add("score", $self->{score});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Anomaly::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1; # Jubatus::Anomaly::Types;

