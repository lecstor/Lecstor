use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Test::MockObject;

use FindBin qw($Bin);
use lib "$Bin/lib";

use_ok('Lecstor::Model::Controller');


my $schema = Test::MockObject->new;
$schema->set_isa('DBIx::Class::Schema');

my $ctrl = Lecstor::Model::Controller->new(
    schema => $schema,
);

my $orig_params = {
    'no_rel' => 'no rel value',
    'no_rel2' => 'no rel value2',
    'address.street' => '123 Some St',
    'address.suburb' => 'Someville',
    'turkey.stuffing' => 'bread crumbs',
    'my.distant.rel' => 'far away',
    'my.distant.rel2' => 'far away2',
};

my ($params, $reldata) = $ctrl->separate_params($orig_params);

is_deeply $params, {
    'no_rel' => 'no rel value',
    'no_rel2' => 'no rel value2',
} => 'params ok';

is_deeply $reldata->{address}, {
    'street' => '123 Some St',
    'suburb' => 'Someville',
} => 'address ok';

is_deeply $reldata->{turkey}, {
    'stuffing' => 'bread crumbs',
} => 'turkey ok';

is_deeply $reldata->{my}, {
    'distant.rel' => 'far away',
    'distant.rel2' => 'far away2',
} => 'my ok';

done_testing();
