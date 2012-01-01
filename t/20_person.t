use strict;
use warnings;
use Test::More;
use Data::Dumper;
use DateTime;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
}, 'Person';

use_ok('Lecstor::Set::Person');

ok my $person_set = Lecstor::Set::Person->new( schema => Schema ), 'get person_set ok';

ok my $person = $person_set->create({
    firstname => 'Jason',
    surname => 'Galea',
    email => 'test1@eightdegrees.com.au',
    homephone => '0123456789',
    workphone => '0123456789',
    mobile => '0123456789',
}), 'create person ok';

isa_ok $person, 'Lecstor::Model::Person';
is $person->firstname, 'Jason', 'firstname ok';
is $person->surname, 'Galea', 'surname ok';
is $person->created, '2012-01-01T14:00:00', 'created datetime ok';

ok my $del_addr = $person->add_to_delivery_addresses({
    street => '123 Test St',
    country => { name => 'Australia' },
}), 'add_to_delivery_addresses ok';

ok $person->delivery_address, 'delivery_address ok';

ok my $bill_addr = $person->set_billing_address({
    street => '123 Other St',
    country => 'Australia',
}), 'set billing_address ok';
is $bill_addr->street, '123 Other St', 'street ok';
is $bill_addr->country->name, 'Australia', 'country ok';

ok $person = $person_set->find($person->id), 'find ok';
isa_ok $person, 'Lecstor::Model::Person';
is $person->firstname, 'Jason', 'firstname ok';

ok $person = $person_set->search({ id => $person->id })->first, 'search first ok';
isa_ok $person, 'Lecstor::Model::Person';
is $person->firstname, 'Jason', 'firstname ok';

done_testing();
