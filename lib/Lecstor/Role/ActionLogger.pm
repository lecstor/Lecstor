package Lecstor::Role::ActionLogger;
use Moose::Role;
use Data::Dumper;

requires 'current_user', 'current_session_id';

has action_ctrl => ( isa => 'Lecstor::Model::Controller', is => 'ro', required => 1 );

=method log_action

=cut

sub log_action{
    my ($self, $type, $data) = @_;

    my $action = {
        type => { name => $type },
        session => $self->current_session_id,
    };

    $data->{caller} = join(' - ', (caller)[0,2]);

    $action->{data} = $data if $data;
#    $action->{user} = $self->request->user->id if $self->request->user;
    $action->{user} = $self->current_user->id if $self->current_user;

    if ($ENV{LECSTOR_DEBUG}){
        warn "[ACTION] $type ".$self->current_session_id.' '.($action->{user} || '')."\n";
        warn Dumper($data) if $data;
    }

    $self->action_ctrl->create($action);
}


1;
