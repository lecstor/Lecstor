package Lecstor::Valid::Person;

use Validation::Class;
use Email::Valid;

mixin NAME => {
    min_length => 1,
    max_length => 32,
    filters    => [qw/trim strip/]
};

mixin PHONE => {
    min_length => 1,
    max_length => 32,
    filters    => [qw/trim strip numeric/]
};

field firstname => {
    mixin => 'NAME',
    label => 'Firstname',
    error => 'your firstname is invalid',
};

field surname => {
    mixin => 'NAME',
    label => 'Surname',
    error => 'your surname is invalid',

};

field email => {
    required => 1,
    validation => sub {
        my ( $self, $this, $params ) = @_;
        if ($this->{value}) {
            return Email::Valid->address($this->{value});
        }
        return 0;
    }
};

field homephone => {
    mixin => 'PHONE',
    label => 'Home Phone',
    error => 'your home phone is invalid',

};

field workphone => {
    mixin => 'PHONE',
    label => 'Work Phone',
    error => 'your work phone is invalid',

};

field mobile => {
    mixin => 'PHONE',
    label => 'Mobile Phone',
    error => 'your mobile phone is invalid',

};

field fax => {
    mixin => 'PHONE',
    label => 'Fax Number',
    error => 'your fax number is invalid',

};

field password => {
    min_length => 8,
    max_length => 64,
    required   => 1,
};


1;
