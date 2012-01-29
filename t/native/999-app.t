

{
    package My::Web::App::Container;
    use Moose;

    has schema => ( is => 'ro', isa => 'DBIx::Class::Schema', lazy_build => 1 );

    sub _build_schema{
        my ($self) = @_;
        return My::Schema->connect($self->config->{schema_connect_info});
    }

    
    has config => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );

    sub _build_config{

    }


    has router => ( is => 'ro', isa => 'Lecstor::Web::Router', lazy_build => 1 );

    sub _build_router{ My::Router->new }

    sub router_match{
        my ($self, $uri) = @_;
        return $self->router->mymatchmethod($uri);
    }

    sub router_uri_for{
        my ($self, $args) = @_;
        return $self->router->myuriformethod($args);
    }


    has model => ( is => 'ro', lazy_build => 1 );

    sub _build_model{
        my ($self) = @_;
        return My::Model->new(
            user => My::Model::Ctrl::User->new(),

        );

    }


    sub app{


    }

}



Plack::Request

App
  Config
    finder
    reader
    merger

  Request
  Model
    Controllers
      Schema
      Instances
