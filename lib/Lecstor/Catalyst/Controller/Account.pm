package Lecstor::Catalyst::Controller::Account;
use Moose;
use Try::Tiny;
use namespace::autoclean;

# ABSTRACT: register an account

BEGIN { extends 'Catalyst::Controller' }


=method setup

=cut

sub setup :Chained('/') :PathPart('') :CaptureArgs(0){
    my ( $self, $c ) = @_;
    $c->session;
    if ($c->user_exists){
        $c->lecstor->login($c->user->user_object);
    }
    $c->stash({
        session => {
            user => $c->user_exists ? $c->user->user_object : undef,
            id => $c->sessionid,
        },
        request => {
            path_info => '/'.$c->req->path_info,
        },
    });
}

=method users_only

=cut

sub users_only :Chained('setup') :PathPart('') :CaptureArgs(0){
    my ( $self, $c ) = @_;

    unless($c->user_exists){
        $c->response->body('400');
        $c->detach;
    }

}

=method register

Register a new account.

=cut

sub register :Chained('setup') :PathPart('register') :Args(0){
    my ( $self, $c ) = @_;

    my $app = $c->lecstor;
    my $params = $c->req->params;
    my $action = delete $params->{action}; # name of submit button

    if ($action){
        try{
            my $result = $app->model->user->register($params);
            $c->stash->{session}{user} = $result;
            $c->authenticate({ email => $params->{email}, password => $params->{password} });
            $app->login($result);
        } catch {
            my $err = $_;
            die $err unless blessed $err && $err->isa('Lecstor::X');
            $c->stash->{error} = $err->as_hash;
            $app->log->action(
                $app->session, 'register fail',
                { error => $err->as_hash, params => $params }
            );
        };
    }

    delete $params->{password};

    $c->stash({
        template => 'account/register.tt',
        params => $params,
#        request => {
#            path_info => '/'.$c->req->path_info,
#        },
#        %{$app->request->stash},
#        view => $app->response->view({ page => { title => 'Register' }}),
    });
}

=method login

Log in to account.

=cut

sub login :Chained('setup') :PathPart('login') :Args(0){
    my ( $self, $c ) = @_;

    my $app = $c->lecstor;
    my $params = $c->req->params;
    my $action = delete $params->{action}; # name of submit button

    if ($action){
        my $v = $app->validator->class('user', params => $params);
        if ( $v->validate ){
            if ( $c->authenticate($params) ){
                $app->login($c->user->user_object);
                $c->stash->{success} = 1;
                my $recent = $c->session->{recent_uri}[0];
                my $uri = $recent ? $recent->path_query : $c->uri_for($c->config->{default_user_uri});
                $c->res->redirect( $uri );
                return;
            } else {
                $app->log->action($app->session, 'login fail', { params => $params, validation => 'catalyst authenticate' });
                $c->stash->{error} = $app->error({
                    error => 'The email address or password is incorrect.'
                });
            }
        } else {
            $app->log->action(
                $app->session, 
                'login fail',
                { username => $params->{email}, errors => $v->error_fields, validation => 'user' }
            );
            $c->stash->{error} = {
                error_fields => $v->error_fields,
                error => $v->errors_to_string,
            };
        }

        delete $params->{password};
    }

    $c->stash({
        template => 'account/login.tt',
#        view => $app->response->view({ page => { title => 'Log In' }}),
        params => $params,
    });

}

sub logout :Chained('setup') :PathPart('logout') :Args(0){
    my ( $self, $c ) = @_;
    # Clear the user's state
    $c->logout;

    # Send the user to the starting point
    $c->res->redirect($c->uri_for('/'));
}

=method login_or_register

Process email & password to login or register.

=cut

sub login_or_register :Chained('setup') :PathPart('login_or_register') :Args(0){
    my ( $self, $c ) = @_;

    if (lc($c->req->params->{action}) eq 'register'){
        $c->detach('register');
    } else {
        $c->detach('login');
    }
  
}

__PACKAGE__->meta->make_immutable;

1;
