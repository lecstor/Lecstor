use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Lecstor::Valid::Address');

#====================================================================
#note('provide good email as only param');

ok my $rules = Lecstor::Valid::Address->new(
    params => {
        name => 'Jason Galea',
        company => 'EDOC',
        street => '123 Test St',
        suburb => 'Somewhere',
        state => 'Qld',
        postcode => '4321',
    }
) => 'new validation object';

ok $rules->validate => 'address ok';


ok $rules = Lecstor::Valid::Address->new(
    params => {
        name => 'Jason Galea Jason Galea Jason Galea Jason Galea Jason Galea Jason Galea ',
        company => '',
        street => '',
        suburb => '',
        state => 'Qldasdadasdasdadasd',
        postcode => '43321',
    }
) => 'new validation object';

ok !$rules->validate => 'address not ok';

is $rules->error_count(), 6, 'error count ok'
    or diag("Error string: ".$rules->errors_to_string);


done_testing();

