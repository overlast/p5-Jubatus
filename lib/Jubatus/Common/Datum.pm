package Jubatus::Common::Datum;

use strict;
use warnings;
use utf8;
use autodie;

sub new {
  my ($self, $string_values, $num_values) = @_;
  my %hash = (
    'string_values' => $self->hash_ref_to_array_ref($string_values),
    'num_values' => $self->hash_ref_to_array_ref($num_values),
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
  my $datum = Jubatus::Common::Datum->new({ map { $_->[0] =>
       $_->[1] } @{ $arg->[0] } }, { map { $_->[0] =>
       $_->[1] } @{ $arg->[1] } });
  return $datum;
}

sub hash_ref_to_array_ref {
    my ($self, $hash_ref) = @_;
    my $array_ref = [];
    if ((defined $hash_ref) && (ref $hash_ref eq "HASH")) {
        foreach my $key (keys %{$hash_ref}) {
            my $value = $hash_ref->{$key};
            my $tmp_arr_ref = [$key, $value];
            push @{$array_ref}, $tmp_arr_ref;
        }
    }
    return $array_ref;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Common::Datum - Common data structure for each Perl client modules of
 Jubatus.

=head1 SYNOPSIS

    use Jubatus::Common::Datum;

    # or use Jubatus
    #
    # Jubatus.pm have the interfaces to use Jubatus::Common::Datum .

=head1 DESCRIPTION

This module provide the constructors and the methods to use interface of
each Perl client modules of Jubatus.

=head1 METHODS

Jubatus::Common::Datum will provide many packages and constructors, methods.
You can use these with Jubatus or Jubatus::***::Clients.

=head2 Packages

=head3 Jubatus::Common::Datum

If you want to use this package, all one need to do is write
 "use Jubatus::Common::Datum;" or "use Jubatus;".

=head4 Constructors

=head4 Jubatus::Common::Datum->new($string_values, $num_values);

Input:

    - $string_values is a hash reference.
      Each entries of this hash reference are String key and String value.

    - $num_values is a hash reference.
      Each entries of this hash reference are String key and Float value.

Output:

    - Jubatus::Common::Datum object.

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

    - Jubatus::Common::Datum object.

=head4 hash_ref_to_array_ref->($hash_ref)

Input:

      - $hash_ref is a hash reference.

      Each entries of this hash reference are String key and (String|Float)
      value.

Output:

      - An array reference of the array references

      This arrry references is allowed to locate many array references. Each
      of these array references should have two values which are called "key"
      and "value". The data type of key should be String. The data type
      of value should be String or Float.

=head1 SEE ALSO

L<Jubatus>

L<http://jubat.us/>
L<https://github.com/jubatus>

L<AnyEvent::MPRPC>
L<AnyEvent::MPRPC::Client>
L<http://msgpack.org/>
L<http://wiki.msgpack.org/display/MSGPACK/RPC+specification>

L<https://github.com/overlast/p5-Jubatus>

=head1 LICENSE

The MIT License (MIT)

Copyright (c) 2013 by Toshinori Sato (@overlast).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut
