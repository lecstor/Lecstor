use strict;
use warnings;
use Test::More;
use Data::Dumper;
use DateTime;
use Bread::Board;

BEGIN {
    eval "use Test::postgresql"; if($@) {
        plan skip_all => 'Test::postgresql not installed';
    }

    # we need the connect_opts option for this test
    use Test::DBIx::Class::SchemaManager;
    unless (Test::DBIx::Class::SchemaManager->meta->has_attribute('connect_info_with_opts')){
        Test::DBIx::Class::SchemaManager->meta->make_mutable;
        Test::DBIx::Class::SchemaManager->meta->add_attribute(
            'connect_opts' => ( is => 'ro', isa => 'HashRef' )
        );
        Test::DBIx::Class::SchemaManager->meta->add_attribute(
            'connect_info_with_opts' => ( is => 'ro', isa => 'HashRef', lazy_build => 1 )
        );
        Test::DBIx::Class::SchemaManager->meta->add_method(
            '_build_schema' => sub{
                my $self = shift @_;
                my $schema_class = $self->schema_class;
                my $connect_info = $self->connect_info_with_opts;
                return unless $schema_class;
                $schema_class = $self->prepare_schema_class($schema_class);
                return $schema_class->connect($connect_info);
            }
        );
        Test::DBIx::Class::SchemaManager->meta->add_method(
            '_build_connect_info_with_opts' => sub{
                my ($self) = @_;
                return { %{$self->connect_info}, %{$self->connect_opts || {}} };
            }
        );
        Test::DBIx::Class::SchemaManager->meta->make_immutable;
    }
}

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
    traits => [qw!Testpostgresql!],
    connect_opts => { name_sep => '.', quote_char => '"', },
};

fixtures_ok 'user'
    => 'installed the product fixtures from configuration files';

use_ok('App::Basic');
use_ok('Test::AppBasic');

my $app = App::Basic->new( schema => Schema );

Test::AppBasic::run($app, Schema);

ok my $user_set = $app->user, 'get login_set ok';

isa_ok $user_set, 'Lecstor::Model::Controller::User';

ok my $user = $user_set->find(1), 'found user ok';

is $user->active, 1, 'user active ok';

done_testing();


