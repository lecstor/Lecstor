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
    validation => sub {
        my ( $self, $this, $params ) = @_;
        if ($this->{value}) {
            return Email::Valid->address($this->{value});
        }
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
};


1;
