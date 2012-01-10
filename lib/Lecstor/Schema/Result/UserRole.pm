package Lecstor::Schema::Result::UserRole;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('user_role');

__PACKAGE__->add_columns(
  'id'      => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'    => { data_type => 'VARCHAR', size =>  32, is_nullable => 1 },

  'modified'         => { data_type => 'TIMESTAMP', is_nullable => 1 },
  'created'          => { data_type => 'DATETIME', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['name']);

__PACKAGE__->has_many(user_role_maps => 'Lecstor::Schema::Result::UserRoleMap', 'role');
__PACKAGE__->many_to_many(users => 'user_role_maps', 'user');


=attr id

=attr user

=attr role

=attr created

L<DateTime>

=attr modified

L<DateTime>

=cut

1;


