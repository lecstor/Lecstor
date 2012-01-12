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

fixtures_ok 'user'
    => 'installed the product fixtures from configuration files';

use_ok('Lecstor::Model::Controller::User');
use_ok('Lecstor::Model::Controller::Person');
use_ok('Lecstor::Model::Controller::Action');
use_ok('Lecstor::Model::Instance::User');
use_ok('Lecstor::Valid');
use_ok('Lecstor::Request');

my $valid = Lecstor::Valid->new;
my $empty_user = Lecstor::Model::Instance::User->new;
my $current_session_id = 'test01',

my $now = DateTime->now;
my $tomorrow = $now->clone->add( days => 1 );
my $yesterday = $now->clone->subtract( days => 1 );
is $tomorrow->dmy, '02-01-2012', 'tomorrow date ok';
is $yesterday->dmy, '31-12-2011', 'yesterday date ok';

ok my $person_ctrl = Lecstor::Model::Controller::Person->new(
    schema => Schema,
), 'get person_set ok';

ok my $action_ctrl = Lecstor::Model::Controller::Action->new(
    schema => Schema,
    current_user => $empty_user,
    current_session_id => $current_session_id,
), 'get person_set ok';

ok my $user_set = Lecstor::Model::Controller::User->new(
    schema => Schema,
    person_ctrl => $person_ctrl,
    action_ctrl => $action_ctrl,
    validator => $valid,
    request => Lecstor::Request->new( session_id => 'testing123' ),
    current_user => $empty_user,
    current_session_id => $current_session_id,
), 'get user_set ok';

my ($user, $user2, $user3, $user4);

note('Create invalid test users'); {

    $user = $user_set->register({
        username => 'lecstor',
        email => 'bad_email',
        password => 'abcd1234',
    });

    isa_ok $user, 'Lecstor::Error';
    is $user->error, 'A valid email address is required', 'invalid email';

};

note('Create test users'); {

    ok $user = $user_set->create({
        username => 'lecstor',
        email => 'test1@eightdegrees.com.au',
        password => 'abcd1234',
    }), 'create user ok';

    $user2 = $user_set->create({
        username => 'lecstor2',
        email => 'test2@eightdegrees.com.au',
        password => 'abcd1234',
    });

    $user3 = $user_set->create({
        username => 'lecstor3',
        email => 'test3@eightdegrees.com.au',
        password => 'abcd1234',
    });

    $user4 = $user_set->create({
        username => 'lecstor4',
        email => 'test4@eightdegrees.com.au',
        password => 'abcd1234',
    });

}

note('Basic user test'); {

    diag($user->error) if $user->isa('Lecstor::Error');
    is $user->username, 'lecstor', 'username ok';
    is $user->email, 'test1@eightdegrees.com.au', 'email ok';
    is $user->created, '2012-01-01T14:00:00', 'created datetime ok';
    ok $user->check_password('abcd1234'), 'password ok';

}

note('Test temporary passwords'); {

    ok $user->set_temporary_password({
        password => '4321abcd',
        expires => $tomorrow,
    }), 'set temporary password ok';
    ok $user->check_password('4321abcd'), 'temporary password ok';

    ok my $tmp = $user2->set_temporary_password({
        password => '4321abcd',
        expires => $yesterday,
    }), 'set temporary password ok';

    ok !$user2->check_password('4321abcd'), 'expired temporary password failed ok';

}

note('user set inflates results to user model; create, find, search'); {

    isa_ok $user, 'Lecstor::Model::Instance::User';
    isa_ok $user_set->find(1), 'Lecstor::Model::Instance::User';
    isa_ok $user_set->search({ id => 1 })->first, 'Lecstor::Model::Instance::User';

}

note('Test roles'); {

    my @roles;

    eval{ $user->add_to_roles('NoRole') };
    ok $@, 'non-existent role not added ok';
    is $@->message, 'NoRole does not exist', 'exception message ok';

    ok my $role = ResultSet('UserRole')->find({ name => 'Role1' }) => 'Role1 exists ok';

    ok @roles = $user->add_to_roles('Role1'), 'add role by name ok';
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

}


done_testing();
