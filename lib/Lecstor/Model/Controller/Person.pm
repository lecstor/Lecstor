package Lecstor::Set::Person;
use Moose;
use Class::Load ('load_class');

# ABSTRACT: interface to person records

extends 'Lecstor::Set';

use Lecstor::Valid::Person;
use Lecstor::Error;

sub resultset_name{ 'Person' }

has model_class => ( isa => 'Str', is => 'ro', builder => '_build_model_class' );

sub _build_model_class{ 'Lecstor::Model::Person' }

=head1 SYNOPSIS

    my $person_set = Lecstor::Set::Person->new({
        schema => $dbic_schema,
    });

    my $person = $person_set->create({
        firstname => 'Jason',
        surname => 'Galea',
        email => 'test1@eightdegrees.com.au',
        homephone => '0123456789',
        workphone => '0123456789',
        mobile => '0123456789',
    })

    my $del_addr = $person->add_to_delivery_addresses({
        street => '123 Test St',
        country => { name => 'Australia' },
    });

    my $bill_addr = $person->set_billing_address({
        street => '123 Other St',
        country => 'Australia',
    });

=cut

around 'create' => sub{
    my ($orig, $self, $params) = @_;
    my $valid = Lecstor::Valid::Person->new( params => $params );
    return Lecstor::Error->new({
        error => $valid->errors_to_string,
        error_fields => $valid->error_fields,
    }) unless $valid->validate;
    # set person active by default
    $params->{active} = 1 unless exists $params->{active};
    my $model_class = $self->model_class;
    load_class($model_class);
    return $model_class->new( _record => $self->$orig($params) );
};

__PACKAGE__->meta->make_immutable;

1;
