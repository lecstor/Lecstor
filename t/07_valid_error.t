use strict;
use warnings;
use Test::More;
use Try::Tiny;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Lecstor::Valid::Error');

my $err = Lecstor::Valid::Error->new({ error => 'this is an error' });

ok !$err, 'error is false';
is $err->error, 'this is an error', 'error message ok';


$err = Lecstor::Valid::Error->new({
    error_fields => {
        field => [
            'this is an error'
        ],
    }
});

ok !$err, 'error is false';
is $err->error, undef, 'undef error message ok';
is_deeply 
    $err->error_fields,
    {
        field => [
            'this is an error'
        ],
    },
    => 'error_fields ok';

done_testing();
