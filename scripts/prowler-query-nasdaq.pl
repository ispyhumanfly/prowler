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

Mojo::IOLoop->recurring(int(rand(scalar @ARGV)) => sub {
    my $loop = shift;

    for my $symbol (@ARGV) {

        $symbol = lc $symbol;

        $ua->max_redirects(1)->get(
            "http://www.nasdaq.com/symbol/$symbol/real-time" => sub {

                my ( $ua, $tx ) = @_;

                $symbol = uc $symbol;
                my $timestamp = DateTime->now;

                my $arrow;
                if ($tx->res->dom->at("#qwidget-arrow > div[class~=arrow-green]")) {
                    print color 'bold green';
                    $arrow = 'Up';
                }
                elsif ($tx->res->dom->at("#qwidget-arrow > div[class~=arrow-red]")) {
                    print color 'bold red';
                    $arrow = 'Down';
                }

                my $lastsale = $tx->res->dom->at("#qwidget_lastsale")->text;
                my $netchange = $tx->res->dom->at("#qwidget_netchange")->text;
                my $percent = $tx->res->dom->at("#qwidget_percent")->text;

                unless (exists $CACHE{$symbol} and $CACHE{$symbol} eq $netchange) {
                    printf "%-6s TIME: %-19s ARROW: %-5s LAST_SALE: %-8s NET_CHANGE: %-8s PERCENT: %-5s\n",
                        $symbol, $timestamp, $arrow, $lastsale, $netchange, $percent;
                    print color 'reset';
                }
                $CACHE{"$symbol"} = $netchange;
            }
        );
    }
});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
