package Prowler;

use 5.018_000;
use strict;
use warnings;

BEGIN {

    die "You must set the PROWLER_ROOT variable before instantiating Context.pm"
      unless exists $ENV{PROWLER_ROOT};
}

our $ROOT = $ENV{PROWLER_ROOT};
chdir $ROOT;

use Perl6::Attributes;
use Data::Dumper;
use File::Temp;

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

sub update {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opupdate $params";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

sub destroy {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opdestroy $params";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

sub report {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opreport";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

sub move {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opmove";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

sub copy {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opcopy";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

sub start {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opstart";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

sub stop {

    my $self = shift;
    my $params = shift || '';

    my $command = "$ROOT/bin/opstop";
    my $output  = `$command`;
    $output =~ s/\n//g;
    return $output;
}

1;
