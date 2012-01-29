
use Plack::Builder;
use Lecstor::Native;

my $app = Lecstor::PSGI->new(
    app_class => 'Lecstor::App',
    webapp_request_class => 'Lecstor::WebApp::Request',
)->coderef;

builder {
#    enable "JSONP";
#    enable "Auth::Basic", authenticator => sub { ... };
#    enable "Deflater";
    $app;
};