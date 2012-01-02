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

fixtures_ok 'login'
    => 'installed the product fixtures from configuration files';

use_ok('Lecstor::Set::Login');

my $now = DateTime->now;
my $tomorrow = $now->clone->add( days => 1 );
my $yesterday = $now->clone->subtract( days => 1 );
is $tomorrow->dmy, '02-01-2012', 'tomorrow date ok';
is $yesterday->dmy, '31-12-2011', 'yesterday date ok';


ok my $login_set = Lecstor::Set::Login->new( schema => Schema ), 'get login_set ok';

ok my $login = $login_set->create({
    username => 'lecstor',
    email => 'test1@eightdegrees.com.au',
    password => 'abcd1234',
}), 'create login ok';

diag($login->error) if $login->isa('Lecstor::Error');

isa_ok $login, 'Lecstor::Model::Login';
is $login->username, 'lecstor', 'username ok';
is $login->email, 'test1@eightdegrees.com.au', 'email ok';
is $login->created, '2012-01-01T14:00:00', 'created datetime ok';
ok $login->check_password('abcd1234'), 'password ok';

ok $login->set_temporary_password({
    password => '4321abcd',
    expires => $tomorrow,
}), 'set temporary password ok';

ok $login->check_password('4321abcd'), 'temporary password ok';

my @roles;

ok @roles = $login->add_to_roles('Role1'), 'add role by name ok';
isa_ok $roles[0], 'Lecstor::Schema::Result::LoginRole';
is $roles[0]->name, 'Role1', 'role name ok';


my $login2 = $login_set->create({
    username => 'lecstor2',
    email => 'test2@eightdegrees.com.au',
    password => 'abcd1234',
});

ok my $tmp = $login2->set_temporary_password({
    password => '4321abcd',
    expires => $yesterday,
}), 'set temporary password ok';

ok !$login2->check_password('4321abcd'), 'expired temporary password failed ok';


ok $login2->add_to_roles(qw! Role1 Role3 !), 'add roles by name ok';
is_deeply [qw! Role1 Role3 !], [sort map{ $_->name } $login2->roles], 'role names ok';
is_deeply [qw! Role1 Role3 !], [$login2->roles_by_name], 'roles by name ok';

@roles = ResultSet('LoginRole')->all;

my $login3 = $login_set->create({
    username => 'lecstor3',
    email => 'test3@eightdegrees.com.au',
    password => 'abcd1234',
});

ok $login3->add_to_roles($roles[0]), 'add role by object ok';
is_deeply [qw! Role1 !], [$login3->roles_by_name], 'roles by name ok';


my $login4 = $login_set->create({
    username => 'lecstor4',
    email => 'test4@eightdegrees.com.au',
    password => 'abcd1234',
});

ok $login4->add_to_roles(@roles), 'add roles by object ok';
is_deeply [qw! Role1 Role2 Role3 !], [$login4->roles_by_name], 'roles by name ok';



done_testing();
