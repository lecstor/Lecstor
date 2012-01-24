package Lecstor::Model::Controller::Product;
use Moose;

# ABSTRACT: interface to product records

extends 'Lecstor::Model::Controller';

sub resultset_name{ 'Product' }

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Instance::Product' }

=head1 SYNOPSIS

    my $product_set = Lecstor::Model::Controller::Product->new({
        schema => $dbic_schema,
    });

    my $product = $product_set->create({
        name => 'My Product',
        categories => ['Tools','Petrol'],
        price => 995.95,
        image => 'my_product.jpg',
        data => {
            images => [qw! product_left.jpg product_right.jpg !]
            sizes => [qw! Sml Med Lge !], 
        },
    });

    is $product->category, 'Tools';


=cut

around 'create' => sub{
    my ($orig, $self, $params) = @_;
    my $model_class = $self->model_class;
    return $model_class->new( _record => $self->$orig($params) );
};



__PACKAGE__->meta->make_immutable;

1;
