use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
}, 'Person';

use_ok('Lecstor::Model::Instance::Person');

ok my $rs = ResultSet('Person'), 'resultset ok';

ok my $person_row = $rs->create({
    created => DateTime->now(),
    firstname => 'Jason',
    surname => 'Galea',
    email => 'test1@eightdegrees.com.au',
    homephone => '0123456789',
    workphone => '0123456789',
    mobile => '0123456789',
}), 'create person ok';

ok my $person = Lecstor::Model::Instance::Person->new({
    _record => $person_row
}), 'create person instance ok';

is $person->name, 'Jason Galea', 'name ok';
is $person->email, 'test1@eightdegrees.com.au', 'email ok';
is $person->homephone, '0123456789', 'homephone ok';
is $person->workphone, '0123456789', 'workphone ok';
is $person->mobile, '0123456789', 'mobile ok';

ok !$person->delivery_address, 'delivery_address not set ok';


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

ok $bill_addr = $person->set_billing_address({
    street => '123 Other St',
    country => 1,
}), 'set billing_address ok';
is $bill_addr->street, '123 Other St', 'street ok';
is $bill_addr->country->name, 'Australia', 'country ok';

eval{ $person->set_billing_address({ street => '123 Other St' }) };
my $x = $@;
ok $x, 'exception caught';
is $x->message, 'Billing address requires a country', 'message ok';

eval{ $person->name('new name') };
$x = $@;
ok $x, 'exception caught';
is $x->message, '$self->name is readonly', 'message ok';

done_testing();

