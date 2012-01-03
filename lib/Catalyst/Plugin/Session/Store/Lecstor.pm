package Catalyst::Plugin::Session::Store::Lecstor;
use base qw/Catalyst::Plugin::Session::Store/;
 
use strict;
use warnings;
 
our $VERSION = "0.01";
 

sub get_session_data {
    my ($c, $key) = @_;
    my ($type, $key) = split(/:/, $key);
    my $session = $c->lecstor->session->find_or_create($key);
    return $session->expires if $type eq 'expires';
    return $session->data->{$type};
}
 
sub store_session_data {
    my ($c, $key, $data) = @_;
    my ($type, $key) = split(/:/, $key);
    my $session = $c->lecstor->session->find_or_create($key);
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
    my ($type, $key) = split(/:/, $key);
    $c->lecstor->session->find_or_create($key)->delete;
}
 
sub delete_expired_sessions {
    $c->lecstor->session->delete_expired;
}

1;
 
__END__
 