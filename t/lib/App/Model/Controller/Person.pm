package App::Model::Controller::Person;
use Moose;
use App::Model::Instance::Person;

extends 'Lecstor::Model::Controller::Person';

# ABSTRACT: add our little touches to the person set.

sub _build_model_class{ 'App::Model::Instance::Person' }

__PACKAGE__->meta->make_immutable;

1;
