package Lecstor::App::Component::Template;
use Moose;
use Lecstor::X;

extends 'Lecstor::App::Component';

has processor => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_processor{
    my ($self) = @_;
    Template::AutoFilter->new({
        INCLUDE_PATH => $self->templates,
        LOAD_PLUGINS => [
          Lecstor::Template::Plugins::Allow->new(@{$self->plugins}),
          Template::Plugins->new(),
        ],
    })
}

has templates => ( is => 'rw', isa => 'ArrayRef', builder => '_build_templates' );

sub _build_templates{ ['root'] }

has plugins => ( is => 'rw', isa => 'ArrayRef', builder => '_build_plugins' );

sub _build_plugins{ [qw! Date Table Dumper !] }

sub process{
    my ($self, $template, $vars) = @_;
    my $out;
    $self->processor->process( $template, $vars, \$out )
        or Lecstor::X->throw($self->processor->error);
    return $out;
}

__PACKAGE__->meta->make_immutable;

1;
