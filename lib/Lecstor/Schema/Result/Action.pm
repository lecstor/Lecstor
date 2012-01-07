package Lecstor::Schema::Result::Action;

use strict;
use warnings;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::Serializer InflateColumn::DateTime Core /);

__PACKAGE__->table('action');

__PACKAGE__->add_columns(
  'id'        => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'type'      => { data_type => 'INT', is_nullable => 0, default_value => 1 },
  'session'   => { data_type => 'VARCHAR', size => 64, is_nullable => 0 },
  'login'     => { data_type => 'INT', is_nullable => 1, is_foreign_key => 1 },
  'data'      => { data_type => 'TEXT', is_nullable => 1, 'serializer_class' => 'JSON' },
  'created'   => { data_type => 'DATETIME', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( 'login' => 'Lecstor::Schema::Result::User', undef, { join_type => 'LEFT OUTER' } );
__PACKAGE__->belongs_to( 'type' => 'Lecstor::Schema::Result::ActionType' );

1;
