package Lecstor::Schema::Result::BillingAddress;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);

__PACKAGE__->table('billing_address');

# the person column is required to identify inactive addresses
__PACKAGE__->add_columns(
  'id'        => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'modified'  => { data_type => 'TIMESTAMP', is_nullable => 1 },
  'created'   => { data_type => 'DATETIME', is_nullable => 1 },
  'name'      => { data_type => 'VARCHAR', size =>  60, is_nullable => 1 },
  'company'   => { data_type => 'VARCHAR', size => 130, is_nullable => 1 },
  'street'    => { data_type => 'VARCHAR', size => 255, is_nullable => 0 },
  'suburb'    => { data_type => 'VARCHAR', size => 130, is_nullable => 1 },
  'state'     => { data_type => 'VARCHAR', size => 130, is_nullable => 1 },
  'postcode'  => { data_type => 'VARCHAR', size => 12,  is_nullable => 1 },
  'country'   => { data_type => 'INT', is_nullable => 0 },
  'active'    => { data_type => 'TINYINT', is_nullable => 1, default_value => 1 },
);

__PACKAGE__->set_primary_key('id');

#__PACKAGE__->belongs_to( country => 'Lecstor7::DB::Result::Country' );

__PACKAGE__->add_unique_constraint(
  full => [ qw/name company street suburb state postcode country/ ],
);

=item id

=item modified

L<DateTime>

=item company

=item street

=item suburb

=item state

=item postcode

=item country

L<EzyApp::DB::Country>

=item active

=cut

1;
