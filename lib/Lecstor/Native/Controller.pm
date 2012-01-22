package Lecstor::Native::Controller;
use Mouse;
use Plack::Response;

has model => ( is => 'ro', isa => 'Object', required => 0 );

has view => ( is => 'ro', isa => 'Object', required => 0 );

has request => ( is => 'ro', isa => 'Object', required => 1 );

has response => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_response{ Plack::Response->new(200); }


sub test{
    my ($self) = @_;
    
    my $res = $self->response;
    $res->content_type('text/html');

    my $out;
    $self->view->template->process(\'Hello [% name %]', { name => 'Jason' }, \$out)
        ? $res->body($out) : $res->body($self->view->template->error);

    return $res;
}

__PACKAGE__->meta->make_immutable();

1;
