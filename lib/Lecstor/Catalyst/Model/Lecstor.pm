package Lecstor::Catalyst::Model::Lecstor;
use Moose;
use Class::Load 'load_class';
use namespace::autoclean;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

sub build_per_context_instance {
    my ($self, $ctx) = @_;

    my $app_container = $ctx->model('LecstorApp');
    my $model_container = $ctx->model('LecstorModel');
    my $request_container = $ctx->model('LecstorRequest');

    return $app_container->create(
        Model => $model_container,
        Request => $request_container,
    )->fetch('app')->get;

}

__PACKAGE__->meta->make_immutable;

1;
