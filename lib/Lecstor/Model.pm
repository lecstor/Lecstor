package Lecstor::Model;
use Moose;

use Lecstor::Model::Controller::Action;
use Lecstor::Model::Controller::Person;
use Lecstor::Model::Controller::User;
use Lecstor::Model::Controller::Session;

=head1 SYNOPSIS

    my $model = Lecstor::Model->new(
        schema => Lecstor::Schema->connect($connect_args)
    );

    my $app = Lecstor::App->new( model => $model );

    my $person_set = $app->model->person;

=cut

=attr schema

=cut

has schema => ( is => 'ro', isa => 'Object', required => 1 );

=attr validator

=cut

has validator => ( is => 'ro', isa => 'Object', required => 1 );

=attr action

=attr person

=attr user

=attr collection

=attr product

=attr session

=cut

#has [qw! product_indexer product_searcher !] => (
#    is => 'ro', isa => 'Object', required => 1
#);

# Lecstor - schema & validator
foreach my $class (qw!  !){
    my $full_class = 'Lecstor::Model::Controller::'.$class;
    my $attr = lc($class);
    has $attr => (
        is => 'ro', isa => 'Lecstor::Model::Controller', lazy => 1,
        default => sub{
            my ($self) = @_;
            $full_class->new(
                schema => $self->schema,
                validator => $self->validator,
            );
        }
    );
}

# Lecstor - only schema
# Collection Product 
foreach my $class (qw! Action Person Session !){
    my $full_class = 'Lecstor::Model::Controller::'.$class;
    my $attr = lc($class);
    has $attr => (
        is => 'ro', isa => 'Lecstor::Model::Controller', lazy => 1,
        default => sub{
            my ($self) = @_;
            $full_class->new(
                schema => $self->schema,
            );
        }
    );
}

=attr user

=cut

has user => (
    is => 'ro', isa => 'Lecstor::Model::Controller', lazy_build => 1
);

sub _build_user{
    my ($self) = @_;
    Lecstor::Model::Controller::User->new(
        schema => $self->schema,
        person_ctrl => $self->person,
        validator => $self->validator,
    );
}


__PACKAGE__->meta->make_immutable;

1;

