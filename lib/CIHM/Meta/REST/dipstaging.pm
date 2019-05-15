package CIHM::Meta::REST::dipstaging;

use strict;
use Carp;
use Data::Dumper;
use DateTime;
use JSON;

use Moo;
with 'Role::REST::Client';
use Types::Standard qw(HashRef Str Int Enum HasMethods);


=head1 NAME

CIHM::TDR::REST::dipstaging - Subclass of Role::REST::Client used to
interact with "dipstaging" CouchDB databases

=head1 SYNOPSIS

    my $t_repo = CIHM::TDR::REST::dipstaging->new($args);
      where $args is a hash of arguments.  In addition to arguments
      processed by Role::REST::Client we have the following 

      $args->{conf} is as defined in CIHM::TDR::TDRConfig
      $args->{database} is the Couch database name.

=cut

sub BUILD {
    my $self = shift;
    my $args = shift;

    $self->{LocalTZ} = DateTime::TimeZone->new( name => 'local' );
    $self->{conf} = $args->{conf}; 
    $self->{database} = $args->{database};
    $self->set_persistent_header('Accept' => 'application/json');
}

# Simple accessors for now -- Do I want to Moo?
sub database {
    my $self = shift;
    return $self->{database};
}

=head1 METHODS

=head2 update_basic

    sub update_basic ( string UID, hash updatedoc )

    updatedoc - a hash that is passed to the _update function of the
        design document to update data for the given UID.
        Meaning of fields in updatedoc is defined by that function.

  returns null, or a string representing the return from the _update
  design document.  Return values include "update", "no update", "no create".


=cut

# Returns the full return object
sub update_basic_full {
  my ($self, $uid, $updatedoc) = @_;
  my ($res, $code, $data);

  # Special case, rather than modify the other update functions
  if (exists $updatedoc->{repos}) {
      $updatedoc->{repos}= decode_json($updatedoc->{repos});
  }
  #  Post directly as JSON data (Different from other couch databases)
  $self->type("application/json");
  $res = $self->post("/".$self->{database}."/_design/sync/_update/basic/".$uid, $updatedoc);

  if ($res->code != 201 && $res->code != 200) {
      warn "_update/basic/$uid POST return code: " . $res->code . "\n";
  }

  # _update function only returns a string and not data, so nothing to return here
  return {};
}

1;
