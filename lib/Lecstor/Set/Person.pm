package Lecstor::Set::Person;
use Moose;

# ABSTRACT: interface to person records

use Lecstor::Valid::Person;
use Lecstor::Error;

sub resultset_name{ 'Person' }

with 'Lecstor::Role::Set';

around 'create' => sub{
    my ($orig, $self, $params) = @_;
    my $valid = Lecstor::Valid::Person->new( params => $params );
    return Lecstor::Error->new({
        error => $valid->errors_to_string,
        error_fields => $valid->error_fields,
    }) unless $valid->validate;
    # set person active by default
    $params->{active} = 1;
    return $self->$orig($params);
};

__PACKAGE__->meta->make_immutable;

1;
