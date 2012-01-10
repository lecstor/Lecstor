package Lecstor;

# ABSTRACT: Lecstor, the electronic store (as in e-commerce)

=head1 SYNOPSIS

    my $app_container = Lecstor::App::Container->new({
        template_processor => Template->new,
    });

    my $model_container = Lecstor::App::Container::Model->new({
        schema => DBIx;:Class->connect,
        config => {
            product_search => {
                index_path => 'path/to/index/directory',
                index_create => 1,
                index_truncate => 1,
            },
        }
    });

    my $app = $app_container->create(
        Model => $model_container,
        Request => Lecstor::App::Container::Request->new({
            session_id => 'abc123',
            uri => URI->new,
        }),
    )->fetch('app')->get;

    my $person = $app->person->create({
        firstname => 'Jason',
        surname => 'Galea',
        email => 'test1@eightdegrees.com.au',
        homephone => '0123456789',
    });

    my $user = $app->user->create({
        username => 'lecstor',
        email => 'test1@eightdegrees.com.au',
        password => 'abcd1234',
        person => $person->id,
    });

    my $app = $app_container->create(
        Model => $model_container,
        Request => Lecstor::App::Container::Request->new({
            session_id => 'abc123',
            user => $user,
            uri => URI->new,
        }),
    )->fetch('app')->get;

=head1 DESCRIPTION

=cut



1;
