package Treex::Block::PCEDT20Coref::AlignCorefStats;

use Moose;
use Treex::Core::Common;
use Treex::Tool::Coreference::Utils;

extends 'Treex::Core::Block';

has '_id_to_entity' => ( is => 'rw', isa => 'HashRef' );

sub id_to_entity {
    my ($doc, $lang, $selector) = @_;
    my @ttrees = map {$_->get_tree($lang, 't', $selector)} $doc->get_bundles;
    my @chains = Treex::Tool::Coreference::Utils::get_coreference_entities(\@ttrees);
    my $entity_id = 1;
    my %id_to_entity = ();
    foreach my $entity (@chains) {
        $id_to_entity{$_->id} = $entity_id foreach (@$entity);
        $entity_id++;
    }
    return \%id_to_entity;
}

before 'process_document' => sub {
    my ($self, $doc) = @_;
    my $id_to_entity = {
        en => id_to_entity($doc, 'en', $self->selector),
        cs => id_to_entity($doc, 'cs', $self->selector),
    };
    $self->_set_id_to_entity($id_to_entity);
};

sub coref_types {
    my ($self, $tnode) = @_;
    my @types = ();
    my @antes = ();
    if (@antes = $tnode->get_coref_text_nodes) {
        push @types, "COREF_TEXT";
    }
    if (@antes = $tnode->get_coref_gram_nodes) {
        push @types, "COREF_GRAM";
    }
    if ($tnode->get_attr('coref_special')) {
        push @types, "COREF_SPECIAL";
    }
    if (!@types && defined $self->_id_to_entity->{$tnode->language}{$tnode->id}) {
        push @types, "FIRST_MENTION";
    }
    if (!@types) {
        push @types, "OTHER";
    }
    return (join("+", @types), \@antes);
}

sub process_tnode {
    my ($self, $tnode) = @_;

    my ($types, $antes) = $self->coref_types($tnode);
    $types = "TNODE=" . $types;
    return if ($types eq "TNODE=OTHER");

    my $is_align_coref = "IS_ALIGN_COREF=" . ($tnode->get_attr('is_align_coref') ? 1 : 0);

    my $tnode_entity = "TNODE_ENTITY=".($self->_id_to_entity->{$tnode->language}{$tnode->id} // "0");

    my ($ali_tnodes, $ali_types) = $tnode->get_undirected_aligned_nodes();
    my @ali_info = ();
    my @ante_ali_info = ();
    my @ali_entities = ();
    for (my $i = 0; $i < @$ali_tnodes; $i++) {
        my ($ali_tnode_types, $ali_tnode_antes) = $self->coref_types($ali_tnodes->[$i]);
        push @ali_info, "ALI_TNODE=".$ali_tnode_types.":".$ali_types->[$i];
        foreach my $l1_ante (@$antes) {
            foreach my $l2_ante (@$ali_tnode_antes) {
                my ($ali_antes, $ali_antes_types) = $l1_ante->get_undirected_aligned_nodes();
                my @matching_idxs = grep {$ali_antes->[$_] == $l2_ante} 0..$#$ali_antes;
                foreach my $match_idx (@matching_idxs) {
                    push @ante_ali_info, "ANTES_ALI=".$ali_antes_types->[$match_idx];
                }
            }
        }
        push @ali_entities, 
            "ALI_ENTITY=".
            ($self->_id_to_entity->{$ali_tnodes->[$i]->language}{$ali_tnodes->[$i]->id} // "0").
            ":".
            $ali_types->[$i];
    }

    print join "\t", ($tnode->id, $types, $is_align_coref, $tnode_entity, @ali_info, @ante_ali_info, @ali_entities);
    print "\n";
}

1;
