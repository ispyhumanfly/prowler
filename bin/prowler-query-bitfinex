#!/usr/bin/env perl

BEGIN {

    die "You must set the PROWLER_ROOT envivironment variable."
      unless exists $ENV{PROWLER_ROOT};
}

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

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

use Mojo::Util qw/ md5_sum /;
use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;
use DateTime;

use Term::ANSIColor;

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my $ua = Mojo::UserAgent->new;
my $proxy = Mojo::UserAgent::Proxy->new;
$proxy->detect;

my %CACHE;

#Mojo::IOLoop->recurring(int(rand(scalar @ARGV)) => sub {
    #my $loop = shift;

    for (@ARGV) {

        my $symbol = lc $_;

        $ua->max_redirects(1)->get(
            "https://api.bitfinex.com/v1/pubticker/$symbol" => sub {

                my ( $ua, $tx ) = @_;

                $symbol = uc $symbol;

                try {

                    my $price = $tx->res->json->{'last_price'};
                    my $volume = $tx->res->json->{'volume'};

                    my $checksum = md5_sum "$symbol$price$volume";

                    unless (exists $CACHE{$symbol} and $CACHE{$symbol} eq $checksum) {

                        my $timestamp = DateTime->now;

                        printf "%-6s TIME: %-19s PRICE: %-10s VOLUME: %-16s\n",
                            $symbol, $timestamp, $price, $volume;
                        print color 'reset';
                    }
                    $CACHE{"$symbol"} = $checksum;
                }
            }
        );
    }
#});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
