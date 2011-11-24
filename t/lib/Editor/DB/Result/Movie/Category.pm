package Editor::DB::Result::Movie::Category;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);

__PACKAGE__->table('category');

__PACKAGE__->add_columns(
  'id'     => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'   => { data_type => 'VARCHAR', size => 32, is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['name']);

1;
