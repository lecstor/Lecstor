{
    'schema_class' => 'Editor::DB',
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
