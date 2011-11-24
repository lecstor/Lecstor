package Editor::Consumer;
use Moose;

# ABSTRACT: Admin module for products

with 'Lecstor::DBIxClass::Role::Editor';

=head1 SYNOPSIS


=attr schema [required]

  $schema = $editor->schema;

=attr resultset_name

returns the name of the main resultset to be used ('Product')

=cut

sub resultset_name{ 'Movie' }

=attr row_schema

=cut

sub _build_row_schema{
    return {
        _default => {
            key => 'id',
            value => 'name',
        },
    };
}

__PACKAGE__->meta->make_immutable;

1;
