#!/usr/bin/env perl

use strict;
use warnings;
use open qw(:std :utf8);

my %texts_in_file = ();
foreach my $text_path (@ARGV) {
    open my $text_f, "<:utf8", $text_path;
    my %texts = ();
    my $curr_id;
    my $curr_text = "";
    while (<$text_f>) {
        if ($_ =~ /^\s*$/ && $curr_text !~ /^\s*$/s && defined $curr_id) {
            chomp $curr_text;
            $texts{$curr_id} = $curr_text;
            $curr_text = "";
            $curr_id = undef;
            next;
        }
        if (!defined $curr_id) {
            chomp $_;
            $curr_id = $_;
        }
        else {
            $curr_text .= $_;
        }
    }
    chomp $curr_text;
    $texts{$curr_id} = $curr_text;
    $text_path =~ s|^.*/([^/]*)$|$1|;
    $texts_in_file{$text_path} = \%texts;
}

while (<STDIN>) {
    while ($_ =~ /__TEXT:([^#]*)##([^_]*)__/) {
        my $text = $texts_in_file{$1}{$2};
        $_ =~ s/__TEXT:$1##$2__/$text/;
    }
    print $_;
}
