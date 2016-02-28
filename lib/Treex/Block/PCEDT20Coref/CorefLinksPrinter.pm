package Treex::Block::PCEDT20Coref::CorefLinksPrinter;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

has '_id_to_xy' => ( is => 'rw', isa => 'HashRef' );

sub print_link { 
    my ($self, $anaph, $ante, $type) = @_;
    print $anaph->get_document->file_stem . "\t";
    print join "\t", map {
        my @feats = ($_->id, $_->t_lemma, $_->functor);
        my $ancestor_path = "";
        my $parent = $_->get_parent;
        while (defined $parent) {
            $ancestor_path .= " " if ($ancestor_path);
            $ancestor_path .= $parent->id;
            $parent = $parent->get_parent;
        }
        push @feats, $ancestor_path;
        my $anode = $_->get_lex_anode;
        #if (defined $anode) {
        #    print STDERR "ANODE_ID: ". $anode->id . ", " . $self->_id_to_xy->{$anode->id} . "\n";
        #}
        push @feats, defined $anode ? $anode->form : "";
        @feats
    } ($anaph, $ante);
    print "\t".$type."\n";
}

sub process_tnode {
    my ($self, $tnode) = @_;
    my @text = $tnode->get_coref_text_nodes;
    $self->print_link($tnode, $_, "coref_text") foreach (@text);
    my @gram = $tnode->get_coref_gram_nodes;
    $self->print_link($tnode, $_, "coref_gram") foreach (@gram);
    my ($bridg_nodes, $bridg_types) = $tnode->get_bridging_nodes;
    $self->print_link($tnode, $bridg_nodes->[$_], "bridging:".$bridg_types->[$_]) foreach (0 .. $#$bridg_nodes);
}

1;
