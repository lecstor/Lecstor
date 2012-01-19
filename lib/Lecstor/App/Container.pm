package Lecstor::App::Container;
use Moose;
use Bread::Board;
 
extends 'Bread::Board::Container';

has '+name' => ( default => 'Lecstor' );

=head1 DESCRIPTION

oh how to name the parts.. this module creates the main app L<Bread::Board>
container which begins as a parameterized container which then creates our
final container using other containers..

=head1 SYNOPSIS

    my $container1 = Lecstor::App::Container->new({
        template_processor => $tt_instance,
    });

    my $container = $container1->create(
        Model => $model_container,
        Request => $request_container,
    );

=attr template_processor

=cut

has template_processor => (
    is      => 'ro',
    isa     => 'Object',
    required => 1,
);

=attr builder

    $app_c->builder->create({
        Model => $model_container,
        Request => $request_container,
    });

Being a parameterized container we need other containers to be complete.

=cut

has 'builder' => ( isa => 'Object', is => 'ro', lazy_build => 1 );

sub _build_builder {
    my $self = shift;

    my $c = container 'Lecstor' => [ 'Model', 'Request' ] => as {
  
        service template_processor => $self->template_processor;
 
        service error_class => 'Lecstor::Error';
 
        service app => (
            class        => 'Lecstor::App',
            lifecycle    => 'Singleton',
            dependencies => {
                model => depends_on('Model/model'),
                request => depends_on('Request/request'),
                template_processor => depends_on('template_processor'),
                validator => depends_on('Model/validator'),
                error_class => depends_on('error_class'),
                action_ctrl => depends_on('Model/action'),
            }
        );
    };

    return $c;
}

=method create

=cut

sub create{
    my ($self, %args) = @_;
    return $self->builder->create(%args);
}
 

__PACKAGE__->meta->make_immutable;

1;
