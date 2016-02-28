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
    my ($doc, $id, $tlemma, $functor, $id_path, $form) = @_;
    # find by its id
    my $node;
    if ($doc->id_is_indexed($id)) {
        $node = $doc->get_node_by_id($id);
        return $node if (defined $node);
    }
    my @ancestor_ids = split / /, $id_path;
    my $ance_id = shift @ancestor_ids;
    while (defined $ance_id && !$doc->id_is_indexed($ance_id)) {
        $ance_id = shift @ancestor_ids;
    }
    if (!defined $ance_id) {
        log_warn "No ancestor id has been found in the old PCEDT.";
        return;
    }
    my $ance_node = $doc->get_node_by_id($ance_id);
    # find a changed generated node, e.g., #Gen -> #PersPron, #PersPron -> #Compar and #PersPron -> #Cor
    if ($tlemma =~ /^#/) {
        my @descs = $ance_node->get_descendants;
        ($node) = grep {$_->t_lemma =~ /^#/ && $_->functor eq $functor} @descs;
        log_warn "No node found for a generated node $id" if (!defined $node);
    }
    # find a changed surface node
    # e.g., the hyphen-compounds: 'third-quartal', 'Miami-based', etc.  -> in the old PCEDT they are represented as a single node, in the new one as three anodes (two tnodes)
    elsif ($form) {
        my @children = $ance_node->get_children({add_self => 1});
        my @surface_children = grep {defined $_->get_lex_anode} @children;
        my @cands = grep {my $child_form = $_->get_lex_anode->form; $child_form =~ /$form/ || $form =~ /$child_form/} @surface_children;
        if (@cands == 1) {
            ($node) = @cands;
        }
        elsif (@cands == 0) {
            log_warn "No candidate found for $id.";
        }
        else {
            log_warn "More than one candidate for $id: " . join ", ", map {$_->get_lex_anode->form} @cands;
        }
    }
    else {
        log_warn "No node found for a surface node $id";
    }
    print STDERR "Node found ( old_tlemma: $tlemma, new_tlemma: ". $node->t_lemma . ")\n" if (defined $node);
    return $node;
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
        
        if ($type =~ /^bridging:(.*)$/) {
            $anaph->add_bridging_node($ante, $1);
        }
        elsif ($type eq "coref_text") {
            $anaph->add_coref_text_nodes($ante);
        }
        else {
            $anaph->add_coref_gram_nodes($ante);
        }
    }
}

1;
