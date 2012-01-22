package Lecstor::Native::View;
use Mouse;
use Template;

has template => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_template{ Template->new() }

#has json => ( is => 'ro', isa => 'Object', lazy_build => 1 );

#sub _build_template{ JSON->new() }

__PACKAGE__->meta->make_immutable();

1;
