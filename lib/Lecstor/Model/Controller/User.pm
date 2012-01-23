package Lecstor::Model::Controller::User;
use Any::Moose;
use Lecstor::Error;

# ABSTRACT: interface to user records

extends 'Lecstor::Model::Controller';

with 'Lecstor::Role::RequestData';
with 'Lecstor::Role::ActionLogger';


sub resultset_name{ 'User' }

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Instance::User' }

=attr person_ctrl

=cut

has person_ctrl => ( isa => 'Lecstor::Model::Controller', is => 'ro', required => 1 );

=attr request

L<Lecstor::Request>

#=cut

has request => ( isa => 'Lecstor::Request', is => 'ro', required => 1 );

=attr validator

=cut

has validator => ( is => 'ro', isa => 'Object', required => 1 );

=head1 SYNOPSIS

    my $user_set = Lecstor::Model::Controller::User->new({
        schema => $dbic_schema,
        current_user => Lecstor::Model::Instance::User->new(),
        current_session_id => 'acbc123',
    });

    my $user = $user_set->create({
        username => 'lecstor',
        email => 'test1@eightdegrees.com.au',
        password => '0123456789',
        person => 321,
    })

=cut

around 'create' => sub{
    my ($orig, $self, $params) = @_;
    my $valid = $self->validator->class('user', params => $params );
    unless ($valid->validate){
        $self->log_action(
            'register fail' => {
                params => $params,
                error => $valid->error_fields,
                validation => 'user',
            }
        );
        return Lecstor::Error->new({
            error => $valid->errors_to_string,
            error_fields => $valid->error_fields,
        });
    }
    # set user active by default
    $params->{active} = 1 unless exists $params->{active};
    my $model_class = $self->model_class;
    return $model_class->new( _record => $self->$orig($params) );
};

=method register

=cut

sub register{
    my ($self,$params) = @_;

    my $v = $self->validator->class('registration', params => $params);

    my $result;

    if ( $v->validate ){
        # input valid
        if ($self->find({ email => $params->{email} })){
            # email already registered
            my $error = 'That email address is already registered';
            $self->log_action('register fail', { email => $params->{email}, error => $error });
            return Lecstor::Error->new({ error => $error });
        }
        if ($params->{username} && $self->find({ username => $params->{username} })){
            # username already registered
            my $error = 'That username is already registered';
            $self->log_action('register fail', { username => $params->{username}, error => $error });
            return Lecstor::Error->new({ error => $error });
        }
        # params ok
        $result = $self->create($v->get_params_hash);
    } else {
        # invalid input
        $self->log_action(
            'register fail', {
                username => $params->{email},
                errors => $v->error_fields,
                validation => 'registration',
            }
        );
        $result = Lecstor::Error->new({
            error_fields => $v->error_fields,
            error => $v->errors_to_string,
        });
    }

    return $result;

}

__PACKAGE__->meta->make_immutable;

1;
