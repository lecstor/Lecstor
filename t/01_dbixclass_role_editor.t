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
  => 'new movie found';

is( $movie->duration, 101, 'new integer ok' );
is( $movie->regular_price, 9.95, 'new dec ok' );
is( $movie->type->name, 'Movie', 'new belongs_to ok' );
is( $movie->bulky, 1, 'new bool ok' );

my $cats = [sort map { $_->name } $movie->categories];
is_deeply( $cats, [qw!Action Drama!], 'new categories ok' ) or diag('Categories: '.join(', ',@$cats));

my $imgs = [sort map { $_->name } $movie->images];
is_deeply( $imgs, [qw! image1.png image2.jpg !], 'new images ok' ) or diag('Images: '.join(', ',@$imgs));

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
  => 'updated movie updated';

is( $movie->duration, 102, 'updated integer ok' );
is( $movie->regular_price, 19.95, 'updated dec ok' );
is( $movie->type->name, 'Game', 'updated belongs_to ok' );
is( $movie->bulky, 0, 'updated bool ok' );

$cats = [sort map { $_->name } $movie->categories];
is_deeply( $cats, [qw! Action Comedy !], 'updated categories ok' ) or diag('Categories: '.join(', ',@$cats));

$imgs = [sort map { $_->name } $movie->images];
is_deeply( $imgs, [qw! image1.png image3.jpg !], 'updated images ok' ) or diag('Images: '.join(', ',@$imgs));

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
  => 'undef movie updated';

is( $movie->duration, undef, 'undef integer ok' );
is( $movie->regular_price, undef, 'undef dec ok' );
is( $movie->type, undef, 'undef belongs_to ok' );
is( $movie->bulky, undef, 'undef bool ok' );

is( $movie->categories, 0, 'undef categories ok' );
is( $movie->images, 0, 'undef images ok' );

#====================================================================
note('Update product belongs_to with reference');

$editor->update({
    type => { name => 'set by ref' },
}, $movie);

ok $movie = ResultSet('Movie')->find($movie->id)
  => 'movie updated';

is( $movie->type->name, 'set by ref', 'set by ref ok' );

#====================================================================
note('Update product with too long type');

my $name_size = $movie->result_source->column_info('name')->{size};
my $type_name_size = $movie->result_source->related_source('type')->column_info('name')->{size};
my $image_name_size = $movie->result_source->related_source('images')->column_info('name')->{size};
my $category_name_size = $movie->result_source->related_source('category')->column_info('name')->{size};


$editor->update({
    name => 'a' x ($name_size+10),
    type => 'b' x ($type_name_size+10),
    categories => ['c' x ($category_name_size+10), 'd' x ($category_name_size+10)],
    images => ['e' x ($image_name_size+10), 'f' x ($image_name_size+10)],
}, $movie);

ok $movie = ResultSet('Movie')->find($movie->id)
  => 'movie updated';

is( $movie->name, ('a' x $name_size), 'too long name ok' );
is( $movie->type->name, ('b' x $type_name_size), 'too long type ok' );

$cats = [sort map { $_->name } $movie->categories];
is_deeply( $cats, [('c' x $category_name_size), ('d' x $category_name_size)], 'too long categories ok' ) or diag('Categories: '.join(', ',@$cats));

$imgs = [sort map { $_->name } $movie->images];
is_deeply( $imgs, [('e' x $image_name_size), ('f' x $image_name_size)], 'too long images ok' ) or diag('Images: '.join(', ',@$imgs));


note('do it again, trying to find truncated strings');

$editor->update({
    name => 'a' x ($name_size+10),
    type => 'b' x ($type_name_size+10),
    categories => ['c' x ($category_name_size+10), 'd' x ($category_name_size+10)],
    images => ['e' x ($image_name_size+10), 'f' x ($image_name_size+10)],
}, $movie);

ok $movie = ResultSet('Movie')->find($movie->id)
  => 'movie updated';

is( $movie->name, ('a' x $name_size), 'too long name 2 ok' );
is( $movie->type->name, ('b' x $type_name_size), 'too long type 2 ok' );

$cats = [sort map { $_->name } $movie->categories];
is_deeply( $cats, [('c' x $category_name_size), ('d' x $category_name_size)], 'too long categories 2 ok' ) or diag('Categories: '.join(', ',@$cats));

$imgs = [sort map { $_->name } $movie->images];
is_deeply( $imgs, [('e' x $image_name_size), ('f' x $image_name_size)], 'too long images 2 ok' ) or diag('Images: '.join(', ',@$imgs));

#====================================================================

done_testing();
