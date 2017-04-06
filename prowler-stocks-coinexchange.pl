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

Mojo::IOLoop->recurring(5 => sub {
    my $loop = shift;

    for my $symbol (@ARGV) {

        $ua->max_redirects(1)->get(
            "https://www.coinexchange.io/api/v1/getmarkets" => sub {

                my ( $ua, $tx ) = @_;

                my $markets = $tx->res->json;
                $symbol = uc $symbol;

                for (@{$markets->{result}}) {
                    next if $_->{"MarketAssetCode"} ne $symbol;

                    my $id = $_->{"MarketID"};

                    $ua->get("https://www.coinexchange.io/api/v1/getmarketsummary?market_id=$id" => sub {

                        my ( $ua, $tx ) = @_;

                        my $lastsale = $tx->res->json->{result}->{'LastPrice'};
                        my $netchange = $tx->res->json->{result}->{'Change'};
                        #my $lastsale = $tx->res->json->{result}->{'LastPrice'};

                        unless (exists $CACHE{$symbol} and $CACHE{$symbol} eq $netchange) {
                            printf "%-6s TIME: %-19s ARROW: %-5s LAST_SALE: %-8s NET_CHANGE: %-8s PERCENT: %-5s\n",
                                $symbol, '--', '--', $lastsale, $netchange, '--';
                            print color 'reset';
                        }
                        $CACHE{"$symbol"} = $netchange;
                    })
                }
                #my $arrow;
                #if ($tx->res->dom->at("#qwidget-arrow > div[class~=arrow-green]")) {
                #    print color 'bold green';
                #    $arrow = 'Up';
                #}
                #elsif ($tx->res->dom->at("#qwidget-arrow > div[class~=arrow-red]")) {
                #    print color 'bold red';
                #    $arrow = 'Down';
                #}

                #my $lastsale = $tx->res->dom->at("#qwidget_lastsale")->text;
                #my $netchange = $tx->res->dom->at("#qwidget_netchange")->text;
                #my $percent = $tx->res->dom->at("#qwidget_percent")->text;
            }
        );
    }
});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
