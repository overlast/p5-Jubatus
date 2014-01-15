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
    my ($self, $e) = @_;
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
    my ($self, $arr_ref) = @_;
    my ($value_str, $type_str) = @{$arr_ref};
    warnf ("Type %s is expected, but %s is given", $type_str, $value_str) if (JUBATUS_DEBUG);
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
    my ($self, $arr_ref) = @_;
    my ($value_str, $min, $max, $type_str) = @{$arr_ref};
    if ($type_str) {
        warnf ("%s value must be in (%d, %d), but %s is given", $value_str, $min, $max, $type_str) if (JUBATUS_DEBUG);
    } else {
        warnf ("Value %s is expected, but %s is given", $value_str, $type_str) if (JUBATUS_DEBUG);
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
    my ($self, $arr_ref) = @_;
    my ($num1, $num2, $type_str) = @{$arr_ref};
    if (($type_str) && ($num1) && ($num2)) {
        warnf ("Two of %s values should have same number elements ,but (%d, %d) are given", $type_str, $num1, $num2) if (JUBATUS_DEBUG);
    }
    return;
}

1;

package Jubatus::Common::NotFoundException;

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
    my ($self, $arr_ref) = @_;
    my ($data, $value_str, $type_str) = @{$arr_ref};
    if (($data) && ($value_str) && ($type_str)) {
        if (JUBATUS_DEBUG) {
            warnf ("%s object should contain %s in data", $type_str, $value_str);
            warnf ("data : $data");
        }
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

use constant JUBATUS_DEBUG => $ENV{JUBATUS_DEBUG};
use Log::Minimal qw/debugf infof warnf critf/; # $ENV{LM_DEBUG}
local $Log::Minimal::AUTODUMP = 1;
local $Log::Minimal::COLOR = 1;
local $Log::Minimal::LOG_LEVEL = "DEBUG";

# Make check the matching of a label of $value object and a string of $type
sub estimate_type {
    my ($value, $caller) = @_;
    my $type;  # a label of $value object and string of $type is matching
    eval {
        infof $caller if (JUBATUS_DEBUG);
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            my $flags = B::svref_2object( \$value )->FLAGS;
            if (ref $value eq "ARRAY") {
                $type = "Array";
            } elsif (ref $value eq "HASH") {
                $type = "Hash";
            } elsif ($flags & B::SVf_NOK || $flags & B::SVp_NOK) {
                $type = "Float";
            } elsif ($flags & B::SVf_IOK || $flags & B::SVp_IOK) {
                $type = "Integer";
            } elsif ($flags & B::SVf_POK) {
                $type = "String";
            } elsif (ref $value ne "") {
                $type = ref $value;
            } else {
                Jubatus::Common::TypeException->throw("data" => [ref $value, "Something type"]);
            }
        } (
            # Catch the thrown error in the above lines
            'Jubatus::Common::TypeException' => sub {
                my $data = ${$@}->{data};
                Jubatus::Common::TypeException->show($data);
            },
        ),
    };
    if ($@) { Jubatus::Common::Exception->show($@); } # Catch the re-thrown exception
    return $type;
}

# Make check the matching of a label of $value object and a string of $type
sub check_type {
    my ($value, $type, $caller) = @_;
    my $is_valid = 1;  # a label of $value object and string of $type is matching
    eval {
        infof "$caller" if (JUBATUS_DEBUG);
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            if (ref $value eq $type) {
            } else {
                my $flags = B::svref_2object( \$value )->FLAGS;
                if (($type eq "Integer") && ($flags & B::SVf_IOK || $flags & B::SVp_IOK)) {
                } elsif (($type eq "Float") && ($flags & B::SVf_NOK || $flags & B::SVp_NOK)) {
                } elsif (($type eq "String") && ($flags & B::SVf_POK)) {
                } elsif (($type eq "Bool") && ((($flags & B::SVf_POK) && ("1" eq $value) || ("0" eq $value)) || (($flags & B::SVf_IOK || $flags & B::SVp_IOK) && (1 == $value) || (0 == $value)))) {
                } elsif (($type eq "Array") && (ref $value eq "ARRAY")) {
                } elsif (($type eq "Hash") && (ref $value eq "HASH")) {
                } else {
                    $is_valid = 0;
                    Jubatus::Common::TypeException->throw("data" => [ref $value, $type],);
                }
            }
        } (
            # Catch the thrown error in the above lines
            'Jubatus::Common::TypeException' => sub {
                my $data = ${$@}->{data};
                Jubatus::Common::TypeException->show($data);
            },
        );
    };
    if ($@) { $is_valid = 0; Jubatus::Common::Exception->show($@); } # Catch the re-thrown exception
    return $is_valid;
}

