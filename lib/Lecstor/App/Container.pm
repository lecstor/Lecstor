package Lecstor::Model::Container;
use Moose;
use Bread::Board;
 
extends 'Bread::Board::Container';
 
has 'schema' => (
    is      => 'ro',
    isa     => 'DBIx::Class::Schema',
    required => 1,
);
 
sub BUILD {
    my $self = shift;
    container $self => as {
 
        service 'schema' => $self->schema;
 
        service 'person_controller' => (
            class        => 'Lecstor::Model::Controller::Person',
            lifecycle    => 'Singleton',
            dependencies => {
                schema => depends_on('schema'),
            }
        );
 
        service 'application' => (
            class        => 'My::Application',
            dependencies => {
                logger => depends_on('logger'),
            }
        );
    };
}

__PACKAGE__->meta->make_immutable;

1;
