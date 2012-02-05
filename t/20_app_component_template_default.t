#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::MockObject;

BEGIN {
    eval "use Template::AutoFilter"; if($@) {
        plan skip_all => 'Template::AutoFilter not installed';
    }
    eval "use Template::Plugins"; if($@) {
        plan skip_all => 'Template::Plugins not installed';
    }
}

use Template::AutoFilter;
use Template::Plugins;

use_ok('Lecstor::App::Component::Template');
use_ok('Lecstor::Template::Plugins::Allow');

ok my $template = Lecstor::App::Component::Template->new() => 'new template component ok';

ok my $content = $template->process(
    \'ello [% val %]', { val => 'dere' }
) => 'process ok';

is $content, 'ello dere', 'content ok';

done_testing();
