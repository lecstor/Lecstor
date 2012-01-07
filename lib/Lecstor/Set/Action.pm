package Lecstor::Set::Action;
use Moose;
use Class::Load ('load_class');

# ABSTRACT: interface to action records

extends 'Lecstor::Set';

sub resultset_name{ 'Action' }

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Action' }

=head1 SYNOPSIS

    my $action_set = Lecstor::Set::Action->new({
        schema => $dbic_schema,
    });

    my $action = $action_set->create(
        type => $type_str,
        session => $session_id,
        data => $data_hash,
        person => $user_id,
    );

=cut

around 'create' => sub{
    my ($orig, $self, $params) = @_;
    my $model_class = $self->model_class;
    load_class($model_class);
    return $model_class->new( _record => $self->$orig($params) );
};



__PACKAGE__->meta->make_immutable;

1;
