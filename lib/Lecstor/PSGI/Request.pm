package Lecstor::PSGI::Request;
use Digest;
use Digest::SHA;

use base 'Plack::Request';

sub new {
    my($class, $env, $log) = @_;
    Carp::croak(q{$env is required})
        unless defined $env && ref($env) eq 'HASH';
 
    bless { env => $env, log => $log }, $class;
}

sub log { $_[0]->{log} }

sub uri_for {
    my($self, $path, $args) = @_;
    my $uri = $self->base;
    $uri->path($uri->path . $path);
    $uri->query_form(@$args) if $args;
    $uri;
}

sub params{ shift->parameters(@_) }

1;

