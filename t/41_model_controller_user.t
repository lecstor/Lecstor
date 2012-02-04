use strict;
use warnings;
use Test::More;
use Try::Tiny;
use Test::Exception;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
};

fixtures_ok 'user'
    => 'installed the product fixtures from configuration files';

use_ok('Lecstor::Model::Controller::User');
use_ok('Lecstor::Model::Controller::Person');
use_ok('Lecstor::Model::Controller::Action');
use_ok('Lecstor::Model::Instance::User');
use_ok('Lecstor::Model::Instance::Action');
use_ok('Lecstor::Model::Instance::Person');
use_ok('Lecstor::Request');
use_ok('Lecstor::Valid');

my $validator = Lecstor::Valid->new;
my $session_id = time;
my $current_user = Lecstor::Model::Instance::User->new();

ok my $user_ctrl = Lecstor::Model::Controller::User->new({
    schema => Schema,
    validator => $validator,
    person_ctrl => Lecstor::Model::Controller::Person->new({ schema => Schema }),
}), 'get controller ok';

ok my $user = $user_ctrl->create({
    username => 'lecstor',
    email => 'jason@lecstor.com',
}), 'create user ok';
isa_ok $user, 'Lecstor::Model::Instance::User';
my $user_id = $user->id;

ok $user = $user_ctrl->find($user_id), 'find ok';
is $user->id, $user_id, 'id ok';
isa_ok $user, 'Lecstor::Model::Instance::User';

ok my $user_rs = $user_ctrl->search({ id => $user_id }), 'search ok';
isa_ok $user_rs, 'DBIx::Class::ResultSet';
ok $user = $user_rs->first, 'first ok';
isa_ok $user, 'Lecstor::Model::Instance::User';

ok my $user_rsc = $user_ctrl->search_for_id({ id => $user_id }), 'search_for_id ok';
isa_ok $user_rsc, 'DBIx::Class::ResultSetColumn';
is_deeply [$user_rsc->all], [$user_id], 'rsc all ok';

ok $user = $user_ctrl->find_or_create({ username => 'lecstor' }), 'find_or_create (find) ok';
is $user->id, $user_id, 'id ok';
isa_ok $user, 'Lecstor::Model::Instance::User';

ok my $user2 = $user_ctrl->find_or_create({ username => 'lecstor2' }), 'find_or_create (create) ok';
is $user2->id, $user_id+1, 'id ok';
isa_ok $user2, 'Lecstor::Model::Instance::User';

throws_ok { $user_ctrl->register({
    username => 'lecstor',
    email => 'jason@lecstor.com',
}) } 'Lecstor::X', 'Lecstor::X thrown';
is $@->message, 'That email address is already registered', 'error message ok';

throws_ok { $user_ctrl->register({
    username => 'lecstor',
    email => 'jason@lecstor.com',
    password => '',
}) } 'Lecstor::X', 'Lecstor::X thrown';
is $@->message, 'Invalid Input', 'error message ok';
is $@->fields->{password}[0], 'Password is required', 'error message ok';

throws_ok { $user_ctrl->register({
    username => 'lecstor',
    email => 'test1@eightdegrees.com.au',
    password => 'aaaaaaaa',
}) } 'Lecstor::X', 'Lecstor::X thrown';
is $@->message, 'That username is already registered', 'error message ok';

ok $user = $user_ctrl->register({
    email => 'test1@eightdegrees.com.au',
    password => 'aaaaaaaa',
}), 'register user ok';
isa_ok $user, 'Lecstor::Model::Instance::User';

ok $user = $user_ctrl->register({
    username => 'lecstor3',
    email => 'test2@eightdegrees.com.au',
    password => 'aaaaaaaa',
}), 'register user ok';
isa_ok $user, 'Lecstor::Model::Instance::User';

done_testing();














