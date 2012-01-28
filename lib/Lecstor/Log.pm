package Lecstor::Log;
use Moose;
use Data::Dumper;

# ABSTRACT: Log stuff

=attr action_ctrl

=cut

has action_ctrl => ( isa => 'Lecstor::Model::Controller', is => 'ro', required => 1 );

=method action

    $log->action(
        { session => 'abc123', user => 123 },
        'login fail',
        { misc => 'data' }
    );

=cut

sub action{
    my ($self, $session, $type, $data) = @_;

    my $action = {
        session => $session->id,
        type => { name => $type },
    };
    $action->{user} = $session->user->id if $session->user;
    $action->{data} = $data if $data;

    $self->action_ctrl->create($action);

    if ($ENV{LECSTOR_DEBUG}){
        warn "[ACTION] $type " . $action->{session}
            . ' ' . ($action->{user} || '')."\n";
        warn Dumper($data) if $data;
    }

}

sub debug{
    return unless $ENV{LECSTOR_DEBUG};
    my ($self, @lines) = @_;
    foreach(@lines){
        warn "[DEBUG] $_\n";
    }
}

sub debug_detail{
    return unless $ENV{LECSTOR_DEBUG} && $ENV{LECSTOR_DEBUG} > 1;
    shift->debug(@_);
}

sub debug_dump{
    return unless $ENV{LECSTOR_DEBUG} && $ENV{LECSTOR_DEBUG} > 1;
    shift->debug(Dumper(shift));
}

1;
