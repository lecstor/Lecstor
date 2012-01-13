{
    package ActionLogger;
    use Moose;

    has current_user => ( is => 'ro', required => 1 );

    has current_session_id => ( is => 'ro', required => 1 );

    with 'Lecstor::Role::ActionLogger';
}

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
};

use_ok('Lecstor::Model::Controller::Action');
use_ok('Lecstor::Model::Controller::User');
use_ok('Lecstor::Model::Controller::Person');
use_ok('Lecstor::Model::Instance::User');
use_ok('Lecstor::Valid');

my $validator = Lecstor::Valid->new;

my $action_ctrl = Lecstor::Model::Controller::Action->new(
    schema => Schema,
    current_session_id => 'abc123',
    current_user => Lecstor::Model::Instance::User->new,
);

my $person_ctrl = Lecstor::Model::Controller::Person->new(
    schema => Schema,
);

my $user = Lecstor::Model::Controller::User->new(
    schema => Schema,
    validator => $validator,
    action_ctrl => $action_ctrl,
    person_ctrl => $person_ctrl,
    current_session_id => 'abc123',
    current_user => Lecstor::Model::Instance::User->new,
)->create({ email => 'jason@lecstor.com' });


ok my $logger = ActionLogger->new(
    action_ctrl => $action_ctrl,
    current_session_id => 'abc123',
    current_user => Lecstor::Model::Instance::User->new,
) => 'new action logger ok';

ok my $action = $logger->log_action('test1') => 'log action with type';
isa_ok $action, 'Lecstor::Model::Instance::Action';
is $action->type->name, 'test1', 'type ok';
is $action->data, undef, 'data ok';

ok $logger = ActionLogger->new(
    action_ctrl => Lecstor::Model::Controller::Action->new(
        schema => Schema,
        current_session_id => 'abc123',
        current_user => $user,
    ),
    current_session_id => 'abc123',
    current_user => $user,
) => 'new action logger ok';

ok $action = $logger->log_action('test1' => { with => 'data' }) => 'log action with type and data';
isa_ok $action, 'Lecstor::Model::Instance::Action';
is $action->type->name, 'test1', 'type ok';
is_deeply $action->data, { with => 'data' }, 'data ok';


done_testing();