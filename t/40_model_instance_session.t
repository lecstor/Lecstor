use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
};

use_ok('Lecstor::Model::Instance::Session');

ok my $rs = ResultSet('Session'), 'resultset ok';

my $expires = time + 3600;

ok my $session_row = $rs->create({
    created => DateTime->now(),
    id => 'abc123',
    expires => $expires,
    data => { something => 'interesting' },
}), 'create session row ok';

ok my $session = Lecstor::Model::Instance::Session->new({
    _record => $session_row
}), 'create session instance ok';

is $session->id, 'abc123', 'session id ok';
is $session->expires, $expires, 'session expires ok';
is_deeply $session->data, { something => 'interesting' }, 'session data ok';

done_testing();
