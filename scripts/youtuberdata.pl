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
use DateTime;

use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;
use URI;

my $ua = Mojo::UserAgent->new;
#$ua->proxy->http('socks://127.0.0.1:9050');

$ua->max_connections(60);
$ua->request_timeout(60);
$ua->connect_timeout(60);

my %DATA;

try {

    # YouTube Trending

    $ua->max_redirects(5)->get(
        "https://youtube.com/feed/trending" => sub {

            my ( $ua, $tx ) = @_;

            for my $user ($tx->res->dom->find("a")->map( attr => 'href' )->each) {
                next unless $user;

                # YouTube User Names

                if ($user =~ m/^\/user/g) {

                    $DATA{$user} = [];

                    $ua->max_redirects(5)->get(
                        "https://youtube.com/$user/about" => sub {

                            my ( $ua, $tx ) = @_;

                            # YouTube User Data

                            for my $data ($tx->res->dom->find("a")->map( attr => 'href' )->each){
                                if ($data =~ m/^http/g) {
                                    push @{ $DATA{$user} }, $data;
                               }
                            }
                        }
                    );
                }
            }
        }
    );
};

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

my $timestamp = DateTime->now;

for my $user (keys %DATA) {
    for my $data (@{ $DATA{$user} }) {
        $user =~ s/\/user\///;
        say "$timestamp $user $data";
    }
}
