package Lecstor::Catalyst::Model::LecstorApp;
use strict;
use warnings;
use base 'Catalyst::Model';
use Class::Load 'load_class';
use Lecstor::Native::Component::Template;

__PACKAGE__->config( 
    class => 'Lecstor::App',
);

sub COMPONENT {
    my ($cclass, $app, $args) = @_;
    my $class = $args->{class} || $cclass->config->{class};
    load_class($class);
    return $class->new(
        template => Lecstor::Native::Component::Template->new(
            processor => $app->view('TT')->template,
        ),
        config_file => 'lecstor_tradie_catalyst.yml',
    );
}

1;