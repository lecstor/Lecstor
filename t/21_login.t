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

use_ok('Lecstor::Set::Login');

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


done_testing();
