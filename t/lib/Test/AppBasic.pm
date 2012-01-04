package Test::AppBasic;
use Test::More;

sub run{
    my ($app, $schema) = @_;

    ok my $person_set = $app->person, 'get person_set ok';

    ok my $login_set = $app->login, 'get login_set ok';


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

    ok my $login = $login_set->create({
        username => 'lecstor',
        email => 'test1@eightdegrees.com.au',
        password => 'abcd1234',
    }), 'create login ok';

    ok $login->update({ person => $person->id }), 'set login person';

    ok $login = $schema->resultset('Login')->find($login->id), 'find rs login ok';

    is $login->person->id, $person->id, 'login rs person id ok';

    is $login->person->firstname, 'Jason', 'login rs person name ok';

    ok $person = $login_set->find($login->id)->person, 'find model login person ok';

    is $person->name, 'Jason Galea', 'person name ok';
}

1;
