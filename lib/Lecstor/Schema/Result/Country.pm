package Lecstor::Schema::Result::Country;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);

__PACKAGE__->table('country');

__PACKAGE__->add_columns(
  'id'         => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
  'name'       => { data_type => 'VARCHAR', size => 64, is_nullable => 0 },
  'region'     => { data_type => 'INT', is_nullable => 0 },
  'public'     => { data_type => 'INT', is_nullable => 1 },
  'sort_order' => { data_type => 'INT', is_nullable => 1 },
  'tax'        => { data_type => 'INT', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( region => 'Lecstor::Schema::Result::CountryRegion' );

__PACKAGE__->add_unique_constraint([ qw/name/ ]);


=item id

=item name

country name

=item region

L<Lecstor7::DB::Result::Country::Region>

=item public

do we display this country in country lists for registration?

=item tax

true if tax is payable by this country. 

=cut

1;
