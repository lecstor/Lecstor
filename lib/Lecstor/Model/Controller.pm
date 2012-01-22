package Lecstor::Model::Controller;
use Moose;
use MooseX::StrictConstructor;
use DateTime;

# ABSTRACT: interface to a set of model objects

# based on the collections role, but leaves it up to modified resultset
# classes to return model objects instead of result objects.

use Try::Tiny;

sub resultset_name{}

=attr schema

L<DBIx::Class::Schema> [required]

=cut

has schema => ( isa => 'DBIx::Class::Schema', is => 'ro', required => 1 );

=attr rs

L<DBIx::Class::ResultSet>

=cut

has rs     => (
    isa => 'DBIx::Class::ResultSet', is => 'ro', lazy_build => 1,
);

sub _build_rs{ $_[0]->schema->resultset($_[0]->resultset_name) }

=method create

=cut

sub create{
    my ($self, $args) = @_;
    $args->{created} = DateTime->now( time_zone => 'local' )
        if !$args->{created} && $self->rs->result_source->has_column('created');
    return $self->rs->create($args);
}

=method search

  $rows = $collection->search({ cond => 123 }, { attrs => 453 }); 

returns an arrayref of item objects.

=cut

sub search{
    my ($self, @args) = @_;
    @args = $self->reconstruct_search_args(@args);
    return $self->prefetch_single_related_rs->search(@args);
}

=method search_for_id

  $rows = $collection->search_for_id({ cond => 123 }, { attrs => 453 }); 

returns an arrayref of collection item ids.

=cut

sub search_for_id{
    my ($self, @args) = @_;
    @args = $self->reconstruct_search_args(@args);
    my $me = $self->rs->current_source_alias;
    return $self->rs->search(@args)->get_column("$me.id");
}

=method find

  $item = $collection->find(23);

returns a collection item object if item_class is defined else returns a
L<DBIx::Class::Result>.

=cut

sub find{
    my ($self, $id) = @_;
    return $self->prefetch_single_related_rs->find($id);
}

=method find_or_create

=cut

sub find_or_create{
    my ($self, $args) = @_;
    my $model = $self->find($args);
    unless ($model){
        $args = { id => $args } unless ref $args;
        $model = $self->create($args);
    }
    return $model;
}

=method prefetch_single_related_rs

  $rs = $collection->prefetch_single_related_rs;

override this method to prefetch simple relationships.

=cut

sub prefetch_single_related_rs{ $_[0]->rs }

=method reconstruct_search_args

reconstruct the provided search args to suit table relationships

=cut

sub reconstruct_search_args{
    my $self = shift;
    return @_;
}

=method separate_params

takes a hashref of parameters and separates out those belonging to
related objects.

=cut

sub separate_params{
    my ($self, $params) = @_;

    my $rel_data;
    foreach my $param (keys %$params){
        next unless $param =~ /\./;
        my $value = delete $params->{$param};
        my ($rel, $key) = split(/\./, $param, 2);
        $rel_data->{$rel}{$key} = $value;
    }
    return ($params, $rel_data);
}

__PACKAGE__->meta->make_immutable;

1;
