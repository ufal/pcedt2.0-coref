package Treex::Block::PCEDT20Coref::AlignCorefStats;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

sub coref_types {
    my ($tnode) = @_;
    my @types = ();
    if ($tnode->get_coref_text_nodes) {
        push @types, "COREF_TEXT";
    }
    if ($tnode->get_coref_gram_nodes) {
        push @types, "COREF_GRAM";
    }
    if ($tnode->get_attr('coref_special')) {
        push @types, "COREF_SPECIAL";
    }
    if (!@types) {
        push @types, "OTHER";
    }
    return join "+", @types;
}

sub process_tnode {
    my ($self, $tnode) = @_;

    my $types = "TNODE=" . coref_types($tnode);
    return if ($types eq "TNODE=OTHER");

    my $is_align_coref = "IS_ALIGN_COREF=" . ($tnode->get_attr('is_align_coref') ? 1 : 0);

    my ($ali_tnodes, $ali_types) = $tnode->get_undirected_aligned_nodes();
    my @ali_info = map {
        my $ali_tnode_types = coref_types($ali_tnodes->[$_]);
        "ALI_TNODE=".$ali_tnode_types.":".$ali_types->[$_];
    } 0..$#$ali_tnodes;

    print join "\t", ($tnode->id, $types, $is_align_coref, @ali_info);
    print "\n";
}

1;
