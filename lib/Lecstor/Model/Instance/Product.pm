package Lecstor::Model::Instance::Product;
use Moose;
use DateTime;

extends 'Lecstor::Model::Instance';

has '+_record' => (
    handles => [qw!
        id created modified data 
        shop_id barcode name alias description price type primary_category
        image status public shipping categories
    !]
);

__PACKAGE__->meta->make_immutable;

1;