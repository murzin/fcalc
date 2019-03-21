#!/usr/bin/env perl

# goto NAH ПРАВЯЩИЕ КЛАССЫ! perl - МАТЬ ПОРЯДКА!
# ФАБРИКИ - РАБОЧИМ, ДАТАЛЕЙКИ - МАТРОСАМ, СЛАВА - РОБОТАМ!

use v5.26.0;
use warnings;
no warnings 'recursion';

my (@ms, @ky, %dm, %ops, @pr, $poslat);
my @th = qw[| + - * / ( )];
my %sy = map {$_ => 1} @th;
my %mx = (
    '|' => [qw[4 1 1 1 1 1 5]],
    '+' => [qw[2 2 2 1 1 1 2]],
    '-' => [qw[2 2 2 1 1 1 2]],
    '*' => [qw[2 2 2 2 2 1 2]],
    '/' => [qw[2 2 2 2 2 1 2]],
    '(' => [qw[5 1 1 1 1 1 3]],
);
for my $i (0..6) {
    for (qw[| + - * / (]) {
        $dm{$th[$i].$_} = $mx{$_}->[$i];
    }
}

@ops{qw[+ - * /]} = (
    sub { 
        my $nok = nok($_[0]->[1], $_[1]->[1]);
        my $c = $_[0]->[0] * ($nok / $_[0]->[1]) + $_[1]->[0] * ($nok / $_[1]->[1]);
        my $nod = nod($c, $nok);
        return [$c/$nod, $nok/$nod];
    },
    sub { 
        my $nok = nok($_[0]->[1], $_[1]->[1]);
        my $c = $_[1]->[0] * ($nok / $_[1]->[1]) - $_[0]->[0] * ($nok / $_[0]->[1]);
        my $nod = nod($c, $nok);
        return [$c/$nod, $nok/$nod];
    },
    sub {
        my $c = $_[0]->[0] * $_[1]->[0];
        my $z = $_[0]->[1] * $_[1]->[1];
        my $nod = nod($c, $z);
        return [$c/$nod, $z/$nod];
    },
    sub {
        my $c = $_[1]->[0] * $_[0]->[1];
        my $z = $_[1]->[1] * $_[0]->[0];
        my $nod = nod($c, $z);
        return [$c/$nod, $z/$nod];
    },
);

sub nok {
    my ($x, $y) = @_;
    return $x * $y / nod($x, $y);
}

sub nod {
    my ($x, $y) = map {abs} @_;
    return $x if $x == $y;
    return $y unless $x;
    return ($x >= $y) ? nod($x-$y, $y) : nod($x, $y-$x);
}

say "fraction is x:y, operations: + - * /, for negation do like (0 - x:y)";

NAH: print '> ';
my $in = <>;

$in    =~ s/\s*:\s*/:/g;
$in    =~ s/([()+*\/-])/ $1 /g;
my @in =  map  { s/^0+(\d+):/$1:/r }
          map  { s/:0+$/:0/r }
          map  { /^\d+$/ ? $_.':1' : $_ }
          grep { length $_ }
          split /\s+/, $in;
@in or goto NAH;
undef $poslat;
for (@in) {
    unless(/^\d+:\d+$/ and $_ !~ /:0$/ or $sy{$_}) {
        say "no such shit > $_ < in my cozy garden!";
        $poslat = 'yea'; last;
    }
}
goto NAH if $poslat;
for (0..$#in) {
    $in[$_] = [split ':', $in[$_]] if $in[$_] =~ /:/;
}

@ms = qw(|);
@ky = @pr = qw();
in: for my $t (@in, '|') {
    if ($sy{$t}) {
        for ($dm{$t.$ms[$#ms]}) {
            /1/ && do { push @ms, $t };
            /2/ && do { push @ky, pop @ms; redo in };
            /3/ && do { pop @ms };
            /5/ && do { say "wrong input $in"; $poslat = 'yea'; last in };
        }
    } else {
        push @ky, $t;
    }
}
goto NAH if $poslat;

$sy{$_} ? push @pr, $ops{$_}->(pop @pr, pop @pr) : push @pr, $_ for @ky;

say $pr[0]->[0] . ($pr[0]->[1] != 1 && ':'.$pr[0]->[1]);

goto NAH;
