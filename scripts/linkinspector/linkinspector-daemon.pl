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
use File::Path;
use URI;

my $timestamp = DateTime->now;
say "\n@ARGV\n\n$timestamp\tStarting...";

my $sitemap = $ENV{'SITEMAP'} || '.sitemap';

mkdir $sitemap unless (-e $sitemap and -d $sitemap);

$SIG{'INT'} = sub {
    if (rmtree $sitemap) {
        say "\n$timestamp\tCleaning up...";
    }
    say "$timestamp\tExiting Site Daemon...";
    exit 0;
};

### Collector

Mojo::IOLoop->recurring(30 => sub {
    my $loop = shift;

    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Collector...";

    my $collected = IO::File->new("$sitemap/$timestamp.collected", "a");

    open my $sitemapper, "./linkinspector-sitemapper.pl @ARGV |";
    while (<$sitemapper>){
        say $collected $_;
    }
    close $collected;
    close $sitemapper;
});

### Processor

Mojo::IOLoop->recurring(60 => sub {
    my $loop = shift;
    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Processor...";

    opendir(DIR, $sitemap)
        or die "Could not open '$sitemap'\n";

    my @files = grep(/collected/, readdir DIR);
    closedir DIR;

    for my $collected (@files) {

        my $record = IO::File->new("$sitemap/$collected", "r");
        my $processed = IO::File->new("$sitemap/$timestamp.processed", "a");

        if (defined $record) {

            while (<$record>) {

                if (defined $processed) {
                    print $processed $_;
                }
            }
            close $record;
        }
        undef $processed;
    }
});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;