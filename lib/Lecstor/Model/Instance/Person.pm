package Lecstor::Model::Instance::Person;
use Moose;
use Lecstor::X;

extends 'Lecstor::Model::Instance';

has '+_record' => (
    handles => [qw!
        id created modified
        update
        firstname surname email homephone workphone mobile
        billing_address
        delivery_addresses default_delivery
    !]
);

has hash_fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

sub _build_hash_fields{
    [qw!firstname surname email homephone workphone mobile!];
}

sub as_hash{
    my ($self) = @_;
    my $hash = {};
    foreach(@{$self->hash_fields}){
        $hash->{$_} = $self->$_;
    }
    return $hash;
}

sub name{
    my $self = shift;
    Lecstor::X->throw('$self->name is readonly') if @_;
    return join(' ', $self->firstname, $self->surname);
}

sub delivery_address{
    my ($self) = @_;
    return unless $self->default_delivery;
    return $self->_record->delivery_addresses->search({
        id => $self->default_delivery
    })->first;
}

sub add_to_delivery_addresses{
    my ($self, $address) = @_;
    my $new_addr = $self->_record->add_to_delivery_addresses($address);
    $self->_record->update({ default_delivery => $new_addr->id });
    return $new_addr;
}

sub set_billing_address{
    my ($self, $address) = @_;
    Lecstor::X->throw('Billing address requires a country')
        unless $address->{country};
    $address->{country} = { name => $address->{country} }
        if $address->{country} =~ /[a-z]/i;
    return $self->related_resultset('billing_address')->create($address);
}

__PACKAGE__->meta->make_immutable;

1;