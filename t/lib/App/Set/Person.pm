package App::Set::Person;
use Moose;
use App::Model::Person;

extends 'Lecstor::Set::Person';

# ABSTRACT: add our little touches to the person set.

sub _build_model_class{ 'App::Model::Person' }

__PACKAGE__->meta->make_immutable;

1;
