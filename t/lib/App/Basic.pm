package App::Basic;
use Moose;

use Lecstor::Valid;
use Lecstor::Model::Controller::Action;
use Lecstor::Model::Controller::Person;
use Lecstor::Model::Controller::User;
use Lecstor::Model::Controller::Collection;
use Lecstor::Model::Controller::Product;
use Lecstor::Model::Instance::User;
use Lecstor::Request;

has schema => ( isa => 'DBIx::Class::Schema', is => 'ro' );

my $valid = Lecstor::Valid->new;

my $session_id = time;

foreach my $set (qw! person collection product !){
    my $class = 'Lecstor::Model::Controller::'. ucfirst($set);
    has $set => (
        isa => 'Object', is => 'ro', lazy => 1,
        default => sub {
            my ($self) = @_;
            return $class->new( schema => $self->schema );
        }
    );
}

has action => (
    isa => 'Object', is => 'ro', lazy => 1,
    default => sub {
        my ($self) = @_;
        return Lecstor::Model::Controller::Action->new(
            schema => $self->schema,
            current_user => Lecstor::Model::Instance::User->new,
            current_session_id => $session_id,
        );
    }
);

has user => (
    isa => 'Object', is => 'ro', lazy => 1,
    default => sub {
        my ($self) = @_;
        return Lecstor::Model::Controller::User->new(
            schema => $self->schema,
            validator => $valid,
            action_ctrl => $self->action,
            person_ctrl => $self->person,
            request => Lecstor::Request->new( session_id => 'testing123' ),
            current_user => Lecstor::Model::Instance::User->new,
            current_session_id => $session_id,
        );
    }
);


__PACKAGE__->meta->make_immutable;

1;
