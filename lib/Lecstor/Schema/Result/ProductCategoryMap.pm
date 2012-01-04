package Lecstor::Schema::Result::ProductCategoryMap;

use strict;
use warnings;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime Core /);

__PACKAGE__->table('product_category_map');

__PACKAGE__->add_columns(
  'id'           => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'product'      => { data_type => 'INT', is_nullable => 0 },
  'category'     => { data_type => 'INT', is_nullable => 0 },
  'created'      => { data_type => 'DATETIME', is_nullable => 1 },
  'modified'     => { data_type => 'TIMESTAMP', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( product  => 'Lecstor::Schema::Result::Product' );
__PACKAGE__->belongs_to( category => 'Lecstor::Schema::Result::ProductCategory' );

1;
