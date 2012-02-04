package Lecstor::Catalyst::Component::Session;
use Moose;

has session => ( is => 'ro', required => 1 );

has sessionid =>  ( is => 'ro', required => 1 );

has user =>  ( is => 'ro', required => 1 );

sub id{ shift->sessionid }

__PACKAGE__->meta->make_immutable;

1;
