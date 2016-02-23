package Treex::Block::PCEDT20Coref::CorefLinksPrinter;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

has '_id_to_xy' => ( is => 'rw', isa => 'HashRef' );

sub print_link { 
    my ($self, $anaph, $ante, $type) = @_;
    print $anaph->get_document->file_stem . "\t";
    print join "\t", map {
        my @feats = ($_->id, $_->get_parent->id, $_->t_lemma, $_->functor);
        my $anode = $_->get_lex_anode;
        #if (defined $anode) {
        #    print STDERR "ANODE_ID: ". $anode->id . ", " . $self->_id_to_xy->{$anode->id} . "\n";
        #}
        push @feats, defined $anode ? $self->_id_to_xy->{$anode->id} : "";
        #push @feats, defined $anode ? $anode->form : "";
        @feats
    } ($anaph, $ante);
    print "\t".$type."\n";
}

sub process_tnode {
    my ($self, $tnode) = @_;
    my @text = $tnode->get_coref_text_nodes;
    $self->print_link($tnode, $_, "text") foreach (@text);
    my @gram = $tnode->get_coref_gram_nodes;
    $self->print_link($tnode, $_, "gram") foreach (@gram);
}

before 'process_document' => sub {
    my ($self, $doc) = @_;
    my %id_to_xy = ();
    my @bundles = $doc->get_bundles();
    for (my $x = 0; $x < @bundles; $x++) {
        foreach my $zone ($bundles[$x]->get_all_zones()) {
            if (($zone->selector // '') eq ($self->selector // '')) {
                my @anodes = grep {defined $_->afun} $zone->get_atree->get_descendants({ordered => 1});
                my $y = 0;
                foreach my $anode (@anodes) {
                    #print STDERR "ANODE: " . $anode->id . ", $x:$y\n";
                    $id_to_xy{$anode->id} = $x.":".$y;
                    $y += length($anode->form);
                }
            }
        }
    }
    $self->_set_id_to_xy(\%id_to_xy);
};

1;
