package Lecstor::App;
use Moose;
use MooseX::Params::Validate;
use MooseX::StrictConstructor;
use Class::Load 'load_class';

=method current_user

=cut

sub current_user{ shift->request->user }

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

=attr model

=cut

has model => ( is => 'ro', isa => 'Object', required => 1 );

=attr request

=cut

has request => ( is => 'ro', isa => 'Object', required => 1 );

=attr validator

=cut

has validator => ( is => 'ro', isa => 'Object', required => 1 );

=attr template_processor

=cut

has template_processor => ( is => 'ro', isa => 'Object', required => 1 );

=attr error_class

=cut

has error_class => ( is => 'ro', isa => 'Str', required => 1 );

sub error{
    my ($self, $args) = @_;
    my $class = $self->error_class;
    return $class->new($args);
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

