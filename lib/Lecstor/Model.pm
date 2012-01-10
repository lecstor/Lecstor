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

=attr user

=attr collection

=attr product

=attr session

=cut

#has schema => ( is => 'ro', isa => 'DBIx::Class::Schema', required => 1 );

has [qw! product_indexer product_searcher !] => (
    is => 'ro', isa => 'Object', required => 1
);

has [qw! action person user collection product session !] => (
    is => 'ro', isa => 'Lecstor::Model::Controller', required => 1
);

__PACKAGE__->meta->make_immutable;

1;

