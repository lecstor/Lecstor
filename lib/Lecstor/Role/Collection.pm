package Lecstor::Role::Collection;
use Moose::Role;

use Try::Tiny;

requires qw! resultset_name !;

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

sub item_class {}

=method create

    $rows = $collection->create( $args );

returns a collection item object if item_class is defined else returns a
L<DBIx::Class::Result>.

=cut

sub create{
    my ($self, $args) = @_;
    my $row = $self->rs->create($args);
    my $item_class = $self->item_class;
    $row = $item_class->new({ row => $row }) if $row && $item_class;
    return $row;
}

=method search

  $rows = $collection->search({ cond => 123 }, { attrs => 453 }); 

returns an arrayref of collection item objects or L<DBIx::Class::Result> objects.

=cut

sub search{
    my ($self, @args) = @_;
    my @items = $self->prefetch_single_related_rs->search(@args);
    my $item_class = $self->item_class;
    @items = map{ $item_class->new(row => $_) } @items if $item_class;
    return \@items;
}

=method search_for_id

  $rows = $collection->search_for_id({ cond => 123 }, { attrs => 453 }); 

returns an arrayref of collection item ids.

=cut

sub search_for_id{
  my ($self, @args) = @_;
  return $self->rs->search(@_)->get_column('id');
}

=method find

  $item = $collection->find(23);

returns a collection item object if item_class is defined else returns a
L<DBIx::Class::Result>.

=cut

sub find{
    my ($self, $id) = @_;
    my $row = $self->prefetch_single_related_rs->find($id);
    if ($row){
        my $item_class = $self->item_class;
        $row = $item_class->new({ row => $row }) if $item_class;
    }
    return $row;
}

=method prefetch_single_related_rs

  $rs = $collection->prefetch_single_related_rs;

override this method to prefetch simple relationships.

=cut

sub prefetch_single_related_rs{ $_[0]->rs }


1;
