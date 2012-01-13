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

use_ok('Lecstor::Model::Instance::User');

ok my $rs = ResultSet('User'), 'resultset ok';

ok my $user_row = $rs->create({
    created => DateTime->now(),
    username => 'lecstor',
    email => 'jason@lecstor.com',
    password => 'abcd1234',
}), 'create user row ok';

ok my $user = Lecstor::Model::Instance::User->new({
    _record => $user_row
}), 'create user instance ok';

my $empty_user = Lecstor::Model::Instance::User->new();
ok !$empty_user, 'create empty user instance ok';
isa_ok $empty_user, 'Lecstor::Model::Instance::User';

ok $empty_user->set_record($user), 'set empty user record';
is $empty_user->id, $user_row->id, 'user id ok';

ok $user->check_password('abcd1234'), 'check_password ok';

ok $user->set_temporary_password({
    password => '87654321',
    expires => DateTime->now->subtract( days => 1 ),
}), 'set temporary password ok';
ok $user->check_password('87654321'), 'check_password (tmp) ok';

eval{ $user->add_to_roles('NoRole') };
ok $@, 'non-existent role not added ok';
is $@->message, "Role: 'NoRole' does not exist", 'exception message ok';

my @roles;

ok @roles = $user->add_to_roles('Role1'), 'add role by name ok';
isa_ok $roles[0], 'Lecstor::Schema::Result::UserRole';
is $roles[0]->name, 'Role1', 'role name ok';

ok $user->add_to_roles(qw! Role2 Role3 !), 'add roles by name ok';
is_deeply [qw! Role1 Role2 Role3 !], [sort map{ $_->name } $user->roles], 'role names ok';
is_deeply [qw! Role1 Role2 Role3 !], [$user->roles_by_name], 'roles by name ok';

try{
    ok @roles = $user->add_to_roles((bless {}, 'NotARow')), 'add bad object as role ok';
} catch {
    my $error = $_;
    ok $error->does('Throwable::X') => 'got exception ok';
    is $error->message, 'Roles must be added by name only. Roles not added.', 'exception message ok';
};

try{
    ok @roles = $user->add_to_roles({}), 'add hashref as role ok';
} catch {
    my $error = $_;
    ok $error->does('Throwable::X') => 'got exception ok';
    is $error->message, 'Roles must be added by name only. Roles not added.', 'exception message ok';
};

done_testing();

