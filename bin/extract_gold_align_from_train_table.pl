#!/usr/bin/env perl

use strict;
use warnings;

my $from_address;
my $file_stem;
while (<STDIN>) {
    chomp $_;
    next if ($_ =~ /^\s*$/);
    my ($vw_line, $address) = split /\t/, $_;
    $address =~ s|^.*/||;
    $address =~ s/\.final\.streex//;
    if ($vw_line =~ /^1:/) {
        ($file_stem, $from_address) = $address =~ /^(.*)##[0-9]+\.(.*)$/;
    }
    if ($vw_line =~ /^[0-9]+:0 /) {
        $address =~ s/^.*##[0-9]+\.//;
        print $file_stem . "\t" . $from_address . "\t" . $address . "\n";
    }
}
