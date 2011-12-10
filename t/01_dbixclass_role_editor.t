use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema) ],
};

use_ok('Editor::Consumer');


fixtures_ok 'editor'
    => 'installed the product fixtures from configuration files';

ok my $editor = Editor::Consumer->new({ schema => Schema, })
    => 'new editor object';

#====================================================================
note('Create a new product');

ok my $movie = $editor->create({
    duration => 101,                        # integer value
    regular_price => 9.95,                  # dec value
    type => 'Movie',                        # belongs to
    name => 'Our First Test Title',         # string
    bulky => 1,                             # bool
    categories => [qw!Action Drama !],
    images => [qw! image1.png image2.jpg !],
}) => 'new movie';

ok $movie = ResultSet('Movie')->find({ name => 'Our First Test Title' })
  => 'movie found';

is( $movie->duration, 101, 'integer ok' );
is( $movie->regular_price, 9.95, 'dec ok' );
is( $movie->type->name, 'Movie', 'belongs_to ok' );
is( $movie->bulky, 1, 'bool ok' );

my $cats = [sort map { $_->name } $movie->categories];

is_deeply( $cats, [qw!Action Drama!], 'categories ok' ) or diag('Categories: '.join(', ',@$cats));

#====================================================================
note('Update product');

$editor->update({
    duration => 102,                        # integer value
    regular_price => 19.95,                 # dec value
    type => 'Game',                         # belongs to
    name => 'Our Updated First Test Title', # string
    bulky => 0,                             # bool
    categories => [qw! Action Comedy !],
    images => [qw! image1.png image3.jpg !],
}, $movie);

ok $movie = ResultSet('Movie')->find({ name => 'Our Updated First Test Title' })
  => 'movie updated';

is( $movie->duration, 102, 'integer ok' );
is( $movie->regular_price, 19.95, 'dec ok' );
is( $movie->type->name, 'Game', 'belongs_to ok' );
is( $movie->bulky, 0, 'bool ok' );

$cats = [sort map { $_->name } $movie->categories];

is_deeply( $cats, [qw! Action Comedy !], 'categories ok' ) or diag('Categories: '.join(', ',@$cats));

#====================================================================
note('Update product with undef values');

$editor->update({
    duration => undef,          # integer value
    regular_price => undef,     # dec value
    type => undef,              # belongs to
    name => undef,              # string
    bulky => undef,             # bool
    categories => undef,
    images => undef,
}, $movie);

ok $movie = ResultSet('Movie')->find($movie->id)
  => 'movie updated';

is( $movie->duration, undef, 'integer ok' );
is( $movie->regular_price, undef, 'dec ok' );
is( $movie->type, undef, 'belongs_to ok' );
is( $movie->bulky, undef, 'bool ok' );

is( $movie->categories, 0, 'categories ok' );

#====================================================================

done_testing();
