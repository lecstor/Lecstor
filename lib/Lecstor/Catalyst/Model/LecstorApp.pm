package Lecstor::Catalyst::Model::LecstorApp;
use strict;
use warnings;
use base 'Catalyst::Model';
use Lecstor::App::Component::Template;

__PACKAGE__->config( 
    class => 'Lecstor::App',
);

sub COMPONENT {
    my ($cclass, $app, $args) = @_;
    my $class = $args->{class} || $cclass->config->{class};
    return $class->new(
        template => Lecstor::App::Component::Template->new(
            processor => $app->view('TT')->template,
        ),
        config => $app->config,
    );
}

1;