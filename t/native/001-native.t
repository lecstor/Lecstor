use strict;
use warnings;
use Test::More;
use Data::Dumper;
use DateTime;

use FindBin qw($Bin);
use lib "$Bin/lib";

use_ok('Lecstor::Native');

{
    package LifeTime::App;
    use Mouse;

    has template_processor => ( is => 'ro', isa => 'Object', lazy_build => 1 );

    sub _build_template_processor{
        Template->new()
    }

    has model => ( is => 'ro', isa => 'Object', required => 1 );



    package LifeTime::Request;
    use Mouse;
    use Plack::Response;

    has app => ( is => 'ro', isa => 'Object', required => 1 );
    has request => ( is => 'ro', isa => 'Object', required => 1 );
    has response => ( is => 'ro', isa => 'Object', lazy_build => 1 );
    sub _build_response{
        Plack::Response->new(200);
    }



    package App::Controller;
    use Mouse;
    extends 'LifeTime::Request';

    sub index{
        my ($self, @args) = @_;
        return ('index.tt', test => 'this');
    }


    package App;
    use Mouse;
    has app => ( is => 'ro', isa => 'LifeTime::App', required => 1 );

    sub app{
        my $self = shift;

        return sub {
            my $req = Plack::Request->new(shift);
            my (undef, $action, @args) = split /\//, $req->path;
            my $controller = App::Controller->new(
                request => $req,
                app => $self->app,
            );
            my ($template, %vars) = $controller->$action(@args);

            my $out;

            my $res = $req->new_response(200);
            $res->content_type('text/html');

            $t->process($template, \%vars, \$out)
              ? $res->body($out) : $res->body($t->error);

            return $res->finalize;
        };

    }

}

my $lt = LifeTime::App->new;
