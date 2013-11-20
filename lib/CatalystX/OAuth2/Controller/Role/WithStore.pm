package CatalystX::OAuth2::Controller::Role::WithStore;
use Moose::Role;

# ABSTRACT: A role for providing oauth2 stores to controllers

has store => (
  does     => 'CatalystX::OAuth2::Store',
  is       => 'ro',
  required => 1
);

around BUILDARGS => sub {
  my $orig = shift;
  my $self = shift;
  my $args = $self->$orig(@_);
  return $args unless @_ == 2;
  my ($app) = @_;
  for ( $args->{store} ) {
    last unless defined and ref eq 'HASH';
    my $store_args = {%$_};
    my $class = delete $store_args->{class};
   	if ($class !~ /^\+(.*)$/){
		$class = "CatalystX::OAuth2::Store::${class}";
    }else{
    	$class = $1;
    }
    my ( $is_success, $error ) = Class::Load::try_load_class($class);
    die qq{Couldn't load OAuth2 store '$class': $error} unless $is_success;
    $args->{store} = $class->new( %$store_args, app => $app );
  }
  return $args;
};

1;
