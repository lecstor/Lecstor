package Lecstor::WebApp;
use Moose;
use MooseX::StrictConstructor;

# ABSTRACT: WebApp combining the main app with request context

has _request => (
    is => 'ro',
    handles => [qw! session user request req response res stash count counts!],
);

has _app => (
    is => 'ro',
    handles => [qw! model view validator config log template !],
);

=attr config

=attr model

=attr validator

=attr log

=method login

  $app->login($user);

=cut

sub login{
    my ($self, $user) = @_;
    $self->session->set_user($user);
    $self->user->set_record($user);
}

=method authenticate

    my $user = $app->authenticate({ email => 'me@my.co', password => 'memy' });

=cut

sub authenticate{
    my ($self, $params, $realm) = @_;
    my $id_type = $params->{email} ? 'email'
                : $params->{username} ? 'username' : undef;

    Lecstor::X->throw({
        ident => 'authenticate fail',
        message => 'Need a username or email to authenticate',
    }) unless $id_type;

    my $user = $self->model->user->search({ $id_type => $params->{$id_type} })->first;
    return $user if $user && $user->check_password($params->{password});

    my $message = sprintf "%s not found", ($params->{email} ? 'Email Address' : 'Username');
    Lecstor::X->throw({
        ident => 'authenticate fail',
        message => $message,
    });

}

sub register_user{
    shift->model->user->register(@_);
}

__PACKAGE__->meta->make_immutable;

1;
