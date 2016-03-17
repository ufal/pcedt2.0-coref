#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use v5.10;

use List::Util qw/sum/;

#sub say {
#    my ($a) = @_;
#    print $a."\n";
#}

my %en_corresp = ();
my %cs_corresp = ();
while (my $line = <STDIN>) {
    chomp $line;
    my @cols = split /\t/, $line;
    my $node_type = $cols[1];
    $node_type =~ s/^TNODE=//;
    my @ali_node_types = map {$_ =~ s/^ALI_TNODE=([^:]*):?.*$/$1/; $_} grep {$_ =~ /^ALI_TNODE=/} @cols;
    @ali_node_types = ("NO_ALI") if (!@ali_node_types);
    #my $ali_node_type;
    #if (@ali_node_types > 1) {
    #    ($ali_node_type, my @rest) = sort {
    #        $a eq $node_type ? -1 : (
    #        $a eq "OTHER" ? 1 : -1)
    #    } @ali_node_types;
    #}
    #else {
    #    $ali_node_type = $ali_node_types[0] // "NO_ALI";
    #}
    if ($cols[0] =~ /^English/) {
        $en_corresp{$node_type}{$_}++ foreach (@ali_node_types);
    }
    else {
        $cs_corresp{$node_type}{$_}++ foreach (@ali_node_types);
    }
}

my @categ_names = ("No alignment", "Non-coref", "Grammatical", "Pronominal", "Nominal", "First mention", "Split ante", "Segment", "Exophora");
my @categ_ids   = qw/NO_ALI OTHER COREF_GRAM COREF_TEXT_PRON COREF_TEXT_NOM FIRST_MENTION SPLIT_ANTE_ANAPH COREF_SPECIAL_SEGM COREF_SPECIAL_EXOPH/;

my @en_total = ();
my @cs_total = ();

say '\begin{tabular}{|l|r r r r r r r r r| r}';
say '\hline';
say 'English vs. Czech & ' . (join " & ", @categ_names) . ' & Total \\\\';
for (my $i = 0; $i < @categ_names; $i++) {
    print $categ_names[$i];
    for (my $j = 0; $j < @categ_names; $j++) {
        print " & ";
        my $val = $en_corresp{$categ_ids[$i]}{$categ_ids[$j]} // ($cs_corresp{$categ_ids[$j]}{$categ_ids[$i]} // "--");
        print $val;
        if ($val ne "--") {
            # do not count NO_ALI and OTHER into the sums for the other language
            if ($j < 2 || $i >= 2) {
                $cs_total[$j] += $val;
            }
            if ($i < 2 || $j >= 2) {
                $en_total[$i] += $val;
            }
        }
    }
    say " & " . $en_total[$i] . ' \\\\';
}
say '\hline';
say 'Total & ' . (join " & ", @cs_total) . " & " . sum(@cs_total, @en_total) . ' \\\\';
say '\hline';
say '\end{tabular}';
