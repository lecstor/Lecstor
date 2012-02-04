use strict;
use warnings;
use Test::More;
use Data::Dumper;
use DateTime;
use Bread::Board;

use FindBin qw($Bin);
use lib "$Bin/lib";

use File::Temp 'tempdir';

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_mods) ],
};

fixtures_ok 'login'
    => 'installed the product fixtures from configuration files';

#use_ok('App::WithSchemaMods');
use_ok('Test::AppBasic');

use_ok('App::Model');
use_ok('Lecstor::Lucy::Indexer');
use_ok('Lecstor::Lucy::Searcher');
use_ok('Lecstor::Model::Controller::Action');
use_ok('Lecstor::Model::Controller::User');
use_ok('Lecstor::Model::Controller::Collection');
use_ok('Lecstor::Model::Controller::Product');
use_ok('Lecstor::Model::Controller::Session');
use_ok('Lecstor::Model::Instance::User');
use_ok('Lecstor::Valid');
use_ok('Lecstor::Request');

use_ok('App::Model::Controller::Person');

use_ok('Test::AppBasic');

my $valid = Lecstor::Valid->new;
my $session_id = time;

=pod 

my %ctrls;

$ctrls{person} = App::Model::Controller::Person->new(
    schema => Schema,
);

foreach my $ctrl (qw! Collection Product Session !){
    my $class = 'Lecstor::Model::Controller::'. ucfirst($ctrl);
    $ctrls{lc($ctrl)} = $class->new( schema => Schema, );
}

$ctrls{action} = Lecstor::Model::Controller::Action->new(
    schema => Schema,
);

$ctrls{user} = Lecstor::Model::Controller::User->new(
    schema => Schema,
    validator => $valid,
    person_ctrl => $ctrls{person},
);

=cut

my $lucy_index = tempdir( CLEANUP => 1);

my $app = App::Model->new(
    schema => Schema,
    validator => $valid,
    product_indexer => Lecstor::Lucy::Indexer->new(
        index_path => $lucy_index,
        create => 1,
        truncate => 1,
    ),
    product_searcher => Lecstor::Lucy::Searcher->new(
        index_path => $lucy_index,
    ),
);

Test::AppBasic::run($app, Schema);

ok my $person_set = $app->person, 'get person_set ok';

isa_ok $person_set, 'App::Model::Controller::Person';

ok my $fred = $person_set->create({
    firstname => 'Fred',
    surname => 'Flintstone',
    email => 'test2@eightdegrees.com.au',
}), 'create person ok';

ok my $jason = $person_set->search({ firstname => 'Jason' })->first, 'found jason ok';

ok $jason->add_to_friends($fred), 'add to friends ok';

is_deeply [map { $_->name } $jason->friends], ['Fred Flintstone'], 'friends ok';

done_testing();


