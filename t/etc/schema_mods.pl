{
    'schema_class' => 'App::Schema',
    'traits' => [qw!Testmysqld!],
    'fixture_sets' => {
        'user' => [
            'UserRole' => [
                ['name'],
                ['Role1'],
                ['Role2'],
                ['Role3'],
            ],
        ],
    },
};
