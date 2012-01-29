package Lecstor::Catalyst::Model::Lecstor;
use Moose;
use Class::Load 'load_class';
use namespace::autoclean;

use Lecstor::Catalyst::WebApp;
use Lecstor::Catalyst::WebApp::Request;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

sub build_per_context_instance {
    my ($self, $ctx) = @_;

    my $app = $ctx->model('LecstorApp');

    $ctx->session;

    return Lecstor::Catalyst::WebApp->new(
        _app => $app,
        _request => Lecstor::Catalyst::WebApp::Request->new(
            request => $ctx->req,
            session => $ctx->session,
            user => $ctx->user_exists ? $ctx->user->user_object : $app->model->user->empty_user,
        ),
    );

}

__PACKAGE__->meta->make_immutable;

1;
