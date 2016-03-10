#!/usr/bin/env perl

use strict;
use warnings;

while (<STDIN>) {
    $_ =~ s/TNODE=COREF_TEXT_PRON[^\t]*/TNODE=COREF_TEXT_PRON/g;
    $_ =~ s/TNODE=COREF_TEXT_NOM[^\t]*/TNODE=COREF_TEXT_NOM/g;
    $_ =~ s/TNODE=FIRST_MENTION\+COREF_SPECIAL_SEGM[^\t]*/TNODE=COREF_SPECIAL_SEGM/g;
    $_ =~ s/TNODE=FIRST_MENTION\+COREF_SPECIAL_EXOPH[^\t]*/TNODE=COREF_SPECIAL_EXOPH/g;
    $_ =~ s/TNODE=SPLIT_[^\t]*/TNODE=SPLIT_ANTE_ANAPH/g;
    print $_;
}
