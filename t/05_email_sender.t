use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use Email::Sender::Transport::Test;

use_ok('Lecstor::Email::Sender');

my $transport = Email::Sender::Transport::Test->new;

my $sender = Lecstor::Email::Sender->new({ transport => $transport });

is(@{ $transport->deliveries }, 0, "no deliveries so far");

$sender->send({
    to          => 'jason@lecstor.com',
    from        => 'jason@eightdegrees.com.au',
    subject     => 'I am a Catalyst generated email',
    content_type => 'text/plain',
    body => 'blah blah blah blah blah',
});

is(@{ $transport->deliveries }, 1, "we've done one delivery so far");



$sender->send({
    template => {
        html => \'<html><body><b>hello</b> [% you %]</body></html>',
        plain => \'*hello* [% you %]',
    },
    to          => 'jason@lecstor.com',
    cc          => 'test1@eightdegrees.com.au',
#    bcc         => 'test2@eightdegrees.com.au test3@eightdegrees.com.au',
    from        => 'jason@eightdegrees.com.au',
    subject     => 'I am a Catalyst generated email',
    content_type => 'multipart/alternative',
    stash => { you => 'Jason' },
});

is(@{ $transport->deliveries }, 2, "we've done two deliveries so far");

my @deliveries = $transport->deliveries;

is_deeply(
  $deliveries[0]{successes},
  [ qw(jason@lecstor.com)],
  "first message delivered to 'recipient'",
);
 
is_deeply(
  $deliveries[1]{successes},
  [ qw(jason@lecstor.com test1@eightdegrees.com.au)],
  "second message delivered to 'cc'",
);

done_testing();
