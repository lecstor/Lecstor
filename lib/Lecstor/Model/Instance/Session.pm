package Lecstor::Model::Instance::Session;
use Moose;
use DateTime;

extends 'Lecstor::Model::Instance';

has '+_record' => (
    handles => [qw!
        id created modified 
        expires data
        update delete
    !]
);

__PACKAGE__->meta->make_immutable;

1;