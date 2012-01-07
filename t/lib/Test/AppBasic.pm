package Test::AppBasic;
use Test::More;

sub run{
    my ($app, $schema) = @_;

    ok my $person_set = $app->person, 'get person_set ok';

    ok my $user_set = $app->user, 'get user_set ok';


    ok my $person = $person_set->create({
        firstname => 'Jason',
        surname => 'Galea',
        email => 'test1@eightdegrees.com.au',
    }), 'create person ok';

    ok my $del_addr = $person->add_to_delivery_addresses({
        street => '123 Test St',
        country => { name => 'Australia' },
    }), 'add_to_delivery_addresses ok';

    ok my $bill_addr = $person->set_billing_address({
        street => '123 Other St',
        country => 'Australia',
    }), 'set billing_address ok';

    ok my $user = $user_set->create({
        username => 'lecstor',
        email => 'test1@eightdegrees.com.au',
        password => 'abcd1234',
    }), 'create user ok';

    ok $user->update({ person => $person->id }), 'set user person';

    ok $user = $schema->resultset('User')->find($user->id), 'find rs user ok';

    is $user->person->id, $person->id, 'user rs person id ok';

    is $user->person->firstname, 'Jason', 'user rs person name ok';

    ok $person = $user_set->find($user->id)->person, 'find model user person ok';

    is $person->name, 'Jason Galea', 'person name ok';
}

1;
