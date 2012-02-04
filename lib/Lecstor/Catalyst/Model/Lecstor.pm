package Lecstor::Catalyst::Model::Lecstor;
use Moose;
use Class::Load 'load_class';
use namespace::autoclean;

use Lecstor::Catalyst::WebApp;
use Lecstor::Catalyst::Component::Session;

use Lecstor::WebApp::Context;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

sub build_per_context_instance {
    my ($self, $ctx) = @_;

    my $app = $ctx->model('LecstorApp');

#    $ctx->session;

    my $user = $ctx->user_exists ? $ctx->user->user_object : $app->model->user->empty_user;

    $ctx->stash->{session} = Lecstor::Catalyst::Component::Session->new(
        session => $ctx->session,
        sessionid => $ctx->sessionid,
        user => $user,
    );
    $ctx->stash->{request} = $ctx->req;

    return Lecstor::Catalyst::WebApp->new(
        _app => $app,
        _request => Lecstor::WebApp::Context->new(
            request => $ctx->req,
            response => $ctx->res,
            session => $ctx->stash->{session},
            user => $user,
        ),
    );

}

__PACKAGE__->meta->make_immutable;

1;
