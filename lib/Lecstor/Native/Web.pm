package Lecstor::Native::Web;
use Moose;
use Try::Tiny;

# ABSTRACT: Generate a PSGI compatible Application

use Lecstor::Native::Request;
use Lecstor::Native::Container;
use Lecstor::Native::WebApp;

=head1 SYNOPSIS

    use Plack::Builder;
    use My::App::Web;

    my $app = My::App::Web->new->web_app;

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

    my $request = $web->request($env);

returns a L<Lecstor::Native::Request> which is a subclass of
L<Plack::Request>

=cut

sub request{
    my ($self, $env) = @_;
    return Lecstor::Native::Request->new($env, $self->app_container->log);
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
        $self->log->debug('Generating session id');
        my $digest = Digest->new('SHA-256');
        $digest->add( $self->session_hash_seed() );
        $session_id = $digest->hexdigest;
    }
    $self->log->debug('Session id: '.$session_id);
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
    return $self->model->session->instance($session_id);
}

=method request_container

    my $req_container = $web->request_container($request);

This holds all the components that are only relevant for a single
request such as the session, user, request, response, and a stash.

If you want to move components between the request container and
the app container, you'll be overriding this.

=cut

sub request_container{
    my ($self, $req) = @_;

    my $session = $self->session($self->session_id($req));

    my $response = $req->new_response(200);
    $response->cookies->{$self->session_cookie_name} = $session->id;

    return Lecstor::Native::Container->new(
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

=attr app_container

    my $app_container = $web->app_container;

This holds all the components that are relevant for the entire app
lifetime such as the model, validator, config, log, template, and
router.

=cut

has app_container => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_app_container{
    my ($self) = @_;
    Lecstor::Native::Container->new(
        model => $self->model,
        validator => $self->validator,
        config => $self->config,
        log => $self->log,
        template => $self->template,
        router => $self->router,
    );
}

=method request_app

    my $app = $web->request_app($request);

This holds the request container and the app container and delegates
methods to whichever is supplying the components.

=cut

sub request_app{
    my ($self, $req) = @_;
    my $req_container = $self->request_container($req);
    return Lecstor::Native::WebApp->new(
        _request => $req_container,
        _app => $self->app_container,
    );
}

=method web_app

    my $plack_code = $web->web_app;

returns the code reference that Plack::Builder wants..

=cut

sub web_app{
    my $self = shift;

    return sub {
        my $env = shift;

        $self->app_container->log->debug_dump($env);

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

=head1 Example Components

has template => ( is => 'ro', isa => 'Lecstor::Native::Component', lazy_build => 1 );

sub _build_template{
    Lecstor::Native::Component::Template->new(
        processor => Template::AutoFilter->new({
            INCLUDE_PATH => [qw! root/bootstrap root/plain !],
            LOAD_PLUGINS => [
              Lecstor::Template::Plugins::Allow->new(qw! Date Table Dumper !),
              Template::Plugins->new(),
            ],
        }),
    );
}

has schema => ( is => 'ro', isa => 'Object', required => 1 );

sub _build_schema{
    My::App::Schema->connect('dbi:SQLite:dbname=share/my-app-schema.db');
}

has model => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_model{
    my ($self) = @_;
    My::App::Model->new(
        schema => $self->schema,
        validator => $self->validator,
    );
}

has validator => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_validator{ My::App::Valid->new }

has router => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_router{
    Lecstor::Native::Router->new(
        controller_base_class => 'My::App::Controller',
        routes => [
            Root => [
                [ '/' => 'index' ],
            ],
            Account => [
                [ '/register' => 'register' ],
                [ '/logout' => 'logout' ],
                [ '/login' => 'login' ],
            ],
            Root => [
                [ '/*' => 'file_not_found' ],
            ],
        ]
    );
}

has config_file => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_config_file{ 'my_app.yml' }

has config => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );

sub _build_config{
    my ($self) = @_;
    my $config_file = $self->config_file;
    my $conf_data = {};
    if (-e $config_file){
        $self->log->debug("Loading config: $config_file");
        $conf_data = YAML::XS::Load(scalar read_file($config_file));
    } else {
        $self->log->debug("Config Missing: $config_file");
    }
    if ($ENV{LECSTOR_DEPLOY}){
        $config_file =~ s/\./_$ENV{LECSTOR_DEPLOY}./;
        if (-e $config_file){
            $self->log->debug("Loading config: $config_file");
            $conf_data = Hash::Merge::merge( $conf_data, YAML::XS::Load(scalar read_file($config_file)));
        } else {
            $self->log->debug("Deploy Config Missing: $config_file");
        }
    }
    $self->log->debug_dump($conf_data);
    return $conf_data;
}

has log => ( is => 'ro', isa => 'Lecstor::Log', lazy_build => 1 );

sub _build_log{
    my ($self) = @_;
    Lecstor::Log->new( action_ctrl => $self->model->action );
}


=cut



__PACKAGE__->meta->make_immutable;

1;
