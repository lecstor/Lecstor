package Lecstor::Model::Action;
use Moose;
use DateTime;

extends 'Lecstor::Model';

has '+_record' => (
    handles => [qw!
        id created data
        type session login
    !]
);

__PACKAGE__->meta->make_immutable;

1;