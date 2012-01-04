package Lecstor::Set::Collection;
use Moose;
use Class::Load ('load_class');

# ABSTRACT: interface to product collection records

sub resultset_name{ 'Collection' }

with 'Lecstor::Role::Set';

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Collection' }

=head1 SYNOPSIS

    my $collection_set = Lecstor::Set::Collection->new({
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
    load_class($model_class);
    return $model_class->new( data => $self->$orig($params) );
};

__PACKAGE__->meta->make_immutable;

1;
