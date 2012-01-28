package Lecstor::Native::Router;
use Moose;
use Router::Simple;

=head1 SYNOPSIS

    my $router = Lecstor::Native::Router->new(
        router => Router::Simple->new,
        controller_base_class => 'My::Web::Controller',
        routes => {
            Root => [
                [ '/' => 'index', method => 'GET' ],
                [ '/product/{id}' => 'product', method => 'GET' ],
            ],
            User => [
                [ '/user/:id' => 'profile', method => 'GET' ],
            ],
        },
    );

=attr router

this defaults to an instance of L<Router::Simple>

=cut

has router => (
    is => 'ro', isa => 'Object', lazy_build => 1,
    handles => [qw! match connect submapper routematch as_string !],
);

sub _build_router{
    return Router::Simple->new;
}

=attr controller_base_class

defaults to 'Lecstor::Native::Controller' and is appended to configured
controller class names unless they are prefixed with a '+'.

=cut

has controller_base_class => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_controller_base_class{ 'Lecstor::Native::Controller' }

=attr routes

a hashref describing uri routes.

=cut

has routes => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

sub _build_routes{
    [
        Root => [
            [ '/' => 'index', method => 'GET' ],
        ],
    ]
}

sub BUILD{
    my ($self) = @_;
    my $router = $self->router;
    my @ctrl_classes = @{$self->routes};
    while(@ctrl_classes){
        my ($ctrl_class, $routes) = (shift @ctrl_classes, shift @ctrl_classes);
        $ctrl_class = $self->controller_base_class.'::'.$ctrl_class unless $ctrl_class =~ s/^\+//;
        foreach my $route (@$routes){
            my ($path, $method, %opts) = @$route;
            $router->connect( $path, { controller => $ctrl_class, action => $method }, \%opts );
        }

    }
}

__PACKAGE__->meta->make_immutable;

1;
