package Lecstor::Request;
use Moose;
use Class::Load 'load_class';

with 'Lecstor::Role::ActionLogger';

=head1 SYNOPSIS

    my $request = Lecstor::Request->new(
        uri => $uri,
        session_id => $session_id,
    );

=cut

sub BUILD{
    shift->update_view;
}
=attr uri

=cut

has uri => ( is => 'ro', isa => 'URI' );

=attr session_id

=cut

has session_id => ( is => 'rw', isa => 'Str', required => 1 );

=attr user

=cut

has user => (
    is => 'rw', isa => 'Lecstor::Model::Instance::User', lazy_build => 1,
#    trigger => \&update_view,    
);

sub _build_user{ Lecstor::Model::Instance::User->new }

=attr view

    $app->view({ animals => { dogs => 1 } });
    # $app->view: { animals => { dogs => 1 } }
    $app->view({ animals => { cats => 2 } });
    # $app->view: { animals => { dogs => 1, cats => 2 } }
    $app->set_view({ foo => bar });
    # $app->view: { foo => bar });
    $app->clear_view;
    # $app->view: undef

Hashref containing view attributes

See L<MooseX::Traits::Attribute::MergeHashRef>

=cut

has view => (
    is => 'rw', isa => 'HashRef',
    traits => [qw(MergeHashRef)],
    default => sub{{}},
);

=method login

set the current user

=cut

sub login{
    my ($self, $user) = @_;
    $self->user->set_record($user);
    $self->update_view;
    return $self->user;
}

=method update_view

=cut

sub update_view{
    my ($self) = @_;
    my $user = $self->user;
    if ($user){
        my $visitor = {
          %{$self->view->{visitor} || {}},
          logged_in => 1,
          email => $user->email,
          name => $user->username,
        };
        $visitor->{name} ||= $user->person->name if $user->person;
        $self->view({ visitor => $visitor });
    }
}

sub current_user{ shift->user }
sub current_session_id{ shift->session_id }


__PACKAGE__->meta->make_immutable;

1;

