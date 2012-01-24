package Lecstor::Model::Controller::Session;
use Moose;

# ABSTRACT: interface to session records

extends 'Lecstor::Model::Controller';

sub resultset_name{ 'Session' }

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Instance::Session' }

# Keys are in the format prefix:id, where prefix is session, expires,
# or flash, and id is always the session ID. Plugins such as
# Catalyst::Plugin::Session::PerUser store extensions to this format,
# such as user:username.

=head1 SYNOPSIS

    my $session_set = Lecstor::Model::Controller::Session->new({
        schema => $dbic_schema,
    });

    my $session = $session_set->find_or_create($key);
    $session->update({
        expires => time + 3600,
        session_data => {},
    });

=cut

around 'create' => sub{
    my ($orig, $self, $params) = @_;
    my $model_class = $self->model_class;
    return $model_class->new( _record => $self->$orig($params) );
};

sub instance{
    my ($self, $id) = @_;
    my $session = $self->find($id);
    $session = $self->create({ id => $id }) unless $session;
    return $session;
}

__PACKAGE__->meta->make_immutable;

1;
