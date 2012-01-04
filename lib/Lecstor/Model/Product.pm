package Lecstor::Model::Product;
use Moose;
use DateTime;

with 'Lecstor::Model';

has '+data' => (
    handles => [qw!
        id created modified data 
        shop_id barcode name alias description price type primary_category
        image status public shipping categories
    !]
);

__PACKAGE__->meta->make_immutable;

1;