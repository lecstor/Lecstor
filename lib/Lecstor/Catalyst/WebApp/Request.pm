package Lecstor::Catalyst::WebApp::Request;
use Moose;
use MooseX::Aliases;

has [qw! session user !] => (
    is => 'ro',
);

has request => ( is => 'ro', isa => 'Object', alias => 'req' );

=attr stash

    $app->stash({ animals => { dogs => 1 } });
    # $app->stash: { animals => { dogs => 1 } }
    $app->stash({ animals => { cats => 2 } });
    # $app->stash: { animals => { dogs => 1, cats => 2 } }
    $app->set_stash({ foo => bar });
    # $app->stash: { foo => bar });
    $app->clear_stash;
    # $app->stash: undef

Hashref containing stash attributes

See L<MooseX::Traits::Attribute::MergeHashRef>

=cut

has stash => (
    is => 'rw', isa => 'HashRef',
    traits => [qw(MergeHashRef)],
    default => sub{{}},
);

__PACKAGE__->meta->make_immutable;

1;
