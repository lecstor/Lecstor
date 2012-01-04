package Lecstor::Schema::Result::Collection;

use strict;
use warnings;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime Core /);

__PACKAGE__->table('collection');

__PACKAGE__->add_columns(
  'id'           => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'         => { data_type => 'VARCHAR', is_nullable => 1, size => 64 },
  'type'         => { data_type => 'INT', is_nullable => 0, size => 3 },
  'created'      => { data_type => 'DATETIME', is_nullable => 1 },
  'modified'     => { data_type => 'TIMESTAMP', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( type => 'Lecstor::Schema::Result::CollectionType' );

__PACKAGE__->has_many('items' => 'Lecstor::Schema::Result::CollectionItem', 'collection');
__PACKAGE__->many_to_many('products' => 'items', 'product');

1;
