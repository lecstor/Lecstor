package Lecstor::Test::DateTime;
use Hook::LexWrap;
use DateTime;

sub import {
    my ($class, $datetime) = @_;
    my ($date,$time) = split('[^0-9\-\:]', $datetime);
    my ($year,$month,$day) = split('-', $date);
    my ($hour,$minute,$second) = split(':', $time);
    my $timestamp = DateTime->new({
        year => $year,
        month => $month,
        day => $day,
        hour => $hour,
        minute => $minute,
        second => $second,
    });
    my $wrapper = wrap 'DateTime::now', post => sub { $_[-1] = $timestamp; };


    my $exporter = Sub::Exporter::build_exporter({
        exports => [
            datetime_now_wrapper => sub {
                return sub {
                    return $wrapper;
                };
            },
        ],
        into_level => 1,    
    });
    $class->$exporter('datetime_now_wrapper');

}

1;
