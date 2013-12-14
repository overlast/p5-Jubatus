package Jubatus::Common::Exception;

use strict;
use warnings;
use utf8;
use autodie;

use parent 'Exception::Tiny';

use constant JUBATUS_DEBUG => $ENV{JUBATUS_DEBUG};
use Log::Minimal qw/debugf infof warnf critf/; # $ENV{LM_DEBUG}
local $Log::Minimal::AUTODUMP = 1;
local $Log::Minimal::COLOR = 1;
local $Log::Minimal::LOG_LEVEL = "DEBUG";

# It's used to show 'OtherException'
sub show {
    my ($e) = @_;
    warnf ($e) if (JUBATUS_DEBUG);
    return;
}

1;

package Jubatus::Common::TypeException;

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::Exception';

use constant JUBATUS_DEBUG => $ENV{JUBATUS_DEBUG};
use Log::Minimal qw/debugf infof warnf critf/; # $ENV{LM_DEBUG}
local $Log::Minimal::AUTODUMP = 1;
local $Log::Minimal::COLOR = 1;
local $Log::Minimal::LOG_LEVEL = "DEBUG";

# It's used to show 'TypeException'
sub show {
    my ($arr_ref) = @_;
    my ($value, $type) = @{$arr_ref};
    warnf ("Type %s is expected, but %s is given", $value, $type) if (JUBATUS_DEBUG);
    return;
}

1;

package Jubatus::Common::ValueException;

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::Exception';

use constant JUBATUS_DEBUG => $ENV{JUBATUS_DEBUG};
use Log::Minimal qw/debugf infof warnf critf/; # $ENV{LM_DEBUG}
local $Log::Minimal::AUTODUMP = 1;
local $Log::Minimal::COLOR = 1;
local $Log::Minimal::LOG_LEVEL = "DEBUG";

# It's used to show 'ValueException'
sub show {
    my ($arr_ref) = @_;
    my ($value, $min, $max, $type) = @{$arr_ref};
    if ($type) {
        warnf ("%s value must be in (%d, %d), but %s is given", $value, $min, $max, $type) if (JUBATUS_DEBUG);
    } else {
        warnf ("Value %s is expected, but %s is given", $value, $type) if (JUBATUS_DEBUG);
    }
    return;
}

1;

package Jubatus::Common::ValuePairException;

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::Exception';

use constant JUBATUS_DEBUG => $ENV{JUBATUS_DEBUG};
use Log::Minimal qw/debugf infof warnf critf/; # $ENV{LM_DEBUG}
local $Log::Minimal::AUTODUMP = 1;
local $Log::Minimal::COLOR = 1;
local $Log::Minimal::LOG_LEVEL = "DEBUG";

# It's used to show 'ValuePairException'
sub show {
    my ($arr_ref) = @_;
    my ($num1, $num2, $type) = @{$arr_ref};
    if (($type) && ($num1) && ($num2)) {
        warnf ("Two of %s values should have same number elements ,but (%d, %d) are given", $type, $num1, $num2) if (JUBATUS_DEBUG);
    }
    return;
}

1;

package Jubatus::Common::Types;

use strict;
use warnings;
use utf8;
use autodie;

use B;
use Try::Lite;

# Make check the matching of a label of $value object and a string of $type
sub check_type {
    my ($value, $type) = @_;
    my $is_valid = 0;
    eval {
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            if (ref $value eq $type) {
            } else {
                my $flags = B::svref_2object( \$value )->FLAGS;
                if (($type eq "Integer") && ($flags & B::SVf_IOK || $flags & B::SVp_IOK)) {
                } elsif (($type eq "Float") && ($flags & B::SVf_NOK || $flags & B::SVp_NOK)) {
                } elsif (($type eq "String") && ($flags & B::SVf_POK)) {
                } elsif (($type eq "Bool") && ($flags & B::SVf_POK)) {
                } elsif (($type eq "Array") && (ref $value eq "ARRAY")) {
                } elsif (($type eq "Hash") && (ref $value eq "HASH")) {
                } else {
                    Jubatus::Common::TypeException->throw([ref $value, $type]);
                }
            }
            $is_valid = 1; # a label of $value object and string of $type is matching
        } {
            # Catch the thrown error in the above lines
            'Jubatus::Common::TypeException' => sub {Jubatus::Common::TypeException::show($@)},
        }
    };
    if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
    return $is_valid;
}

