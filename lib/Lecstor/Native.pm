package Lecstor::Native;
use Mouse;
use Class::Load;

use Template;
use Plack::Request;
use Lecstor::Native::View;
use Lecstor::Native::Controller;

has view => ( is => 'ro', isa => 'Lecstor::Native::View', lazy_build => 1 );

sub _build_view{ Lecstor::Native::View->new }

has model => ( is => 'ro', isa => 'Object', required => 0 );

sub app{
    my $self = shift;

    return sub {
        my $req = Plack::Request->new(shift);
        my (undef, $action, @args) = split /\//, $req->path;
        my $controller = Lecstor::Native::Controller->new(
            request => $req,
#            model => $self->model,
            view => $self->view,
        );
        $controller->$action(@args);
        my $res = $controller->response;
        return $res->finalize;
    };

}

__PACKAGE__->meta->make_immutable;


1;
