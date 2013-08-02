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

__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Recommender::Types - Perl extension for treating a data structure
to use interface of recommendation server 'jubarecommender'

=head1 SYNOPSIS

    use Jubatus::Recommender::Types;

    # If you want to any Jubatus::Recommender::* packages,
    # all one need to do is write "use Jubatus::Recommender::Types;"

=head1 DESCRIPTION

This module provide the constructors and the methods to use interface of
recommendation server 'jubarecommender'.

=head1 METHODS

Jubatus::Recommender::Types will provide many packages and constructors, methods.
These are used in Jubatus::Recommender::Clients.

See L<Jubatus::Recommender::Client> for more detail.

=head2 Packages

=head3 Jubatus::Recommender::Datum

If you want to use this package, all one need to do is write "use Jubatus::Recommender::Types;"

=head4 Constructors

=head4 Jubatus::Recommender::Datum->new($string_values, $num_values);

Input:

    - $string_values is a array reference which are allowed to locate many array
      references. Each of located arrry references should have two string
      value which are called "key" and "value".

    - $num_values is a array reference which are allowed to locate many array
      references. Each of located arrry references should have two values.
      First string value which are called "key" and second float value which
      are called "value".

Output:

    - Jubatus::Recommender::Datum object.

      This object have two fields.
      'string_values' field locate the array reference which was inputed as
      $string_values in constructor.
      'num_values' field locate the array reference which was inputed as
      $num_values in constructor.

=head4 Functions

=head4 to_msgpack->()

Input:

    - None

Output:

    - A array reference

      This array reference locate $string_values and $num_values which are given
      in constructor.

      This array reference certainly locate two array references. First
      reference are allowed to locate many array references. Each of located
      arrry references should have two string value which are called "key"
      and "value". Second reference are allowed to locate many array references.
      Each of located arrry references should have two values. First string
      value which are called "key" and second float value which are called
      "value".

=head4 from_msgpack->($return_value_from_msgpack)

Input:

    - $return_value_from_msgpack is a array reference.

      This array reference certainly locate two array references. First
      reference are allowed to locate many array references. Each of located
      arrry references should have two string value which are called "key"
      and "value". Second reference are allowed to locate many array references.
      Each of located arrry references should have two values. First string
      value which are called "key" and second float value which are called
      "value".

Output:

    - Jubatus::Recommender::Datum object.

=head3 Jubatus::Recommender::SimilarResult

If you want to use this package, all one need to do is write "use Jubatus::Recommender::Types;"

=head4 Functions

=head4 from_msgpack->($return_value_from_msgpack)

Input:

    - $return_value_from_msgpack is a array reference.

      This array reference certainly locate one of array reference. This
      reference are allowed to locate many array references. Each of located
      arrry references should have more than two values. First is string
      value which are called "id" and second is float value which are called
     "score".

Output:

    - A Array reference

      This array reference certainly locate one of array reference. This
      reference are allowed to locate many array references. Each of located
      arrry references should have two values. First is string value which
      are called "id" and second is float value which are called "score".

=head1 SEE ALSO

L<Jubatus::Recommender::Client>

L<http://jubat.us/>
L<https://github.com/jubatus>

L<AnyEvent::MPRPC>
L<AnyEvent::MPRPC::Client>
L<http://msgpack.org/>
L<http://wiki.msgpack.org/display/MSGPACK/RPC+specification>

L<https://github.com/overlast/p5-Jubatus>

=head1 LICENSE

Copyright (C) 2013 by Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

The licence of Jubatus is LGPL 2.1.

    Jubatus: Online machine learning framework for distributed environment
    Copyright (C) 2011,2012 Preferred Infrastructure and Nippon Telegraph and Telephone Corporation.

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License version 2.1 as published by the Free Software Foundation.

However Jubatus.pm and Jubatus::*.pm is the pure Perl modules.
Therefor the licence of Jubatus.pm and Jubatus::*.pm is the Perl's licence.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut

