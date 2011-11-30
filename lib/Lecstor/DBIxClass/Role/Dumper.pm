package Lecstor::DBIxClass::Role::Dumper;
use Moose::Role;
use namespace::autoclean;
use Carp qw! croak !;

=attr columns

arrayref of names of columns which are not foreign keys. 

=cut

has 'columns' => ( isa => 'ArrayRef', is => 'ro', auto_deref => 1, lazy_build => 1 );

sub _build_columns{ ['id'] }

=attr methods

arrayref of methods which contain data to be included in the dump.

=cut

has 'methods' => ( isa => 'ArrayRef', is => 'ro', auto_deref => 1, lazy_build => 1 );

sub _build_methods{ [] }

=attr single_related

arrayref of names of columns containing a foreign key.

=cut

has 'single_related' => ( isa => 'ArrayRef', is => 'ro', auto_deref => 1, lazy_build => 1 );

sub _build_single_related{ [] }

=attr many_related

arrayref of names of relationships to many rows.

=cut

has 'many_related' => ( isa => 'ArrayRef', is => 'ro', auto_deref => 1, lazy_build => 1 );

sub _build_many_related{ [] }

=attr field_types

arrayref of names of methods which return an arrayref of columns or relationships..
defaults to columns, methods, single_related, many_related.

=cut

has 'field_types' => ( isa => 'ArrayRef', is => 'ro', lazy_build => 1 );

sub _build_field_types{
    return [qw!columns methods single_related many_related!];
}

=attr fields

an arrayref of fields to include in the dump.
defaults to all columns and relationships in all field_types.

=cut

has 'fields' => ( isa => 'ArrayRef', is => 'ro', default => sub{[]} );
has 'fields_ok' => ( isa => 'HashRef', is => 'ro', lazy_build => 1 );
sub _build_fields_ok{
    my ($self) = @_;
    my @fields = @{$self->fields};
    my $ok;
    if (@fields){
        $ok = { map { $_ => 1 } @{$self->fields} };
    } else {
        $ok = {
            map { $_ => 1 }
            map { @{$self->$_} } @{$self->field_types}            
        };
    }
    return $ok;
}

=method row

  my $data = $dumper->row($dbixclass_row);

  $data: {
    'format' => {
                  'name' => 'DVD',
                  'id' => '1'
                },
    'release_date' => '2011-10-29',
    'name' => 'Test1',
    'categories' => [
                      {
                        'name' => 'Horror',
                        'id' => 1
                      },
                      {
                        'name' => 'Drama',
                        'id' => 3
                      }
                    ],
    'category' => {
                    'name' => 'Comedy',
                    'id' => 2
                  },
    'type' => {
                'name' => 'Movie',
                'id' => '1'
              },
    'id' => '1'
  },

returns a hash of data containing the row data for all allowed columns,
relationships, and methods.

=cut

sub row{
    my ($self, $result) = @_;

    croak 'Need a result object' unless $result;

    my $data = {};

    foreach my $col ($self->columns){
        next unless $self->fields_ok->{$col};
        my $value = $result->get_column($col);
        $data->{$col} = $value if defined $value;
    }

    foreach my $belongs ($self->single_related){
        next unless $self->fields_ok->{$belongs};
        if (my $obj = $result->$belongs){
            $data->{$belongs} = {$obj->get_columns()};
        }
    }

    foreach my $many ($self->many_related){
        next unless $self->fields_ok->{$many};
        foreach my $related ( $result->$many ){
            push(@{$data->{$many}}, {$related->get_columns()});
        }
    }

    foreach my $method ($self->methods){
        next unless $self->fields_ok->{$method};
        my $value = $result->$method();
        $data->{$method} = $value if defined $value;
    }

    return $data;
}

=method resultset

    my $data = $dumper->resultset($dbixclass_resultset);

returns an arrayref of row data hashrefs for all rows in the resultset.

=cut

sub resultset{
    my ($self, $rs) = @_;
    my @rows;
    while (my $row = $rs->next){
        push(@rows, $self->row($row));
    }
    return \@rows;
}

=method flatten_row

  my $data = $dumper->flatten_row($dbixclass_row);

  $data: {
      'format' => 'DVD',
      'release_date' => '2011-11-29',
      'name' => 'Test2',
      'categories' => 'Comedy, Drama',
      'category' => 'Horror',
      'type' => 'Movie',
      'id' => '2'
  }

flatten down the rows to keep only the name values.

=cut

sub flatten_row{
    my ($self, $row) = @_;
    $row = $self->row($row) if ref $row ne 'HASH';
    foreach my $field (keys %$row){
        next unless ref $row->{$field};
        $row->{$field} = $self->flatten($row->{$field});
    }
    return $row;
}

=method flatten

    my $data = $dumper->flatten({
        'categories' => [
            { 'name' => 'Horror', 'id' => 1 }, 
            { 'name' => 'Drama', 'id' => 3 } 
        ],
    });

    $data: {
        'categories' => 'Horror, Drama',
    }

reduces hashrefs to the value of their 'name' attribute.
rucursively loops though arrayrefs and joins the results with commas.

=cut

sub flatten{
    my ($self, $value) = @_;
    if (ref $value eq 'ARRAY'){
        foreach my $sub_value (@$value){
            $sub_value = $self->flatten($sub_value);
        }
        return join(', ', @$value);
    }
    return $value->{name};
}

=method flatten_resultset

returns an arrayref of flattened row data hashrefs for all rows in the resultset.

=cut

sub flatten_resultset{
    my ($self, $rs) = @_;
    my @rows;
    while (my $row = $rs->next){
        push(@rows, $self->flatten_row($row));
    }
    return \@rows;
}

1;









