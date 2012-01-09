package Lecstor::App::Container;
use Moose;
use Bread::Board;
 
extends 'Bread::Board::Container';

has '+name' => ( default => 'Lecstor' );

=head1 SYNOPSIS

    my $container = Lecstor::Model::Container->new({
        template_processor => $tt_instance,
    });

    my $lecstor = $container->build_app();

=attr template_processor

=cut

has template_processor => (
    is      => 'ro',
    isa     => 'Object',
    required => 1,
);
 
sub build_container {
    my $self = shift;

    my $c = container 'Lecstor' => [ 'Model', 'Request' ] => as {
  
#        service view => $self->view;
#        service session_id => $self->session_id;
#        service user => ( block => sub { $self->user } );
        service template_processor => $self->template_processor;
 
        service validator => (
            class        => 'Lecstor::Valid',
            lifecycle    => 'Singleton',
        );
 
        service error_class => 'Lecstor::Error';
 
        service app => (
            class        => 'Lecstor::App',
            lifecycle    => 'Singleton',
            dependencies => {
                model => depends_on('Model/model'),
                request => depends_on('Request/request'),
                template_processor => depends_on('template_processor'),
                validator => depends_on('validator'),
                error_class => depends_on('error_class'),
#                session_id => depends_on('session_id'),
#                user => depends_on('user'),
#                view => depends_on('view'),
            }
        );
    };

    return $c;
}

__PACKAGE__->meta->make_immutable;

1;
