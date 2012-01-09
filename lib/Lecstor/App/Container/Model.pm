package Lecstor::App::Container::Model;
use Moose;
use Bread::Board;
 
extends 'Bread::Board::Container';

has '+name' => ( default => 'Lecstor-Model' );

=head1 SYNOPSIS

    my $container = Lecstor::App::Container::Model->new({
        schema => $dbic_schema,
        config => {
            product_search => {
                index_path => 'path/to/index/directory',
                index_create => 1,
                index_truncate => 1,
            },
        },
    });

    my $model = $container->build_app();

=attr schema

=cut

has schema => (
    is      => 'ro',
    isa     => 'DBIx::Class::Schema',
    required => 1,
);

=attr config

=cut

has config => (
    is      => 'ro',
    isa     => 'HashRef',
    required => 1,
);
 
sub build_container {
    my $self = shift;

    my $c = container 'Lecstor-Model' => as {
 
        service 'schema' => $self->schema;
 
        service product_search_index => $self->config->{product_search}{index_path};
        service product_index_create => $self->config->{product_search}{index_create};
        service product_index_truncate => $self->config->{product_search}{index_truncate};

        service product_indexer => (
            class        => 'Lecstor::Lucy::Indexer',
            lifecycle    => 'Singleton',
            dependencies => {
                index_path => depends_on('product_search_index'),
                create => depends_on('product_index_create'),
                truncate => depends_on('product_index_truncate'),
            }
        );
 
        service product_searcher => (
            class        => 'Lecstor::Lucy::Searcher',
            lifecycle    => 'Singleton',
            dependencies => {
                index_path => depends_on('product_search_index'),
            }
        );

        service model => (
            class        => 'Lecstor::Model',
            lifecycle    => 'Singleton',
            dependencies => {
                schema => depends_on('schema'),
                product_indexer => depends_on('product_indexer'),
                product_searcher => depends_on('product_searcher'),
            }
        );
  
    };

    return $c;
}

__PACKAGE__->meta->make_immutable;

1;
