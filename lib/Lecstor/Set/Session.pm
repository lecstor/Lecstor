package Lecstor::Set::Session;
use Moose;
use Class::Load ('load_class');

# ABSTRACT: interface to session records

sub resultset_name{ 'Session' }

with 'Lecstor::Role::Set';

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Session' }

=head1 SYNOPSIS

    my $session_set = Lecstor::Set::Session->new({
        schema => $dbic_schema,
    });

    my $session = $session_set->find_or_create($key);
    $session->update({
        expires => time + 3600,
        session_data => {},
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
