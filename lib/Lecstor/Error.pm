package Lecstor::Error;
use Moose;

# ABSTRACT: an error object which returns false in scalar context

use overload '""' => sub{ 0 };

=attr error

single string error message

=cut

has error => ( isa => 'Str', is => 'ro' );

=attr exception

true if the error was an exception

=cut

has exception => ( isa => 'Bool', is => 'ro' );

__PACKAGE__->meta->make_immutable;

1;

