package Catalyst::Authentication::Store::Lecstor;
use Moose;
use namespace::autoclean;

# ABSTRACT: Catalyst authentication store

use Catalyst::Authentication::User::Lecstor;
use Data::Dumper;

has 'config' => ( isa => 'HashRef', is => 'ro' );
has 'catalyst' => ( is => 'ro' );
has 'realm' => ( is => 'ro' );

sub BUILDARGS{
  my ($class, $config, $app, $realm ) = @_;
  return {
    config => $config,
    catalyst => $app,
    realm => $realm,
  };
}

sub find_user{
  my ($self, $authinfo, $c) = @_;

  return unless $authinfo->{email} || $authinfo->{username} || $authinfo->{id};
  my $user = $c->lecstor->model->user->find($authinfo);
  return unless $user;

  return Catalyst::Authentication::User::Lecstor->new({ user_object => $user });
}

sub for_session{
  my ( $self, $c, $user ) = @_;
  return($user->get('id'));
}

sub from_session{
  my ( $self, $c, $id ) = @_;
  return $self->find_user({ id => $id }, $c);
}

1;
