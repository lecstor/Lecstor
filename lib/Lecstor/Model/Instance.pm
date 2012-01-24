package Lecstor::Model::Instance;
use Moose;
use MooseX::StrictConstructor;

has '_record' => (
    isa => 'Object', is => 'ro',
);

# result_source:     $self->_record->result_source
# related_source:    $self->_record->result_source->related_source($relname);
# related_resultset: $self->_record->result_source->related_source($relname)->resultset;

sub related_resultset{
    my ($self, $relname) = @_;
    return $self->_record->result_source->related_source($relname)->resultset;
}

__PACKAGE__->meta->make_immutable;

1;