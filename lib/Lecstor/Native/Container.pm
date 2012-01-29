package Lecstor::Native::Container;
use Moose;
use MooseX::Aliases;

has [qw!model template validator log session user router !] => (
    is => 'ro',
);

has request => ( is => 'ro', isa => 'Object', alias => 'req' );

has response => ( is => 'ro', isa => 'Object', alias => 'res' );

has config => ( is => 'ro', isa => 'HashRef' );

=attr counts

store a count of various things.
eg this is used to cound tthe number of redirects that have happened
during the current request.

=cut

has counts => ( is => 'ro', isa => 'HashRef', default => sub{{}} );

=method counts

    my $count = $container->count('redirect');

increments the named count by one and returns the result.

=cut

sub count{
    my ($self, $name) = @_;
    return ++$self->counts->{$name};
}

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
