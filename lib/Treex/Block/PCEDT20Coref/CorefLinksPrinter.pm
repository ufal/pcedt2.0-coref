package Treex::Block::PCEDT20Coref::CorefLinksPrinter;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

sub print_link { 
    my ($anaph, $ante, $type) = @_;
    print $anaph->get_document->file_stem . "\t";
    print join "\t", map {
        my @feats = ($_->id, $_->get_parent->id, $_->t_lemma, $_->functor);
        my $anode = $_->get_lex_anode;
        push @feats, defined $anode ? $anode->form : "";
        @feats
    } ($anaph, $ante);
    print "\t".$type."\n";
}

sub process_tnode {
    my ($self, $tnode) = @_;
    my @text = $tnode->get_coref_text_nodes;
    print_link($tnode, $_, "text") foreach (@text);
    my @gram = $tnode->get_coref_gram_nodes;
    print_link($tnode, $_, "gram") foreach (@gram);
}

1;
