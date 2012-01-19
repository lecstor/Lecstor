package Lecstor::Catalyst::Model::LecstorApp;
use strict;
use warnings;
use base 'Catalyst::Model';
use Class::Load 'load_class';
 
__PACKAGE__->config( 
    class => 'Lecstor::App::Container',
);

sub COMPONENT {
    my ($cclass, $app, $args) = @_;
    my $class = $args->{class} || $cclass->config->{class};
    load_class($class);
    return $class->new(
        template_processor => Template->new( $app->config->{'View::TT'} ),
    );
}

1;