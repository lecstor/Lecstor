package Lecstor::App;
use Moose;
use MooseX::StrictConstructor;

=attr schema_class

your DBIx::Class::Schema class name

see L<Lecstor::Schema>

=cut

has schema_class => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_schema_class{ 'Lecstor::Schema' }

=attr schema

your DBIx::Class::Schema class

see L<Lecstor::Schema>

=cut

has schema => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_schema{
    my ($self) = @_;
    my $schema_class = $self->schema_class;
    return $schema_class->connect(@{$self->config->{schema}{connect_info}});
}

=attr model_class

your model class name

see L<Lecstor::Model>

=cut

has model_class => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_model_class{ 'Lecstor::Model' }

=attr model

your model class

see L<Lecstor::Model>

=cut

has model => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_model{
    my ($self) = @_;
    my $model_class = $self->model_class;
    $model_class->new(
        schema => $self->schema,
        validator => $self->validator,
    );
}

=attr validator_class

your validator class name

see L<Lecstor::Valid>

=cut

has validator_class => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_validator_class{ 'Lecstor::Valid' }

=attr validator

your validator class

see L<Lecstor::Valid>

=cut

has validator => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_validator{
    my ($self) = @_;
    my $valid_class = $self->validator_class;
    return $valid_class->new;
}

=attr config_file

config file path

defaults to package name as a yaml file.. eg

  My::App becomes my_app.yml

=cut

has config_file => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_config_file{
    my ($self) = @_;
    my $conf = lc(ref $self);
    $conf =~ s/::/_/g;
    $conf .= '.yml';
    return $conf;
}

=attr config

config as a hash reference

=cut

has config => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );

sub _build_config{
    my ($self) = @_;
    my $debug = $ENV{LECSTOR_DEBUG};
    my $config_file = $self->config_file;
    my $conf_data = {};
    if (-e $config_file){
        warn "Loading config: $config_file" if $debug;
        $conf_data = YAML::XS::Load(scalar File::Slurp::read_file($config_file));
    } else {
        warn "Config Missing: $config_file" if $debug;
    }
    if ($ENV{LECSTOR_DEPLOY}){
        $config_file =~ s/\./_$ENV{LECSTOR_DEPLOY}./;
        if (-e $config_file){
            warn "Loading config: $config_file" if $debug;
            $conf_data = Hash::Merge::merge( YAML::XS::Load(scalar File::Slurp::read_file($config_file)), $conf_data);
        } else {
            warn "Deploy Config Missing: $config_file" if $debug;
        }
    }
    warn Data::Dumper->Dumper($conf_data) if $debug;
    return $conf_data;
}

=attr log

see L<Lecstor::Log>

=cut

has log => ( is => 'ro', isa => 'Lecstor::Log', lazy_build => 1 );

sub _build_log{
    my ($self) = @_;
    Lecstor::Log->new( action_ctrl => $self->model->action );
}

=attr template

see L<Lecstor::Native::Component::Template>

=cut

has template => ( is => 'ro', isa => 'Lecstor::App::Component', lazy_build => 1 );

sub _build_template{
    my ($self) = @_;
    Lecstor::App::Component::Template->new(
        templates => $self->template_include_paths,
        plugins => $self->template_allowed_plugins,
    );
}

=attr template_include_paths

paths to search for templates 

default: ['root']

=cut

has template_include_paths => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

sub _build_template_include_paths{ ['root'] }

=attr template_allowed_plugins

plugins to enable for template processor

default: [qw! Date Table Dumper !]

=cut

has template_allowed_plugins => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

sub _build_template_allowed_plugins{ [qw! Date Table Dumper !] }


__PACKAGE__->meta->make_immutable;

1;
