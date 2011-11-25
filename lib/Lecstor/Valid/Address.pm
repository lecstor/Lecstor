package Lecstor::Valid::Address;
use Validation::Class;

# ABSTRACT: validate address details

=head1 SYNOPSIS

    my $rules = Lecstor::Valid::Address->new(
        params => {
            name => 'Jason Galea',
            company => 'EDOC',
            street => '123 Test St',
            suburb => 'Somewhere',
            state => 'Qld',
            postcode => '4321',
        }
    );

    unless ($rules->validate){
        print $rules->errors_to_string;
        my @errors = @{$rules->error};
        my %errors = %{$rules->error_fields};
        my $cnt = $rules->error_count;
    }

=cut

mixin STRING => {
    min_length => 1,
    max_length => 255,
    filters    => [qw/trim strip/]
};

=attr name

length 1 to 60 characters.
filters: trim & strip

=cut

field name => {
    required => 1,
    min_length => 1,
    max_length => 60,
    mixin => 'STRING',
    label => 'Name',
};

=attr company

length 1 to 130 characters.
filters: trim & strip

=cut

field company => {
    required => 1,
    min_length => 1,
    max_length => 130,
    mixin => 'STRING',
    label => 'Company',
};

=attr street

length 1 to 255 characters.
filters: trim & strip

=cut

field street => {
    required => 1,
    min_length => 1,
    max_length => 255,
    mixin => 'STRING',
    label => 'Street',
};

=attr suburb

length 1 to 255 characters.
filters: trim & strip

=cut

field suburb => {
    required => 1,
    min_length => 1,
    max_length => 130,
    mixin => 'STRING',
    label => 'Suburb',
};

=attr state

length 1 to 12 characters.
filters: trim & strip

=cut

field state => {
    required => 1,
    min_length => 1,
    max_length => 12,
    mixin => 'STRING',
    label => 'State',
};

=attr postcode

length 4 characters.
filters: trim & strip

=cut

field postcode => {
    required => 1,
    min_length => 4,
    max_length => 4,
    mixin => 'STRING',
    label => 'Postcode',
    filters => ['numeric'],
};



1;
