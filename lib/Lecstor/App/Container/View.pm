package Lecstor::App::Container::View;
use Moose;
use Bread::Board;
use Digest;
use Digest::SHA;

extends 'Bread::Board::Container';

has '+name' => ( default => 'Lecstor-View' );

=head1 SYNOPSIS

    my $container = Lecstor::App::Container::View->new({
        template => Template->new( $app->config->{'View::TT'} ),
    });

=attr uri

=cut

has template => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_template{ Template->new() }


sub BUILD {
    my $self = shift;

    container $self => as {
        service template => $self->template;
        service view => (
            class        => 'Lecstor::View',
            dependencies => {
                template => depends_on('template'),
            },
        );
    };
}

__PACKAGE__->meta->make_immutable;

1;
