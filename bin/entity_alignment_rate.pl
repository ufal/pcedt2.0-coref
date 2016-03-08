#!/usr/bin/env perl

use strict;
use warnings;
use List::Util qw/sum max/;

my $ali_type = $ARGV[0];

my %entity_aligns = ();

while (my $line = <STDIN>) {
    chomp $line;
    my @cols = split /\t/, $line;
    my ($docid) = ($cols[0] =~ /(wsj_?....)/);
    $line =~ /TNODE_ENTITY=(\d+)/;
    next if (!$1);
    my $tnode_entity = $docid."_".$1;
    #print STDERR "TNODE_ENTITY: $tnode_entity\n";
    my @ali_entities = ();
    foreach my $col (@cols) {
        my ($ali_entity, $type) = ($col =~ /^ALI_ENTITY=(\d+):(\S+)/);
        next if (!$ali_entity);
        #next if ($ali_entity == 0);
        if ($line =~ /IS_ALIGN_COREF=1/) {
            next if ($ali_type eq "unsup" && $type =~ /coref_(supervised|gold)/);
            next if ($ali_type eq "sup" && $type !~ /coref_supervised/);
            next if ($ali_type eq "gold" && $type !~ /coref_gold/);
        }
        push @ali_entities, $ali_entity;
    }
    $entity_aligns{$tnode_entity}{$_}++ foreach (@ali_entities);
    $entity_aligns{$tnode_entity}{0}++ if (!@ali_entities);
}

use Data::Dumper;
#print STDERR Dumper(\%entity_aligns);

my %aligned_entities_number_freq;
my $entity_rate_sum = 0;
foreach my $entity_id (sort keys %entity_aligns) {
    my $sum = sum values %{$entity_aligns{$entity_id}};
    my %no_zero = map {$_ => $entity_aligns{$entity_id}{$_}} grep {$_} keys %{$entity_aligns{$entity_id}};
    my $max = max(values %no_zero) // 0;
    $entity_rate_sum += ($max / $sum);
    $aligned_entities_number_freq{scalar(keys %no_zero)}++;

    #print STDERR "$entity_id => $entity_rate_sum ( $max / $sum )\n";
}
print "# ENTITIES: " . scalar(keys %entity_aligns) . "\n";
print "ENTITY ALIGN RATE: " . ($entity_rate_sum / scalar(keys %entity_aligns)) . "\n";
print "ALIGNED ENTITIES NUMBER DISTRIBUTION: " . Dumper(\%aligned_entities_number_freq) . "\n";
