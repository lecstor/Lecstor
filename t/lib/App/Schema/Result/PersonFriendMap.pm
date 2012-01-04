package App::Schema::Result::PersonFriendMap;

use strict;
use warnings;

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime Core /);

__PACKAGE__->table('person_friend_map');

__PACKAGE__->add_columns(
  'id'           => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'person'       => { data_type => 'INT', is_nullable => 0 },
  'friend'       => { data_type => 'INT', is_nullable => 0 },
  'created'      => { data_type => 'DATETIME', is_nullable => 1 },
  'modified'     => { data_type => 'TIMESTAMP', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( person => 'App::Schema::Result::Person' );
__PACKAGE__->belongs_to( friend => 'App::Schema::Result::Person' );

1;
