#!/usr/bin/env perl

BEGIN {

    die "You must set the PROWLER_ROOT envivironment variable."
      unless exists $ENV{PROWLER_ROOT};
}

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

use 5.018_000;
use strict;
use warnings;
use utf8;
use DateTime;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Mojo::Asset::Memory;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;

use IO::File;
use URI;

my $timestamp = DateTime->now;
say "$timestamp\tSite Agent for @ARGV...";

# Console Monitor
Mojo::IOLoop->recurring(30 => sub {
    my $loop = shift;
    my $timestamp = DateTime->now;
    say "$timestamp\tWatching @ARGV...";
});

# Collector (every 15 minutes)
Mojo::IOLoop->recurring(300 => sub {
    my $loop = shift;
    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Collector...";

    my $collected = IO::File->new("data/$timestamp.collected", "w");

    open my $sitecrawler, "$ENV{PROWLER_ROOT}/scripts/sitecrawler.pl @ARGV |";
    while (<$sitecrawler>){

        print $_;

        if (defined $collected) {

            print $collected $_;
            undef $collected;
        }
    }
    close $sitecrawler;
});

# Processor (every 45 minutes)
Mojo::IOLoop->recurring(600 => sub {
    my $loop = shift;
    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Processor...";

    opendir(DIR, "data")
        or die "Could not open 'data'\n";

    my @files = grep(/collected/, readdir DIR);
    closedir DIR;

    for my $collected (@files) {

        my $record = IO::File->new($collected, "r");
        my $processed = IO::File->new($collected, "w");

        if (defined $record) {
            while (<$record>) {

                my $input = URI->new($_);
                my $output = $input->new_abs( $record, $ARGV[0]);

                print $output;

                if (defined $processed) {
                    print $processed $output;
                    undef $processed;
                }
            }
            close $record;
        }
    }
});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;