package Lecstor::App::Model;
use Moose;
use Class::Load 'load_class';

use Lecstor::Set::Person;
use Lecstor::Set::Action;
use Lecstor::Set::Login;
use Lecstor::Set::Collection;
use Lecstor::Set::Product;
use Lecstor::Set::Session;
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

has action => ( isa => 'Lecstor::Set::Action', is => 'ro', lazy_build => 1 );

sub _build_action{ Lecstor::Set::Action->new( schema => $_[0]->schema ) }

=attr person

=cut

has person => ( isa => 'Lecstor::Set::Person', is => 'ro', lazy_build => 1 );

sub _build_person{ Lecstor::Set::Person->new( schema => $_[0]->schema ) }

=attr login

=cut

has login => ( isa => 'Lecstor::Set::Login', is => 'ro', lazy_build => 1 );

sub _build_login{ Lecstor::Set::Login->new( schema => $_[0]->schema ) }

=attr collection

=cut

has collection => ( isa => 'Lecstor::Set::Collection', is => 'ro', lazy_build => 1 );

sub _build_collection{ Lecstor::Set::Collection->new( schema => $_[0]->schema ) }

=attr product

=cut

has product => ( isa => 'Lecstor::Set::Product', is => 'ro', lazy_build => 1 );

sub _build_product{ Lecstor::Set::Product->new( schema => $_[0]->schema ) }

=attr session

=cut

has session => ( isa => 'Lecstor::Set::Session', is => 'ro', lazy_build => 1 );

sub _build_session{ Lecstor::Set::Session->new( schema => $_[0]->schema ) }

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

