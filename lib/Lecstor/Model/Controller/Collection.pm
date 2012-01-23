package Lecstor::Model::Controller::Collection;
use Any::Moose;

# ABSTRACT: interface to product collection records

extends 'Lecstor::Model::Controller';

sub resultset_name{ 'Collection' }

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Instance::Collection' }

=head1 DESCRIPTION

Collections are simply lists of products. By default people and sessions can
have collections. Types of collections include baskets, wishlists, orders,
and sales. Custom collection types are easily added as an instance of the
CollectionType set.

=head1 SYNOPSIS

    my $collection_set = Lecstor::Model::Controller::Collection->new({
        schema => $dbic_schema,
    });

    my $collection = $collection_set->create({
        name => 'My Favourites',
        type => { name => 'Custom' },
    });

=cut

around 'create' => sub{
    my ($orig, $self, $params) = @_;
    my $model_class = $self->model_class;
    return $model_class->new( _record => $self->$orig($params) );
};

__PACKAGE__->meta->make_immutable;

1;