# Make check the matching of a label of $value object and each string value of type in $types
sub check_types {
    my ($value, $types, $caller) = @_;
    my $is_valid = 0;
    infof $caller if (JUBATUS_DEBUG);
    foreach my $type (@{$types}) {
        # Call check_type() to compare $value and $type
        $is_valid = check_type($value, $type, $caller);
        if ($is_valid) {
            last; # a label of $value object and string of $type is matching
        }
    }
    return $is_valid;
}

# Make check the matching of $value and $query_value
sub check_value {
    my ($value, $query_value, $type, $caller) = @_;
    my $is_valid = 1; # a label of $value object and string of $type is matching
    eval {
        infof $caller if (JUBATUS_DEBUG);
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            if (($type eq "Integer") && ($value == $query_value)){
            } elsif (($type eq "Float") && ($value == $query_value)) {
            } elsif (($type eq "String") && ($value eq $query_value)){
            } elsif (($type eq "Bool") && ($value eq $query_value)){
            } else {
                $is_valid = 0;
                Jubatus::Common::TypeException->throw("data" => [ref $value, $type],);
            }
        } (
            # Catch the thrown error in the above lines
            'Jubatus::Common::TypeException' => sub {
                my $data = ${$@}->{data};
                Jubatus::Common::TypeException->show($data);
            },
        );
    };
    if ($@) { $is_valid = 0; Jubatus::Common::Exception->show($@); } # Catch the re-thrown exception
    return $is_valid;
}

# Make check the matching one of value in a $values object and value of the target object
sub check_values {
    my ($values, $query_value, $type, $caller) = @_;
    my $is_valid = 1;
    eval {
        infof $caller if (JUBATUS_DEBUG);
        try {
            if (ref $values eq "ARRAY") {
                foreach my $value (@{$values}) {
                    # Call check_type() to compare $value and $type
                    $is_valid = check_value($value, $query_value, $type, $caller);
                    last if ($is_valid); # a label of $value object and string of $type is matching
                }
            } elsif (ref $values eq "HASH") {
                foreach my $key (keys @{$values}) {
                    my $value = $values->{$key};
                    # Call check_type() to compare $value and $type
                    $is_valid = check_value($value, $query_value, $type, $caller);
                    last if ($is_valid); # a label of $value object and string of $type is matching
                }
            } else {
                $is_valid = 0;
                Jubatus::Common::TypeException->throw("data" => [ref $values, "ARRAY or HASH"]);
            }
        } (
            "Jubatus::Common::TypeException" => sub {
                my $data = ${$@}->{data};
                Jubatus::Common::TypeException->show($data);
            },
        );
    };
    if ($@) { $is_valid = 0; Jubatus::Common::Exception->show($@); } # Catch the re-thrown exception
    return $is_valid;
}

sub check_bound {
    my ($value, $max, $min, $type, $caller) = @_;
    my $is_valid = 1; # a label of $value object and string of $type is matching
    eval {
        infof $caller if (JUBATUS_DEBUG);
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            if (($type eq "Integer") && ($min <= $value) && ($value <= $max)) {
            } elsif (($type eq "Bool") && (("1" eq $value) || ("0" eq $value))) {
            } else {
                $is_valid = 0;
                Jubatus::Common::ValueException->throw("data" => [ref $value, $max, $min, $type]);
            }
        } (
            # Catch the thrown error in the above lines
            'Jubatus::Common::ValueException' => sub {
                my $data = ${$@}->{data};
                Jubatus::Common::ValueException->show($data);
            },
        );
    };
    if ($@) { $is_valid = 0; Jubatus::Common::Exception->show($@); } # Catch the re-thrown exception
    return $is_valid;
}

