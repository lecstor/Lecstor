package Lecstor::App::Container::Request;
use Moose;
use Bread::Board;
use Digest;
use Digest::SHA;

extends 'Bread::Board::Container';

has '+name' => ( default => 'Lecstor-Request' );

=head1 SYNOPSIS

    my $container = Lecstor::App::Container::Request->new({
        session_id => $sess_id,
        uri => $uri,
    });

=attr uri

=cut

has uri => ( is => 'ro', isa => 'URI' );

=attr session_id

=cut

has session_id => ( is => 'rw', isa => 'Str', lazy_build => 1 );

sub _build_session_id {
    my $self = shift;
    my $digest = Digest->new('SHA-256');
    $digest->add( $self->session_hash_seed() );
    return $digest->hexdigest;
}

my $counter;
 
sub session_hash_seed {
    my $self = shift;
    return join( "", ++$counter, time, rand, $$, {}, overload::StrVal($self), );
} 

sub BUILD {
    my $self = shift;

    container $self => as {
        service uri => $self->uri;
        service session_id => $self->session_id;
        service request => (
            class        => 'Lecstor::Request',
            dependencies => {
                uri => depends_on('uri'),
                session_id => depends_on('session_id'),
            },
        );
    };
}

__PACKAGE__->meta->make_immutable;

1;
