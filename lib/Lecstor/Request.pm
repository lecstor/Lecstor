package Lecstor::Request;
use Moose;
use Class::Load 'load_class';

#with 'Lecstor::Role::ActionLogger';

=head1 SYNOPSIS

    my $request = Lecstor::Request->new(
        uri => $uri,
        session_id => $session_id,
    );

#=cut

sub BUILD{
    shift->update_view;
}
=attr uri

=cut

has uri => ( is => 'ro', isa => 'URI' );

=attr session_id

=cut

has session_id => ( is => 'rw', isa => 'Str', required => 1 );


=method login

set the current user

#=cut

sub login{
    my ($self, $user) = @_;
    $self->user->set_record($user);
    $self->update_view;
    return $self->user;
}

=method update_view

#=cut

sub update_view{
    my ($self) = @_;
    my $user = $self->user;
    if ($user){
        my $visitor = {
          %{$self->view->{visitor} || {}},
          logged_in => 1,
          email => $user->email,
          name => $user->username,
          username => $user->username,
          user_id => $user->id,
        };
        $visitor->{name} ||= $user->person->name if $user->person;
        $self->view({ visitor => $visitor });
    }
}

sub current_user{ shift->user }
sub current_session_id{ shift->session_id }

=cut


__PACKAGE__->meta->make_immutable;

1;

