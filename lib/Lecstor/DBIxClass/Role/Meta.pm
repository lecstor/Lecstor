package Lecstor::DBIxClass::Role::Meta;
use Moose::Role;

# ABSTRACT: provides access to a DBIx::Class::ResultSet metadata

requires 'resultset';

=attr result_source

the resultset result_source

=cut

has result_source => (
    isa => 'DBIx::Class::ResultSource', is => 'ro', lazy_build => 1,
    handles => [qw! columns relationships has_relationship relationship_info !],
);

sub _build_result_source{ shift->resultset->result_source }

=attr result_class

the resultset result_class

=cut

has result_class => ( isa => 'Str', is => 'ro', lazy_build => 1 );

sub _build_result_class{ shift->resultset->result_class }

=attr no_related

arrayref of names of columns which are not foreign keys. 

=cut

has 'no_related' => ( isa => 'ArrayRef', is => 'ro', auto_deref => 1, lazy_build => 1 );

sub _build_no_related{ $_[0]->column_types_cache->{no_related} }

=attr single_related

arrayref of names of columns containing a foreign key.

=cut

has 'single_related' => ( isa => 'ArrayRef', is => 'ro', auto_deref => 1, lazy_build => 1 );

sub _build_single_related{ $_[0]->column_types_cache->{single_related} }

=attr many_related

arrayref of names of relationships to many rows.

=cut

has 'many_related' => ( isa => 'ArrayRef', is => 'ro', auto_deref => 1, lazy_build => 1 );

sub _build_many_related{ $_[0]->column_types_cache->{many_related} }

=attr column_types_cache

=cut

has 'column_types_cache' => ( isa => 'HashRef', is => 'ro', lazy_build => 1 );

sub _build_column_types_cache{
    my ($self) = @_;

    my $result_source = $self->result_source;

    my (@vals, @single, @multi);

    foreach my $field ($self->columns){
        if ($self->has_relationship($field)){
            push(@single, $field);
        } else {
            push(@vals, $field);
        }
    }

    foreach my $field ($self->relationships){
        if ($self->relationship_info($field)->{attrs}{accessor} eq 'multi'){
            push(@multi, $field);
        }
    }

    return {
        no_related => \@vals,
        single_related => \@single,
        many_related => \@multi,
    };

}



1;
