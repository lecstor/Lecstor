package Lecstor::Request::Visitor;
use Moose;
use Class::Load 'load_class';

# ABSTRACT: a request from an anonymous visitor

extends 'Lecstor::Request';

=head1 SYNOPSIS

    my $request = Lecstor::Request->new(
        uri => $uri,
        session_id => $session_id,
    );

=cut

__PACKAGE__->meta->make_immutable;

1;

