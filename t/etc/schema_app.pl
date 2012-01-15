{
    'schema_class' => 'Lecstor::Schema',
    'connect_info' => ['dbi:SQLite:dbname=test.db','',''],
    'fixture_sets' => {
        'basic' => [
            'ActionType' => [
                ['name'],
                ['login'],
                ['login fail'],
                ['register'],
                ['register fail'],
                ['view product'],
            ],
        ],
        'user' => [
            'UserRole' => [
                ['name','created'],
                ['Role1', '2012-01-01 13:00:00'],
                ['Role2', '2012-01-01 13:00:00'],
                ['Role3', '2012-01-01 13:00:00'],
            ],
        ],
    },
};
