package Lecstor::Schema::Result::Login;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime EncodedColumn Core /);

__PACKAGE__->table('login');

__PACKAGE__->add_columns(
  'id'               => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'username'         => { data_type => 'VARCHAR', size =>  32, is_nullable => 1 },
  'email'            => { data_type => 'VARCHAR', size => 128, is_nullable => 1 },
  'person'           => { data_type => 'INT', is_nullable => 1 },

  # Have the 'password' column use a SHA-1 hash and 10-character salt
  # with hex encoding; Generate the 'check_password" method
  'password'         => {
    data_type => 'VARCHAR', size => 128, is_nullable => 1,
    encode_column       => 1,
    encode_class        => 'Digest',
    encode_args         => { algorithm => 'SHA-1', format => 'hex' },
    encode_check_method => 'check_password',
  },

  'active'           => { data_type => 'INT', is_nullable => 1, default_value => 1 },
  'modified'         => { data_type => 'TIMESTAMP', is_nullable => 1 },
  'created'          => { data_type => 'DATETIME', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['email']);
__PACKAGE__->add_unique_constraint(['username']);

__PACKAGE__->belongs_to( person => 'Lecstor::Schema::Result::Person'    );

__PACKAGE__->has_many(login_to_role_maps => 'Lecstor::Schema::Result::LoginToRoleMap', 'login');
__PACKAGE__->many_to_many(roles => 'login_to_role_maps', 'role');

__PACKAGE__->might_have( temporary_password => 'Lecstor::Schema::Result::LoginTempPass', 'login' );

sub inflate_result {
    my $self = shift;
    my $ret = $self->next::method(@_);
    return unless $ret;
    return Lecstor::Model::Login->new( data => $ret );
}
 

=attr id

=attr email

=attr username

=attr created

L<DateTime>

=attr modified

L<DateTime>

=attr active

=method roles

returns a list of L<LoginRole> objects

=cut

1;


