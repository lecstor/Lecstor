package Lecstor::Template::Plugins::Allow;

use strict;
use Template::Constants qw(:status);

sub new{
  my ($class) = @_;
  bless { map { ($_, 1) } @_ }, $class;
}

sub fetch{
  my ($self, $name) = @_;
  return $self->{$name}
    ? (undef, STATUS_DECLINED)
    : ("access to $name not allowed", STATUS_ERROR);
}

1;
