use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Lecstor::FeedProxy::Diff');

my $bef = {
  name => 'Fred',
  wife => 'Wilma',
  hobby => 'Breaking Rocks',
  friends => [qw! Barney Wilma Betty !],
};

my $aft = { 
  name => 'Fred',
  pet => 'Dino',
  hobby => 'Bowling',
  friends => [qw! Barney Betty Dino !],
  kids => [qw! Bam Pebbles !],
};

ok my $differ = Lecstor::FeedProxy::Diff->new => 'new diff ok';

ok my $diff = $differ->differences($bef, $aft) => 'differences ok';

my $exp = {
  'pet' => 'Dino',
  'wife' => undef,
  'hobby' => 'Bowling',
  'friends' => {
    'remove' => [ 'Wilma' ],
    'add' => [ 'Dino' ]
  },
  'kids' => {
    'add' => [ 'Bam', 'Pebbles' ]
  }
};

is_deeply $diff, $exp, 'diff ok';




done_testing();
