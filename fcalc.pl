#!/usr/bin/env perl

# see https://en.wikipedia.org/wiki/Reverse_Polish_notation
# based on https://habr.com/ru/post/100869/ (russian)

use v5.26.0;
use warnings;
no warnings 'recursion';

my (@temp_stack, @main_stack, %work_mx, %ops, @primary_stack, $again);

my @mx_headrow = 
            qw[| + - * / ( )];
my %matrix = (
    '|' => [qw[4 1 1 1 1 1 5]],
    '+' => [qw[2 2 2 1 1 1 2]],
    '-' => [qw[2 2 2 1 1 1 2]],
    '*' => [qw[2 2 2 2 2 1 2]],
    '/' => [qw[2 2 2 2 2 1 2]],
    '(' => [qw[5 1 1 1 1 1 3]],
);
my %controls = map {$_ => 1} @mx_headrow;

for my $i (0..6) {
    for (@mx_headrow) {
        $work_mx{$mx_headrow[$i].$_} = $matrix{$_}->[$i];
    }
}

# calculations
# receiving two arrayrefs representing fractions
# doing apropriate math with fractions
# returning normalized arrayref as result
@ops{qw[+ - * /]} = (
    sub { 
        my $lcm = lcm($_[0]->[1], $_[1]->[1]);
        my $c = $_[0]->[0] * ($lcm / $_[0]->[1]) + $_[1]->[0] * ($lcm / $_[1]->[1]);
        my $gcd = gcd($c, $lcm);
        return [$c/$gcd, $lcm/$gcd];
    },
    sub { 
        my $lcm = lcm($_[0]->[1], $_[1]->[1]);
        my $c = $_[1]->[0] * ($lcm / $_[1]->[1]) - $_[0]->[0] * ($lcm / $_[0]->[1]);
        my $gcd = gcd($c, $lcm);
        return [$c/$gcd, $lcm/$gcd];
    },
    sub {
        my $c = $_[0]->[0] * $_[1]->[0];
        my $z = $_[0]->[1] * $_[1]->[1];
        my $gcd = gcd($c, $z);
        return [$c/$gcd, $z/$gcd];
    },
    sub {
        my $c = $_[1]->[0] * $_[0]->[1];
        my $z = $_[1]->[1] * $_[0]->[0];
        my $gcd = gcd($c, $z);
        return [$c/$gcd, $z/$gcd];
    },
);

# Least Common Multiple
sub lcm {
    my ($x, $y) = @_;
    return $x * $y / gcd($x, $y);
}

# Greatest Common Divisor
sub gcd {
    my ($x, $y) = map {abs} @_;
    return $x if $x == $y;
    return $y unless $x;
    return ($x >= $y) ? gcd($x-$y, $y) : gcd($x, $y-$x);
}

# main loop

say "Fractional calculator";
say "Fraction should be presented as `x:y`, operations: + - * /, for negation do like (0 - x:y)";
say "Example: (1:3 - 7:4) * 2:3 - (5:7 + 1:3) / 3:5";

while (1) {
    print '> ';
    my $in = <>; # get the input string
    
    $in    =~ s/\s*:\s*/:/g;                # normalizing input string:
    $in    =~ s/([()+*\/-])/ $1 /g;         # removing spaces around :, adding spaces around ops
    my @in =  map  { s/^0+(\d+):/$1:/r }    # parsing string into array
              map  { s/:0+$/:0/r }
              map  { /^\d+$/ ? $_.':1' : $_ }
              grep { length }
              split /\s+/, $in;
    @in or next;
    $again = 0; # if up - bad input, start main loop again
    for (@in) {
        unless(/^\d+:\d+$/ and $_ !~ /:0$/ or $controls{$_}) { # check for allowed tokens
            say "unknown token: $_";
            $again = 1; last;
        }
    }
    next if $again;
    # so @in contains allowed operations and fractions in x:y form
    # transform x:y str to arrayref [x, y] - prepare for calculations
    for (0..$#in) {
        $in[$_] = [split ':', $in[$_]] if $in[$_] =~ /:/;
    }
    
    # reorganizing @in to polish notation
    # based om article algorithm
    @temp_stack = qw(|);
    @main_stack = @primary_stack = qw();
    in: for my $t (@in, '|') {
        if ($controls{$t}) {
            for ($work_mx{$t.$temp_stack[$#temp_stack]}) { # just switch
                /1/ && do { push @temp_stack, $t };
                /2/ && do { push @main_stack, pop @temp_stack; redo in };
                /3/ && do { pop  @temp_stack };
                /5/ && do { say "wrong input $in"; $again = 1; last in };
            }
        } else {
            push @main_stack, $t;
        }
    }
    next if $again;
    
    # main calc loop - populating primary stack
    $controls{$_} ? push @primary_stack, $ops{$_}->(pop @primary_stack, pop @primary_stack) 
                  : push @primary_stack, $_ 
                      for @main_stack;
    
    # @primary_stack contains 1 element - result
    # output result converting x:1 => x
    say $primary_stack[0]->[0] . ($primary_stack[0]->[1] != 1 && ':'.$primary_stack[0]->[1]);
}
