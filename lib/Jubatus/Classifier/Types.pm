# This file is auto-generated from classifier.idl(0.4.5-347-g86989a6) with jenerator version 0.4.5-532-g61b108e/develop
# *** DO NOT EDIT ***

package Jubatus::Classifier::EstimateResult;

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
  my ($self, $label, $score) = @_;
  my %hash = (
    'label' => $label,
    'score' => $score,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{label}, $self->{score}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $estimate_result = Jubatus::Classifier::EstimateResult->new(
      @{ $TYPE->from_msgpack($args) });
  return $estimate_result;
}

sub to_s {
  my ($self, $label, $score) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("estimate_result");
  $gen->add("label", $self->{label});
  $gen->add("score", $self->{score});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Classifier::LabeledDatum;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;
use Jubatus::Common::Datum;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([Jubatus::Common::TString->new(),
    Jubatus::Common::TDatum->new()]);

sub new {
  my ($self, $label, $data) = @_;
  my %hash = (
    'label' => $label,
    'data' => $data,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{label}, $self->{data}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $labeled_datum = Jubatus::Classifier::LabeledDatum->new(
      @{ $TYPE->from_msgpack($args) });
  return $labeled_datum;
}

sub to_s {
  my ($self, $label, $data) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("labeled_datum");
  $gen->add("label", $self->{label});
  $gen->add("data", $self->{data});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Classifier::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1; # Jubatus::Classifier::Types;

