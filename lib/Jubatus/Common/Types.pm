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
    my ($type, $value, $min, $max) = @{$arr_ref};
    if ($type) {
        warnf ("%s value must be in (%d, %d), but %d is given", $type, $min, $max, $value) if (JUBATUS_DEBUG);
    } else {
        warnf ("Value %s is expected, but %s is given", $value, $type) if (JUBATUS_DEBUG);
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
                } elsif (($type eq "Boolean") && ($flags & B::SVf_POK)) {
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
    my ($type, $value, $max, $min) = @_;
    my $is_valid = 0;
    eval {
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            if (($type eq "Integer") && ($min <= $value) && ($value <= $max)) {
            } elsif (($type eq "Boolean") && (("1" eq $value) || ("0" eq $value))) {
            } else {
                Jubatus::Common::TypeException->throw([$type, $value, $min, $max]);
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
        my $is_valid_bound = Jubatus::Common::Types::check_bound($type, $m, $self->{max}. $self->{min});
    }
    return $m;
}

sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of IV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type);
    if ($is_valid_type) { # Check of the lower bound and the upper bound
        my $is_valid_bound = Jubatus::Common::Types::check_bound($type, $m, $self->{max}. $self->{min});
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

package Jubatus::Common::TBoolean;
# Boolean value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Constructor of J::C::TBoolean
sub new {
    my ($class) = @_;
    my $hash = {};
    $hash->{type} = "Boolean";
    bless $hash, $class;
}

sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of PV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    if ($is_valid_type) { # Check of $m is "0" as the false value or "1" as the true value
        my $is_valid_bound = Jubatus::Common::Types::check_bound($type, $m);
    }
    return $m;
}

sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of PV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_types($m, $type);
    if ($is_valid_type) { # Check of $m is "0" as the false value or "1" as the true value
        my $is_valid_bound = Jubatus::Common::Types::check_bound($type, $m);
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

=pod

class TDatum
  def from_msgpack(m)

  end

  def to_msgpack(m)
    Jubatus::Common.check_type(m, Jubatus::Common::Datum)
    m.to_msgpack()
  end
end

class TNullable
  def initialize(type)
    @type = type
  end

  def from_msgpack(m)
    if m.nil?
      return nil
    else
      @type.from_msgpack(m)
    end
  end

  def to_msgpack(m)
    if m.nil?
      nil
    else
      @type.to_msgpack(m)
    end
  end
end

class TList
  def initialize(type)
    @type = type
  end

  def from_msgpack(m)
    Jubatus::Common.check_type(m, Array)
    return m.map { |v| @type.from_msgpack(v) }
  end

  def to_msgpack(m)
    Jubatus::Common.check_type(m, Array)
    return m.map { |v| @type.to_msgpack(v) }
  end
end

class TMap
  def initialize(key, value)
    @key = key
    @value = value
  end

  def from_msgpack(m)
    Jubatus::Common.check_type(m, Hash)
    dic = {}
    m.each do |k, v|
      dic[@key.from_msgpack(k)] = @value.from_msgpack(v)
    end
    return dic
  end

  def to_msgpack(m)
    Jubatus::Common.check_type(m, Hash)
    dic = {}
    m.each do |k, v|
      dic[@key.to_msgpack(k)] = @value.to_msgpack(v)
    end
    return dic
  end
end

class TTuple
  def initialize(*types)
    @types = types
  end

  def check_tuple(m)
    Jubatus::Common.check_type(m, Array)
    if m.size != @types.size
      raise TypeError, "size of tuple is %d, but %d is expected: %s" % [m.size, @types.size, m.to_s]
    end
  end

  def from_msgpack(m)
    check_tuple(m)
    tpl = []
    @types.zip(m).each do |type, x|
      tpl << type.from_msgpack(x)
    end
    return tpl
  end

  def to_msgpack(m)
    check_tuple(m)
    tpl = []
    @types.zip(m).each do |type, x|
      tpl << type.to_msgpack(x)
    end
    return tpl
  end
end

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
