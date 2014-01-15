package Jubatus::Common::Datum;

use strict;
use warnings;
use utf8;
use autodie;

require Jubatus::Common::Types;
use Jubatus::Common::MessageStringGenerator;

our $TYPE = Jubatus::Common::TTuple->new([
    Jubatus::Common::TList->new(
        Jubatus::Common::TTuple->new([
            Jubatus::Common::TString->new(), Jubatus::Common::TString->new()])),
    Jubatus::Common::TList->new(
        Jubatus::Common::TTuple->new([
            Jubatus::Common::TString->new(), Jubatus::Common::TFloat->new()])),
    Jubatus::Common::TList->new(
        Jubatus::Common::TTuple->new([
            Jubatus::Common::TString->new(), Jubatus::Common::TRaw->new()])),
]);

sub new {
    my ($self, $label_value_pairs) = @_;
    my ($string_values, $num_values, $binary_values) = ([], [], []);
    # $self->hash_ref_to_array_ref($string_values),
    if ((defined $label_value_pairs) && (ref $label_value_pairs eq "ARRAY")) {
        for (my $i = 0; $i <= $#$label_value_pairs; $i++) {
            # $label_value_pairs->[$i] = [label(String), value(Any type)]
            my $type = Jubatus::Common::Types::estimate_type($label_value_pairs->[$i]->[1]);
            if ($type eq "String") {
                push @{$string_values}, $label_value_pairs->[$i];
            } elsif ($type eq "Integer") {
                my $tmp_float = [$label_value_pairs->[$i]->[0] , 1.1 + $label_value_pairs->[$i]->[1] - 1.1];
                push @{$num_values}, $tmp_float;
            } elsif ($type eq "Float") {
                push @{$num_values}, $label_value_pairs->[$i];
            } else {
                Jubatus::Common::TypeException->show([$label_value_pairs->[$i]->[1], $type]);
            }
        }
    } elsif ((defined $label_value_pairs) && (ref $label_value_pairs eq "HASH")) {
        foreach my $key (keys %{$label_value_pairs}) {
            # $label_value_pairs->[$i] = [label(String), value(Any type)]
            my $type = Jubatus::Common::Types::estimate_type($label_value_pairs->{$key});
            if ($type eq "String") {
                my $tmp_string = [$key, $label_value_pairs->{$key}];
                push @{$string_values}, $tmp_string;
            } elsif ($type eq "Integer") {
                my $tmp_float = [$key, 1.1 + $label_value_pairs->{$key} - 1.1];
                push @{$num_values}, $tmp_float;
            } elsif ($type eq "Float") {
                my $tmp_float = [$key, 1.1 + $label_value_pairs->{$key} - 1.1];
                push @{$num_values}, $tmp_float;
            } else {
                Jubatus::Common::TypeException->show([$label_value_pairs->{$key}, $type]);
            }
        }
    }
    my %hash = (
        'type' => "Jubatus::Common::Datum",
        'string_values' => $string_values,
        'num_values' => $num_values,
        'binary_values' => $binary_values,
    );
    bless \%hash, $self;
}

sub add_string {
    my ($self, $key, $value) = @_;
    my $done_add = 0;
    if (Jubatus::Common::Type::check_type($key, "String")) {
        if (Jubatus::Common::Type::check_type($value, "String")) {
            push @{$self->{string_values}}, [$key, $value];
            $done_add = 1;
        }
    }
    return $done_add;
}

sub add_number {
    my ($self, $key, $value) = @_;
    my $done_add = 0;
    if (Jubatus::Common::Type::check_type($key, "String")) {
        my $value_type = (Jubatus::Common::Type::estimate_type($value));
        if ($value_type eq "Float") {
            push @{$self->{num_values}}, [$key, $value];
            $done_add = 1;
        } elsif ($value_type eq "Integer") {
            push @{$self->{num_values}}, [$key, 1.1 + $value - 1.1];
            $done_add = 1;
        }
    }
    return $done_add;
}

sub add_binary {
    my ($self, $key, $value) = @_;
    my $done_add = 0;
    if (Jubatus::Common::Type::check_type($key, "String")) {
        if (Jubatus::Common::Type::check_type($value, "String")) {
            push @{$self->{binary_values}}, [$key, $value];
            $done_add = 1;
        }
    }
    return $done_add;
}

sub to_msgpack {
    my ($self) = @_;
    return [
        $self->{string_values},
        $self->{num_values},
        $self->{binary_values},
    ];
}

sub from_msgpack {
    my ($self, $arg) = @_;
    my $value = $TYPE->from_msgpack($arg);
    my $datum = Jubatus::Common::Datum->new();
    $datum->{string_values} = $value->[0];
    $datum->{num_values} = $value->[1];
    $datum->{binary_values} = $value->[2];
    return $datum;
}

sub to_s {
    my ($self) = @_;
    my $gen = Jubatus::Common::MessageStringGenerator->new();
    $gen->open_buf("datum");
    $gen->add_buf("string_values", $self->{string_values});
    $gen->add_buf("num_values", $self->{num_values});
    $gen->add_buf("binary_values", $self->{binary_values});
    $gen->close_buf();
    return $gen->to_str();
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
