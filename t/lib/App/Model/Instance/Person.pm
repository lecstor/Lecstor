package App::Model::Instance::Person;
use Moose;

extends 'Lecstor::Model::Instance::Person';

has '_record' => (
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
    $person = $person->_record if $person->isa('App::Model::Instance::Person');
    $self->_record->add_to_friends($person);
}

__PACKAGE__->meta->make_immutable;

1;
