package Lecstor::Catalyst::WebApp::Role;
use Moose::Role;

# ABSTRACT: override webapp methods for Catalyst enviroment

=method login

    $app->login($user);

=cut

sub login{
    my ($self, $user) = @_;
    $self->session->{user} = $user;
    $self->user->set_record($user);
}

1;