# Make check the matching of a label of $value object and each string value of type in $types
sub check_types {
    my ($value, $types) = @_;
    my $is_valid = 0;
    foreach my $type (@{$types}) {
        # Call check_type() to compare $value and $type
        $is_valid = check_type($value, $type);
        if ($is_valid) {
            last; # a label of $value object and string of $type is matching
        }
    }
    return $is_valid;
}

sub check_bound {
    my ($value, $max, $min, $type) = @_;
    my $is_valid = 0;
    eval {
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            if (($type eq "Integer") && ($min <= $value) && ($value <= $max)) {
            } elsif (($type eq "Bool") && (("1" eq $value) || ("0" eq $value))) {
            } else {
                Jubatus::Common::TypeException->throw([$value, $max, $min, $type]);
            }
            $is_valid = 1; # a label of $value object and string of $type is matching
        } {
            # Catch the thrown error in the above lines
            'Jubatus::Common::TypeException' => sub {Jubatus::Common::TypeException::show($@)},
        }
    };
    if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
    return $is_valid;
}

sub compare_element_num {
    my ($value1, $value2, $type) = @_;
    my $is_valid = 0;
    eval {
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            if ($type eq "Array") {
                unless ($#{$value1} == $#{$value2}) {
                    Jubatus::Common::ValuePairException->throw([$#{$value1}, $#{$value2}, $type]);
                }
            } elsif ($type eq "Hash") {
                unless ( scalar(keys %{$value1}) == scalar(keys %{$value2})) {
                    Jubatus::Common::ValuePairException->throw([scalar(keys %{$value1}), scalar(keys %{$value2}), $type]);
                }
            }
            $is_valid = 1; # a label of $value object and string of $type is matching
        } {
            # Catch the thrown error in the above lines
            'Jubatus::Common::TypeException' => sub {Jubatus::Common::TypeException::show($@)},
        }
    };
    if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
    return $is_valid;
}

1;

package Jubatus::Common::TPrimitive;
# A parent class of the T* classes

use strict;
use warnings;
use utf8;
use autodie;

# Constructor of J::C::TPrimitive
# Second argument $types should be an array reference
sub new {
    my ($class, $types) = @_;
    my $hash = {
        "types" => $types, # Use to check a type label of given object
    };
    bless $hash, $class;
}

# Only check the matching of a label of $m object and one of string values in $self->{types} array reference
sub from_msgpack {
    my ($self, $m) = @_;
    my $is_valid = Jubatus::Common::Types::check_types($m, $self->{types});
    return $m;
}

# Only check the matching of a label of $m object and one of string values in $self->{types} array reference
sub to_msgpack {
    my ($self, $m) = @_;
    my $is_valid = Jubatus::Common::Types::check_types($m, $self->{types});
    return $m;
}

1;

package Jubatus::Common::TInt;
# Integer value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Constructor of J::C::TInt
sub new {
    my ($class, $signed, $bytes) = @_;
    my $hash = {};
    $hash->{type} = "Integer";
    if ($signed) { # signed integer
        $hash->{max} = (1 << (8 * $bytes - 1)) - 1;
        $hash->{min} = - (1 << (8 * $bytes - 1));
    } else { # unsigned integer
        $hash->{max} = (1 << (8 * $bytes)) - 1;
        $hash->{min} = 0;
    }
    bless $hash, $class;
}

sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of IV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type);
    if ($is_valid_type) { # Check of the lower bound and the upper bound
        my $is_valid_bound = Jubatus::Common::Types::check_bound($m, $self->{max}. $self->{min}, $type);
    }
    return $m;
}

sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of IV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type);
    if ($is_valid_type) { # Check of the lower bound and the upper bound
        my $is_valid_bound = Jubatus::Common::Types::check_bound($m, $self->{max}. $self->{min}, $type);
    }
    return $m;
}

1;

package Jubatus::Common::TFloat;
# Float value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Constructor of J::C::TFloat
sub new {
    my ($class) = @_;
    my $hash = {};
    $hash->{type} = "Float";
    bless $hash, $class;
}

# Only check the matching of NV flags of $m object and the string value of $type
sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    return $m;
}

# Only check the matching of NV flags of $m object and the string value of $type
sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    return $m;
}

1;

package Jubatus::Common::TString;
# String value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Constructor of J::C::TString
sub new {
    my ($class) = @_;
    my $hash = {};
    $hash->{type} = "String";
    bless $hash, $class;
}

# Only check the matching of PV flags of $m object and the string value of $type
sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    return $m;
}

