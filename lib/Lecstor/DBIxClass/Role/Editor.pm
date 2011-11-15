package Lecstor::DBIxClass::Role::Editor;
use Moose::Role;

# ABSTRACT: Role to create DBIx::Class objects

requires 'resultset_name';

use Data::Dumper;

=head1 DESCRIPTION

This role will add a create method (and others) to the consuming class to
enable creating database records via L<DBIx::Class> from simple hash structures.
The intended use is to ease importing data from flat files such as csv.

The degree of simplicity of using this role is directly related to the simplicity
of the related rows to be created.

The consuming class is required to provide a resultset_name method which returns
the name of the main resultset to be used.

=attr schema [required]

  $schema = $editor->schema;

=cut

has schema => ( isa => 'DBIx::Class::Schema', is => 'ro', required => 1 );

=attr resultset

  $rs = $editor->resultset;

=cut

has resultset => ( isa => 'DBIx::Class::ResultSet', is => 'ro', lazy_build => 1 );

sub _build_resultset{
    my ($self) = @_;
    $self->schema->resultset($self->resultset_name);
}

=attr result_source

  $rs = $editor->result_source;

=cut

has result_source => ( isa => 'DBIx::Class::ResultSource', is => 'ro', lazy_build => 1 );

sub _build_result_source{ shift->resultset->result_source }

=attr result_class

  $rs = $editor->result_class;

=cut

has result_class => ( isa => 'Str', is => 'ro', lazy_build => 1 );

sub _build_result_class{ shift->resultset->result_class }

=attr row_schema

=cut

has row_schema => ( isa => 'HashRef', is => 'ro', lazy_build => 1 );

sub _build_row_schema{
    return {
        _default => {
            key => 'id',
            value => 'name',
        },
    };
}

=method create

  $prod = $editor->create({ title => 'Product Name' });

=cut

sub create{
    my ($self, $args) = @_;

    die sprintf "Args to create must be a hash reference, not %s", ref $args
        unless ref $args eq 'HASH';

    my $rs = $self->resultset;
    my $source = $self->result_source;
    my $class = $self->result_class;

    my $rels = $self->_relations($args);

    $self->_process_single($rels);

    my $trxn = sub{
        my $row = $self->resultset->create($rels->{column});
        $self->_process_multi($rels, $row);
        $self->_process_m2m($rels, $row);
    };
    $self->schema->txn_do($trxn);

}

sub _relations{
    my ($self, $args) = @_;

    my %rels;
    my $source = $self->result_source;
    my $class = $self->result_class;

    foreach my $field (keys %$args){
warn "Field: $field\n";
        if ($source->has_relationship($field)){
warn "  has relationship\n";
            my $info = $source->relationship_info($field);
            if ($info->{attrs}{accessor} eq 'multi'){
                $rels{multi}{$field} = {
                    info => $info,
                    value => $args->{$field},
                };
#                $multi_rel->{$field} = $args->{$field};
            } else {
                $rels{single}{$field} = {
                    info => $info,
                    value => $args->{$field},
                };
#                $single_rel->{$field} = $args->{$field};
            }
        } elsif ($source->has_column($field)){
warn "  has column\n";
            $rels{column}{$field} = $args->{$field};
#            $columns->{$field} = $args->{$field};
        } elsif (my $info = $class->_m2m_metadata->{$field}){
warn "  has m2m relationship\n";
            $rels{m2m}{$field} = {
                info => $info,
                value => $args->{$field},
            };
#            $m2m_rel->{$field} = $args->{$field};
        } else {
            die "field $field has no relationship or column?";
        }
    }
    return \%rels;
}

sub _process_single{
    my ($self, $rels) = @_;

    my $single_rels = $rels->{single};
    my $source = $self->result_source;

    # add single rel relationships
    foreach my $field (keys %$single_rels){
warn "Field: $field\n";
        my $info = $single_rels->{$field}{info};
        my $value = $single_rels->{$field}{value};
        if (ref $value){

            # value is a reference

        } else {
            my $rel_rs = $source->related_source($field)->resultset;
            my $column = $self->row_schema->{$field}{value} || $self->row_schema->{_default}{value};
            my $result = $rel_rs->find_or_create({ $column => $value });
            $rels->{column}{$field} = $result->id;
        }
    }

}

sub _process_multi{
    my ($self, $rels, $row) = @_;

    my $multi_rel = $rels->{multi};

    foreach my $field (keys %$multi_rel){
warn "Field: $field\n";
        my $column = $self->row_schema->{$field}{value} || $self->row_schema->{_default}{value};
        my $add_method = 'add_to_'.$field;
        my $value = $multi_rel->{$field}{value};
        foreach my $item ( @$value ){
            ref $item
            ? $row->$add_method($item)
            : $row->$add_method({ $column => $item });
        }
    }

}

sub _process_m2m{
    my ($self, $rels, $row) = @_;

    my $m2m_rel = $rels->{m2m};
    my $source = $self->result_source;

    foreach my $field (keys %$m2m_rel){
        my $m2m_info = $m2m_rel->{$field}{info}; # field: categories
        my $rel = $m2m_info->{relation};                # has_many: product_category_maps
        my $rel_source = $source->related_source($rel); # source: Product::CategoryMap
        my $foreign_rel = $m2m_info->{foreign_relation}; # related source field: category
        my $rel_rel_rs = $rel_source->related_source($foreign_rel)->resultset; # Product::Category
        my $column = $self->row_schema->{$foreign_rel}{value} || $self->row_schema->{_default}{value};
        my $add_method = $m2m_info->{add_method};
        my $value = $m2m_rel->{$field}{value};

        foreach my $item (@$value){
            my $result = $rel_rel_rs->find_or_create({ $column => $item });
            $row->$add_method($result);
        }
    }

}

1;
