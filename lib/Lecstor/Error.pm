package Lecstor::Error;
use Moose;

use overload '""' => 0;

has code => ( isa => 'Int', is => 'ro' );

has message => ( isa => 'Str', is => 'ro' );

__PACKAGE__->meta->make_immutable;

1;

