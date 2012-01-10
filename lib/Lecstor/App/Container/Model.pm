package Lecstor::App::Container::Model;
use Moose;
use Bread::Board;
use Class::Load 'load_class';

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
    lazy_build => 1,
);

sub _build_schema{
    my ($self) = @_;
    die "we need a schema or schema config" unless $self->config->{schema};
    my $class = $self->config->{schema}{schema_class};
    load_class($class);
    return $class->connect(@{$self->config->{schema}{connect_info}});
}

=attr config

=cut

has config => (
    is      => 'ro',
    isa     => 'HashRef',
    required => 1,
);
 
sub BUILD {
    my $self = shift;

    container $self => as {
 
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

}

__PACKAGE__->meta->make_immutable;

1;
