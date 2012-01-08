package Valid::Thing;
use Validation::Class;

mixin STRING => {
    min_length => 5,
    max_length => 10,
    filters    => [qw/trim strip/]
};

field required_string_with_error => {
    mixin => 'STRING',
    required => 1,
    error => 'string is invalid',
};

field required_string_without_error => {
    mixin => 'STRING',
    required => 1,
};

field string_with_error => {
    mixin => 'STRING',
    required => 1,
    error => 'string is invalid',
};

field string_without_error => {
    mixin => 'STRING',
    required => 1,
};

1;
