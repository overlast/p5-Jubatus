# This file is auto-generated from graph.idl
# *** DO NOT EDIT ***


package Jubatus::Graph::Node;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

sub new {
  my ($self, $property, $in_edges, $out_edges) = @_;
  my $mp = Data::MessagePack->new();
  my %hash = (
    'mp' => $mp,
    'property' => $property,
    'in_edges' => $in_edges,
    'out_edges' => $out_edges,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return [ 
        $self->{property},
        $self->{in_edges},
        $self->{out_edges},
   ];
}

sub from_msgpack {
  my ($self, $arg) = @_;
  my $node = Jubatus::Graph::Node->new($arg->[0], [ map { $_} @{ $arg->[1] } ],
       [ map { $_} @{ $arg->[2] } ]);
  return $node;
}

1;

package Jubatus::Graph::PresetQuery;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

sub new {
  my ($self, $edge_query, $node_query) = @_;
  my $mp = Data::MessagePack->new();
  my %hash = (
    'mp' => $mp,
    'edge_query' => $edge_query,
    'node_query' => $node_query,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return [ 
        $self->{edge_query},
        $self->{node_query},
   ];
}

sub from_msgpack {
  my ($self, $arg) = @_;
  my $preset_query = Jubatus::Graph::PresetQuery->new([ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[0] } ], [ map {  [ $_->[0],
       $_->[1] ] } @{ $arg->[1] } ]);
  return $preset_query;
}

1;

package Jubatus::Graph::Edge;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

sub new {
  my ($self, $property, $source, $target) = @_;
  my $mp = Data::MessagePack->new();
  my %hash = (
    'mp' => $mp,
    'property' => $property,
    'source' => $source,
    'target' => $target,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return [ 
        $self->{property},
        $self->{source},
        $self->{target},
   ];
}

sub from_msgpack {
  my ($self, $arg) = @_;
  my $edge = Jubatus::Graph::Edge->new($arg->[0], $arg->[1], $arg->[2]);
  return $edge;
}

1;

package Jubatus::Graph::ShortestPathQuery;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

sub new {
  my ($self, $source, $target, $max_hop, $query) = @_;
  my $mp = Data::MessagePack->new();
  my %hash = (
    'mp' => $mp,
    'source' => $source,
    'target' => $target,
    'max_hop' => $max_hop,
    'query' => $query,
  );
  bless \%hash, $self;
}

sub to_msgpack {
  my ($self) = @_;
  return [ 
        $self->{source},
        $self->{target},
        $self->{max_hop},
        $self->{query},
   ];
}

sub from_msgpack {
  my ($self, $arg) = @_;
  my $shortest_path_query = Jubatus::Graph::ShortestPathQuery->new($arg->[0],
       $arg->[1], $arg->[2], Jubatus::Graph::PresetQuery->from_msgpack(
      $arg->[3]));
  return $shortest_path_query;
}

1;

package Jubatus::Graph::Types;

use strict;
use warnings;
use utf8;
use autodie;
use AnyEvent::MPRPC;

1;

