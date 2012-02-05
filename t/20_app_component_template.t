#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::MockObject;
use Test::Exception;

use_ok('Lecstor::App::Component::Template');

my $tt = Test::MockObject->new;
$tt->mock( 'process', sub{ my $out = pop(@_); $$out = 'ello dere' });

ok my $template = Lecstor::App::Component::Template->new(
    processor => $tt,
) => 'new template component ok';

ok my $content = $template->process(
    \'ello [% val %]', { val => 'dere' }
) => 'process ok';

is $content, 'ello dere', 'content ok';



$tt->set_always('process', 0);
$tt->set_always('error', 'Thar be dragins!');

throws_ok { $template->process(\'', {}) } 'Lecstor::X', 'Lecstor::X thrown';
is $@->message, 'Thar be dragins!', 'error message ok';


done_testing();

