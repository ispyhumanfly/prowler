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

while (<STDIN>) {

    my $feeding = $_;

    $ua->max_redirects(5)->get(
        "$feeding" => sub {

            my ( $ua, $tx ) = @_;

            for ($tx->res->dom->find("a")->map( attr => 'href' )->each) {

                next unless $_;
                say $_;

                if (not exists $CACHE{$_}) {
                    $CACHE{$_} = 0;

                    try {
                        my $link;

                        # This sequence needs work. But it'say
                        # good enough for now I think.

                        $link = "$feeding$_" if m/^\//g;
                        $link = "$feeding/$_" if m/^.*[A-Za-z0-9_.]+\//g;

                        if ($link and $link =~ m/$feeding/g) {
                            say $link if $link;
                        }
                    }
                }
            }
        }
    );

    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

}
