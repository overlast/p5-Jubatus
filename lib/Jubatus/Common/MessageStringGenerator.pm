package Jubatus::Common::MessageStringGenerator;

use strict;
use warnings;
use utf8;
use autodie;

our $OPEN = "{";
our $COLON = ": ";
our $DELIMITER = ", ";
our $CLOSE = "}";

# Constructor of J::C::MessageStringGenerator
sub new {
    my ($class) = @_;
    my $hash = {
        "buf" => [],
        "first" => "1",
    };
    bless $hash, $class;
}

# Initialize $self->{buffer} with type name and bracket character
sub open_buf {
    my ($self, $type) = @_;
    push @{$self->{buf}}, $type;
    push @{$self->{buf}}, $OPEN;
}

# Insert the key-value pairs to $self->{buffer}
sub add_buf {
    my ($self, $key, $value) = @_;
    if ((exists $self->{first}) && ($self->{first})) {
        $self->{first} = "0";
    } else {
        push @{$self->{buf}}, $DELIMITER;
    }
    push @{$self->{buf}}, "$key";
    push @{$self->{buf}}, $COLON;
    push @{$self->{buf}}, "$value";
}

# Finalize $self->{buffer} with bracket character
sub close_buf {
    my ($self) = @_;
    push @{$self->{buf}}, $CLOSE;
}

# Convert an array reference to a string value
sub to_str {
    my ($self) = @_;
    my $string = join "", @{$self->{buf}};
    return $string;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Common::MessageStringGenerator - Perl interface of Jubatus::Common::MessageStringGenerator

=head1 SYNOPSIS

    use Jubatus::Common::MessageStringGenerator;

=head1 DESCRIPTION

This module provide a interface of

=head1 METHODS

Jubatus::Common::MessageStringGenerator provide

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Common::MessageStringGenerator->new();

=head1 FUNCTIONS

=head3 get()

=head1 SEE ALSO

L<http://jubat.us/>
L<https://github.com/jubatus>
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
