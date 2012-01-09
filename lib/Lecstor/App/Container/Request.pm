package Lecstor::App::Container::Request;
use Moose;
use Bread::Board;
 
extends 'Bread::Board::Container';

has '+name' => ( default => 'Lecstor-Request' );

=head1 SYNOPSIS

    my $container = Lecstor::App::Container::Request->new({
        session_id => $sess_id,
        user => $user,
        uri => $uri,
    });

    my $model = $container->build_app();

=attr schema

=cut

has uri => ( is => 'ro', isa => 'URI' );

has session_id => ( is => 'rw', isa => 'Str', required => 1 );

has user => ( is => 'rw', isa => 'Lecstor::Model::Instance::User', required => 0 );

sub build_container {
    my $self = shift;

    my $c = container 'Lecstor-Request' => as {
 
        service 'uri' => $self->uri;
        service 'session_id' => $self->session_id;
        service 'user' => $self->user;
 
        service request => (
            class        => 'Lecstor::Request',
            dependencies => [
                depends_on('uri'),
                depends_on('session_id'),
                depends_on('user'),
            ]
        );
  
    };

    return $c;
}

__PACKAGE__->meta->make_immutable;

1;