# Only check the matching of PV flag of $m object and the string value of $type
sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    return $m;
}

1;

package Jubatus::Common::TRaw;
# Raw value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TString';

1;

package Jubatus::Common::TBool;
# Boolean value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Constructor of J::C::TBool
sub new {
    my ($class) = @_;
    my $hash = {};
    $hash->{type} = "Bool";
    bless $hash, $class;
}

sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of PV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    if ($is_valid_type) { # Check of $m is "0" as the false value or "1" as the true value
        my $is_valid_bound = Jubatus::Common::Types::check_bound($m, 1, 0, $type);
    }
    return $m;
}

sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of PV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    if ($is_valid_type) { # Check of $m is "0" as the false value or "1" as the true value
        my $is_valid_bound = Jubatus::Common::Types::check_bound($m, 1, 0, $type);
    }
    return $m;
}

1;

package Jubatus::Common::TDatum;
# Datum value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

use Jubatus::Common::Datum;

# Constructor of J::C::TString
sub new {
    my ($class) = @_;
    my $hash = {};
    $hash->{type} = "Jubatus::Common::Datum";
    bless $hash, $class;
}

# Only return an unpacked value of $m message pack object
sub from_msgpack {
    my ($self, $m) = @_;
    return Jubatus::Common::Datum->from_msgpack($m);
}

# Check the matching of a label of $m object and the string value of $type
sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    # Return an packed value of $m using message pack protocol
    return $m->to_msgpack();
}

1;

package Jubatus::Common::TNullable;
# Nullable value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Constructor of J::C::TNullable
# Second argument must be a type string of an object which will use to call the methods of this class
sub new {
    my ($class, $type) = @_;
    my $hash = {};
    $hash->{type} = $type;
    bless $hash, $class;
}

# Call from_msgpack() which belong to Jubatus::Common::$type
sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $result = undef;
    if (!(defined $m)) {
    } else {
        eval { $result = "Jubatus::Common::$type"->from_msgpack($m); };
        if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
    }
    return $result;
}
# Call to_msgpack() which belong to Jubatus::Common::$type
sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $result = undef;
    if (!(defined $m)) {
    } else {
        eval { $result = "Jubatus::Common::$type"->to_msgpack($m); };
        if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
    }
    return $result;
}

1;

package Jubatus::Common::TList;
# List value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Constructor of J::C::TList
# Second argument must be a type string of an object which will use to call the methods of this class
sub new {
    my ($class, $type) = @_;
    my $hash = {};
    $hash->{type} = $type;
    bless $hash, $class;
}

# Call from_msgpack() which belong to Jubatus::Common::$type
sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $result = [];
    # Check a data type of $m to push the data to an array reference
    my $is_valid_type = Jubatus::Common::Types::check_types($m, "Array");
    if ($is_valid_type) { # If $m is Array reference value
        foreach my $v (@{$m}) {
            eval {
                my $tmp = "Jubatus::Common::$type"->from_msgpack($v);
                push @{$result}, $tmp;
            };
            if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
        }
    }
    return $result; # Return an array reference
}

# Call to_msgpack() which belong to Jubatus::Common::$type
sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $result = [];
    # Check a data type of $m to push the data to an array reference
    my $is_valid_type = Jubatus::Common::Types::check_types($m, "Array");
    if ($is_valid_type) { # If $m is Array reference value
        foreach my $v (@{$m}) {
            eval {
                my $tmp = "Jubatus::Common::$type"->to_msgpack($v);
                push @{$result}, $tmp;
            };
            if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
        }
    }
    return $result; # Return an array reference
}

1;

package Jubatus::Common::TMap;
# Map value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Constructor of J::C::TMap
# Second argument must be a type string of an object which will use to call the methods of this class
sub new {
    my ($class, $key_type, $value_type) = @_;
    my $hash = {};
    $hash->{key_type} = $key_type;
    $hash->{value_type} = $value_type;
    bless $hash, $class;
}

# Call from_msgpack() which belong to Jubatus::Common::$type
sub from_msgpack {
    my ($self, $m) = @_;
    my $key_type = $self->{key_type};
    my $value_type = $self->{value_type};
    my $result = {};
    # Check a data type of $m to push the data to an array reference
    my $is_valid_type = Jubatus::Common::Types::check_types($m, "Hash");
    if ($is_valid_type) { # If $m is hash reference value
        foreach my $key (keys %{$m}) {
            eval {
                $result->{"Jubatus::Common::$key_type"->from_msgpack($key)} = "Jubatus::Common::$key_type"->from_msgpack($m->{$key});
            };
            if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
        }
    }
    return $result; # Return an hash reference
}

