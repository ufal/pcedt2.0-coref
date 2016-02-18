package Treex::Block::PCEDT20Coref::CorefLinksPrinter;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

sub print_link { 
    my ($anaph, $ante, $type) = @_;
    print $anaph->get_document->file_stem . "\t";
    print join "\t", map {$_->id} ($anaph, $ante);
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
