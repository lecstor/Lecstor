use strict;
use warnings;
use Test::More;
use Data::Dumper;
use DateTime;
use Bread::Board;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_mods) ],
};

fixtures_ok 'login'
    => 'installed the product fixtures from configuration files';

use_ok('App::WithSchemaMods');
use_ok('Test::AppBasic');

my $app = App::WithSchemaMods->new( schema => Schema );

Test::AppBasic::run($app, Schema);

ok my $person_set = $app->person, 'get person_set ok';

isa_ok $person_set, 'App::Set::Person';

ok my $fred = $person_set->create({
    firstname => 'Fred',
    surname => 'Flintstone',
    email => 'test2@eightdegrees.com.au',
}), 'create person ok';

ok my $jason = $person_set->search({ firstname => 'Jason' })->first, 'found jason ok';

ok $jason->add_to_friends($fred), 'add to friends ok';

is_deeply [map { $_->name } $jason->friends], ['Fred Flintstone'], 'friends ok';

done_testing();


