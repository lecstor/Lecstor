package CatApp::Controller::Uri;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

=head1 NAME

Lecstor::Shop::Catalyst::Controller::Root - Root Controller for Lecstor::Shop::Catalyst

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=method setup

=cut

sub setup :Chained('/') :PathPart('') :CaptureArgs(0){
    my ( $self, $c ) = @_;
    if ($c->user_exists){
        $c->lecstor->login($c->user->user_object);
    }
}

=method full_page

=cut

sub full_page :Chained('setup') :PathPart('') :CaptureArgs(0){
    my ( $self, $c ) = @_;

    my $app = $c->lecstor;

#    $c->stash({
#        site => $app->site,
#        products => $app->products,
#        visitor => $app->visitor,
#    });

    if ($c->req->method eq 'GET'){
        my $recent = $c->session->{recent_uri} || [];
        pop @$recent if @$recent >= 10;
        unshift @$recent, { uri => $c->req->uri->as_string };
    }
}

=head2 index

The root page (/)

=cut

sub index :Chained('full_page') :PathPart('uri/test') :Args(0){
    my ( $self, $c ) = @_;

    my $app = $c->lecstor;
    
    $c->stash({
        template => 'index.tt',
    });
}


=head2 default

Standard 404 error page

=cut

sub default :Private {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Jason Galea <lecstor@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
