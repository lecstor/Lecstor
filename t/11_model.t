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
};

fixtures_ok 'login'
    => 'installed the product fixtures from configuration files';

use_ok('Lecstor::Model');
use_ok('Test::AppBasic');

my $app = Lecstor::Model->new( schema => Schema );

Test::AppBasic::run($app, Schema);

ok my $user_set = $app->user, 'get login_set ok';

isa_ok $user_set, 'Lecstor::Model::Controller::User';

ok my $user = $user_set->find(1), 'found login ok';

is $user->active, 1, 'login active ok';

done_testing();


