package Editor::DB::Result::Movie::Categories;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);

__PACKAGE__->table('categories');

__PACKAGE__->add_columns(
  'id'       => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'category' => { data_type => 'INT', is_nullable => 0, is_foreign_key => 1 },
  'movie'    => { data_type => 'INT', is_nullable => 0, is_foreign_key => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( category => 'Editor::DB::Result::Movie::Category', undef, { join_type => 'left' } );
__PACKAGE__->belongs_to( movie    => 'Editor::DB::Result::Movie' );

__PACKAGE__->add_unique_constraint([ qw/category movie/ ]);

1;
