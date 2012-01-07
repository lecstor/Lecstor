package Lecstor::Test::Content;
require Exporter;
BEGIN {
    @ISA = qw(Exporter);
    @EXPORT = qw(get_view_meta);
}

sub get_view_meta{
    my ($content) = @_;
    my ($meta) = $content =~ /(<!-- VIEW META.*-->)/s;
    return $meta;
}


1;
