package Lecstor::Model::Session;
use Moose;
use DateTime;

with 'Lecstor::Model';

has '+data' => (
    handles => [qw!
        id created modified 
        expires data 
    !]
);

__PACKAGE__->meta->make_immutable;

1;