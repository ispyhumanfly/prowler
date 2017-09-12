BEGIN {

    die "You must set the PROWLER_ROOT variable before instantiating Prowler.pm"
      unless exists $ENV{PROWLER_ROOT};
}

package Prowler;

use 5.018_000;
use strict;
use warnings;
use utf8;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

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

sub query {

    my $self = shift;
    my $cli = shift || '';

    $cli = "$ROOT/bin/prowler-query-$cli";
    my $output  = `$cli`;
    $output =~ s/\n//g;
    return $output;
}

sub filter {

    my $self = shift;
    my $cli = shift || '';

    $cli = "$ROOT/bin/prowler-filter-$cli";
    my $output  = `$cli`;
    $output =~ s/\n//g;
    return $output;
}

sub format {

    my $self = shift;
    my $cli = shift || '';

    $cli = "$ROOT/bin/prowler-format-$cli";
    my $output  = `$cli`;
    $output =~ s/\n//g;
    return $output;
}

sub storage {

    my $self = shift;
    my $cli = shift || '';

    $cli = "$ROOT/bin/prowler-storage-$cli";
    my $output  = `$cli`;
    $output =~ s/\n//g;
    return $output;
}

1;
