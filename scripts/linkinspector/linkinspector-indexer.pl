#!/usr/bin/env perl

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

use 5.018_000;
use strict;
use warnings;
use utf8;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;
use URI;

my $ua = Mojo::UserAgent->new;
#$ua->proxy->http('socks://127.0.0.1:9050');

my %CACHE;

$ua->max_connections(60);
$ua->request_timeout(60);
$ua->connect_timeout(60);

for (@ARGV) {

    my $domain = $_;

    try {

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

                                say $link;

                                ### Level 2

                                for ($ua->max_redirects(5)->get($link)->res->dom->find("a")->map(attr => "href")->each) {
                                    next unless $_;

                                    if (not exists $CACHE{$_}) {
                                        $CACHE{$_} = 0;

                                        try {

                                            my $link = normalize_link($_);
                                            if ($link and $link =~ m/$domain/g) {

                                                eval{ say $link };

                                                for ($ua->max_redirects(5)->get($link)->res->dom->find("a")->map(attr => "href")->each) {
                                                    next unless $_;

                                                    my $link = normalize_link($_);
                                                    if ($link and $link =~ m/$domain/g) {

                                                        eval{ say $link };

                                                        ### Level 3

                                                        for ($ua->max_redirects(5)->get($link)->res->dom->find("a")->map(attr => "href")->each) {
                                                            next unless $_;

                                                            if (not exists $CACHE{$_}) {
                                                                $CACHE{$_} = 0;

                                                                try {

                                                                    my $link = normalize_link($_);
                                                                    if ($link and $link =~ m/$domain/g) {

                                                                        eval{ say $link };
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
                $link = "http://$domain$link";
            #}
        }
        $link =~ s/[^\x00-\x7f]//g;
        return $link if $link =~ m/^http/g;
    }
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
