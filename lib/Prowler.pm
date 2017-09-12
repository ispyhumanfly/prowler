package Prowler;

use 5.018_000;
use strict;
use warnings;

BEGIN {

    die "You must set the PROWLER_ROOT variable before instantiating Prowler.pm"
      unless exists $ENV{PROWLER_ROOT};
}

our $ROOT = $ENV{PROWLER_ROOT};
chdir $ROOT;

use Perl6::Attributes;
use Data::Dumper;

use Moo;
use namespace::clean;

# Class Constructor

## Class Parameters

has json => ( is => 'rw' );

### Setup

sub BUILD {

    my $self = shift;

    #$self->path_to_bin("$ENV{PROWLER_ROOT}/usr/local/bin")
    #  unless defined $self->path_to_bin;

}

sub DEMOLISH {

    my $self = shift;
    return undef $self;
}

# Class Methods

sub create {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opcreate $params";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

sub delete {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opdestroy $params";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

1;