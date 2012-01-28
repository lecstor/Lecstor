package Lecstor::Model::Instance::User;
use Moose;
use DateTime;
use Scalar::Util 'blessed';
use Lecstor::X;

use overload '""' => sub{ shift->_record ? 1 : 0 };

extends 'Lecstor::Model::Instance';

has '_record' => (
    isa => 'Object', is => 'rw',
    handles => [qw!
        id created modified active
        username email person password
        update 
        roles
    !],
    clearer => 'clear__record',
);

sub as_hash{
    my ($self) = @_;
    return {
        id => $self->id,
        email => $self->email,
        username => $self->username,
        person => $self->person ? $self->person->as_hash : 0,
    };
}

=method set_record

    $user->set_record($other_user);

=cut

sub set_record{
    my ($self, $user) = @_;
    $self->_record($user->_record);
}

=method login

=cut

sub login{
    my ($self, $user) = @_;
    $self->set_record($user);
}

=method logout

=cut

sub logout{
    my ($self) = @_;
    $self->clear__record;
}

=method check_password

  $person->check_password('trypass');

returns true if the supplied password is correct

=cut

sub check_password{
    my ($self, $password) = @_;
    return 1 if $self->_record->check_password($password);
    if (my $tmppass = $self->_record->temporary_password){
        if ($tmppass->expires < DateTime->now){
            $tmppass->delete;
            return;
        }
        return $tmppass->check_password($password);
    }
    return;
}

=method set_temporary_password

    $user->set_temporary_password({
        password => '4321abcd',
        expires => DateTime->now->add( days => 1 ),
    });

=cut

sub set_temporary_password{
    my ($self, $args) = @_;
    $args->{user} = $self->id;
    $args->{created} = DateTime->now( time_zone => 'local' );
    return $self->related_resultset('temporary_password')->create($args);
}

=method add_to_roles

    @roles = $user->add_to_roles('Role1');
    @roles = $user->add_to_roles(qw! Role1 Role3 !)

The role to be added must already exist.

=cut

sub add_to_roles{
    my ($self, @roles) = @_;
    foreach(@roles){
        Lecstor::X->throw('Roles must be added by name only. Roles not added.')
            if ref $_;
    }
    my @objects;
    my $role_rs = $self->_record->result_source->schema->resultset('UserRole');
    my $role_map_rs = $self->_record->result_source->schema->resultset('UserRoleMap');
    foreach my $role (@roles){
        my $record = $role_rs->search({ name => $role })->single;
        Lecstor::X->throw( "Role: '$role' does not exist" ) unless $record;
        $role_map_rs->create({
            created => DateTime->now( time_zone => 'local' ),
            user => $self->_record->id,
            role => $record->id,
        });
        push(@objects, $record);
    }
    return @objects;
}

=method roles_by_name

    my @role_names = $user->roles_by_name;

=cut

sub roles_by_name{
    my ($self) = @_;
    return sort map{ $_->name } $self->roles;
}

__PACKAGE__->meta->make_immutable;

1;