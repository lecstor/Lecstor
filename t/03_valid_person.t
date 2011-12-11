use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Lecstor::Valid::Person');

#====================================================================
note('provide good email as only param');

ok my $rules = Lecstor::Valid::Person->new(
    params => { email => 'jason@lecstor.com' }
) => 'new validation object';

ok $rules->validate('email')
    => 'email ok';

ok $rules->validate
    => 'email ok';

#====================================================================
note('provide good password as only param');

ok $rules = Lecstor::Valid::Person->new(
    params => { password => 'abcd1234' }
) => 'new validation object';

ok $rules->validate('password')
    => 'password ok';

ok $rules->validate
    => 'password ok';

#====================================================================
note('provide bad password as only param');

ok $rules = Lecstor::Valid::Person->new(
    params => { password => 'abc123' }
) => 'new validation object';

ok !$rules->validate => 'no field validate ok';
like $rules->errors_to_string, qr/at\-least/, 'error ok';

ok !$rules->validate(qw! email password !)
    => 'email and password not ok';

is $rules->error_count(), 2, 'error count ok'
    or diag("Error string: ".$rules->errors_to_string);

like $rules->errors_to_string, qr/at\-least/, 'error ok';
like $rules->errors_to_string, qr/is required/, 'error ok';

#====================================================================
note('provide bad password and bad email');

ok $rules = Lecstor::Valid::Person->new(
    params => {
        email => 'jason',
        password => 'abc123',
    }
) => 'new validation object';

ok !$rules->validate => 'no check ok';
is $rules->error_count(), 2, 'error count ok'
    or diag("Error string: ".$rules->errors_to_string);
like $rules->errors_to_string, qr/at\-least/, 'error ok';
like $rules->errors_to_string, qr/A valid email address is required/, 'error ok';

ok !$rules->validate(qw! email password !) => 'email and password not ok';
is $rules->error_count(), 2, 'error count ok'
    or diag("Error string: ".$rules->errors_to_string);
like $rules->errors_to_string, qr/at\-least/, 'error ok';
like $rules->errors_to_string, qr/A valid email address is required/, 'error ok';

#====================================================================

done_testing();
