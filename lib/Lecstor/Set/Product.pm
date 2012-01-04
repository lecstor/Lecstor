package Lecstor::Set::Product;
use Moose;
use Class::Load ('load_class');

# ABSTRACT: interface to product records

sub resultset_name{ 'Product' }

with 'Lecstor::Role::Set';

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Product' }

=head1 SYNOPSIS

    my $product_set = Lecstor::Set::Product->new({
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
    load_class($model_class);
    return $model_class->new( data => $self->$orig($params) );
};



__PACKAGE__->meta->make_immutable;

1;
