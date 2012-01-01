package Lecstor::Valid::Person;
use Validation::Class;
use Email::Valid;

# ABSTRACT: validate person details

=head1 SYNOPSIS

    my $rules = Lecstor::Valid::Person->new(
        params => {
            email => 'jason@lecstor.com',
            password => 'abc123',
            firstname => 'Jason',
            surname => 'Galea',
            homephone => '12345678',
            workphone => '23456789',
            mobile => '0123456789',
            fax => '34567890',
        }
    );

    unless ($rules->validate){
        print $rules->errors_to_string;
        my @errors = @{$rules->error};
        my %errors = %{$rules->error_fields};
        my $cnt = $rules->error_count;
    }

=cut

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

=attr firstname

length 1 to 32 characters.
filters: trim & strip

=cut

field firstname => {
    mixin => 'NAME',
    label => 'Firstname',
    error => 'your firstname is invalid',
};

=attr surname

length 1 to 32 characters.
filters: trim & strip

=cut

field surname => {
    mixin => 'NAME',
    label => 'Surname',
    error => 'your surname is invalid',

};

=attr email

required
validated with L<Email::Valid>

=cut

field email => {
    required => 1,
    error => 'A valid email address is required',
    label => 'Email Address',
    validation => sub {
        my ( $self, $this, $params ) = @_;
        return Email::Valid->address($this->{value});
        return 0;
    }
};

=attr homephone

length 1 to 32 characters.
filters: trim, strip, numeric

=cut

field homephone => {
    mixin => 'PHONE',
    label => 'Home Phone',
    error => 'your home phone is invalid',

};

=attr workphone

length 1 to 32 characters.
filters: trim, strip, numeric

=cut

field workphone => {
    mixin => 'PHONE',
    label => 'Work Phone',
    error => 'your work phone is invalid',

};

=attr mobile

length 1 to 32 characters.
filters: trim, strip, numeric

=cut

field mobile => {
    mixin => 'PHONE',
    label => 'Mobile Phone',
    error => 'your mobile phone is invalid',

};

=attr fax

length 1 to 32 characters.
filters: trim, strip, numeric

=cut

field fax => {
    mixin => 'PHONE',
    label => 'Fax Number',
    error => 'your fax number is invalid',

};

=attr password

required
length 8 to 64 characters.

=cut

field password => {
    min_length => 8,
    max_length => 64,
    required   => 1,
    label => 'Password',
};

=attr address.name

length 1 to 64 characters.
filters: trim & strip

=cut

field 'address.name' => {
    mixin => 'NAME',
    max_length => 64,
    label => 'Address: Name',
};

=attr address.company

length 1 to 32 characters.
filters: trim & strip

=cut

field 'address.company' => {
    mixin => 'NAME',
    label => 'Address: Company',
};

=attr address.street

length 1 to 128 characters.
filters: trim & strip

=cut

field 'address.street' => {
    mixin => 'NAME',
    max_length => 128,
    label => 'Address: Street',
};

=attr address.suburb

length 1 to 32 characters.
filters: trim & strip

=cut

field 'address.suburb' => {
    mixin => 'NAME',
    label => 'Address: Suburb',
};

=attr address.state

length 1 to 12 characters.
filters: trim & strip

=cut

field 'address.state' => {
    mixin => 'NAME',
    max_length => 12,
    label => 'Address: State',
};

=attr address.postcode

length 4 characters.
filters: trim & strip

=cut

field 'address.postcode' => {
    mixin => 'NAME',
    min_length => 4,
    max_length => 4,
    label => 'Address: Postcode',
};

1;
