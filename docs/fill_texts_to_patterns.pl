#!/usr/bin/env perl

use strict;
use warnings;
use open qw(:std :utf8);

my %texts_in_file = ();
foreach my $text_path (@ARGV) {
    open my $text_f, "<:utf8", $text_path;
    my @texts = ();
    my $curr_text = "";
    while (<$text_f>) {
        if ($_ =~ /^\s*$/ && $curr_text !~ /^\s*$/s) {
            chomp $curr_text;
            push @texts, $curr_text;
            $curr_text = "";
            next;
        }
        $curr_text .= $_;
    }
    chomp $curr_text;
    push @texts, $curr_text;
    $text_path =~ s|^.*/([^/]*)$|$1|;
    $texts_in_file{$text_path} = \@texts;
}

while (<STDIN>) {
    while ($_ =~ /__TEXT:([^#]*)##([^_]*)__/) {
        my $text = $texts_in_file{$1}[$2-1];
        $_ =~ s/__TEXT:$1##$2__/$text/;
    }
    print $_;
}
