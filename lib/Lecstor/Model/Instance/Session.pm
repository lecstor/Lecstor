package Lecstor::Model::Instance::Session;
use Moose;
use DateTime;

extends 'Lecstor::Model::Instance';

has '+_record' => (
    handles => [qw!
        id created modified 
        expires data user
        update delete
    !]
);

sub set_user{
    my ($self, $user) = @_;
    $self->update({ user => $user->_record });
}

__PACKAGE__->meta->make_immutable;

1;