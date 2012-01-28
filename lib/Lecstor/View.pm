package Lecstor::View;
use Moose;

=head1 SYNOPSIS

    my $request = Lecstor::View->new(
        template => $template,
    );

=attr template

=cut

has template => ( is => 'ro', isa => 'Object' );

__PACKAGE__->meta->make_immutable;

1;

