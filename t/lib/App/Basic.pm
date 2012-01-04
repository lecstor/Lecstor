package App::Basic;
use Moose;

use Lecstor::Set::Person;
use Lecstor::Set::Login;
use Lecstor::Set::Collection;
use Lecstor::Set::Product;

has schema => ( isa => 'DBIx::Class::Schema', is => 'ro' );

foreach my $set (qw! person login collection product !){
    my $class = 'Lecstor::Set::'. ucfirst($set);
    has $set => (
        isa => 'Object', is => 'ro', lazy => 1,
        default => sub {
            my ($self) = @_;
            return $class->new( schema => $self->schema );
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
