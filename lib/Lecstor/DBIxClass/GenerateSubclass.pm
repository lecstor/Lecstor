package Lecstor::DBIxClass::GenerateSubclass;

# ABSTRACT: Generate subclass sources directly from your Schema
 
use strict;
use warnings;
 
use Scalar::Util 'blessed';
 
sub _schema_class { blessed($_[0]) || $_[0] }
 
sub _generate_subclass_name {
   $_[0]->_schema_class . '::Result::'. $_[1]
}
 
sub _generate_subclass {
   die $@ unless eval "
   package $_[1]; use parent '$_[2]';
   __PACKAGE__->load_components(qw/ Helper::Row::SubClass Core /);
   __PACKAGE__->subclass;
   1;
   ";
}
 
sub generate_subclass_source {
   my ($self, $moniker, $base) = @_;
 
   my $class = $self->_generate_subclass_name($moniker);
   $self->_generate_subclass($class, $base);
   $self->register_class($moniker, $class);
}
 
1;
 
 
__END__