use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
}, 'Person';

use_ok('Lecstor::Model::Controller::Person');
use_ok('Lecstor::Model::Instance::Person');

ok my $person_ctrl = Lecstor::Model::Controller::Person->new(
    schema => Schema,
), 'get person_ctrl ok';

ok my $person = $person_ctrl->create({
    firstname => 'Jason',
    surname => 'Galea',
    email => 'test1@eightdegrees.com.au',
    homephone => '0123456789',
    workphone => '0123456789',
    mobile => '0123456789',
}), 'create person ok';

isa_ok $person, 'Lecstor::Model::Instance::Person';
is $person->firstname, 'Jason', 'firstname ok';

ok $person = $person_ctrl->find($person->id), 'find ok';
isa_ok $person, 'Lecstor::Model::Instance::Person';
is $person->firstname, 'Jason', 'firstname ok';

done_testing();