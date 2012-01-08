package Lecstor::App::Container;
use Moose;
use Bread::Board;
 
extends 'Bread::Board::Container';

has '+name' => ( default => 'Lecstor' );

=head1 SYNOPSIS

    my $container = Lecstor::Model::Container->new({
        schema => $dbic_schema,
        template_processor => $tt_instance,
        config => {
            product_search => {
                index_path => 'path/to/index/directory',
                create => 1,
                truncate => 1,
            },
        },
    });

    my $lecstor = $container->build_app();

=attr schema

=cut

has schema => (
    is      => 'ro',
    isa     => 'DBIx::Class::Schema',
    required => 1,
);

=attr template_processor

=cut

has template_processor => (
    is      => 'ro',
    isa     => 'Object',
    required => 1,
);

=attr config

=cut

has config => (
    is      => 'ro',
    isa     => 'HashRef',
    required => 1,
);


=attr view

=cut

has view => ( is => 'ro', isa => 'HashRef' );

has session_id => ( is => 'rw', isa => 'Str', required => 0 );

has user => ( is => 'rw', isa => 'Lecstor::Model::Instance::User', required => 0 );

 
sub build_app {
    my $self = shift;

    my $c = container Lecstor => as {
 
        service 'schema' => $self->schema;
 
        service model => (
            class        => 'Lecstor::Model',
            lifecycle    => 'Singleton',
            dependencies => {
                schema => depends_on('schema'),
            }
        );
 
        service view => $self->view;
        service session_id => $self->session_id;
        service user => ( block => sub { $self->user } );
        service template_processor => $self->template_processor;

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
 
        service validator => (
            class        => 'Lecstor::Valid',
            lifecycle    => 'Singleton',
        );
 
        service error_class => 'Lecstor::Error';
 
        service app => (
            class        => 'Lecstor::App',
            lifecycle    => 'Singleton',
            dependencies => {
                model => depends_on('model'),
                template_processor => depends_on('template_processor'),
                product_indexer => depends_on('product_indexer'),
                product_searcher => depends_on('product_searcher'),
                validator => depends_on('validator'),
                error_class => depends_on('error_class'),
                session_id => depends_on('session_id'),
                user => depends_on('user'),
                view => depends_on('view'),
            }
        );
    };
    return $c->fetch('app')->get;
}

__PACKAGE__->meta->make_immutable;

1;
