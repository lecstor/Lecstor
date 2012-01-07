package App::WithSetModsOnly;
use Moose;

use Lecstor::Model::Controller::Person;
use App::Model::Controller::User;
use Lecstor::Model::Controller::Collection;
use Lecstor::Model::Controller::Product;

has schema => ( isa => 'DBIx::Class::Schema', is => 'ro' );

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

has user => (
    isa => 'Object', is => 'ro', lazy => 1,
    default => sub {
        my ($self) = @_;
        return App::Model::Controller::User->new( schema => $self->schema );
    }
);

__PACKAGE__->meta->make_immutable;

1;
