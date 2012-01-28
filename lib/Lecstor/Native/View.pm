package Lecstor::Native::View;
use Moose;
use Template;
use Lecstor::X;

has template => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_template{ Template->new() }

#has json => ( is => 'ro', isa => 'Object', lazy_build => 1 );

#sub _build_json{ JSON->new() }

sub process_template{
    my ($self, $template, $vars) = @_;
    my $out;
    $self->template->process($template, $vars, \$out)
        or Lecstor::X->throw($self->template->error);
    return $out;
}

sub template_error{
    shift->template->error;
}

__PACKAGE__->meta->make_immutable();

1;
