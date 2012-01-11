package Lecstor::App::Container::Request;
use Moose;
use Bread::Board;
use Lecstor::Model::Instance::User;

extends 'Bread::Board::Container';

has '+name' => ( default => 'Lecstor-Request' );

=head1 SYNOPSIS

    my $container = Lecstor::App::Container::Request->new({
        session_id => $sess_id,
        user => $user,
        uri => $uri,
    });

    my $model = $container->build_app();

=attr schema

=cut

has uri => ( is => 'ro', isa => 'URI' );

has session_id => ( is => 'rw', isa => 'Str', required => 1 );

=attr user

the currently logged in user

L<Lecstor::Model::Instance::User>

=cut

has user => (
    is => 'ro',
    isa => 'Lecstor::Model::Instance::User',
    lazy_build => 1
);

sub _build_user{ Lecstor::Model::Instance::User->new }

=attr view

    $app->view({ animals => { dogs => 1 } });
    # $app->view: { animals => { dogs => 1 } }
    $app->view({ animals => { cats => 2 } });
    # $app->view: { animals => { dogs => 1, cats => 2 } }
    $app->set_view({ foo => bar });
    # $app->view: { foo => bar });
    $app->clear_view;
    # $app->view: undef

Hashref containing view attributes

See L<MooseX::Traits::Attribute::MergeHashRef>

=cut

has view => ( is => 'rw', isa => 'HashRef', default => sub{{}} );


sub BUILD {
    my $self = shift;

    container $self => as {
        service uri => $self->uri;
        service session_id => $self->session_id;
        service view => $self->view;
        service user => $self->user;

        service request => (
            class        => 'Lecstor::Request',
            dependencies => [
                depends_on('uri'),
                depends_on('session_id'),
                depends_on('view'),
                depends_on('user'),
            ],
        );
    };
}

__PACKAGE__->meta->make_immutable;

1;
