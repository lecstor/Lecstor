package Lecstor::Schema::Result::CountryRegion;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);

__PACKAGE__->table('country_region');

__PACKAGE__->add_columns(
  'id'     => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'   => { data_type => 'VARCHAR', size => 64, is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many( 'countries' => 'Lecstor::Schema::Result::Country', 'region' );

=item id

=item name

region name

=cut

1;
