package Lecstor;
use strict;
use warnings;
use Lecstor::App::Container;

# ABSTRACT: Lecstor, the electronic store (as in e-commerce)

sub new{
    my ($class, @args) = @_;
    my $container = Lecstor::App::Container->new( @args );
    return $container->build_app();
}

=head1 DESCRIPTION

=cut



1;
