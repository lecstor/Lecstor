use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
}, 'Person';

use_ok('Lecstor::Model::Controller::Action');
use_ok('Lecstor::Model::Instance::User');

my $session_id = time;
my $current_user = Lecstor::Model::Instance::User->new();

ok my $ctrl = Lecstor::Model::Controller::Action->new(
    schema => Schema,
    current_session_id => $session_id,
    current_user => $current_user,
), 'get person_ctrl ok';

ok my $instance = $ctrl->create({
    type => { name => 'test1' },
    session => $session_id,
    data => { something => 'boring' },
#    user => $current_user->id,
}), 'create action ok';

isa_ok $instance, 'Lecstor::Model::Instance::Action';
is $instance->type->name, 'test1', 'type ok';

ok $instance = $ctrl->find($instance->id), 'find ok';
isa_ok $instance, 'Lecstor::Model::Instance::Action';
is $instance->type->name, 'test1', 'type ok';

done_testing();