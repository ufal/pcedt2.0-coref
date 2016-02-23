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
    my ($doc, $xy_to_anode, $id, $par_id, $tlemma, $functor, $xy) = @_;
    # find by its id
    my $node;
    if ($doc->id_is_indexed($id)) {
        $node = $doc->get_node_by_id($id);
        return $node if (defined $node);
    }
    # find a changed generated node, e.g., #Gen -> #PersPron, #PersPron -> #Compar and #PersPron -> #Cor
    if ($tlemma =~ /^#/) {
        my $par_node = $doc->get_node_by_id($par_id);
        my @descs = $par_node->get_descendants;
        ($node) = grep {$_->t_lemma =~ /^#/ && $_->functor eq $functor} @descs;
        if (defined $node) {
            return $node;
        }
        else {
            log_warn "No node found for a generated node $id";
        }
    }
    # find a changed surface node
    # e.g., the hyphen-compounds: 'third-quartal', 'Miami-based', etc.  -> in the old PCEDT they are represented as a single node, in the new one as three anodes (two tnodes)
    else {
        my $lang = 'cs';
        if ($id =~ /English/) {
            $lang = 'en';
        }
        my $anode = $xy_to_anode->{$lang}{$xy};
        if (!defined $anode) {
            print STDERR "LANG: $lang, XY: $xy\n";
        }
        ($node) = $anode->get_referencing_nodes('a/lex.rf');
        if (defined $node) {
            return $node;
        }
        else {
            log_warn "No node found for a surface node $id";
        }
    }
}

sub process_document {
    my ($self, $doc) = @_;

    my %xy_to_id = ();
    my @bundles = $doc->get_bundles();
    for (my $x = 0; $x < @bundles; $x++) {
        foreach my $zone ($bundles[$x]->get_all_zones()) {
            if (($zone->selector // '') eq ($self->selector // '')) {
                my @anodes = grep {defined $_->afun} $zone->get_atree->get_descendants({ordered => 1});
                my $y = 0;
                foreach my $anode (@anodes) {
                    #print STDERR "ANODE: " . $anode->id . ", $x:$y\n";
                    $xy_to_id{$anode->language}{"$x:$y"} = $anode;
                    $y += length($anode->form);
                }
            }
        }
    }
    foreach my $tuple (@{$self->_coref_links->{$doc->file_stem}}) {
        my ($anaph_feats, $ante_feats, $type) = @$tuple;
        my $anaph = find_node($doc, \%xy_to_id, @$anaph_feats);
        next if (!defined $anaph);
        my $ante = find_node($doc, \%xy_to_id, @$ante_feats);
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
