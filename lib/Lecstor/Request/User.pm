package Lecstor::Request::User;
use Moose;
use Class::Load 'load_class';

# ABSTRACT: a request from a user

extends 'Lecstor::Request';

=head1 SYNOPSIS

    my $request = Lecstor::Request->new(
        uri => $uri,
        session_id => $session_id,
        user => $user,
    );

=cut

=attr user

=cut

has user => (
    is => 'rw', isa => 'Lecstor::Model::Instance::User',
    required => 0, trigger => \&update_view,
);

__PACKAGE__->meta->make_immutable;

1;

