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
say "\n@ARGV\n\n$timestamp\tStarting LinkInspector Daemon...";

my $sitemap = $ENV{'SITEMAP'} || '.sitemap';

mkdir $sitemap unless (-e $sitemap and -d $sitemap);

for (@ARGV) {
    mkdir "$sitemap/$_" for @ARGV;
}

$SIG{'INT'} = sub {
    if (rmtree $sitemap) {
        say "\n$timestamp\tCleaning up...";
    }
    say "$timestamp\tExiting LinkInspector Daemon...";
    exit 0;
};

### Collector

Mojo::IOLoop->recurring((15 * scalar @ARGV) => sub {
    my $loop = shift;

    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Collector...";

    for my $domain (@ARGV) {

        my $collected = IO::File->new("$sitemap/$domain/$timestamp.collected", "a");

        #open my $sitemapper, "perl linkinspector-sitemapper.pl $domain |";

        my $sitemapper = readpipe("perl linkinspector-sitemapper.pl $domain");
        my @sitemapper = split /\n/ , $sitemapper;
        #print "@sitemapper";

        for my $link (@sitemapper){
            try {
                say $collected $link;
            };
        }
        try {
            close $collected;
        };

        #close $sitemapper;
        sleep 1;
    }
});

### Processor

Mojo::IOLoop->recurring((30 * scalar @ARGV) => sub {
    my $loop = shift;
    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Processor...";

    my %PROCESSED;

    for my $domain (@ARGV) {

        opendir(DIR, "$sitemap/$domain")
            or die "Could not open '$sitemap/$domain'\n";

        my @files = grep(/collected/, readdir DIR);
        closedir DIR;

        for my $collected (@files) {

            my $record = IO::File->new("$sitemap/$domain/$collected", "r");
            my $processed = IO::File->new("$sitemap/$domain/$timestamp.processed", "a");

            if (defined $record) {

                while (<$record>) {

                    if (defined $processed) {

                        unless (exists $PROCESSED{$_}) {
                            $PROCESSED{$_} = 0;
                            print $processed $_;
                        }
                    }
                }
                close $record;
            }
            undef $processed;
        }
    }
});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;