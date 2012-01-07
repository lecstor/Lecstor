package Lecstor::Valid::Registration;
use Validation::Class;
use Email::Valid;

# ABSTRACT: validate registration details

=head1 SYNOPSIS

    my $rules = Lecstor::Valid::Person->new(
        params => {
            email => 'jason@lecstor.com',
            password => 'abc123',
            username => 'lecstor',
        }
    );

    unless ($rules->validate){
        print $rules->errors_to_string;
        my @errors = @{$rules->error};
        my %errors = %{$rules->error_fields};
        my $cnt = $rules->error_count;
    }

=attr username

length 1 to 32 characters.
filters: trim & strip

=cut

field username => {
    min_length => 1,
    max_length => 32,
    filters    => [qw/trim strip/],
    label => 'Username',
    error => 'your username is invalid',
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

1;
