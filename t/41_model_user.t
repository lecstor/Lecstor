use strict;
use warnings;
use Test::More;
use Try::Tiny;

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
use_ok('Lecstor::Request');
use_ok('Lecstor::Valid');

my $validator = Lecstor::Valid->new;
my $session_id = time;
my $current_user = Lecstor::Model::Instance::User->new();

ok my $user_ctrl = Lecstor::Model::Controller::User->new({
    schema => Schema,
    current_session_id => $session_id,
    current_user => $current_user,
    validator => $validator,
    person_ctrl => Lecstor::Model::Controller::Person->new({ schema => Schema }),
    action_ctrl => Lecstor::Model::Controller::Action->new({
        schema => Schema,
        current_session_id => $session_id,
        current_user => $current_user,
    }),
}), 'get controller ok';

my ($user, $user2, $user3, $user4);

ok !Lecstor::Model::Instance::User->new, 'empty user returns false ok';

ok $user = $user_ctrl->create({
    username => 'lecstor',
    email => 'jason@lecstor.com',
}), 'create user ok';
my $user_id = $user->id;

ok $user = $user_ctrl->find($user_id), 'find ok';
is $user->id, $user_id, 'id ok';

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

ok $user2 = $user_ctrl->find_or_create({ username => 'lecstor2' }), 'find_or_create (create) ok';
is $user2->id, $user_id+1, 'id ok';
isa_ok $user2, 'Lecstor::Model::Instance::User';

ok $user3 = $user_ctrl->create({
    username => 'lecstor3',
    email => 'test1@eightdegrees.com.au',
    password => 'abcd1234',
}), 'create user ok';
isa_ok $user3, 'Lecstor::Model::Instance::User';
ok $user3->check_password('abcd1234'), 'check_password ok';

ok $user3->set_temporary_password({
    password => '4321abcd',
    expires => DateTime->now->add( days => 1 ),
}) => 'set_temporary_password ok';
ok $user3->check_password('4321abcd'), 'check_password (tmp pass) ok';

ok $user3->set_temporary_password({
    password => 'dcba4321',
    expires => DateTime->now->subtract( days => 1 ),
}) => 'set_temporary_password (expired) ok';
ok !$user3->check_password('dcba4321'), 'check_password (expired tmp pass) ok';

$user4 = $user_ctrl->create({
    username => 'lecstor4',
    email => 'test4@eightdegrees.com.au',
    password => 'abcd1234',
});

note('Test roles'); {

    my @roles;

    eval{ $user->add_to_roles('NoRole') };
    ok $@, 'non-existent role not added ok';
    is $@->message, 'NoRole does not exist', 'exception message ok';

    ok my $role = ResultSet('UserRole')->find({ name => 'Role1' }) => 'Role1 exists ok';

    ok @roles = $user->add_to_roles({ name => 'Role1' }), 'add role by name ok';
    isa_ok $roles[0], 'Lecstor::Schema::Result::UserRole';
    is $roles[0]->name, 'Role1', 'role name ok';

    ok $user2->add_to_roles(qw! Role1 Role3 !), 'add roles by name ok';
    is_deeply [qw! Role1 Role3 !], [sort map{ $_->name } $user2->roles], 'role names ok';
    is_deeply [qw! Role1 Role3 !], [$user2->roles_by_name], 'roles by name ok';

    @roles = ResultSet('UserRole')->all;

    ok $user3->add_to_roles($roles[0]), 'add role by object ok';
    is_deeply [qw! Role1 !], [$user3->roles_by_name], 'roles by name ok';

    ok $user4->add_to_roles(@roles), 'add roles by object ok';
    is_deeply [qw! Role1 Role2 Role3 !], [$user4->roles_by_name], 'roles by name ok';

    try{
        ok @roles = $user->add_to_roles((bless {}, 'NotARow')), 'add bad object as role ok';
    } catch {
        my $error = $_;
        ok $error->does('Throwable::X') => 'got exception ok';
        is $error->message, 'Roles must be either a string, hashref, or DBIx::Class::Row', 'exception message ok';
    }
}

done_testing();


















