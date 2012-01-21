package Lecstor::Response;
use Moose;

use MooseX::Traits::Attribute::MergeHashRef;

=head1 SYNOPSIS

    my $request = Lecstor::Response->new(
        view => {},
    );

=attr view

    $app->view({ animals => { dogs => 1 } });
    # $app->view: { animals => { dogs => 1 } }
    $app->view({ animals => { cats => 2 } });
    # $app->view: { animals => { dogs => 1, cats => 2 } }
    $app->set_view({ foo => bar });
    # $app->view: { foo => bar });
    $app->clear_view;
    # $app->view: undef

Hashref containing view attributes

See L<MooseX::Traits::Attribute::MergeHashRef>

=cut

has view => (
    is => 'rw', isa => 'HashRef',
    traits => [qw(MergeHashRef)],
    default => sub{{}},
);

__PACKAGE__->meta->make_immutable;

1;

