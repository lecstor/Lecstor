package Lecstor::Catalyst::Model::LecstorRequest;
use Moose;
use Class::Load 'load_class';
use namespace::autoclean;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

__PACKAGE__->config( 
    class => 'Lecstor::App::Container::Request',
);

sub build_per_context_instance {
    my ($self, $ctx) = @_;

    $ctx->session;

    my $args = {
        uri => $ctx->req->uri,
        session_id => $ctx->sessionid,
    };
    $args->{user} = $ctx->user->user_object if $ctx->user_exists;

    my $class = $self->config->{class};
    load_class($class);
    return $class->new($args);
}

__PACKAGE__->meta->make_immutable;

1;

 
1;