package Catalyst::Authentication::User::Lecstor;
use Moose;

# ABSTRACT: Catalyst authentication user.

extends 'Catalyst::Authentication::User';

has 'user_object' => (
  is => 'rw',
  handles => [qw!username firstname surname!],
);

sub get_object{
  return shift->user_object;
}

my %supports = map{$_=>1}
  qw!roles session!;

sub supports{
  my ($self,@features) = @_;
  foreach(@features){
    return unless $supports{$_};
  }
  return 1;
}

sub roles{
  my ($self) = @_;
  return map{ $_->name } $self->user_object->roles;
}

1;
