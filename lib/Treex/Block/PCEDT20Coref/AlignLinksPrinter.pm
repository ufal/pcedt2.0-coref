package Treex::Block::PCEDT20Coref::AlignLinksPrinter;

use Moose;
use Treex::Core::Common;
use Moose::Util::TypeConstraints;
use List::MoreUtils qw/any/;

subtype 'LangArrayRef', as 'ArrayRef';
coerce 'LangArrayRef',
    from 'Str',
    via { [ split /,/, $_ ] };

extends 'Treex::Core::Block';
with 'Treex::Block::Filter::Node::T';

has '+node_types' => ( default => 'all_anaph' );
has 'align_langs' => (is => 'ro', isa => 'LangArrayRef', coerce => 1, required => 1);
has '_links' => ( is => 'rw', isa => 'ArrayRef', default => sub {[]} );

sub _get_aligned_lang {
    my ($self, $node) = @_;
    if ($node->language eq $self->align_langs->[0]) {
        return $self->align_langs->[1];
    }
    else {
        return $self->align_langs->[0];
    }
}

after 'process_bundle' => sub {
    my ($self, $bundle) = @_;
    my $file_stem = $bundle->get_document->file_stem;
    $file_stem =~ s/\.final//;
    my $links = $self->_links;
    foreach my $pair (@$links) {
        my ($from, $to) = @$pair;
        my ($from_align_coref, $to_align_coref) = map {
            my %types = map {$_ => 1} (split /,/, ($_->wild->{filter_types} // ""));
            (any {$types{$_}} @{$self->node_types}) ? 1 : 0
        } ($from, $to);
        print join "\t", ($file_stem, $from_align_coref, $from->id, $to_align_coref, $to->id);
        print "\n";
    }
    $self->_set_links([]);
};

sub process_filtered_tnode {
    my ($self, $tnode) = @_;
    my ($nodes, $types) = $tnode->get_undirected_aligned_nodes({language => $self->_get_aligned_lang($tnode), selector => $tnode->selector, rel_types => ['gold']});
    if (!@$nodes) {
        push @{$self->_links}, [$tnode, $tnode];
    }
    else {
        foreach my $ali_node (@$nodes) {
            push @{$self->_links}, [$tnode, $ali_node];
        }
    }
}

1;
