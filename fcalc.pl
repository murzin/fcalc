#!/usr/bin/env perl

# goto NAH ПРАВЯЩИЕ КЛАССЫ! perl - МАТЬ ПОРЯДКА!
# ФАБРИКИ - РАБОЧИМ, ДАТАЛЕЙКИ - МАТРОСАМ, СЛАВА - РОБОТАМ!

use v5.26.0;
use warnings;
no warnings 'recursion';

my (@ms, @ky, %dm, %ops, @pr);
my %sy = qw[en | lc ( rc ) pl + mi - mu * di /];
my %ys = reverse %sy;
my %mx = (
    th => [qw[| + - * / ( )]],
    en => [qw[4 1 1 1 1 1 5]],
    pl => [qw[2 2 2 1 1 1 2]],
    mi => [qw[2 2 2 1 1 1 2]],
    mu => [qw[2 2 2 2 2 1 2]],
    di => [qw[2 2 2 2 2 1 2]],
    lc => [qw[5 1 1 1 1 1 3]],
);

for my $i (0..$#{$mx{th}}) {
    for (qw[| + - * / (]) {
        $dm{$mx{th}->[$i].$_} = $mx{$ys{$_}}->[$i];
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
    return ($x>=$y)? nod($x-$y, $y) : nod($x, $y-$x);
}

say "fraction is x:y, operations: + - * /, for negation do like (0 - x:y)";

NAH: print '> ';
my $in = <>;

$in    =~ s/\s*:\s*/:/g;
$in    =~ s/([()+*\/-])/ $1 /g;
my @in =  map {s/^0+(\d+):/$1:/r}
          map {s/:0+$/:0/r}
          map {/^\d+$/ ? $_.':1' : $_}
          grep {length $_}
          split /\s+/, $in;
@in or goto NAH;
my $poslat;
for (@in) {
    unless(/^\d+:\d+$/ and $_ !~ /:0$/ or $ys{$_}) {
        say "no such shit > $_ < in my cozy garden!";
        $poslat = 1; last;
    }
}
goto NAN if $poslat;
for (0..$#in) {
    $in[$_] = [split ':', $in[$_]] if $in[$_] =~ /:/;
}

@ms = qw(|);
@ky = @pr = qw();
in: for my $t (@in, '|') {
    if ($ys{$t}) {
        for ($dm{$t.$ms[$#ms]}) {
            $_ == 1 && do { push @ms, $t };
            $_ == 2 && do { push @ky, pop @ms; redo in};
            $_ == 3 && do { pop @ms };
            $_ == 5 && do { die "wrong input $in" };
        }
    } else {
        push @ky, $t;
    }
}

$ys{$_} ? push @pr, $ops{$_}->(pop @pr, pop @pr) : push @pr, $_ for @ky;

say $pr[0]->[0] . ($pr[0]->[1] != 1 && ':'.$pr[0]->[1]);

goto NAH;
