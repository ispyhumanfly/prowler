#!/usr/bin/env perl

use 5.018_000;
use strict;
use warnings;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;

my $ua = Mojo::UserAgent->new;

#$ua->proxy->http('socks://127.0.0.1:9050');

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

for my $query (@ARGV) {

    $ua->max_redirects(5)->get(
        "https://duckduckgo.com/html/?q=$query" => sub {

            my ( $ua, $tx ) = @_;

            # Level 1

            for ($tx->res->dom->find("a")->map( attr => 'href' )->each) {

                next unless $_;

                $_ = normalize_links($_);

                if (not exists $CACHE{$_}) {

                    next if $_ eq '1';
                    $CACHE{$_} = 0;
                    say $_;

                    # Level 2

                    for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {

                        next unless $_;

                        $_ = normalize_links($_);

                        if (not exists $CACHE{$_}) {

                            next if $_ eq '1';
                            next if $_ =~ m/mailto:/g;
                            next if $_ =~ m/javascript:/g;
                            $CACHE{$_} = 0;
                            say $_;

                            # Level 3

                            for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {

                                next unless $_;

                                $_ = normalize_links($_);

                                if (not exists $CACHE{$_}) {

                                    next if $_ eq '1';
                                    next if $_ =~ m/mailto:/g;
                                    next if $_ =~ m/javascript:/g;
                                    $CACHE{$_} = 0;
                                    say $_;

                                    # Level 4

                                    for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {

                                        next unless $_;

                                        $_ = normalize_links($_);

                                        if (not exists $CACHE{$_}) {

                                            next if $_ eq '1';
                                            next if $_ =~ m/mailto:/g;
                                            next if $_ =~ m/javascript:/g;
                                            $CACHE{$_} = 0;
                                            say $_;

                                            # Level 5

                                            for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {

                                                next unless $_;

                                                $_ = normalize_links($_);

                                                if (not exists $CACHE{$_}) {

                                                    next if $_ eq '1';
                                                    next if $_ =~ m/mailto:/g;
                                                    next if $_ =~ m/javascript:/g;
                                                    $CACHE{$_} = 0;
                                                    say $_;

                                                    # Level 6

                                                    for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {

                                                        next unless $_;

                                                        $_ = normalize_links($_);

                                                        if (not exists $CACHE{$_}) {

                                                            next if $_ eq '1';
                                                            next if $_ =~ m/mailto:/g;
                                                            next if $_ =~ m/javascript:/g;
                                                            $CACHE{$_} = 0;
                                                            say $_;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    );

    sub normalize_links {

        my $link = shift;

        try {
            $link = url_unescape $link;

            my ($clean) = $link =~ m/.*(http.*)/g;
            return $clean unless not $clean;
        }
    }
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
