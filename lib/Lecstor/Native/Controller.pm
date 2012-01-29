package Lecstor::Native::Controller;
use Moose;
use Plack::Response;
use Try::Tiny;
use MooseX::Aliases;
use Lecstor::X::Redirect;

has app => ( is => 'ro', isa => 'Object', required => 1 );

#has request => ( is => 'ro', isa => 'Object', required => 1, alias => 'req' );

#has response => ( is => 'ro', isa => 'Object', lazy_build => 1, alias => 'res' );

#sub _build_response{ Plack::Response->new(200); }

=attr config

=cut

#has config => ( is => 'ro', isa => 'HashRef', required => 1 );

=attr session

=cut

#has session => ( is => 'ro', isa => 'Object', required => 1 );

=attr user

=cut

#has user => ( is => 'ro', isa => 'Object', required => 1 );

=attr view

template processor, email, serializers, etc

L<Lecstor::Native::View>

=cut

#has view => ( is => 'ro', isa => 'Lecstor::Native::View', required => 1 );

=attr log

=cut

#has log => ( is => 'ro', isa => 'Object', required => 1 );

=attr stash

    $app->stash({ animals => { dogs => 1 } });
    # $app->stash: { animals => { dogs => 1 } }
    $app->stash({ animals => { cats => 2 } });
    # $app->stash: { animals => { dogs => 1, cats => 2 } }
    $app->set_stash({ foo => bar });
    # $app->stash: { foo => bar });
    $app->clear_stash;
    # $app->stash: undef

Hashref containing stash attributes

See L<MooseX::Traits::Attribute::MergeHashRef>

=cut

#has stash => (
#    is => 'rw', isa => 'HashRef',
#    traits => [qw(MergeHashRef)],
#    default => sub{{}},
#);

sub process_template{
    my ($self, $template) = @_;

    my $res = $self->app->response;
    $res->content_type('text/html') unless $res->content_type;

    try{
        my $body = $self->app->template->process($template, $self->app->stash);
        $self->app->response->body($body);
    } catch {
        die $_ unless $_->isa('Lecstor::X');
        warn 'Template Error: '.$_->message;
        $self->app->response->body($_->message);
    }

}

sub redirect{
    my ($self, $uri, $http_code) = @_;
    $self->app->log->debug("Redirect: $uri");
    $self->app->response->redirect($uri, $http_code);
    Lecstor::X::Redirect->throw('redirect');    
}

sub uri_for{
    return $_[1];
}

__PACKAGE__->meta->make_immutable();

1;
