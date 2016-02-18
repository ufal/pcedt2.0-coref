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
        if (defined $coref_links->{$doc_id}) {
            push @{$coref_links->{$doc_id}}, \@rest;
        }
        else {
            $coref_links->{$doc_id} = [ \@rest ];
        }
    }
    close FILE;
    return $coref_links;
}

sub process_document {
    my ($self, $doc) = @_;
    print STDERR $doc->file_stem."\n";
    foreach my $triple (@{$self->_coref_links->{$doc->file_stem}}) {
        my ($anaph_id, $ante_id, $type) = @$triple;
        my $anaph = $doc->get_node_by_id($anaph_id);
        next if (!defined $anaph);
        my $ante = $doc->get_node_by_id($ante_id);
        next if (!defined $ante);
        if ($type eq "text") {
            $anaph->add_coref_text_nodes($ante);
        }
        else {
            $anaph->add_coref_gram_nodes($ante);
        }
    }
}

1;
