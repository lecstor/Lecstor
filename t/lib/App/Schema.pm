package App::Schema;
use Moose;

our $VERSION = 1;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_components('+Lecstor::DBIxClass::GenerateSubclass');

__PACKAGE__->load_namespaces();

foreach my $res (qw!
    BillingAddress Collection CollectionItem CollectionType Country DeliveryAddress
    User UserRole UserTempPass UserRoleMap  PersonCollectionMap
    Product ProductCategory ProductCategoryMap ProductShipping ProductStatus ProductType
    Session SessionCollectionMap
!){
    __PACKAGE__->generate_subclass_source( $res => "Lecstor::Schema::Result::$res");
}

1;
