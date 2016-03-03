package Treex::Block::PCEDT20Coref::AlignLinksLoader;

use Moose;
use Treex::Core::Common;
use Moose::Util::TypeConstraints;

subtype 'LangArrayRef', as 'ArrayRef';
coerce 'LangArrayRef',
    from 'Str',
    via { [ split /_/, $_ ] };

extends 'Treex::Core::Block';

has 'links_file' => (is => 'ro', isa => 'Str', required => 1);
has 'align_dir' => (is => 'ro', isa => 'LangArrayRef', coerce => 1, required => 1);
has 'align_name' => (is => 'ro', isa => 'Str', required => 1);
has 'delete_orig_align' => (is => 'ro', isa => 'Bool', default => 0);
has '_align_links' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_align_links' );

sub BUILD {
    my ($self) = @_;
    $self->_align_links;
}

sub _build_align_links {
    my ($self) = @_;
    my $align_links = {};
    open FILE, "<:utf8", $self->links_file;
    while (my $line = <FILE>) {
        chomp $line;
        my ($file_stem, $from_align_coref, $from_id, $to_align_coref, $to_id) = split /\t/, $line;
        $align_links->{align_coref_nodes}{$file_stem}{$from_id} = 1 if ($from_align_coref);
        $align_links->{align_coref_nodes}{$file_stem}{$to_id} = 1 if ($to_align_coref);
        $align_links->{links}{$file_stem}{$from_id}{$to_id} = 0;
        $align_links->{links}{$file_stem}{$to_id}{$from_id} = 1;
    }
    close FILE;
    return $align_links;
}

sub _get_aligned_lang {
    my ($self, $node) = @_;
    if ($node->language eq $self->align_dir->[0]) {
        return $self->align_dir->[1];
    }
    else {
        return $self->align_dir->[0];
    }
}

sub process_document {
    my ($self, $doc) = @_;


    # remove links for the nodes under inspection
    my $align_coref_nodes = $self->_align_links->{align_coref_nodes}{$doc->file_stem};
    foreach my $id (keys %$align_coref_nodes) {
        my $node = $doc->get_node_by_id($id);
        if ($self->delete_orig_align) {
            $node->delete_aligned_nodes_by_filter({language => $self->_get_aligned_lang($node), selector => $node->selector});
        }
        $node->set_attr('is_align_coref', 1);
    }

    my $links = $self->_align_links->{links}{$doc->file_stem};
    foreach my $from_id (keys %$links) {
        my $from = $doc->get_node_by_id($from_id);
        foreach my $to_id (keys %{$links->{$from_id}}) {
            next if (!$links->{$from_id}{$to_id});

            if ($to_id ne $from_id) {
                my $to = $doc->get_node_by_id($to_id);
                if ($to->language eq $self->align_dir->[1]) {
                    $from->add_aligned_node($to, $self->align_name);
                }
                else {
                    $to->add_aligned_node($from, $self->align_name);
                }
            }
        }
    }
}

1;
