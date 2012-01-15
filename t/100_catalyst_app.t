#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

BEGIN {
    $ENV{LECSTOR_DEPLOY} = 'test';
};

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_app) ],
};

use Catalyst::Test 'CatApp';

ok( request('/')->is_success, 'Request should succeed' );

done_testing();
