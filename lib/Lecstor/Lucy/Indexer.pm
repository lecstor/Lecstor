package Lecstor::Lucy::Indexer;
use Moose;

# ABSTRACT: Search Indexer based on Lucy

use Lucy::Plan::Schema;
use Lucy::Plan::FullTextType;
use Lucy::Plan::StringType;
use Lucy::Index::Indexer;
use Lucy::Analysis::PolyAnalyzer;
use Lucy::Analysis::CaseFolder;
use Lucy::Analysis::RegexTokenizer;

=head1 SYNOPSIS

  my $indexer = Lecstor::Lucy::Indexer->new({
      index_path => 'path/to/index/directory',
      create => 1,
      truncate => 1,
  });

  $indexer->add_item({ id => 1, description => 'I can see clearly now' });
  $indexer->update_item({ id => 1, description => 'the rain is gone.' });
  $indexer->delete_item({ id => 1 });
  $indexer->commit;

=attr index_path

path to index directory

=cut

has index_path => ( isa => 'Str', is => 'ro', required => 1 );

=attr create

=cut

has create => ( isa => 'Bool', is => 'ro' );

=attr truncate

=cut

has truncate => ( isa => 'Bool', is => 'ro' );

=attr indexer

=cut

has indexer => ( isa => 'Str', is => 'ro', lazy_build => 1 );

sub _build_indexer{
    my ($self) = @_;
    return {
        Lucy::Index::Indexer->new(
            index    => $self->index_path,
            schema   => $self->schema,
            create   => $self->create,
            truncate => $self->truncate,
        )
    };
}

=attr schema

L<Lucy::Plan::Schema>

=cut

has schema => ( isa => 'Lucy::Plan::Schema', is => 'ro', lazy_build => 1 );

sub _build_schema{
    my ($self) = @_;
    my $schema = Lucy::Plan::Schema->new;
    $schema->spec_field( name => 'id', type => $self->stored_string_type );
    $schema->spec_field( name => 'description', type => $self->fulltext_type );
    return $schema;
}

=attr string_type

L<Lucy::Plan::StringType>

fields requiring an exact match

=cut

has string_type => ( isa => 'Lucy::Plan::StringType', is => 'ro', lazy_build => 1 );

sub _build_string_type{ Lucy::Plan::StringType->new }

=attr stored_string_type

L<Lucy::Plan::StringType>

fields requiring an exact match
stored for retrieval.
used for product ids.

=cut

has stored_string_type => ( isa => 'Lucy::Plan::StringType', is => 'ro', lazy_build => 1 );

sub _build_stored_string_type{ Lucy::Plan::StringType->new( stored => 1 ) }

=attr fulltext_type

L<Lucy::Plan::FullTextType>

=cut

has fulltext_type => ( isa => 'Lucy::Plan::FullTextType', is => 'ro', lazy_build => 1 );

sub _build_fulltext_type{
    return Lucy::Plan::FullTextType->new(
        analyzer => Lucy::Analysis::PolyAnalyzer->new(
            analyzers => [
                Lucy::Analysis::CaseFolder->new,
                Lucy::Analysis::RegexTokenizer->new
            ],
        )
    );
}

=attr list_type

L<Lucy::Plan::FullTextType>

=cut

has list_type => ( isa => 'Lucy::Plan::FullTextType', is => 'ro', lazy_build => 1 );

sub _build_list_type{
    return Lucy::Plan::FullTextType->new(
        analyzer => Lucy::Analysis::PolyAnalyzer->new(
            analyzers => [
                Lucy::Analysis::CaseFolder->new,
                Lucy::Analysis::RegexTokenizer->new(
                    pattern => '\w[\w\s]+\w'
                )
            ],
        )
    );
}

=method add_item

=cut

sub add_item{
    my ($self, $doc) = @_;
    die Lecstor::Error->new( error => 'add_item needs an id' ) unless $doc->{id};
    $self->indexer->add_item($doc);
}

=method update_item

=cut

sub update_item{
    my ($self, $doc) = @_;
    die Lecstor::Error->new( error => 'update_item needs an id' ) unless $doc->{id};
    $self->delete_item($doc);
    $self->add_item($doc);
}

=method delete_item

=cut

sub delete_item{
    my ($self, $doc) = @_;
    die Lecstor::Error->new( error => 'delete_item needs an id' ) unless $doc->{id};
    $self->indexer->delete_by_term( field => 'id', term => $doc->{id} ); 
}

=method commit

commit changes to the index.

=cut

sub commit{
    my ($self) = @_;
    $self->indexer->commit; 
}


__PACKAGE__->meta->make_immutable;

1;
