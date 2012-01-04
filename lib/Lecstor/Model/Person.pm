package Lecstor::Model::Person;
use Moose;

with 'Lecstor::Model';

has '+data' => (
    handles => [qw!
        id created modified
        update
        firstname surname default_delivery
        billing_address
        delivery_addresses
    !]
);

sub name{
    my $self = shift;
    die "$self->name is readonly" if @_;
    return join(' ', $self->firstname, $self->surname);
}

sub delivery_address{
    my ($self) = @_;
    return unless $self->default_delivery;
    return $self->data->delivery_addresses->search({
        id => $self->default_delivery
    })->first;
}

sub add_to_delivery_addresses{
    my ($self, $address) = @_;
    my $new_addr = $self->data->add_to_delivery_addresses($address);
    $self->data->update({ default_delivery => $new_addr->id });
    return $new_addr;
}

sub set_billing_address{
    my ($self, $address) = @_;
    if ($address->{country} && $address->{country} =~ /[a-z]/i){
        $address->{country} = { name => $address->{country} };
    }
    return $self->related_resultset('billing_address')->create($address);
}

__PACKAGE__->meta->make_immutable;

1;