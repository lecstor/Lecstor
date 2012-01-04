package App::WithSetModsOnly;
use Moose;

use Lecstor::Set::Person;
use App::Set::Login;
use Lecstor::Set::Collection;
use Lecstor::Set::Product;

has schema => ( isa => 'DBIx::Class::Schema', is => 'ro' );

foreach my $set (qw! person collection product !){
    my $class = 'Lecstor::Set::'. ucfirst($set);
    has $set => (
        isa => 'Object', is => 'ro', lazy => 1,
        default => sub {
            my ($self) = @_;
            return $class->new( schema => $self->schema );
        }
    );
}

has login => (
    isa => 'Object', is => 'ro', lazy => 1,
    default => sub {
        my ($self) = @_;
        return App::Set::Login->new( schema => $self->schema );
    }
);

__PACKAGE__->meta->make_immutable;

1;
