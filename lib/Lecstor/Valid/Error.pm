package Lecstor::Valid::Error;
use Moose;

extends 'Lecstor::Error';

=attr error_fields

a hashref of field errors where the key is the field name and values
are arrayrefs of errors.

=cut

has error_fields => ( isa => 'HashRef[ArrayRef]', is => 'ro' );

__PACKAGE__->meta->make_immutable;

1;
