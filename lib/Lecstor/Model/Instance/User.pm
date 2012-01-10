package Lecstor::Model::Instance::User;
use Moose;
use DateTime;
use Scalar::Util 'blessed';
use Lecstor::X;

extends 'Lecstor::Model::Instance';

has '+_record' => (
    handles => [qw!
        id created modified active
        username email person password
        update temporary_password
        roles
    !]
);

=method check_password

  $person->check_password('trypass');

returns true if the supplied password is correct

=cut

sub check_password{
  my ($self, $password) = @_;
  return 1 if $self->_record->check_password($password);
  if (my $tmppass = $self->temporary_password){
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
    @roles = $user->add_to_roles({ name => 'Role1' });
    @roles = $user->add_to_roles([
        { name => 'Role1' },
        { name => 'Role3' },
    ]);
    @roles = $user->add_to_roles($dbic_role_result);
    @roles = $user->add_to_roles($dbic_role_result, $dbic_role_result2);

The role to be added must already exist.

=cut

sub add_to_roles{
    my ($self, @roles) = @_;
    my @objects;
    my $role_rs = $self->_record->result_source->schema->resultset('UserRole');
    my $role_map_rs = $self->_record->result_source->schema->resultset('UserRoleMap');
    foreach my $role (@roles){
        unless( blessed $role && $role->isa('DBIx::Class::Row') ){
            $role = { name => $role } unless ref $role;
            my $record = $role_rs->search($role)->single;
            Lecstor::X->throw( $role->{name} . " does not exist" )
                unless $record;
            $role = $record;
        }
        $role_map_rs->create({
            created => DateTime->now( time_zone => 'local' ),
            user => $self->_record->id,
            role => $role->id,
        });
        push(@objects, $role);
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