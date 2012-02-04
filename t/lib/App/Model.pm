package App::Model;
use Moose;

use App::Model::Controller::Person;

extends 'Lecstor::Model';

has person => (
    is => 'ro', isa => 'Lecstor::Model::Controller', lazy_build => 1
);

sub _build_person{
    my ($self) = @_;
    App::Model::Controller::Person->new(
        schema => $self->schema,
    );
}


__PACKAGE__->meta->make_immutable;

1;

