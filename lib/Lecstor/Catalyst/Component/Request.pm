package Lecstor::Catalyst::Component::Request;
use Moose;

has request => (
    is => 'ro',
    required => 1,
    handles => [qw!
        address method protocol secure cookies query_parameters
        body_parameters parameters params param base headers uploads
        content_encoding content_length content_type header referer
        user_agent upload
    !],
);

has uri => (
    is => 'ro',
    lazy_build => 1,
    handles => [qw!
        scheme
    !],
);

sub _build_uri{ shift->request->uri }

sub path_info{ '/'.shift->request->path_info }

sub path{ shift->request->path || '/' }

sub user{ shift->request->remote_user }

__PACKAGE__->meta->make_immutable;

1;
