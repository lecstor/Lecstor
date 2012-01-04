package App::Model::Person;
use Moose;

extends 'Lecstor::Model::Person';

has 'data' => (
    isa => 'App::Schema::Result::Person', is => 'ro',
    handles => [qw!
        id created modified
        update
        firstname surname default_delivery
        billing_address
        delivery_addresses
        buddy friends 
    !]
);

sub add_to_friends{
    my ($self, $person) = @_;
    $person = $person->data if $person->isa('App::Model::Person');
    $self->data->add_to_friends($person);
}

__PACKAGE__->meta->make_immutable;

1;
