package Lecstor::Role::RequestData;
use Moose::Role;

=attr current_user

=cut

has current_user => (
    is => 'ro',
    isa => 'Lecstor::Model::Instance::User',
    required => 1
);

=attr current_session_id

=cut

has current_session_id => ( is => 'ro', isa => 'Str', required => 1 );


1;
