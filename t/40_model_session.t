use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Lecstor::Test::DateTime '2012-01-01 14:00:00';

use Test::DBIx::Class {
    config_path => [ File::Spec->splitdir($Bin), qw(etc schema_base) ],
};

use_ok('Lecstor::Model::Controller::Session');

ok my $session_ctrl = Lecstor::Model::Controller::Session->new({
    schema => Schema,
}), 'get controller ok';

ok my $session = $session_ctrl->create({
    id => 'abc123',
    expires => time + 3600,
    data => { something => 'interesting' },
}), 'create session ok';

ok $session = $session_ctrl->find('abc123'), 'find ok';
is $session->id, 'abc123', 'id ok';

ok my $session_rs = $session_ctrl->search({ id => 'abc123' }), 'search ok';
isa_ok $session_rs, 'DBIx::Class::ResultSet';
ok $session = $session_rs->first, 'first ok';
isa_ok $session, 'Lecstor::Schema::Result::Session';

ok my $session_rsc = $session_ctrl->search_for_id({ id => 'abc123' }), 'search_for_id ok';
isa_ok $session_rsc, 'DBIx::Class::ResultSetColumn';
is_deeply [$session_rsc->all], ['abc123'], 'rsc all ok';

ok $session = $session_ctrl->find_or_create({ id => 'abc123' }), 'find_or_create (find) ok';
is $session->id, 'abc123', 'id ok';

ok $session = $session_ctrl->find_or_create({ id => 'abc123456' }), 'find_or_create (create) ok';
is $session->id, 'abc123456', 'id ok';

done_testing();