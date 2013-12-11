package Jubatus::Common::Exception;

use strict;
use warnings;
use utf8;
use autodie;

use parent 'Exception::Tiny';

1;

package Jubatus::Common::TypeException;

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::Exception';

1;

package Jubatus::Common::ValueException;

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::Exception';

1;

package Jubatus::Common::Types;

use strict;
use warnings;
use utf8;
use autodie;

sub check_type {
    my ($value, $type) = @_;
    my $is_valid = 0;
    return $is_valid;
}

sub check_types {
    my ($value, $types) = @_;
    my $is_valid = 0;
    return $is_valid;
}

1;

=pod

def self.check_type(value, typ)
  if not (typ === value)
    raise TypeError, "type %s is expected, but %s is given" % [typ, value.class]
  end
end

def self.check_types(value, types)
  types.each do |t|
    return if t === value
  end
  t = types.map { |t| t.to_s }.join(", ")
  raise TypeError, "type %s is expected, but %s is given" % [t, value.class]
end

1;


module Jubatus
module Common

class TypeError < Exception; end
class ValueError < Exception; end

def self.check_type(value, typ)
  if not (typ === value)
    raise TypeError, "type %s is expected, but %s is given" % [typ, value.class]
  end
end

def self.check_types(value, types)
  types.each do |t|
    return if t === value
  end
  t = types.map { |t| t.to_s }.join(", ")
  raise TypeError, "type %s is expected, but %s is given" % [t, value.class]
end

class TPrimitive
  def initialize(types)
    @types = types
  end

  def from_msgpack(m)
    Jubatus::Common.check_types(m, @types)
    return m
  end

  def to_msgpack(m)
    Jubatus::Common.check_types(m, @types)
    return m
  end
end

class TInt < TPrimitive
  def initialize(signed, byts)
    if signed
      @max = (1 << (8 * byts - 1)) - 1
      @min = - (1 << (8 * byts - 1))
    else
      @max = (1 << (8 * byts)) - 1
      @min = 0
    end
  end

  def from_msgpack(m)
    Jubatus::Common.check_type(m, Integer)
    if not (@min <= m and m <= @max)
      raise ValueError, "int value must be in (%d, %d), but %d is given" % [@min, @max, m]
    end
    return m
  end

  def to_msgpack(m)
    Jubatus::Common.check_type(m, Integer)
    if not (@min <= m and m <= @max)
      raise ValueError, "int value must be in (%d, %d), but %d is given" % [@min, @max, m]
    end
    return m
  end
end

class TFloat < TPrimitive
  def initialize
    super([Float])
  end
end

class TBool < TPrimitive
  def initialize
    super([TrueClass, FalseClass])
  end
end

class TString < TPrimitive
  def initialize()
    super([String])
  end
end

class TDatum
  def from_msgpack(m)
    Jubatus::Common::Datum.from_msgpack(m)
  end

  def to_msgpack(m)
    Jubatus::Common.check_type(m, Jubatus::Common::Datum)
    m.to_msgpack()
  end
end

class TRaw < TPrimitive
  def initialize()
    super([String])
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
