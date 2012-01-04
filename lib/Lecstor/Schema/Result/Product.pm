package Lecstor::Schema::Result::Product;

use strict;
use warnings;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::Serializer InflateColumn::DateTime Core /);

__PACKAGE__->table('product');

__PACKAGE__->add_columns(
  'id'           => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'shop_id'      => { data_type => 'VARCHAR', is_nullable => 1, size => 24 },
  'barcode'      => { data_type => 'VARCHAR', size => 13, is_nullable => 1 },
  'data'         => { data_type => 'TEXT', is_nullable => 1, 'serializer_class' => 'JSON' },
  'name'         => { data_type => 'VARCHAR', is_nullable => 0, size => 128 },
  'alias'        => { data_type => 'VARCHAR', size => 128, is_nullable => 1 },
  'description'  => { data_type => 'TEXT', is_nullable => 1 },
  'price'        => { data_type => 'DEC', is_nullable => 0, size => [8,2] },
  'type'         => { data_type => 'INT', is_nullable => 0, size => 3 },
  'primary_category' => { data_type => 'INT', is_nullable => 1, size => 3 },
  'image'        => { data_type => 'VARCHAR', is_nullable => 1, size => 24 },
  'status'       => { data_type => 'INT', is_nullable => 0 },
  'public'       => { data_type => 'INT', is_nullable => 1 },
  'shipping'     => { data_type => 'INT', is_nullable => 0 },
  'created'      => { data_type => 'DATETIME', is_nullable => 1 },
  'modified'     => { data_type => 'TIMESTAMP', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( type => 'Lecstor::Schema::Result::ProductType' );
__PACKAGE__->belongs_to( status => 'Lecstor::Schema::Result::ProductStatus' );
__PACKAGE__->belongs_to( shipping => 'Lecstor::Schema::Result::ProductShipping' );

# has many categories
__PACKAGE__->has_many('product_to_category_maps' => 'Lecstor::Schema::Result::ProductCategoryMap', 'product');
__PACKAGE__->many_to_many('categories' => 'product_to_category_maps', 'category');

1;
