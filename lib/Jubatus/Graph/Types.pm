# This file is auto-generated from graph.idl(0.4.5-347-g86989a6) with jenerator version 0.4.5-532-g61b108e/develop
# *** DO NOT EDIT ***


package Jubatus::Graph::Node;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;
use Jubatus::Common::Datum;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([Jubatus::Common::TMap->new(
    Jubatus::Common::TString->new(), Jubatus::Common::TString->new()),
    Jubatus::Common::TList->new(Jubatus::Common::TInt->new(0, 8)),
    Jubatus::Common::TList->new(Jubatus::Common::TInt->new(0, 8))]);

sub new {
  my ($self, $property, $in_edges, $out_edges) = @_;
  my %hash = (
    'property' => $property,
    'in_edges' => $in_edges,
    'out_edges' => $out_edges,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{property}, $self->{in_edges}, $self->{out_edges}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $node = Jubatus::Graph::Node->new( @{ $TYPE->from_msgpack($args) });
  return $node;
}

sub to_s {
  my ($self, $property, $in_edges, $out_edges) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("node");
  $gen->add("property", $self->{property});
  $gen->add("in_edges", $self->{in_edges});
  $gen->add("out_edges", $self->{out_edges});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Graph::Query;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;
use Jubatus::Common::Datum;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([Jubatus::Common::TString->new(),
    Jubatus::Common::TString->new()]);

sub new {
  my ($self, $from_id, $to_id) = @_;
  my %hash = (
    'from_id' => $from_id,
    'to_id' => $to_id,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{from_id}, $self->{to_id}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $query = Jubatus::Graph::Query->new( @{ $TYPE->from_msgpack($args) });
  return $query;
}

sub to_s {
  my ($self, $from_id, $to_id) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("query");
  $gen->add("from_id", $self->{from_id});
  $gen->add("to_id", $self->{to_id});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Graph::PresetQuery;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;
use Jubatus::Common::Datum;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([Jubatus::Common::TList->new(
    Jubatus::Common::TUserDef->new(Jubatus::Graph::Query->new())),
    Jubatus::Common::TList->new(Jubatus::Common::TUserDef->new(
    Jubatus::Graph::Query->new()))]);

sub new {
  my ($self, $edge_query, $node_query) = @_;
  my %hash = (
    'edge_query' => $edge_query,
    'node_query' => $node_query,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{edge_query}, $self->{node_query}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $preset_query = Jubatus::Graph::PresetQuery->new( @{ $TYPE->from_msgpack(
      $args) });
  return $preset_query;
}

sub to_s {
  my ($self, $edge_query, $node_query) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("preset_query");
  $gen->add("edge_query", $self->{edge_query});
  $gen->add("node_query", $self->{node_query});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Graph::Edge;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;
use Jubatus::Common::Datum;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([Jubatus::Common::TMap->new(
    Jubatus::Common::TString->new(), Jubatus::Common::TString->new()),
    Jubatus::Common::TString->new(), Jubatus::Common::TString->new()]);

sub new {
  my ($self, $property, $source, $target) = @_;
  my %hash = (
    'property' => $property,
    'source' => $source,
    'target' => $target,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{property}, $self->{source}, $self->{target}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $edge = Jubatus::Graph::Edge->new( @{ $TYPE->from_msgpack($args) });
  return $edge;
}

sub to_s {
  my ($self, $property, $source, $target) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("edge");
  $gen->add("property", $self->{property});
  $gen->add("source", $self->{source});
  $gen->add("target", $self->{target});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Graph::ShortestPathQuery;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;
use Jubatus::Common::Datum;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([Jubatus::Common::TString->new(),
    Jubatus::Common::TString->new(), Jubatus::Common::TInt->new(0, 4),
    Jubatus::Common::TUserDef->new(Jubatus::Graph::PresetQuery->new())]);

sub new {
  my ($self, $source, $target, $max_hop, $query) = @_;
  my %hash = (
    'source' => $source,
    'target' => $target,
    'max_hop' => $max_hop,
    'query' => $query,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return $TYPE->to_msgpack([
    $self->{source}, $self->{target}, $self->{max_hop}, $self->{query}
  ]);
}

sub from_msgpack {
  my ($self, $args) = @_;
  my $shortest_path_query = Jubatus::Graph::ShortestPathQuery->new(
      @{ $TYPE->from_msgpack($args) });
  return $shortest_path_query;
}

sub to_s {
  my ($self, $source, $target, $max_hop, $query) = @_;
  my $gen = Jubatus::Common::MessageStringGenerator->new();
  $gen->open("shortest_path_query");
  $gen->add("source", $self->{source});
  $gen->add("target", $self->{target});
  $gen->add("max_hop", $self->{max_hop});
  $gen->add("query", $self->{query});
  $gen->close();
  return $gen->to_s();
}

sub get_type {
  return $TYPE;
}

1;

package Jubatus::Graph::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1; # Jubatus::Graph::Types;

