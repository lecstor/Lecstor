package Lecstor::X::Valid;
use Moose;
extends 'Lecstor::X';

# ABSTRACT: parameter based exceptions

has fields => (
    is => 'ro',
    isa => 'HashRef',
    default => sub {{}},
);

has validation => ( is => 'ro', isa => 'Str', required => 1 );

# fields for as_hash
sub _build_hash_fields{
    [qw!ident message fields validation!];
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

