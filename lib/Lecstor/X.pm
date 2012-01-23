package Lecstor::X;
use Any::Moose;
with qw(Throwable::X StackTrace::Auto);

# ABSTRACT: base exception class

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

