package Lecstor::Schema::Result::Person;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('person');

__PACKAGE__->add_columns(
  'id'               => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'firstname'        => { data_type => 'VARCHAR', size =>  32, is_nullable => 1 },
  'surname'          => { data_type => 'VARCHAR', size =>  32, is_nullable => 1 },
  'billing_address'  => { data_type => 'INT', is_nullable => 1 },
  'default_delivery' => { data_type => 'INT', is_nullable => 1 },
  'active'           => { data_type => 'INT', is_nullable => 1, default_value => 1 },
  'email'            => { data_type => 'VARCHAR', size => 128, is_nullable => 1 },
  'homephone'        => { data_type => 'VARCHAR', size =>  32, is_nullable => 1 },
  'workphone'        => { data_type => 'VARCHAR', size =>  32, is_nullable => 1 },
  'mobile'           => { data_type => 'VARCHAR', size =>  32, is_nullable => 1 },
  'fax'              => { data_type => 'VARCHAR', size =>  32, is_nullable => 1 },

  'modified'         => { data_type => 'TIMESTAMP', is_nullable => 1 },
  'created'          => { data_type => 'DATETIME', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( billing_address  => 'Lecstor::Schema::Result::BillingAddress'    );

#__PACKAGE__->has_many(person2role_maps => 'Person::MapRole', 'person');
#__PACKAGE__->many_to_many(roles => 'person2role_maps', 'role');

__PACKAGE__->has_many  ( delivery_addresses => 'Lecstor::Schema::Result::DeliveryAddress',    'person' );

#__PACKAGE__->add_unique_constraint(['email']);

#__PACKAGE__->might_have( temp_pass => 'Person::TempPass', 'person' );

sub inflate_result {
    Lecstor::Model::Instance::Person->new( _record => shift->next::method(@_) );
}
 

=attr id

=attr firstname

=attr surname

=attr billing_address

L<Person::Address>

=attr active

=attr email

=attr homephone

=attr workphone

=attr mobile

=attr fax

=attr created

L<DateTime>

=attr modified

L<DateTime>

=attr active

=method roles

returns a list of L<Person::Role> objects

=method delivery_addresses

returns a list of L<Person::DeliveryAddress> objects

=cut

1;


