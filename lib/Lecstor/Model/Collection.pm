package Lecstor::Model::Collection;
use Moose;
use DateTime;

with 'Lecstor::Model';

has '+data' => (
    handles => [qw!
        id created modified
        name type
        items products
    !]
);

__PACKAGE__->meta->make_immutable;

1;