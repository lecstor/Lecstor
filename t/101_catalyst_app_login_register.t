#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

BEGIN {
    $ENV{LECSTOR_DEPLOY} ||= 'test';
    $ENV{EMAIL_SENDER_TRANSPORT} = 'Test';
};


use HTTP::Request::Common;
use File::Path qw!rmtree!;

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_app) ],
    resultsets => [ 'User' ],
};

use_ok 'Test::WWW::Mechanize::Catalyst', 'CatApp';

fixtures_ok 'basic'
    => 'installed the basic fixtures from configuration files';


my $mech = Test::WWW::Mechanize::Catalyst->new;

#-----------------------
$mech->post_ok(
    '/login_or_register',
    {
        email => 'bad_email_address',
        password => 'irrelevant',
        action => 'Register',
    }
);
$mech->content_like( qr!<h2>Register</h2>!, 'is register page' );
$mech->content_like( qr/A valid email address is required/, 'invalid email' );

#-----------------------
$mech->post_ok(
    '/login_or_register',
    {
        email => 'jason@lecstor.com',
        password => 'abcd1234',
        action => 'Register',
    }
);

ok my $person = User->find({ email => 'jason@lecstor.com' })
  => 'login created' or diag($mech->content);



$mech->post_ok(
    '/login_or_register',
    {
        email => 'bad_email_address',
        password => 'irrelevant',
        action => 'Sign In',
    }
);

#warn $mech->content;
$mech->content_like( qr!<h2>Log In</h2>!, 'is login page' );
$mech->content_like( qr/A valid email address is required/, 'invalid email' );

$mech->post_ok(
    '/login',
    {
        email => 'jason@lecstor.com',
        password => 'abcd1234',
        action => 'Sign In',
    }
);
$mech->content_like( qr!uri: "/"!, 'is home page' ) or dump_meta($mech);
$mech->content_like( qr!Logged in as!, 'logged in' );

#warn $mech->content;

done_testing();

sub dump_meta{
    my ($mech) = @_;
    my ($meta) = $mech->content =~ /(<!-- VIEW META.*-->)/s;
    diag('VIEW META: '.$meta);
}



