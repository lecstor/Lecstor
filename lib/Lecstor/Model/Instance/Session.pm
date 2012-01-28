package Lecstor::Model::Instance::Session;
use Moose;
use DateTime;
use Lecstor::Model::Instance::User;

extends 'Lecstor::Model::Instance';

has '+_record' => (
    handles => [qw!
        id created modified 
        expires
        update delete
    !]
);

has user_instance_class => ( is => 'ro', isa => 'Str', builder => '_build_user_instance_class' );

sub _build_user_instance_class{ 'Lecstor::Model::Instance::User' }

sub set_user{
    my ($self, $user) = @_;
    $self->update({ user => $user->_record });
}

sub user{
    my ($self) = @_;
    my $user = $self->_record->user;
    my $user_class = $self->user_instance_class;
    return $user ?
        $user_class->new('_record' => $user )
        : $user_class->new();
}

sub data{
    my $data = shift->_record->data(@_);
    return $data || {};
}

sub as_hash{
    my ($self) = @_;

    my %hash = (
        id => $self->id,
        data => $self->data,
    );
    if (my $user = $self->user){
        $hash{user} = $user->as_hash;
    }

    return \%hash;
}

__PACKAGE__->meta->make_immutable;

1;