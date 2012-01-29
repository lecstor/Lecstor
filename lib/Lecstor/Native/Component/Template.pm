package Lecstor::Native::Component::Template;
use Moose;

extends 'Lecstor::Native::Component';

has processor => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_processor{
    my ($self) = @_;
    Template::AutoFilter->new({
        INCLUDE_PATH => $self->templates,
    })
}

has templates => ( is => 'rw', isa => 'ArrayRef', builder => '_build_templates' );

sub _build_templates{ ['root'] }

sub process{
    my ($self, $template, $vars) = @_;
    my $out;
    $self->processor->process( $template, $vars, \$out )
        or Lecstor::X->throw($self->processor->error);
    return $out;
}

__PACKAGE__->meta->make_immutable;

1;
