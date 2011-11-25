package Lecstor::Valid;
use Validation::Class;

# ABSTRACT: parent validation class

__PACKAGE__->load_classes;

=head1 SYNOPSIS

    my $valid = Lecstor::Valid->new(
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

    my $rules = $valid->class('person');

    unless ($rules->validate){
        print $rules->errors_to_string;
        my @errors = @{$rules->error};
        my %errors = %{$rules->error_fields};
        my $cnt = $rules->error_count;
    }

=head1 DESCRIPTION

This is the parent validation class which gives simple access to validation
classes. Child classes can be accessed directly to avoid loading all validation
classes.

=cut



1;
