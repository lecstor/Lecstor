package Lecstor::Error;
use Moose;

# ABSTRACT: an error object which returns false in scalar context

use overload '""' => sub{ 0 };

=attr error

single string error message

=cut

has error => ( isa => 'Str', is => 'ro' );

=attr error_fields

a hashref of field errors where the key is the field name and values
are arrayrefs of errors.

=cut

has error_fields => ( isa => 'HashRef[ArrayRef]', is => 'ro' );

__PACKAGE__->meta->make_immutable;

1;

