package Lecstor::Catalyst::WebApp;
use Moose;
use MooseX::StrictConstructor;

# ABSTRACT: App Component Container

extends 'Lecstor::WebApp';
with 'Lecstor::Catalyst::WebApp::Role';

__PACKAGE__->meta->make_immutable;

1;
