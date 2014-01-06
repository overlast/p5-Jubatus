package Jubatus::Common::Client;

use strict;
use warnings;
use utf8;
use autodie;

use Try::Lite;
use AnyEvent::MPRPC;

use Jubatus::Common::Types;

sub new {
    my ($class, $host, $port, $name, $timeout) = @_;
    $timeout = 10 unless ((defined $timeout) && ($timeout >= 0));
    my $hash = {
        "host" => $host, # hostname of jubatus server
        "port" => $port, # port number of jubatus server
        "name" => $name, # name of jubatus application
        "client" => AnyEvent::MPRPC::Client->new( # MPRPC client
            'host' => $host,
            'port' => $port,
            "on_error" => sub { # to wrap an error handle
                my ($hdl, $fatal, $msg) = @_;
                $hdl->destroy;
                _error_handler($msg);
            },
            "timeout" => $timeout, # default time out = 10 sec
        ),
    };
    bless $hash, $class;
}

# Replace the naive error message with readable error message
sub _error_handler {
    my ($e) = @_;
    if ($e == 1) {
        Jubatus::Common::Exception->show("Unknown method exception : $e");
    } elsif ($e == 2) {
        Jubatus::Common::Exception->show("API mismatch exception : $e");
    } else {
        Jubatus::Common::Exception->show("Something RPC exception : $e");
    }
    return;
}

# Wrap AnyEvent::MPRPC::Client->call() to reduce $name from argument values
sub _call {
    my ($self, $method, $ret_type, $args, $arg_types) = @_;
    my $res;
    # Chek matching of argument types and the types of argument value
    if (Jubatus::Common::Types::compare_element_num($args, $arg_types, "Array")) {
        my $name = $self->{name} || "";
        my $values = [$name];
        for (my $i = 0; $i <= $#$args; $i++) { # zip()
            my $arg = $args->[$i];
            my $arg_type = $arg_types->[$i];
            push @{$values}, $arg_type->to_msgpack($arg); # to_msgpackがtype checkする
        }
        eval {
            try {
                # {client}->handler->**で諸々設定できる。
                my $retval = $self->{client}->call($method, $values)->recv;
                if ((defined $retval) && (defined $ret_type)) {
                    $res = $ret_type->from_msgpack($retval); # from_msgpackがtype checkする
                }
            } (
                "*" => sub { Jubatus::Common::Exception->show($@); },
            );
        }; if ($@) { Jubatus::Common::Exception->show($@); }
    }
    return $res;
}

# Get AnyEvent::MPRPC::Client instance
sub get_client {
    my ($self) = @_;
    return $self->{client};
}

# Get JSON configure data from Jubatus server
sub get_config {
    my ($self) = @_;
    my $retval = $self->_call("get_config",
                              Jubatus::Common::TString->new(),
                              [],
                              [],);
    return $retval;
}

# Get JSON status data from Jubatus server
sub get_status {
    my ($self) = @_;
    my $retval = $self->_call("get_status",
                              Jubatus::Common::TMap->new(
                                  Jubatus::Common::TString->new(),
                                  Jubatus::Common::TMap->new(
                                      Jubatus::Common::TString->new(),
                                      Jubatus::Common::TString->new(),
                                  ),
                              ),
                              [],
                              [],);
    return $retval;
}

# Dump the model data from current Jubatus server process
sub save {
    my ($self, $id) = @_;
    my $retval = $self->_call("save",
                              Jubatus::Common::TBool->new(),
                              [$id],
                              [Jubatus::Common::TString->new()]);
    return $retval;
}

# Load the model data to current Jubatus server process
sub load {
    my ($self, $id) = @_;
    my $retval = $self->_call("load",
                              Jubatus::Common::TBool->new(),
                              [$id],
                              [Jubatus::Common::TString->new()]);
    return $retval;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Common::Client - Perl interface of Jubatus::Common::Client

=head1 SYNOPSIS

    use Jubatus::Common::Client;

=head1 DESCRIPTION

This module provide a interface of

=head1 METHODS

Jubatus::Common::Client provide

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Common::Client->new();

=head1 FUNCTIONS

=head3 get()

=head1 SEE ALSO

L<http://jubat.us/>
L<https://github.com/jubatus>
L<https://github.com/overlast/p5-Jubatus>

=head1 LICENSE

The MIT License (MIT)

Copyright (c) 2013 by Toshinori Sato (@overlast).

_Permission is hereby granted, free of charge, to any person obtaining a copy
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
