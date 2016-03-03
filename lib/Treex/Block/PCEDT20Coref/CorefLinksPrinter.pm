package Treex::Block::PCEDT20Coref::CorefLinksPrinter;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

sub print_link { 
    my ($self, $anaph, $ante, $type) = @_;
    print $anaph->get_document->file_stem . "\t";
    print join "\t", map {
        my @feats = ();
        if (defined $_) {
            @feats = ($_->id, $_->t_lemma, $_->functor);
            my $ancestor_path = "";
            my $parent = $_->get_parent;
            while (defined $parent) {
                $ancestor_path .= " " if ($ancestor_path);
                $ancestor_path .= $parent->id;
                $parent = $parent->get_parent;
            }
            push @feats, $ancestor_path;
            my $anode = $_->get_lex_anode;
            push @feats, defined $anode ? $anode->form : "";
        }
        else {
            @feats = map {""} 1..5;
        }
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
    my ($coref_spec) = $tnode->get_attr('coref_special');
    $self->print_link($tnode, undef, "coref_special:$coref_spec") if (defined $coref_spec);
}

1;
