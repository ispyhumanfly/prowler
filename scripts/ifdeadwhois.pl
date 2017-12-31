#!/usr/bin/env perl

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

use 5.018_000;
use strict;
use warnings;
use utf8;
use Text::Unidecode;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;
use URI;
use LWP::Simple;
use Data::Dumper;

use Net::Whois::Parser;
$Net::Whois::Parser::GET_ALL_VALUES = 1;

my $ua = Mojo::UserAgent->new;

#$ua->proxy->http('socks://127.0.0.1:9050');

my %CACHE;

$ua->max_connections(60);
$ua->request_timeout(60);
$ua->max_redirects(60);

$ua->get($ARGV[0] => sub {

    my ( $ua, $tx ) = @_;

    # Level 1

    for ($tx->res->dom->find("a")->map( attr => 'href' )->each) {
        next unless $_;

        my $link = clean_link($_);
        next if $link eq '1';

        if (not exists $CACHE{$link}) {
            $CACHE{$link} = 0;
            say $link;

            #my $site = extract_domain($link);
            #if_dead_report($link);

            # Level 2

            for ($tx->res->dom->find("a")->map( attr => 'href' )->each) {
                next unless $_;

                my $link = clean_link($_);
                next if $link eq '1';

                if (not exists $CACHE{$link}) {
                    $CACHE{$link} = 0;
                    say $link;

                    #my $site = extract_domain($link);
                    #if_dead_report($site);
                    #if_dead_report($link);


                    # Level 3

                    for ($tx->res->dom->find("a")->map( attr => 'href' )->each) {
                        next unless $_;

                        my $link = clean_link($_);
                        next if $link eq '1';

                        if (not exists $CACHE{$link}) {
                            $CACHE{$link} = 0;
                            say $link;

                            #my $site = extract_domain($link);
                            #if_dead_report($site);
                            #if_dead_report($link);


                            # Level 4

                            for ($tx->res->dom->find("a")->map( attr => 'href' )->each) {
                                next unless $_;

                                my $link = clean_link($_);
                                next if $link eq '1';

                                if (not exists $CACHE{$link}) {
                                    $CACHE{$link} = 0;
                                    say $link;

                                    #my $site = extract_domain($link);
                                    #if_dead_report($site);
                                    #if_dead_report($link);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
});

sub clean_link {

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

sub if_dead_report {

    my $domain = shift;

    Mojo::UserAgent->new->max_redirects(5)->connect_timeout(60)->request_timeout(60)->get($domain => sub {

        my ( $ua, $tx ) = @_;

        if (!$tx->success) {

            my $err = $tx->error;

            say "$err->{code} response: $err->{message}" if $err->{code};
            say "Connection error: $err->{message}";
            say "This domain is busted?: $domain";
        }
    });

    #Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
