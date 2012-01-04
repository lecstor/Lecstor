package Lecstor::Schema::Result::ProductStatus;

use strict;
use warnings;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime Core /);

__PACKAGE__->table('product_status');

__PACKAGE__->add_columns(
  'id'           => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'         => { data_type => 'VARCHAR', is_nullable => 0, size => 128 },
  'take_order'   => { data_type => 'INT', is_nullable => 1, size => 1 },
  'in_stock'     => { data_type => 'INT', is_nullable => 1, size => 1 },
  'created'      => { data_type => 'DATETIME', is_nullable => 1 },
  'modified'     => { data_type => 'TIMESTAMP', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('products' => 'Lecstor::Schema::Result::Product', 'status');

1;
