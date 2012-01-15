package Lecstor::Role::Catalyst;
use Moose::Role;
use CatalystX::InjectComponent;
use Lecstor::App;
use namespace::autoclean;

# ABSTRACT: Lecstor Catalyst customisations

=head1 SYNOPSIS

    package My::Store;
    use Moose;
    use namespace::autoclean;

    use Catalyst::Runtime 5.80;

    use Catalyst qw/
        ConfigLoader
        Static::Simple
        Session
        Session::Store::Lecstor
        Session::State::Cookie
        Authentication
        RunAfterRequest
        Unicode::Encoding
    /;

    extends 'Catalyst';

    with 'Lecstor::Role::Catalyst';

    __PACKAGE__->config(
        name => 'Lecstor::Shop::Catalyst',
        # Disable deprecated behavior needed by old applications
        disable_component_resolution_regex_fallback => 1,
        enable_catalyst_header => 1, # Send X-Catalyst header

        'Plugin::Authentication' => {
            use_session => 1,
            default => {
                credential => {
                    class => 'Password',
                    password_type => 'self_check',
                },
                store => {
                    class => 'Lecstor',
                },
            },
        },

        'View::TT' => {
            include_paths => [qw! bootstrap plain !],
        },

    );

=head1 DESCRIPTION

This Moose role is intended to be consumer by the main class of a
Catalyst app. By default it will add a selection of pre-defined
controllers, views, and models, turning the app into an e-commerce
store. This app is then fully customisable including the templates,
the controllers, the database, and the app itself through various
methods of importing or subclassing predefined elements of the
system.  

=cut

$ENV{CATALYST_CONFIG_LOCAL_SUFFIX} ||= $ENV{LECSTOR_DEPLOY};

sub lecstor{ shift->model('Lecstor', @_) }

sub controllers{qw( Root Account )}

sub views{qw( TT )}

sub models{qw( LecstorApp LecstorRequest LecstorModel Lecstor )}

after 'setup_components' => sub {
    my $class = shift;

    foreach( $class->controllers ){
        my $comp = s/^\+// ? $_ : 'Lecstor::Catalyst::Controller::'.$_;
        CatalystX::InjectComponent->inject(
            component => $comp, into => $class, as => $_
        );
    }

    foreach( $class->views ){
        my $comp = s/^\+// ? $_ : 'Lecstor::Catalyst::View::'.$_;
        CatalystX::InjectComponent->inject(
            component => $comp, into => $class, as => $_
        );
    }

    foreach( $class->models ){
        my $comp = s/^\+// ? $_ : 'Lecstor::Catalyst::Model::'.$_;
        CatalystX::InjectComponent->inject(
            component => $comp, into => $class, as => $_
        );
    }

};

1;

