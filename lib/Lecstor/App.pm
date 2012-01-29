package Lecstor::App;
use Moose;
use MooseX::StrictConstructor;
use File::Slurp qw(read_file);
use YAML::XS;

has schema => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub base_app_class{
    my ($self) = @_;
    my $base = ref $self;
    $base =~ s/::App$//;
    return $base;
}

sub _build_schema{
    my ($self) = @_;
    my $schema_class = $self->config->{'Model::Schema'}{schema_class};
    die 'Schema config not set' unless $schema_class;
    return $schema_class->connect(@{$self->config->{'Model::Schema'}{connect_info}});
}

has model => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_model{
    my ($self) = @_;
    my $app_model_class = $self->base_app_class . '::Model';
    $app_model_class->new(
        schema => $self->schema,
        validator => $self->validator,
    );
}

has validator => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_validator{
    my ($self) = @_;
    my $app_valid_class = $self->base_app_class . '::Valid';
    return $app_valid_class->new;
}

has config_file => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_config_file{
    my ($self) = @_;
    my $app_class = ref $self;
    my $conf = lc($app_class);
    $conf =~ s/::/_/g;
    $conf .= '.yml';
    return $conf;
}

has config => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );

sub _build_config{
    my ($self) = @_;
    my $debug = $ENV{LECSTOR_DEBUG};
    my $config_file = $self->config_file;
    my $conf_data = {};
    if (-e $config_file){
        warn "Loading config: $config_file" if $debug;
        $conf_data = YAML::XS::Load(scalar read_file($config_file));
    } else {
        warn "Config Missing: $config_file" if $debug;
    }
    if ($ENV{LECSTOR_DEPLOY}){
        $config_file =~ s/\./_$ENV{LECSTOR_DEPLOY}./;
        if (-e $config_file){
            warn "Loading config: $config_file" if $debug;
            $conf_data = Hash::Merge::merge( YAML::XS::Load(scalar read_file($config_file)), $conf_data);
        } else {
            warn "Deploy Config Missing: $config_file" if $debug;
        }
    }
    warn Data::Dumper->Dumper($conf_data) if $debug;
    return $conf_data;
}

has log => ( is => 'ro', isa => 'Lecstor::Log', lazy_build => 1 );

sub _build_log{
    my ($self) = @_;
    Lecstor::Log->new( action_ctrl => $self->model->action );
}

has template => ( is => 'ro', isa => 'Lecstor::Native::Component', lazy_build => 1 );

sub _build_template{
    my ($self) = @_;
    Lecstor::Native::Component::Template->new(
        processor => Template::AutoFilter->new({
            INCLUDE_PATH => $self->template_include_paths,
            LOAD_PLUGINS => [
              Lecstor::Template::Plugins::Allow->new(@{$self->template_allowed_plugins}),
              Template::Plugins->new(),
            ],
        }),
    );
}

has template_include_paths => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

sub _build_template_include_paths{ ['root'] }

has template_allowed_plugins => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

sub _build_template_allowed_plugins{ [qw! Date Table Dumper !] }

__PACKAGE__->meta->make_immutable;

1;
