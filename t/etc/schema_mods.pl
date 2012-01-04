{
    'schema_class' => 'App::Schema',
    'traits' => [qw!Testmysqld!],
    'fixture_sets' => {
        'login' => [
            'LoginRole' => [
                ['name'],
                ['Role1'],
                ['Role2'],
                ['Role3'],
            ],
        ],
    },
};
