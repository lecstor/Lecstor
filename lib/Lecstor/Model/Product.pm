package Lecstor::Model::Product;
use Moose;
use DateTime;

extends 'Lecstor::Model';

has '+_record' => (
    handles => [qw!
        id created modified data 
        shop_id barcode name alias description price type primary_category
        image status public shipping categories
    !]
);

__PACKAGE__->meta->make_immutable;

1;