sub compare_element_num {
    my ($value1, $value2, $type, $caller) = @_;
    my $is_valid = 1; # a label of $value object and string of $type is matching
    eval {
        infof $caller if (JUBATUS_DEBUG);
        try {
            # Throw a exception when a label of $value object and a string value of $type aren't matching
            if ($type eq "Array") {
                unless ($#{$value1} == $#{$value2}) {
                    $is_valid = 0;
                    Jubatus::Common::ValuePairException->throw("data" => [$#{$value1}, $#{$value2}, $type]);
                }
            } elsif ($type eq "Hash") {
                unless ( scalar(keys %{$value1}) == scalar(keys %{$value2})) {
                    $is_valid = 0;
                    Jubatus::Common::ValuePairException->throw("data" => [scalar(keys %{$value1}), scalar(keys %{$value2}), $type]);
                }
            } else {
                $is_valid = 0;
                Jubatus::Common::TypeException->throw("data" => [$type, "ARRAY or HASH"]);
            }
        } (
            # Catch the thrown error in the above lines
            'Jubatus::Common::ValuePairException' => sub {
                my $data = ${$@}->{data};
                Jubatus::Common::ValuePairException->show($data);
            },
        );
    };
    if ($@) { $is_valid = 0; Jubatus::Common::Exception->show($@); } # Catch the re-thrown exception
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
    my $is_valid = Jubatus::Common::Types::check_types($m, $self->{types}, (caller 0));
    return $m;
}

# Only check the matching of a label of $m object and one of string values in $self->{types} array reference
sub to_msgpack {
    my ($self, $m) = @_;
    my $is_valid = Jubatus::Common::Types::check_types($m, $self->{types}, (caller 0)."_".(caller 0)[3]);
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
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) { # Check of the lower bound and the upper bound
        my $is_valid_bound = Jubatus::Common::Types::check_bound($m, $self->{max}, $self->{min}, $type, (caller 0)."_".(caller 0)[3]);
    }
    return $m;
}

sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of IV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) { # Check of the lower bound and the upper bound
        my $is_valid_bound = Jubatus::Common::Types::check_bound($m, $self->{max}, $self->{min}, $type, (caller 0)."_".(caller 0)[3]);
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
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
    return $m;
}

# Only check the matching of NV flags of $m object and the string value of $type
sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
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
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
    return $m;
}

# Only check the matching of PV flag of $m object and the string value of $type
sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
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
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) { # Check of $m is "0" as the false value or "1" as the true value
        my $is_valid_bound = Jubatus::Common::Types::check_bound($m, 1, 0, $type, (caller 0)."_".(caller 0)[3]);
    }
    return $m;
}

sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    # Check the matching of PV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) { # Check of $m is "0" as the false value or "1" as the true value
        my $is_valid_bound = Jubatus::Common::Types::check_bound($m, 1, 0, $type, (caller 0)."_".(caller 0)[3]);
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

use parent -norequire, 'Jubatus::Common::Datum';

# sub new {}
# sub from_msgpack() {}

sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type}; # = "Jubatus::Common::Datum" which set on new()
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Array", (caller 0)."_".(caller 0)[3]);
    # Return an packed value of $m using message pack protocol
    return "$type"->from_msgpack($m);
}

