#!/usr/bin/env perl

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

my $sitedata = $ENV{'SITEDATA'} || '.sitedata';

mkdir $sitedata and data_collector()
    unless (-e $sitedata and -d $sitedata);

my $timestamp = DateTime->now;
say "$timestamp\tSite Daemon for @ARGV...";

# Console Monitor
Mojo::IOLoop->recurring(30 => sub {
    my $loop = shift;
    my $timestamp = DateTime->now;
    say "$timestamp\tWatching @ARGV...";
});

# Collector (every 15 minutes)
Mojo::IOLoop->recurring(300 => sub {
    my $loop = shift;
    data_collector();
});

# Processor (every 45 minutes)
Mojo::IOLoop->recurring(600 => sub {
    my $loop = shift;
    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Processor...";

    opendir(DIR, $sitedata)
        or die "Could not open '$sitedata'\n";

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

sub data_collector {

    my $data = shift;
    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Collector...";

    my $collected = IO::File->new("$sitedata/$timestamp.collected", "a");

    open my $sitequery, "./sitequery.pl @ARGV |";
    while (<$sitequery>){

        print $_;

        if (defined $collected) {

            print $collected $_;
            undef $collected;
        }
    }

    close $sitequery;
    close $collected;
}

sub data_processor {
    my $data = shift;
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;