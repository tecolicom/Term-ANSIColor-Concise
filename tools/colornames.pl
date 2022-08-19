#!/usr/bin/env perl

use v5.14;
use warnings;
use Data::Dumper;

use Graphics::ColorNames::X;
my $table = Graphics::ColorNames::X->NamesRgbTable;
my %variants;
my %prefix;
for my $key (sort keys %$table) {
    if ($key =~ /(\w+?)\d+$/) {
	$table->{$1} or die "$key: invalid\n";
	push @{$variants{$1}}, $key;
    }
    elsif ($key =~ /^(dark|light|medium|pale|deep)([a-z]+)$/) {
	$table->{$2} or next;
	push @{$prefix{$2}}, $key;
    }
}
sub del {
    my $key = shift;
    #return if ($variants{$key} or $prefix{$key});
    delete $table->{$key};
}
map { del $_ } map { @$_ } values %variants;
map { del $_ } map { @$_ } values %prefix;

my @names = sort keys %$table;
my @variants = grep { @{$variants{$_}} == 4 } sort keys %variants;

open STDOUT, '| fold -s -w67';

print "@names\n";
print "\n";
print "@variants\n";
print "\n";

use List::Util qw(max);
my $max = max map length, keys %prefix;
for (sort keys %prefix) {
    printf "%-*s  %s\n", $max, $_, join(' ', @{$prefix{$_}});
}

close STDOUT;
