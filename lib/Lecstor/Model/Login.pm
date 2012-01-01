package Lecstor::Model::Login;
use Moose;

with 'Lecstor::Model';

has '+data' => (
    handles => [qw!
        id created modified active
        username email person password
        update check_password
    !]
);

__PACKAGE__->meta->make_immutable;

1;