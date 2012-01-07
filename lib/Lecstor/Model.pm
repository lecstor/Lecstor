package Lecstor::Model;
use Moose;
use Class::Load 'load_class';

=head1 SYNOPSIS

    my $model = Lecstor::Model->new(
        schema => Lecstor::Schema->connect($connect_args)
    );

    my $app = Lecstor::App->new( model => $model );

    my $person_set = $app->model->person;

=cut

=attr schema

=attr action

=attr person

=attr login

=attr collection

=attr product

=attr session

=cut

has schema => ( is => 'ro', isa => 'DBIx::Class::Schema', required => 1 );

foreach my $set (qw! Action Person Login Collection Product Session !){
    my $class = "Lecstor::Model::Controller::$set";
    load_class($class);
    has lc($set) => (
        isa => 'Object', is => 'ro', lazy => 1,
        default => sub {
            my ($self) = @_;
            return $class->new( schema => $self->schema );
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

