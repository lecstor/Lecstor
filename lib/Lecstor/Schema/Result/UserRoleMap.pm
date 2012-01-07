package Lecstor::Schema::Result::UserRoleMap;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('user_role_map');

__PACKAGE__->add_columns(
  'id'      => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'user'    => { data_type => 'INT', is_nullable => 1 },
  'role'    => { data_type => 'INT', is_nullable => 1 },

  'modified'         => { data_type => 'TIMESTAMP', is_nullable => 1 },
  'created'          => { data_type => 'DATETIME', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint([qw! user role !]);

__PACKAGE__->belongs_to( user => 'Lecstor::Schema::Result::User'    );

__PACKAGE__->belongs_to( role => 'Lecstor::Schema::Result::UserRole'    );
 
=attr id

=attr login

=attr role

=attr created

L<DateTime>

=attr modified

L<DateTime>

=cut

1;


