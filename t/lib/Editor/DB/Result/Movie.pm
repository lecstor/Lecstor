package Editor::DB::Result::Movie;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ IntrospectableM2M Core /);

__PACKAGE__->table('movie');

__PACKAGE__->add_columns(
  'id'                 => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'               => { data_type => 'VARCHAR', size => 128, is_nullable => 1 },
  'type'               => { data_type => 'INT', is_nullable => 1, is_foreign_key => 1 },
  'regular_price'      => { data_type => 'DEC', size => [6,2], is_nullable => 1 },
  'available_date'     => { data_type => 'DATE', is_nullable => 1, datetime_undef_if_invalid => 1 },
  'duration'           => { data_type => 'INT',     size =>  6, is_nullable => 1 },
  'bulky'              => { data_type => 'INT',     size =>  1, is_nullable => 1 },
  'created'            => { data_type => 'DATETIME', is_nullable => 1, datetime_undef_if_invalid => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many( 'images' => 'Editor::DB::Result::Movie::Image', 'movie');

__PACKAGE__->belongs_to( type => 'Editor::DB::Result::Movie::Type', undef, { join_type => 'left' } );

__PACKAGE__->has_many('movie2categories' => 'Editor::DB::Result::Movie::Categories', 'movie');
__PACKAGE__->many_to_many('categories' => 'movie2categories', 'category');

1;


