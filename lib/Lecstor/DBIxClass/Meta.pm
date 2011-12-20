package Lecstor::DBIxClass::Meta;
use Moose;

# ABSTRACT: provides access to a DBIx::Class::ResultSet metadata

has resultset => ( isa => 'DBIx::Class::ResultSet', is => 'ro', lazy_build => 1 );

sub _build_resultset{
    my ($self) = @_;
    $self->schema->resultset($self->resultset_name);
}

=attr result_source

the resultset result_source

=cut

has result_source => (
    isa => 'DBIx::Class::ResultSource', is => 'ro', lazy_build => 1,
    handles => [qw! columns relationship_info !],
);

sub _build_result_source{ shift->resultset->result_source }

=attr result_class

the resultset result_class

=cut

has result_class => ( isa => 'Str', is => 'ro', lazy_build => 1 );

sub _build_result_class{ shift->resultset->result_class }

=head1 SYNOPSIS

  my $meta = Lecstor::DBIxClass::Meta->new({ resultset => $dbix_class_rs });

  if ($meta->categories->accessor->is_multi){

  }



=cut


sub BUILD{
    my ($self) = @_;

    my $result_source = $self->result_source;

    foreach my $field ($self->columns){
        if ($result_source->has_relationship($field)){

            my $code = sub{
                Lecstor::DBIxClass::Meta::Field->new(
                    accessor => Lecstor::DBIxClass::Meta::Accessor->new(
                        type => $self->result_source->relationship_info($field)->{attrs}{accessor},
                    ),
                );
            };

            $self->meta->add_method(
                $field,
                Class::MOP::Method->wrap(
                    $code, name => $field, package_name => __PACKAGE__
                )
            );

        } else {

        }
    }

    my $metadata = $self->result_class->_m2m_metadata;

}



1;
