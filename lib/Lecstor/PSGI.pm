package Lecstor::PSGI;
use Moose;
use Try::Tiny;

# ABSTRACT: Generate a PSGI compatible Application

use Lecstor::PSGI::Request;
use Lecstor::Native::WebApp;
use Digest;

=head1 SYNOPSIS

    use Plack::Builder;
    use My::App::Web;

    my $app = My::App::PSGI->new->web_app;

    builder {
        enable "Plack::Middleware::Static",
            path => qr{^/static/}, root => 'root/';
        $app;
    };

=head1 DESCRIPTION

This module is all about creating a Plack compatible code reference.
The methods and attributes here will not be available from our web
controllers or the app itself.

You should sublclass (extend) this in your own module.

=cut

=attr session_cookie_name

hmm.. one guess.. yes! it returns the name of our session cookie!

=cut

sub session_cookie_name{ 'lecstor_session' }

=method request

    my $request = $psgi->request($env);

returns a L<Lecstor::PSGI::Request> which is a subclass of
L<Plack::Request>

=cut

sub request{
    my ($self, $env) = @_;
    return Lecstor::PSGI::Request->new($env, $self->app->log);
}

=method session_id

    my $session_id = $web->session_id($request);

gets the visitor's session id from a cookie in the request.

Derived from L<Catalyst> code of a similar nature.

=cut

sub session_id{
    my ($self, $req) = @_;
    my $session_id = $req->cookies->{$self->session_cookie_name};
    unless ($session_id){
        $self->app->log->debug('Generating session id');
        my $digest = Digest->new('SHA-256');
        $digest->add( $self->session_hash_seed() );
        $session_id = $digest->hexdigest;
    }
    $self->app->log->debug('Session id: '.$session_id);
    return $session_id;
}

=method session_hash_seed

    my $hash_seed = $web->session_hash_seed;

Borrowed directly from L<Catalyst>

=cut

my $counter;
 
sub session_hash_seed {
    my $self = shift;
    return join( "", ++$counter, time, rand, $$, {}, overload::StrVal($self) );
} 

=method session

    my $session = $web->session($session_id);

returns the current session.

see L<Lecstor::Model::Instance:Session>

=cut

sub session{
    my ($self, $session_id) = @_;
    return $self->app->model->session->instance($session_id);
}

=method webapp_request_class

Returns the WebApp class..

see L<Lecstor::Native::Request>

=cut

sub webapp_request_class{ 'Lecstor::Native::Request' }

=method webapp_request

    my $webapp_request = $web->webapp_request($request);

This holds all the components that are only relevant for a single
request such as the session, user, request, response, and a stash.

If you want to move components between the request container and
the app container, you'll be overriding this.

=cut

sub webapp_request{
    my ($self, $req) = @_;

    my $session = $self->session($self->session_id($req));

    my $response = $req->new_response(200);
    $response->cookies->{$self->session_cookie_name} = $session->id;

    my $webapp_request_class = $self->webapp_request_class;

    return $webapp_request_class->new(
        session => $session,
        user => $session->user,
        request => $req,
        response => $response,
        stash => {
            session => $session->as_hash,
            request => $req,
        }            
    );
}

=attr app

    my $app = $web->app;

This holds all the components that are relevant for the entire app
lifetime such as the model, validator, config, log, template, and
router.

=cut

has app => ( is => 'ro', isa => 'Object', required => 1 );

=method request_app

    my $app = $web->request_app($request);

This holds the request container and the app container and delegates
methods to whichever is supplying the components.

=cut

sub request_app{
    my ($self, $req) = @_;
    my $req_container = $self->webapp_request($req);
    return Lecstor::Native::WebApp->new(
        _request => $req_container,
        _app => $self->app,
    );
}

=method coderef

    my $plack_code = $web->coderef;

returns the code reference that Plack::Builder wants..

=cut

sub coderef{
    my $self = shift;

    return sub {
        my $env = shift;

        $self->app->log->debug_dump($env);

        my $request_app = $self->request_app( $self->request($env) );

        $self->dispatch($env, $request_app);

        return $request_app->response->finalize;
    };

}

=method dispatch

    $web->dispatch($env, $app);

Dispatches requests to controllers selected using the router.
Calls itself to handle redirects and dies after 20 redirects
in a single request.

=cut

sub dispatch{
    my ($self, $env, $app) = @_;

    my $params = $self->router->match($env);
    my $ctrl_class = delete $params->{controller};
    my $action = delete $params->{action};
    $app->log->debug($app->req->path_info." => $ctrl_class->$action");

    my $controller = $ctrl_class->new( app => $app );

    try{
        $controller->$action($params);
    } catch {
        die $_ unless blessed $_ && $_->isa('Lecstor::X');
        if ($_->isa('Lecstor::X::Redirect')){
            Lecstor::X->throw('Too many redirects!')
                if $app->count('redirect') > 20;
            return unless $_->uri;
            return $self->dispatch($_->uri, $app);
        }
        die $_;
    };
}

has router => ( is => 'ro', isa => 'Object', lazy_build => 1 );



__PACKAGE__->meta->make_immutable;

1;
