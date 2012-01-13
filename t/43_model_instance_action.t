use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
};

use_ok('Lecstor::Model::Instance::Action');

ok my $rs = ResultSet('Action'), 'resultset ok';

my $session_id = time;

ok my $row = $rs->create({
    type => { name => 'test1' },
    session => $session_id,
    user => 1,
    data => { something => 'interesting' },
}), 'create action row ok';

ok my $instance = Lecstor::Model::Instance::Action->new({
    _record => $row
}), 'create action instance ok';

is $instance->id, 1, 'instance id ok';
is $instance->session, $session_id, 'instance session ok';
is_deeply $instance->data, { something => 'interesting' }, 'instance data ok';

done_testing();
