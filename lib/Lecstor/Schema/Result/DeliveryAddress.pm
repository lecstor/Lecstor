package Lecstor::Schema::Result::DeliveryAddress;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);

__PACKAGE__->table('delivery_address');

__PACKAGE__->add_columns(
  'id'        => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'modified'  => { data_type => 'TIMESTAMP', is_nullable => 1 },
  'created'   => { data_type => 'DATETIME', is_nullable => 1 },
  'person'    => { data_type => 'INT', is_nullable => 0 },
  'name'      => { data_type => 'VARCHAR', size =>  60, is_nullable => 1 },
  'company'   => { data_type => 'VARCHAR', size => 130, is_nullable => 1 },
  'street'    => { data_type => 'VARCHAR', size => 255, is_nullable => 0 },
  'suburb'    => { data_type => 'VARCHAR', size => 130, is_nullable => 1 },
  'state'     => { data_type => 'VARCHAR', size => 130, is_nullable => 1 },
  'postcode'  => { data_type => 'VARCHAR', size => 12,  is_nullable => 1 },
  'country'   => { data_type => 'INT', is_nullable => 0 },
  'phone'     => { data_type => 'VARCHAR', size =>  16, is_nullable => 1 },
  'active'    => { data_type => 'TINYINT', is_nullable => 1, default_value => 1 },
  'post_office_box'    => { data_type => 'INT', is_nullable => 1 },
  'instructions'       => { data_type => 'VARCHAR', size => 255, is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( person => 'Lecstor::Schema::Result::Person' );

__PACKAGE__->belongs_to( country => 'Lecstor::Schema::Result::Country' );

__PACKAGE__->add_unique_constraint([ qw/person name company street suburb state postcode phone country/ ]);

=item id

=item modified

L<Lecstor7::DateTime>

=item person

L<Lecstor7::DB::Person>

=item company

=item street

=item suburb

=item state

=item postcode

=item country

L<Lecstor7::DB::Country>

=item phone

=item active

=item max_dispatch_value

=item post_office_box

=item instructions

=cut

1;
