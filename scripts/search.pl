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

for my $domain (@ARGV) {

    $ua->max_redirects(5)->get(
        "$domain" => sub {

            my ( $ua, $tx ) = @_;

            # Level 1

            for ($tx->res->dom->find("a")->map( attr => 'href' )->each) {
                next unless $_;

                #$_ = normalize_links($_);
                #next if $_ eq '1';

                #my $root = extract_domain($_);
                #next if $root ne $domain;

                if (not exists $CACHE{$_}) {
                    $CACHE{$_} = 0;
                    my $uri = URI->new_abs( $_, $domain );
                    say $uri->canonical;
                    #say $_;

                    # Level 2

                    for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {
                        next unless $_;

                        #$_ = normalize_links($_);
                        #next if $_ eq '1';

                        #my $root = extract_domain($_);
                        #next if $root ne $domain;

                        if (not exists $CACHE{$_}) {
                            $CACHE{$_} = 0;
                            my $uri = URI->new_abs( $_, $domain );
                            say $uri->canonical;
                            #say $_;

                            # Level 3

                            for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {
                                next unless $_;

                                #$_ = normalize_links($_);
                                #next if $_ eq '1';

                                #my $root = extract_domain($_);
                                #next if $root ne $domain;

                                if (not exists $CACHE{$_}) {
                                    $CACHE{$_} = 0;
                                    my $uri = URI->new_abs( $_, $domain );
                                    say $uri->canonical;
                                    #say $_;

                                    # Level 4

                                    for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {
                                        next unless $_;

                                        #$_ = normalize_links($_);
                                        #next if $_ eq '1';

                                        #my $root = extract_domain($_);
                                        #next if $root ne $domain;

                                        if (not exists $CACHE{$_}) {
                                            $CACHE{$_} = 0;
                                            my $uri = URI->new_abs( $_, $domain );
                                            say $uri->canonical;
                                            #say $_;

                                            # Level 5

                                            for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {

                                                next unless $_;

                                                #$_ = normalize_links($_);
                                                #next if $_ eq '1';

                                                #my $root = extract_domain($_);
                                                #next if $root ne $domain;

                                                if (not exists $CACHE{$_}) {
                                                    $CACHE{$_} = 0;
                                                    my $uri = URI->new_abs( $_, $domain );
                                                    say $uri->canonical;
                                                    #say $_;

                                                    # Level 6

                                                    for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each) {

                                                        next unless $_;

                                                        #$_ = normalize_links($_);
                                                        #next if $_ eq '1';

                                                        #my $root = extract_domain($_);
                                                        #next if $root ne $domain;

                                                        if (not exists $CACHE{$_}) {
                                                            $CACHE{$_} = 0;
                                                            my $uri = URI->new_abs( $_, $domain );
                                                            say $uri->canonical;
                                                            #say $_;
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
        $link = url_unescape $link;
        my ($clean) = $link =~ m/.*(http.*)/g;
        #$clean =~ s/([^[:ascii:]]+)/unidecode($1)/ge;
        return $clean unless not $clean;
    }
    sub extract_domain {
        my $link = shift;
        chomp $link;
        my $uri = URI->new($_);
        my $host = $uri->host;
        my ($domain) = $host =~ m/([^.]+\.[^.]+$)/;
        return $domain;
    }
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
