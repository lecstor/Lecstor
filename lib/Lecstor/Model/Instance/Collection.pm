package Lecstor::Model::Instance::Collection;
use Any::Moose;
use DateTime;

extends 'Lecstor::Model::Instance';

has '+_record' => (
    handles => [qw!
        id created modified
        name type
        items products
    !]
);

__PACKAGE__->meta->make_immutable;

1;