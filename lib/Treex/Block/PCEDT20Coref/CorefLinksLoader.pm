package Treex::Block::PCEDT20Coref::CorefLinksLoader;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

has 'links_file' => (is => 'ro', isa => 'Str', required => 1);
has '_coref_links' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_coref_links' );

sub BUILD {
    my ($self) = @_;
    $self->_coref_links;
}

sub _build_coref_links {
    my ($self) = @_;
    my $coref_links = {};
    open FILE, "<:utf8", $self->links_file;
    while (my $line = <FILE>) {
        chomp $line;
        my ($doc_id, @rest) = split /\t/, $line;
        my $type = pop @rest;
        my @anaph_feats = splice @rest, 0, scalar(@rest)/2;
        if (defined $coref_links->{$doc_id}) {
            push @{$coref_links->{$doc_id}}, [ \@anaph_feats, \@rest, $type ];
        }
        else {
            $coref_links->{$doc_id} = [ [ \@anaph_feats, \@rest, $type] ];
        }
    }
    close FILE;
    return $coref_links;
}

sub find_node {
    my ($doc, $id, $par_id, $tlemma, $functor, $form) = @_;
    # find by its id
    my $node;
    if ($doc->id_is_indexed($id)) {
        $node = $doc->get_node_by_id($id);
        return $node if (defined $node);
    }
    if ($doc->id_is_indexed($par_id)) {
        my $par_node = $doc->get_node_by_id($par_id);
        my @descs = $par_node->get_descendants;
        # find a changed generated node, e.g., #Gen -> #PersPron, #PersPron -> #Compar and #PersPron -> #Cor
        if ($tlemma =~ /^#/) {
            ($node) = grep {$_->t_lemma =~ /^#/ && $_->functor eq $functor} @descs;
            return $node if (defined $node);
        }
        # find the hyphen-compounds, e.g., 'third-quartal', 'Miami-based'  -> in the old PCEDT they are represented as a single node, in the new one as three anodes (two tnodes)
        ($node, my @rest) = grep {my $anode = $_->get_lex_anode; defined $anode ? $anode->form =~ /$form/ : 0 } @descs;
        if (@rest) {
            log_warn "More than one node match the form $form among the descendants of $par_id";
        }
        return $node if (defined $node);
    }
    else {
        log_warn "Parent $par_id not defined";
    }
    log_warn "The node $id not found";
}

sub process_document {
    my ($self, $doc) = @_;
    foreach my $tuple (@{$self->_coref_links->{$doc->file_stem}}) {
        my ($anaph_feats, $ante_feats, $type) = @$tuple;
        my $anaph = find_node($doc, @$anaph_feats);
        next if (!defined $anaph);
        my $ante = find_node($doc, @$ante_feats);
        next if (!defined $ante);
        if ($anaph->t_lemma eq "#Gen") {
            log_info "A link that would originate from a #Gen node found.";
            #next;
        }
        if ($type eq "text") {
            $anaph->add_coref_text_nodes($ante);
        }
        else {
            $anaph->add_coref_gram_nodes($ante);
        }
    }
}

1;
