{
    'schema_class' => 'Editor::DB',
    'traits' => [qw!Testmysqld!],
    'fixture_sets' => {
        'basic' => [],
        'editor' => [
            'Movie::Category' => [
                [qw/name/],
                [qw/Horror/],
                [qw/Comedy/],
                [qw/Drama/],
            ],
        ],
    },
};
