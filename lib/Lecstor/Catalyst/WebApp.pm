package Lecstor::Catalyst::WebApp;
use Moose;
use MooseX::StrictConstructor;

# ABSTRACT: App Component Container

extends 'Lecstor::WebApp';

=method login

    $app->login($user);

=cut

sub login{
    my ($self, $user) = @_;
    $self->session->{user} = $user;
    $self->user->set_record($user);
}

__PACKAGE__->meta->make_immutable;

1;
