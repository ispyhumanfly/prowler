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
use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;
use URI;


use IO::File;
use File::Path;

my $timestamp = DateTime->now;
say "\n@ARGV\n\n$timestamp\tStarting LinkInspector Crawler...";

my $sitemap = $ENV{'SITEMAP'} || '.sitemap';

mkdir $sitemap unless (-e $sitemap and -d $sitemap);

for (@ARGV) {
    mkdir "$sitemap/$_" for @ARGV;
}

$SIG{'INT'} = sub {
    #f (rmtree $sitemap) {
    #    say "\n$timestamp\tCleaning up...";
    #}
    say "$timestamp\tExiting LinkInspector Crawler..."
        and exit 0;
};

### Collector

sub collector {

    my %CACHE;

    my $ua = Mojo::UserAgent->new;

    $ua->max_connections(60);
    $ua->request_timeout(60);
    $ua->connect_timeout(60);

    my $timestamp = DateTime->now;

    for my $domain (@ARGV) {

        say "$timestamp\tRunning LinkInspector Indexer for $domain...";

        sub normalize_link {

            my $link = shift;
            #my $uri = $uri->new($link);
            #$link = URI->new_abs( $link, "http://" . $domain);
            if ($link =~ m/^\//g) {
                #if ($link =~ m/^\/$domain.*/g) {
                #    $link =~ s/^\///g;
                #    $link = "http://$domain$link";
                #}
                #else {
                    #$link = "http://${domain}$link";
                #}
            }
            $link =~ s/[^\x00-\x7f]//g;
            return $link if $link =~ m/^http/g;
        }

        try {

            my $collected = IO::File->new("$sitemap/$domain/$timestamp.collected", "a");

            $ua->max_redirects(5)->get(
                "$domain" => sub {

                    my ( $ua, $tx ) = @_;

                    ### Level 1

                    for ($tx->res->dom->find("a")->map( attr => 'href' )->each) {
                        next unless $_;

                        if (not exists $CACHE{$_}) {
                            $CACHE{$_} = 0;

                            try {

                                my $link = normalize_link($_);
                                if ($link and $link =~ m/$domain/g) {

                                    say $collected $link;

                                    ### Level 2

                                    for ($ua->max_redirects(5)->get($link)->res->dom->find("a")->map(attr => "href")->each) {
                                        next unless $_;

                                        if (not exists $CACHE{$_}) {
                                            $CACHE{$_} = 0;

                                            try {

                                                my $link = normalize_link($_);
                                                if ($link and $link =~ m/$domain/g) {

                                                    say $collected $link;

                                                    for ($ua->max_redirects(5)->get($link)->res->dom->find("a")->map(attr => "href")->each) {
                                                        next unless $_;

                                                        my $link = normalize_link($_);
                                                        if ($link and $link =~ m/$domain/g) {

                                                            say $collected $link;

                                                            ### Level 3

                                                            for ($ua->max_redirects(5)->get($link)->res->dom->find("a")->map(attr => "href")->each) {
                                                                next unless $_;

                                                                if (not exists $CACHE{$_}) {
                                                                    $CACHE{$_} = 0;

                                                                    try {

                                                                        my $link = normalize_link($_);
                                                                        if ($link and $link =~ m/$domain/g) {

                                                                            say $collected $link;
                                                                        }
                                                                    };
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            };
                                        }
                                    }
                                }
                            };
                        }
                    }
                }
            );
        };
        #close $collected;
    }

    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

}

### Processor

sub processor {

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
}

### Cleanser

sub cleanser {

    my $timestamp = DateTime->now;

    say "$timestamp\tRunning Cleanser...";

    my %CLEANED;

    for my $domain (@ARGV) {

        opendir(DIR, "$sitemap/$domain")
            or die "Could not open '$sitemap/$domain'\n";

        my @files = grep(/processed/, readdir DIR);
        closedir DIR;

        for my $processed (@files) {

            my $record = IO::File->new("$sitemap/$domain/$processed", "r");
            my $cleaned = IO::File->new("$sitemap/$domain/$timestamp.cleaned", "a");

            if (defined $record) {
                while (<$record>) {

                    if (defined $cleaned) {
                        unless (exists $CLEANED{$_}) {

                            $CLEANED{$_} = 0;
                            print $cleaned $_;
                        }
                    }
                }
                close $record;
            }
            undef $cleaned;
        }
    }
}

sub main {
    collector();
    processor();
    cleanser();
}
main() and exit 0;
