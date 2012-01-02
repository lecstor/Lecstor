package Lecstor::Schema::Result::LoginTempPass;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime EncodedColumn Core /);

__PACKAGE__->table('login_temp_pass');

__PACKAGE__->add_columns(
  'id'       => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'login'    => { data_type => 'INT', is_nullable => 0 },
  'expires'  => { data_type => 'DATETIME', is_nullable => 0 },

  # Have the 'password' column use a SHA-1 hash and 10-character salt
  # with hex encoding; Generate the 'check_password" method
  'password'         => {
    data_type => 'VARCHAR', size => 128, is_nullable => 0,
    encode_column       => 1,
    encode_class        => 'Digest',
    encode_args         => { algorithm => 'SHA-1', format => 'hex' },
    encode_check_method => 'check_password',
  },
  'modified'         => { data_type => 'TIMESTAMP', is_nullable => 1 },
  'created'          => { data_type => 'DATETIME', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( 'login' => 'Lecstor::Schema::Result::Login' );

=attr login

=attr expires

L<DateTime>

=attr password

=over

=item check_password

  $person->check_password('trypass');

returns true if the supplied password is correct

=item created

L<DateTime>

=item modified

L<DateTime>

=back

=head1 AUTHOR

Jason Galea, E<lt>jason@eightdegrees.com.auE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 Jason Galea

=cut

1;


