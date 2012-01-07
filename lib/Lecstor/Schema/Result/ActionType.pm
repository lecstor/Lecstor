package Lecstor::Schema::Result::ActionType;
use strict;
use warnings;

# ABSTRACT: a type of action

use parent qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);

__PACKAGE__->table('action_type');

__PACKAGE__->add_columns(
  'id'         => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'       => { data_type => 'VARCHAR', size =>  32, is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint([qw/name/]);

=attr id

=attr name

=cut


1;
