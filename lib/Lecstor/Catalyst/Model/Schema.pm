package Lecstor::Catalyst::Model::Schema;
use Moose;
extends 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Lecstor::Schema',
    connect_info => [],
);

__PACKAGE__->meta->make_immutable;

1;
