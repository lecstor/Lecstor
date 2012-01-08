package Lecstor::Catalyst::Model::Lecstor;
use Moose;
use Class::Load 'load_class';
use namespace::autoclean;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

__PACKAGE__->config(
    app_class => 'Lecstor',
);

sub build_per_context_instance {
    my ($self, $ctx) = @_;

    my $app_class = $self->config->{app_class};
    load_class($app_class);

    $ctx->session;

    my $args = {
        view => {
            uri => $ctx->req->uri,
        },
        session_id => $ctx->sessionid,
        config => $ctx->config->{lecstor},
        schema => $ctx->model('Schema')->schema,
        template_processor => $ctx->view('TT')->template,
    };

    $args->{user} = $ctx->user->user_object if $ctx->user_exists;

    return $app_class->new($args);
}

__PACKAGE__->meta->make_immutable;

1;
