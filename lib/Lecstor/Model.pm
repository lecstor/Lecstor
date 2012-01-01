package Lecstor::Model;
use Moose::Role;

has 'data' => (
    isa => 'Object', is => 'ro',
);

# result_source:     $self->data->result_source
# related_source:    $self->data->result_source->related_source($relname);
# related_resultset: $self->data->result_source->related_source($relname)->resultset;

sub related_resultset{
    my ($self, $relname) = @_;
    return $self->data->result_source->related_source($relname)->resultset;
}

1;