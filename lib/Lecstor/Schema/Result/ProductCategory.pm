package Lecstor::Schema::Result::ProductCategory;

use strict;
use warnings;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime Core /);

__PACKAGE__->table('product_category');

__PACKAGE__->add_columns(
  'id'           => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'         => { data_type => 'VARCHAR', is_nullable => 0, size => 64 },
  'created'      => { data_type => 'DATETIME', is_nullable => 1 },
  'modified'     => { data_type => 'TIMESTAMP', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('product_to_category_maps' => 'Lecstor::Schema::Result::ProductCategoryMap', 'category');
__PACKAGE__->many_to_many('products' => 'product_to_category_maps', 'product');

1;
