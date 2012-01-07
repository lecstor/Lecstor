package Lecstor::App::Model;
use Moose;
use Class::Load 'load_class';

use Lecstor::Model::Controller::Person;
use Lecstor::Model::Controller::Action;
use Lecstor::Model::Controller::Login;
use Lecstor::Model::Controller::Collection;
use Lecstor::Model::Controller::Product;
use Lecstor::Model::Controller::Session;
use Lecstor::Lucy::Indexer;
use Lecstor::Lucy::Searcher;

=head1 SYNOPSIS

    my $schema = Lecstor::Schema->connect($connect_args);

    my $model = Lecstor::App::Model->new(
        schema => $schema,
        template_processor => $tt,
        product_search_config => {
            index_path => 'path/to/index/directory',
            create => 1,
            truncate => 1,
        }
    );

    my $app = Lecstor::App->new( model => $model );

    my $person_set = $app->model->person;

=cut

=attr schema

=cut

has schema => ( is => 'ro', isa => 'DBIx::Class::Schema', required => 1 );

=attr template_processor

=cut

has template_processor => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_template_processor{
    my ($self) = @_;
    load_class('Template');
    return Template->new;
}

=attr action

=cut

has action => ( isa => 'Lecstor::Model::Controller::Action', is => 'ro', lazy_build => 1 );

sub _build_action{ Lecstor::Model::Controller::Action->new( schema => $_[0]->schema ) }

=attr person

=cut

has person => ( isa => 'Lecstor::Model::Controller::Person', is => 'ro', lazy_build => 1 );

sub _build_person{ Lecstor::Model::Controller::Person->new( schema => $_[0]->schema ) }

=attr login

=cut

has login => ( isa => 'Lecstor::Model::Controller::Login', is => 'ro', lazy_build => 1 );

sub _build_login{ Lecstor::Model::Controller::Login->new( schema => $_[0]->schema ) }

=attr collection

=cut

has collection => ( isa => 'Lecstor::Model::Controller::Collection', is => 'ro', lazy_build => 1 );

sub _build_collection{ Lecstor::Model::Controller::Collection->new( schema => $_[0]->schema ) }

=attr product

=cut

has product => ( isa => 'Lecstor::Model::Controller::Product', is => 'ro', lazy_build => 1 );

sub _build_product{ Lecstor::Model::Controller::Product->new( schema => $_[0]->schema ) }

=attr session

=cut

has session => ( isa => 'Lecstor::Model::Controller::Session', is => 'ro', lazy_build => 1 );

sub _build_session{ Lecstor::Model::Controller::Session->new( schema => $_[0]->schema ) }

=attr product_indexer

=cut

has product_indexer => ( isa => 'Lecstor::Lucy::Indexer', is => 'ro', lazy_build => 1 );

sub _build_product_indexer{ Lecstor::Lucy::Indexer->new( $_[0]->product_search_config ) }

=attr product_searcher

=cut

has product_searcher => ( isa => 'Lecstor::Lucy::Searcher', is => 'ro', lazy_build => 1 );

sub _build_product_searcher{
    return Lecstor::Lucy::Searcher->new(
        index_path => $_[0]->product_search_config->{index_path}
    );
}



__PACKAGE__->meta->make_immutable;

1;