# Call to_msgpack() which belong to Jubatus::Common::$type
sub to_msgpack {
    my ($self, $m) = @_;
    my $key_type = $self->{key_type};
    my $value_type = $self->{value_type};
    my $result = {};
    # Check a data type of $m to push the data to an array reference
    my $is_valid_type = Jubatus::Common::Types::check_types($m, "Hash");
    if ($is_valid_type) { # If $m is hash reference value
        foreach my $key (keys %{$m}) {
            eval {
                $result->{"Jubatus::Common::$key_type"->to_msgpack($key)} = "Jubatus::Common::$key_type"->to_msgpack($m->{$key});
            };
            if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
        }
    }
    return $result; # Return an hash reference
}

1;

package Jubatus::Common::TTuple;
# Map value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

use List::MoreUtils;

# Constructor of J::C::TTuple
# Second argument must be an array reference of the type strings
sub new {
    my ($class, $types) = @_;
    my $hash = {};
    $hash->{types} = $types if Jubatus::Common::Types::check_type($types, "Array");
    bless $hash, $class;
}

sub check_tuple {
    my ($self, $m) =  @_;
    my $is_valid = 0;
    my $types = $self->{types};
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Array");
    if ($is_valid_type) {
        if ($#$m != $#$types) {
            Jubatus::Common::ValuePairException->show($#$m, $#$types, "Array");
        } else {
            $is_valid = 1;
        }
    }
    return $is_valid;
}

# Call from_msgpack() which belong to Jubatus::Common::$type
sub from_msgpack {
    my ($self, $m) = @_;
    my $types = $self->{types};
    # Check a data type and matching of the elements numbers of $m and $type
    my $is_valid_tuple = $self->check_tuple($m);
    my $result = [];
    if ($is_valid_tuple) {
        # Make type and value pairs
        my @zipped = map {[$types->[$_], $m->[$_]]} (0 .. $#$m);
        eval {
            foreach my $pair (@zipped) {
                my ($type, $value) = @{$pair};
                push @{$result}, "Jubatus::Common::$type"->from_msgpack($value);
            }
        };
        if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
    }
    return $result; # Return an hash reference
}

# Call to_msgpack() which belong to Jubatus::Common::$type
sub to_msgpack {
    my ($self, $m) = @_;
    my $types = $self->{types};
    # Check a data type and matching of the elements numbers of $m and $type
    my $is_valid_tuple = $self->check_tuple($m);
    my $result = [];
    if ($is_valid_tuple) {
        # Make type and value pairs
        my @zipped = map {[$types->[$_], $m->[$_]]} (0 .. $#$m);
        eval {
            foreach my $pair (@zipped) {
                my ($type, $value) = @{$pair};
                push @{$result}, "Jubatus::Common::$type"->to_msgpack($value);
            }
        };
        if ($@) { Jubatus::Common::Exception::show($@); } # Catch the re-thrown exception
    }
    return $result; # Return an hash reference
}

1;


=pod

class TUserDef
  def initialize(type)
    @type = type
  end

  def from_msgpack(m)
    return @type.from_msgpack(m)
  end

  def to_msgpack(m)
    if @type === m
      return m.to_msgpack()
    elsif Array === m
      return @type::TYPE.to_msgpack(m)
    else
      raise TypeError, "type %s or Array are expected, but %s is given" % [@type, m.class]
    end
  end
end

class TObject
  def from_msgpack(m)
    return m
  end

  def to_msgpack(m)
    return m
  end
end

class TEnum
  def initialize(values)
    @values = values
  end

  def from_msgpack(m)
    Jubatus::Common.check_type(m, Integer)
    if not (@values.include?(m))
      raise ValueError
    end
    return m
  end

  def to_msgpack(m)
    Jubatus::Common.check_type(m, Integer)
    if not (@values.inlcude?(m))
      raise ValueError
    end
    return m
  end
end

end
end


=cut


__END__

=pod

=encoding utf-8

=head1 NAME

Jubatus::Common::Types - Perl interface of Jubatus::Common::Types

=head1 SYNOPSIS

    use Jubatus::Common::Types;

=head1 DESCRIPTION

This module provide a interface of

=head1 METHODS

Jubatus::Common::Types provide

=head2 Constructors

This constructors can die when invalid parameters are given.

=head3 Jubatus::Common::Types->new();

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
