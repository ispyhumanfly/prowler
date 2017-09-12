#!/usr/bin/env perl

BEGIN {

    $ENV{MOJO_MAX_MESSAGE_SIZE} = '0';
};

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

my $ua = Mojo::UserAgent->new;
my $proxy = Mojo::UserAgent::Proxy->new;
$proxy->detect;

my %CACHE;

#Mojo::IOLoop->recurring(rand(scalar @ARGV) => sub {
    my $loop = shift;

    for my $symbol (@ARGV) {

        $ua->max_redirects(1)->get(
            "https://coinmarketcap.com/all/views/all/" => sub {

                my ( $ua, $tx ) = @_;

                $symbol = uc $symbol;

                for ($tx->res->dom->find("table > tbody > tr")->each)
                {
                    if ($_->at("td.text-left")) {
                        next if $symbol ne $_->at("td.text-left")->text;
                    }

                    try {

                        my $price = $_->at("td:nth-child(5) > a")->text;
                        my $volume = $_->at("td:nth-child(7) > a")->text;
                        my $marketcap = $_->at("td.no-wrap.market-cap.text-right")->text;
                        $marketcap =~ s/^\s+|\s+$//g;
                        my $supply = $_->at("td:nth-child(6) > a")->text;
                        $supply =~ s/^\s+|\s+$//g;

                        my $checksum = md5_sum "$symbol$price$marketcap$volume$supply";

                        unless (exists $CACHE{$symbol} and $CACHE{$symbol} eq $checksum) {

                            my $timestamp = DateTime->now;

                            printf "%-6s TIME: %-10s PRICE: %-9s MARKETCAP: %-15s VOLUME: %-14s SUPPLY: %-14s\n",
                                $symbol, $timestamp, $price, $marketcap, $volume, $supply;

                        }
                        $CACHE{"$symbol"} = $checksum;
                    }
                }
            }
        );
    }
#});

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
