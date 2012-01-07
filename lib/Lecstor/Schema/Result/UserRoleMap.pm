package Lecstor::Schema::Result::LoginToRoleMap;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('login_to_role_map');

__PACKAGE__->add_columns(
  'id'      => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'login'   => { data_type => 'INT', is_nullable => 1 },
  'role'    => { data_type => 'INT', is_nullable => 1 },

  'modified'         => { data_type => 'TIMESTAMP', is_nullable => 1 },
  'created'          => { data_type => 'DATETIME', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint([qw! login role !]);

__PACKAGE__->belongs_to( login => 'Lecstor::Schema::Result::Login'    );

__PACKAGE__->belongs_to( role => 'Lecstor::Schema::Result::LoginRole'    );
 
=attr id

=attr login

=attr role

=attr created

L<DateTime>

=attr modified

L<DateTime>

=cut

1;


