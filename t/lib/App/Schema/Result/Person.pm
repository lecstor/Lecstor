package App::Schema::Result::Person;
use strict;
use warnings;
use base 'Lecstor::Schema::Result::Person';
use App::Model::Instance::Person;

__PACKAGE__->load_components(qw/ Helper::Row::SubClass Core /);

__PACKAGE__->add_columns(
  'buddy' => { data_type => 'INT', is_nullable => 1 }
);

__PACKAGE__->belongs_to( buddy  => 'App::Schema::Result::Person'    );

__PACKAGE__->has_many(person2friend_maps => 'App::Schema::Result::PersonFriendMap', 'person');
__PACKAGE__->many_to_many(friends => 'person2friend_maps', 'friend');

__PACKAGE__->subclass;

sub inflate_result {
    my $self = shift;
    my $result = $self->next::method(@_);
    return unless $result;
    # $result has already been through our parent's inflate_result
    # so it's actually a Lecstor::Model::Person..
    return App::Model::Instance::Person->new( _record => $result->_record );
}
 

1;