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

#$ua->proxy->http('socks://127.0.0.1:9050');

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

$ua->max_connections(25);
$ua->request_timeout(10);

for my $query (@ARGV) {

    for (my $start=0; $start <= 100; $start += 10) {

        $ua->max_redirects(5)->get(
            "https://www.yelp.com/search?find_desc=Restaurants&find_loc=$query&start=$start" => sub {

                my ( $ua, $tx ) = @_;

                for($tx->res->dom->find('li.regular-search-result')->each) {
                    s/^\s+|\s+$//g;

                    my $restaurant = $_->at('h3 > span > a > span')->text;

                    if (not exists $CACHE{$restaurant}) {
                        $CACHE{$restaurant} = 0;

                        say $_->at('h3 > span > a > span')->text;
                        #say $_->at('div.biz-rating.biz-rating-large.clearfix > div')->attr('title');
                    }
                }
            });
    }
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
