package Lecstor::X;
use Moose;
with qw(Throwable::X StackTrace::Auto);

# ABSTRACT: base exception class

has hash_fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

sub _build_hash_fields{
    [qw!ident message!];
}

sub as_hash{
    my ($self) = @_;
    my $hash = {};
    foreach(@{$self->hash_fields}){
        $hash->{$_} = $self->$_;
    }
    return $hash;
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

