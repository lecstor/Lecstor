package Lecstor::Model::Login;
use Moose;
use DateTime;

with 'Lecstor::Model';

has '+data' => (
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
  return 1 if $self->data->check_password($password);
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

    $login->set_temporary_password({
        password => '4321abcd',
        expires => DateTime->now->add( days => 1 ),
    });

=cut

sub set_temporary_password{
    my ($self, $args) = @_;
    $args->{login} = $self->id;
    return $self->related_resultset('temporary_password')->create($args);
}

=method add_to_roles

    @roles = $login->add_to_roles('Role1');
    @roles = $login->add_to_roles(qw! Role1 Role3 !)
    @roles = $login->add_to_roles({ name => 'Role1' });
    @roles = $login->add_to_roles([
        { name => 'Role1' },
        { name => 'Role3' },
    ]);
    @roles = $login->add_to_roles($dbic_role_result);
    @roles = $login->add_to_roles($dbic_role_result, $dbic_role_result2);

=cut

sub add_to_roles{
    my ($self, @roles) = @_;
    my @objects;
    foreach my $role (@roles){
        $role = { name => $role } unless ref $role;
        push(@objects, $self->data->add_to_roles($role) );
    }
    return @objects;
}

=method roles_by_name

    my @role_names = $login->roles_by_name;

=cut

sub roles_by_name{
    my ($self) = @_;
    return sort map{ $_->name } $self->roles;
}

__PACKAGE__->meta->make_immutable;

1;