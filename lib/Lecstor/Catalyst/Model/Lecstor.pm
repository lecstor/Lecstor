package Lecstor::Catalyst::Model::Lecstor;
use Moose;
use Class::Load 'load_class';
use namespace::autoclean;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

__PACKAGE__->config(
    app_class => 'Lecstor::App',
    model_class => 'Lecstor::App::Model',
);

sub build_per_context_instance {
    my ($self, $ctx) = @_;

    my $model_class = $self->config->{model_class};
    load_class($model_class);

    my $model = $model_class->new(
        schema => $ctx->model('Schema')->schema,
        template_processor => $ctx->view('TT')->template,
    );

    my $app_class = $self->config->{app_class};
    load_class($app_class);

    $ctx->session;

    my $args = {
        model => $model,
        view => {
            uri => $ctx->req->uri,
        },
        session_id => $ctx->sessionid
    };

    $args->{login} = $ctx->user->user_object if $ctx->user_exists;

    return $app_class->new($args);
}

__PACKAGE__->meta->make_immutable;

1;
