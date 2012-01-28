package Lecstor::X::Redirect;
use Moose;
extends 'Lecstor::X';

# ABSTRACT: parameter based exceptions

has uri => (
    is => 'ro',
    isa => 'Str',
    default => '/',
);

has method => (
    is => 'ro',
    isa => 'Str',
    default => 'http',
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

