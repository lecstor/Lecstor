use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Validation::Class');
use_ok('Valid');

#--------------------------------------------------------------------
package main;

my $rules;

ok $rules = Valid->new(
    params => { string_with_error => 'jason123' }
) => 'new validation object - string ok';

ok $rules->class('Thing')->validate('string_with_error')
    => 'string_with_error, field specified ok';

ok $rules = Valid->new => 'new validation object - no params ok';
ok $rules = $rules->class('thing', params => { string_with_error => 'jason123' }), 'validation sub-class with params  ok';
ok $rules->validate('string_with_error') => 'string_with_error, field specified ok';

#-----------------------
ok $rules = Valid::Thing->new(
    params => { string_with_error => 'jason123' }
) => 'new validation object - string ok';

ok $rules->validate('string_with_error')
    => 'string_with_error, field specified ok';

ok $rules->validate()
    => 'string_with_error, no fields specified ok';


#-----------------------
ok $rules = Valid::Thing->new(
    params => { string_with_error => 'jaso' }
) => 'new validation object - short string';

ok !$rules->validate('string_with_error')
    => 'string_with_error, field specified ok';

is $rules->error_count(), 1, 'error count ok';
like $rules->errors_to_string, qr/string is invalid/, 'error ok';

ok !$rules->validate()
    => 'string_with_error, no fields specified ok';
is $rules->error_count(), 1, 'error count ok';
like $rules->errors_to_string, qr/string is invalid/, 'error ok';


#-----------------------
ok $rules = Valid::Thing->new(
    params => { string_without_error => 'jaso' }
) => 'new validation object - short string';

ok !$rules->validate('string_without_error')
    => 'string_with_error, field specified ok';

is $rules->error_count(), 1, 'error count ok';
like $rules->errors_to_string, qr/must contain/, 'error ok';

ok !$rules->validate()
    => 'string_with_error, no fields specified ok';
is $rules->error_count(), 1, 'error count ok';
like $rules->errors_to_string, qr/must contain/, 'error ok';

#-----------------------
ok $rules = Valid::Thing->new(
    params => {
        string_without_error => 'jaso',
        required_string_without_error => undef,
    }
) => 'new validation object - short string';

ok !$rules->validate('string_without_error')
    => 'string_with_error, field specified ok';

is $rules->error_count(), 1, 'error count ok';
like $rules->errors_to_string, qr/must contain/, 'error ok';

ok !$rules->validate()
    => 'string_with_error, no fields specified ok';
is $rules->error_count(), 2, 'error count ok';
like $rules->errors_to_string, qr/must contain/, 'has "must contain" ok';
like $rules->errors_to_string, qr/is required/, 'has "is required" ok';


#-----------------------
ok $rules = Valid::Thing->new(
    params => {
        string_without_error => 'jaso',
        required_string_with_error => undef,
    }
) => 'new validation object - short string';

ok !$rules->validate('string_without_error')
    => 'string_with_error, field specified ok';

is $rules->error_count(), 1, 'error count ok';
like $rules->errors_to_string, qr/must contain/, 'error ok';

ok !$rules->validate()
    => 'string_with_error, no fields specified ok';
is $rules->error_count(), 2, 'error count ok';
like $rules->errors_to_string, qr/must contain/, 'has "must contain" ok'
    or diag($rules->errors_to_string);
like $rules->errors_to_string, qr/is invalid/, 'has "is required" ok'
    or diag($rules->errors_to_string);


done_testing();
