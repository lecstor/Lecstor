package Lecstor::Model::Controller::User;
use Moose;
use Class::Load ('load_class');

# ABSTRACT: interface to user records

extends 'Lecstor::Model::Controller';

use Lecstor::Valid::User;
use Lecstor::Error;

sub resultset_name{ 'User' }

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Instance::User' }

=head1 SYNOPSIS

    my $user_set = Lecstor::Model::Controller::User->new({
        schema => $dbic_schema,
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
    my $valid = Lecstor::Valid::User->new( params => $params );
    return Lecstor::Error->new({
        error => $valid->errors_to_string,
        error_fields => $valid->error_fields,
    }) unless $valid->validate;
    # set user active by default
    $params->{active} = 1 unless exists $params->{active};
    my $model_class = $self->model_class;
    load_class($model_class);
    return $model_class->new( _record => $self->$orig($params) );
};

__PACKAGE__->meta->make_immutable;

1;
