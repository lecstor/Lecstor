package Lecstor::Catalyst::Model::LecstorModel;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';
 
__PACKAGE__->config( 
    class => 'Lecstor::App::Container::Model',
);
 
1;