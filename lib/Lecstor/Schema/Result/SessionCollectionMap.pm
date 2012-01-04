package Lecstor::Schema::Result::SessionCollectionMap;

use strict;
use warnings;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime Core /);

__PACKAGE__->table('session_collection_map');

__PACKAGE__->add_columns(
  'id'           => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'session'      => { data_type => 'INT', is_nullable => 0 },
  'collection'   => { data_type => 'INT', is_nullable => 0 },
  'created'      => { data_type => 'DATETIME', is_nullable => 1 },
  'modified'     => { data_type => 'TIMESTAMP', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( session    => 'Lecstor::Schema::Result::Session' );
__PACKAGE__->belongs_to( collection => 'Lecstor::Schema::Result::Collection' );

1;
