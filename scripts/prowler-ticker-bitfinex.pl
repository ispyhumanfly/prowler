#!/usr/bin/env perl

use 5.018_000;
use strict;
use warnings;
use utf8;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::UserAgent::Proxy;
use Mojo::IOLoop;

use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;
use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;
use DateTime;

use Term::ANSIColor;

my $ua = Mojo::UserAgent->new;

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

my $proxy = Mojo::UserAgent::Proxy->new;
$proxy->detect;

$ua->max_connections(25);
$ua->request_timeout(10);

Mojo::IOLoop->recurring(int(rand(15)) => sub {
    my $loop = shift;

    for my $symbol (@ARGV) {

        $symbol = lc $symbol;

        $ua->max_redirects(1)->get(
            "https://api.bitfinex.com/v1/pubticker/$symbol" => sub {

                my ( $ua, $tx ) = @_;

                $symbol = uc $symbol;

                #for (@{$tx->res->json}) {
                    #next if $_->{"short"} ne $symbol;

                    my $timestamp = DateTime->now;

                    my $volume = $tx->res->json->{'volume'};
                    my $price = $tx->res->json->{'last_price'};

                    #print color 'bold red' if ($change =~ m/^\-/g);
                    #print color 'bold green' if ($change =~ m/^\d+/g);

                    unless (exists $CACHE{$symbol} and $CACHE{$symbol} eq $price) {
                        printf "%-6s TIME: %-19s VOLUME: %-19s PRICE: %-16s\n",
                            $symbol, $timestamp, "$volume", $price;
                        print color 'reset';
                    }
                    $CACHE{"$symbol"} = $price;
                #}
            }
        );
    }
});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
