package Lecstor::App;
use Moose;
use MooseX::Params::Validate;
use MooseX::StrictConstructor;
use Class::Load 'load_class';
use Lecstor::Response;

=method current_user

=cut

sub current_user{ shift->user }

=method current_session_id

=cut

sub current_session_id{ shift->request->session_id }

with 'Lecstor::Role::ActionLogger';

=head1 SYNOPSIS

    my $app = Lecstor::App->new(
        model = Lecstor::App::Model->new(
            schema => Lecstor::Schema->connect($connect_args),
        ),
        template_processor => $tt,
        product_search_config => {
            index_path => 'path/to/index/directory',
            create => 1,
            truncate => 1,
        }
    );

    my $person_set = $app->model->person;

=cut

sub BUILD{
    shift->update_view;
}

has 'session_fetcher' => (
    traits  => ['Code'],
    is      => 'ro',
    isa     => 'CodeRef',
    handles => { session => 'execute_method' },
    required => 1,
);

#has session => ( is => 'ro', isa => 'Object', builder => '_build_session' );

has 'user_fetcher' => (
    traits  => ['Code'],
    is      => 'ro',
    isa     => 'CodeRef',
    handles => { user => 'execute_method' },
    required => 1,
);

#has user => ( is => 'rw', isa => 'Object', default => sub{ $_[0]->fetch_user } );

=attr model

=cut

has model => ( is => 'ro', isa => 'Object', required => 1 );

=attr view

=cut

has view => ( is => 'ro', isa => 'Object', required => 1 );

=attr request

=cut

has request => ( is => 'ro', isa => 'Object', required => 1 );

=attr response

=cut

has response => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_response{
    Lecstor::Response->new({ view => { uri => $_[0]->request->uri }});
}

=attr validator

=cut

has validator => ( is => 'ro', isa => 'Object', required => 1 );

=attr error_class

=cut

has error_class => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_error_class{ 'Lecstor::Error' }

sub error{
    my ($self, $args) = @_;
    my $class = $self->error_class;
    return $class->new($args);
}

sub login{
    my ($self, $user) = @_;
    my $session = $self->session->set_user($user);
    $self->user->_record($user->_record);
    $self->update_view;
}

sub update_view{
    my ($self) = @_;
    my $user = $self->user;
    if ($user){
        my $visitor = {
#          %{$self->view->{visitor} || {}},
          logged_in => 1,
          email => $user->email,
          name => $user->username,
          username => $user->username,
          user_id => $user->id,
        };
        $visitor->{name} ||= $user->person->name if $user->person;
        $self->response->view({ visitor => $visitor });
    }
}

=method log_action

#=cut

sub log_action{
    my ($self, $type, $data) = @_;

    my $action = {
        type => { name => $type },
        session => $self->request->session_id,
    };
    $action->{data} = $data if $data;
    $action->{user} = $self->request->user->id if $self->request->user;

    $self->model->action->create($action);
}

=method run_after_request

NOT IMPLEMENTED - executes code immediately

#=cut

sub run_after_request{
    my ($self, $code) = @_;
    eval{ &$code() };
}

=method register

#=cut

sub register{
    my ($self,$params) = @_;

    my $v = $self->validator->class('registration', params => $params);

    my $result;

    if ( $v->validate ){
        # input valid
        if ($self->model->user->find({ email => $params->{email} })){
            # email already registered
            my $error = 'That email address is already registered';
            $self->log_action('register fail', { email => $params->{email}, error => $error });
            $result = $self->error({ error => $error });
        } else {
            # params ok
            $result = $self->model->user->create($v->get_params_hash);
        }
    } else {
        # invalid input
        $self->log_action('register fail', { username => $params->{email}, errors => $v->error_fields });
        $result = $self->error({
            error_fields => $v->error_fields,
            error => $v->errors_to_string,
        });
    }

    return $result;
}

=cut

__PACKAGE__->meta->make_immutable;

1;

