package Lecstor::Model::Instance::Action;
use Moose;
use DateTime;

extends 'Lecstor::Model::Instance';

has '+_record' => (
    handles => [qw!
        id created data
        type session login
    !]
);

__PACKAGE__->meta->make_immutable;

1;