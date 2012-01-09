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



ok my $app_container_factory = Lecstor::App::Container->new({
    template_processor => $mock_tt,
}), 'app container factory ok';

ok my $model_container_factory = Lecstor::App::Container::Model->new({
    schema => Schema,
    config => {
        product_search => {
            index_path => 'path/to/index/directory',
            index_create => 1,
            index_truncate => 1,
        },
    }
}), 'model container factory ok';
ok my $model_container = $model_container_factory->build_container => 'model container ok';

ok my $empty_app_container = $app_container_factory->build_container => 'empty app container ok';

ok my $request_container_factory = Lecstor::App::Container::Request->new({
    session_id => 'abc123',
    user => $mock_user,
    uri => $mock_uri,
}), 'request container factory ok';
ok my $request_container = $request_container_factory->build_container => 'request container ok';


ok my $app_container = $empty_app_container->create(
    Model => $model_container,
    Request => $request_container,
), 'app ok';




done_testing();