# Check the matching of a label of $m object and the string value of $type
sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type}; # = "Jubatus::Common::Datum" which set on new()
    my $is_valid_type = Jubatus::Common::Types::check_type($m, $type, (caller 0)."_".(caller 0)[3]);
    # Return an packed value of $m using message pack protocol
    my $data = $m->to_msgpack();
    return $data;
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
        $result = $type->from_msgpack($m);
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
        $result = $type->to_msgpack($m);
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
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Array", (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) { # If $m is Array reference value
        foreach my $v (@{$m}) {
            my $tmp = $type->from_msgpack($v);
            push @{$result}, $tmp;
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
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Array", (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) { # If $m is Array reference value
        foreach my $v (@{$m}) {
            my $tmp = $type->to_msgpack($v);
            push @{$result}, $tmp;
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
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Hash", (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) { # If $m is hash reference value
        foreach my $key (keys %{$m}) {
            $result->{$key_type->from_msgpack($key)} = $value_type->from_msgpack($m->{$key});
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
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Hash", (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) { # If $m is hash reference value
        foreach my $key (keys %{$m}) {
            $result->{$key_type->to_msgpack($key)} = $value_type->to_msgpack($m->{$key});
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

# Constructor of J::C::TTuple
# Second argument must be an array reference of the type strings
sub new {
    my ($class, $types) = @_;
    my $hash = {};
    $hash->{types} = $types if Jubatus::Common::Types::check_type($types, "Array", (caller 0)."_".(caller 0)[3]);
    bless $hash, $class;
}

sub check_tuple {
    my ($self, $m) =  @_;
    my $is_valid = 0;
    my $types = $self->{types};
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Array", (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) {
        $is_valid = Jubatus::Common::Types::compare_element_num($m, $types, "Array", (caller 0)."_".(caller 0)[3]);
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
        for (my $i = 0; $i <= $#$m; $i++) {
            my $type = $types->[$i];
            my $value = $m->[$i];
            push @{$result}, $type->from_msgpack($value);
        }
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
        for (my $i = 0; $i <= $#$m; $i++) {
            my $type = $types->[$i];
            my $value = $m->[$i];
            push @{$result}, $type->to_msgpack($value);
        }
    }
    return $result; # Return an hash reference
}

1;

package Jubatus::Common::TObject;

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

# Non check returning
sub from_msgpack {
    my ($self, $m) = @_;
    return $m;
}

# Non check returning
sub to_msgpack {
    my ($self, $m) = @_;
    return $m;
}

1;


package Jubatus::Common::TEnum;
# Enum value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

use Try::Lite;

# Constructor of J::C::TEnum
sub new {
    my ($class, $values) = @_;
    my $hash = {};
    my $is_valid_type = Jubatus::Common::Types::check_type($values, "Array", (caller 0)."_".(caller 0)[3]);
    if ($is_valid_type) {
        foreach my $value (@{$values}) {
            my $is_valid_value = Jubatus::Common::Types::check_type($value, "Integer", (caller 0)."_".(caller 0)[3][3]);
            last unless ($is_valid_value);
        }
        $hash->{values} = $values;
    }
    bless $hash, $class;
}

sub from_msgpack {
    my ($self, $m) = @_;
    my $values = $self->{values};
    # Check the matching of IV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Integer", (caller 0)."_".(caller 0)[3]);
    my $is_found = 0;
    if ($is_valid_type) {
        $is_found = Jubatus::Common::Types::check_values($values, $m ,"Integer", (caller 0)."_".(caller 0)[3]);
    }
    return $m;
}

sub to_msgpack {
    my ($self, $m) = @_;
    my $values = $self->{values};
    # Check the matching of IV flags of $m object and the string value of $type
    my $is_valid_type = Jubatus::Common::Types::check_type($m, "Integer", (caller 0)."_".(caller 0)[3]);
    my $is_found = 0;
    if ($is_valid_type) {
        $is_found = Jubatus::Common::Types::check_values($values, $m ,"Integer", (caller 0)."_".(caller 0)[3]);
    }
    return $m;
}

1;

package Jubatus::Common::TUserDef;
# TUserDef value classes

use strict;
use warnings;
use utf8;
use autodie;

use parent -norequire, 'Jubatus::Common::TPrimitive';

use Try::Lite;

# Constructor of J::C::TUserDef
sub new {
    my ($class, $type) = @_;
    my $hash = {};
    $hash->{type} = $type;
    bless $hash, $class;
}

sub from_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $data = $m;
    my $sub_name = (caller 0)."_".(caller 0)[3];
    try {
        if (Jubatus::Common::Types::check_type($m, "Array", $sub_name)) {
            $data = $type->from_msgpack($m);
        } elsif (Jubatus::Common::Types::check_type($m, ref $type, $sub_name)) {
            $data = $type->from_msgpack($m);
        } else {
            Jubatus::Common::NotFoundException->throw("data" => [ref $m, $type]);
        }
    } (
        # Catch the thrown error in the above lines
        'Jubatus::Common::NotFoundException' => sub {
            my $data = ${$@}->{data};
            Jubatus::Common::NotFoundException->show($data);
        },
    );
    return $data;
}

sub to_msgpack {
    my ($self, $m) = @_;
    my $type = $self->{type};
    my $data = $m;
    my $sub_name = (caller 0)."_".(caller 0)[3];
    try {
        if (Jubatus::Common::Types::check_type($m, "Array", $sub_name)) {
            $data = $type->get_type()->to_msgpack($m);
        } elsif (Jubatus::Common::Types::check_type($m, ref $type, $sub_name)) {
            $data = $m->to_msgpack();
        } else {
            Jubatus::Common::NotFoundException->throw("data" => [ref $m, $type]);
        }
    } (
        # Catch the thrown error in the above lines
        'Jubatus::Common::NotFoundException' => sub {
            my $data = ${$@}->{data};
            Jubatus::Common::NotFoundException->show($data);
        },
    );
    return $data;
}

1;

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
