use strict;
use warnings;
use Test::More;
use Data::Dumper;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema) ],
}, 'Movie';

use_ok('Meta::Consumer');

fixtures_ok 'editor'
    => 'installed the product fixtures from configuration files';

ok my $object = Meta::Consumer->new({ resultset => Movie }), 'get object';

is_deeply
    [sort $object->no_related],
    [ 'available_date', 'bulky', 'created', 'duration', 'id', 'name', 'regular_price' ],
    'no_related';

is_deeply
    [sort $object->single_related],
    [ 'category', 'type' ],
    'single_related';

is_deeply
    [sort $object->many_related],
    [ 'images', 'movie2categories' ],
    'many_related';

done_testing();
