package Lecstor::Catalyst::View::TT;
use Moose;
use namespace::clean -except => 'meta';

# ABSTRACT: TT Catalyst View with html filtered content and restricted plugins

use Catalyst::View::TT 0.37 ();
extends 'Catalyst::View::TT';
with 'Catalyst::Component::InstancePerContext';

use Template::AutoFilter;
use Template::Plugins;
use Lecstor::Template::Plugins::Allow;

__PACKAGE__->config(
    CLASS => "Template::AutoFilter",
    LOAD_PLUGINS => [
      Lecstor::Template::Plugins::Allow->new(qw! Date Table Dumper !),
      Template::Plugins->new(),
    ],
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

sub build_per_context_instance {
    my ($self, $ctx) = @_;
    my $root = $ctx->path_to('root');
    $ctx->log->debug("Path to root: $root") if $ctx->debug;
    if (my @inc = @{$self->config->{include_paths}}){
        @{ $self->include_path } = map { "$root/$_" } @inc;
    }
    return $self;
}

=head1 DESCRIPTION

TT View for Lecstor::Catalyst using L<Template::AutoFilter> and
L<Lecstor::Template::Plugins::Allow>

=cut

1;
