package Lecstor::Lucy::Searcher;
use Moose;

# ABSTRACT: Index Searcher based on Lucy

use Lecstor::Error;

use Lucy::Search::IndexSearcher;
use Lucy::Search::QueryParser;
use Lucy::Search::TermQuery;
use Lucy::Search::ANDQuery;


=head1 SYNOPSIS



=method new

    my $searcher = BB::Product::Lucy::Searcher->new({
          index_path => 't/lucy_index',
    });

=attr index_path

path to index directory

=cut

has index_path => ( isa => 'Str', is => 'ro', required => 1 );

=attr searcher

=cut

has searcher => ( isa => 'Lucy::Search::IndexSearcher', is => 'ro', lazy_build => 1 );

sub _build_searcher{
    my ($self) = @_;
    return Lucy::Search::IndexSearcher->new(
        index => $self->index_path,
    );
}

=attr query_parser

=cut

has query_parser => ( isa => 'Lucy::Search::QueryParser', is => 'ro', lazy_build => 1 );

sub _build_query_parser{
    my ($self) = @_;
    return Lucy::Search::QueryParser->new( 
        schema => $self->searcher->get_schema
    );
}


__PACKAGE__->meta->make_immutable;

1;
