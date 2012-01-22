package Lecstor::Schema::Result::Session;
use strict;
use warnings;
use Lecstor::Model::Instance::Session;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::Serializer InflateColumn::DateTime Core /);

__PACKAGE__->table('session');

__PACKAGE__->add_columns(
  'id'           => { data_type => 'CHAR', is_nullable => 0, size => 72 },
  'expires'      => { data_type => 'INT', is_nullable => 1 },
  'user'         => { data_type => 'INT', is_nullable => 1 },
  'data'         => { data_type => 'TEXT', is_nullable => 1, 'serializer_class' => 'JSON' },
  'created'      => { data_type => 'DATETIME', is_nullable => 1 },
  'modified'     => { data_type => 'TIMESTAMP', is_nullable => 1 },
);

__PACKAGE__->belongs_to( user => 'Lecstor::Schema::Result::User' );

__PACKAGE__->set_primary_key('id');

sub inflate_result {
    Lecstor::Model::Instance::Session->new( _record => shift->next::method(@_) );
}

1;
