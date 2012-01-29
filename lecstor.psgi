
use Plack::Builder;
use Lecstor::Native;

my $app = Lecstor::Native->new->app;

builder {
#    enable "JSONP";
#    enable "Auth::Basic", authenticator => sub { ... };
#    enable "Deflater";
    $app;
};