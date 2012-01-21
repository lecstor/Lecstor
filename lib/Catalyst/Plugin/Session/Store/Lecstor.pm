package Catalyst::Plugin::Session::Store::Lecstor;
use base qw/Catalyst::Plugin::Session::Store/;
 
use strict;
use warnings;
 
our $VERSION = "0.01";
 
# Keys are in the format prefix:id, where prefix is session, expires,
# or flash, and id is always the session ID. Plugins such as
# Catalyst::Plugin::Session::PerUser store extensions to this format,
# such as user:username.

sub get_session_data {
    my ($c, $key) = @_;
    my $type;
    ($type, $key) = split(/:/, $key);
    my $session = $c->lecstor->model->session->find_or_create($key);

    return $session->expires if $type eq 'expires';

    my $data = $session->data || {};
    return $data->{$type};
}
 
sub store_session_data {
    my ($c, $key, $data) = @_;
    my $type;
    ($type, $key) = split(/:/, $key);
    my $session = $c->lecstor->model->session->find_or_create($key);
    if ($type eq 'expires'){
        $session->update({ expires => $data });
    } else {
        my $session_data = $session->data;
        $session_data->{$type} = $data;
        $session->data($session_data);
        $session->update;
    }
}
 
sub delete_session_data {
    my ( $c, $key ) = @_;
    my $type;
    ($type, $key) = split(/:/, $key);
    $c->lecstor->model->session->find_or_create($key)->delete;
}
 
sub delete_expired_sessions {
    $_[0]->lecstor->session->delete_expired;
}

1;
 
__END__
 