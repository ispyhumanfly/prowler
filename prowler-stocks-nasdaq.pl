#!/usr/bin/env perl

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

my $ua = Mojo::UserAgent->new;

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

$ua->max_connections(25);
$ua->request_timeout(10);

for my $symbol (@ARGV) {

        #$ua->proxy->http('socks://localhost:9050')->https('socks://localhost:9050');

        $ua->max_redirects(1)->get(
            "http://www.nasdaq.com/symbol/$symbol/real-time" => sub {

                my ( $ua, $tx ) = @_;

                $symbol = uc $symbol;

                my $lastsale = $tx->res->dom->at("#qwidget_lastsale")->text;
                my $netchange = $tx->res->dom->at("#qwidget_netchange")->text;
                my $percent = $tx->res->dom->at("#qwidget_percent")->text;


                say "STOCK: $symbol, LAST_SALE: $lastsale, NC: $netchange, %: $percent";
            }
        );
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
