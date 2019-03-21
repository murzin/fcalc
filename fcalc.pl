#!/usr/bin/env perl

use v5.20.0;
use warnings;
no warnings 'recursion';

use Data::Dumper;

my (@ms, @ky, %dm, %ops);
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
        my $op1 = [split ':', shift()];
        my $op2 = [split ':', shift()]; 
        my $nok = nok($op1->[1], $op2->[1]);
        my $c = $op1->[0] * ($nok / $op1->[1]) + $op2->[0] * ($nok / $op2->[1]);
        my $nod = nod($c, $nok);
        return $c/$nod.':'.$nok/$nod;
    },
    sub { 
        my $op2 = [split ':', shift()];
        my $op1 = [split ':', shift()]; 
        my $nok = nok($op1->[1], $op2->[1]);
        my $c = $op1->[0] * ($nok / $op1->[1]) - $op2->[0] * ($nok / $op2->[1]);
        my $nod = nod($c, $nok);
        return $c/$nod.':'.$nok/$nod;
    },
    sub {
        my $op1 = [split ':', shift()]; 
        my $op2 = [split ':', shift()];
        my $c = $op1->[0] * $op2->[0];
        my $z = $op1->[1] * $op2->[1];
        my $nod = nod($c, $z);
        return $c/$nod.':'.$z/$nod;
    },
    sub {
        my $op2 = [split ':', shift()];
        my $op1 = [split ':', shift()]; 
        my $c = $op1->[0] * $op2->[1];
        my $z = $op1->[1] * $op2->[0];
        my $nod = nod($c, $z);
        return $c/$nod.':'.$z/$nod;
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

NAH:
my $in = '11-(8:3+ 2: 3 * 5 : 7 )/( 1:2 + 3 * 2 :5 -4 :7 )';
#my $in = '2:3 / 2';
#my $in = '(000 - 2:3) +2:3 * 1:2 + 2:3';
#print '> ';
#my $in = <>;

$in    =~ s/\s*:\s*/:/g;
$in    =~ s/([()+*\/-])/ $1 /g;
my @in =  map {s/^0+(\d+):/$1:/r }
          map {s/:0+$/:0/r}
          map {/^\d+$/ ? $_.':1' : $_ }
          grep {length $_}
          split /\s+/, $in;
$" = '_';
say "@in";
for (@in) {
    unless(/^\d+:\d+$/ and $_ !~ /:0$/ or  $ys{$_}) {
        say "no such shit > $_ < in my cozy garden!";
        #goto NAH;
        exit;
    }
}

@ms = qw(|);
@ky = qw();
for my $t (@in, '|') {
    if ($ys{$t}) {
        my $lvm = $ms[$#ms];
        my $ch = $dm{$t.$lvm};
        if ($ch == 1) {
            push @ms, $t;
        } elsif ($ch == 2) {
            push @ky, pop @ms;
            redo;
        } elsif ($ch == 3) {
            pop @ms;
        } elsif ($ch == 4) {
            # done
        } else {
            die "ch - $ch , wrong input $in";
        }
    } else {
        push @ky, $t;
    }
}

my @pr;
for my $t (@ky) {
    if ($ys{$t}) {
        push @pr, $ops{$t}->(pop @pr, pop @pr);
    } else {
        push @pr, $t;
    }
}

say $pr[0] =~ s/:1$//r;
#goto HAHA;

