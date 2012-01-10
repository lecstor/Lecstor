package Lecstor::Catalyst::Model::LecstorModel;
use strict;
use warnings;
use base 'Catalyst::Model';
use Class::Load 'load_class';

__PACKAGE__->config( 
    class => 'Lecstor::App::Container::Model',
);

sub COMPONENT {
    my ($cclass, $app, $args) = @_;
    my $class = $cclass->config->{class};
    load_class($class);
    return $class->new(
        config => {
            schema => $app->config->{'Model::Schema'},
            product_search => $app->config->{lecstor}{product_search},
        }
    );
}

1;

