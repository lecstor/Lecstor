package Lecstor::App;
use Moose;
use MooseX::Params::Validate;
use MooseX::StrictConstructor;
use Class::Load 'load_class';

=head1 SYNOPSIS

    my $app = Lecstor::App->new(
        model = Lecstor::App::Model->new(
            schema => Lecstor::Schema->connect($connect_args),
        ),
        template_processor => $tt,
        product_search_config => {
            index_path => 'path/to/index/directory',
            create => 1,
            truncate => 1,
        }
    );

    my $person_set = $app->model->person;

=attr model

=cut

sub BUILD{
    my ($self) = @_;
    $self->update_view;
}

has model => ( is => 'ro', isa => 'Lecstor::Model', required => 0 );

has session_id => ( is => 'rw', isa => 'Str', required => 0 );
has user => ( is => 'rw', isa => 'Lecstor::Model::Instance::User', required => 0 );

has validator_class => ( is => 'ro', isa => 'Str', builder => '_build_validator_class' );

sub _build_validator_class{ 'Lecstor::Valid' }

sub validator{
    my ($self, $args) = @_;
    my $class = $self->validator_class;
    load_class($class);
    return $class->new($args);
}

=attr template_processor

=cut

has template_processor => ( is => 'ro', isa => 'Object', lazy_build => 1 );

sub _build_template_processor{
    my ($self) = @_;
    load_class('Template');
    return Template->new;
}

=attr product_search_config

=cut

has product_search_config => ( isa => 'HashRef', is => 'ro', required => 1 );

=attr product_indexer

=cut

has product_indexer => ( isa => 'Lecstor::Lucy::Indexer', is => 'ro', lazy_build => 1 );

sub _build_product_indexer{ Lecstor::Lucy::Indexer->new( $_[0]->product_search_config ) }

=attr product_searcher

=cut

has product_searcher => ( isa => 'Lecstor::Lucy::Searcher', is => 'ro', lazy_build => 1 );

sub _build_product_searcher{
    return Lecstor::Lucy::Searcher->new(
        index_path => $_[0]->product_search_config->{index_path}
    );
}

has error_class => ( is => 'ro', isa => 'Str', builder => '_build_error_class' );

sub _build_error_class{ 'Lecstor::Error' }

sub error{
    my ($self, $args) = @_;
    my $class = $self->error_class;
    load_class($class);
    return $class->new($args);
}

=method log_action

=cut

sub log_action{
    my ($self, $type, $data) = @_;

    my $action = {
        type => { name => $type },
        session => $self->session_id,
    };
    $action->{data} = $data if $data;
    $action->{user} = $self->user->id if $self->user;

    $self->run_after_request(
        sub{ $self->model->action->create($action); }
    );
}

=method run_after_request

NOT IMPLEMENTED - executes code immediately

=cut

sub run_after_request{
    my ($self, $code) = @_;
    eval{ &$code() };
}

=attr view

    $app->view({ animals => { dogs => 1 } });
    # $app->view: { animals => { dogs => 1 } }
    $app->view({ animals => { cats => 2 } });
    # $app->view: { animals => { dogs => 1, cats => 2 } }
    $app->set_view({ foo => bar });
    # $app->view: { foo => bar });
    $app->clear_view;
    # $app->view: undef

Hashref containing view attributes

See L<MooseX::Traits::Attribute::MergeHashRef>

=cut

has view => ( is => 'rw', isa => 'HashRef', traits => [qw(MergeHashRef)] );


=method register

=cut

sub register{
    my ($self,$params) = @_;

    my $v = $self->validator({ params => $params })->class('registration');

    my $result;

    if ( $v->validate ){
        # input valid
        if ($self->model->user->find({ email => $params->{email} })){
            # email already registered
            my $error = 'That email address is already registered';
            $self->log_action('register fail', { email => $params->{email}, error => $error });
            $result = $self->error({ error => $error });
        } else {
            # params ok
            $result = $self->model->user->create($v->get_params_hash);
        }
    } else {
        # invalid input
        $self->log_action('register fail', { username => $params->{email}, errors => $v->error_fields });
        $result = $self->error({
            error_fields => $v->error_fields,
            error => $v->errors_to_string,
        });
    }

    return $result;
}

=method logged_in

=cut

sub logged_in{
    my ($self,$user) = @_;
    $self->user($user);
    $self->log_action('login');
    $self->update_view;
}

=method update_view

=cut

sub update_view{
    my ($self) = @_;
    my $user = $self->user;
    if ($user){
        my $visitor = {
            logged_in => 1,
            email => $user->email,
            name => $user->username,
        };
        $visitor->{name} ||= $user->person->name if $user->person;
        $self->view({ visitor => $visitor });
    }
}

__PACKAGE__->meta->make_immutable;

1;
