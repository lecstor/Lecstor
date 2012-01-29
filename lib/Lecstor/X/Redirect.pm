package Lecstor::X::Redirect;
use Moose;
extends 'Lecstor::X';

# ABSTRACT: redirect to another url / action

has uri => (
    is => 'ro',
    isa => 'Str',
);

=head1 SYNOPSIS

    Lecstor::X::Redirect->throw({ uri => '/new/action' });

Trigger an internal redirect based on an external uri.

=cut

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

