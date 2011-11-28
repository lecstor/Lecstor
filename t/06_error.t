use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Lecstor::Error');

my $err = Lecstor::Error->new({ error => 'this is an error' });

ok !$err, 'error is false';
is $err->error, 'this is an error', 'error message ok';


done_testing();
