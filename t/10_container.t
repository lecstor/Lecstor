use strict;
use warnings;
use Test::More;
use Data::Dumper;
use DateTime;

use FindBin qw($Bin);
use lib "$Bin/lib";

#use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
}, 'Person';

fixtures_ok 'user'
    => 'installed the product fixtures from configuration files';

use_ok('Lecstor::App::Container');
use_ok('Lecstor::App::Container::Model');
use_ok('Lecstor::App::Container::Request');

my $mock_tt = bless {}, 'Template';
my $mock_uri = bless {}, 'URI';
my $mock_user = bless {}, 'Lecstor::Model::Instance::User';



ok my $model_container = Lecstor::App::Container::Model->new({
    schema => Schema,
    config => {
        product_search => {
            index_path => 'path/to/index/directory',
            index_create => 1,
            index_truncate => 1,
        },
    }
}), 'model container ok';

ok my $request_container = Lecstor::App::Container::Request->new({
    session_id => 'abc123',
#    user => $mock_user,
    uri => $mock_uri,
}), 'request container ok';

ok my $app_container_factory = Lecstor::App::Container->new({
    template_processor => $mock_tt,
}), 'app container ok';

ok my $empty_app_container = $app_container_factory->builder => 'empty app container ok';

ok my $app_container = $empty_app_container->create(
    Model => $model_container,
    Request => $request_container,
), 'app ok';

ok $app_container = $app_container_factory->create(
    Model => $model_container,
    Request => $request_container,
), 'app container ok';

ok my $app = $app_container->fetch('app')->get, 'app ok';

ok my $person = $app->model->person->create({
    firstname => 'Jason',
    surname => 'Galea',
    email => 'test1@eightdegrees.com.au',
    homephone => '0123456789',
}) => 'create person ok';

ok my $user = $app->model->user->create({
    username => 'lecstor',
    email => 'test1@eightdegrees.com.au',
    password => 'abcd1234',
}) => 'create user ok';

ok $user->person($person->id), 'set user person ok';
$user->update;

$user = $app->model->user->register({
    username => 'lecstor',
    email => 'test1@eightdegrees.com.au',
    password => 'abcd1234',
});
ok !$user, 'register failed ok';
is $user->error, 'That email address is already registered', 'error ok';

ok $user = $app->model->user->register({
    username => 'lecstor2',
    email => 'test2@eightdegrees.com.au',
    password => 'abcd1234',
}), 'register ok';

TODO: {
    local $TODO = 'cos I really gotta go to bed..';
    eval{
        $user = $app->model->user->register({
            username => 'lecstor',
            email => 'jason@lecstor.com',
            password => 'abcd1234',
        });
    };
    diag($@);
    ok $user, 'register ok';
}

done_testing();
