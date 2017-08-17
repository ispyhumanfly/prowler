#!/usr/bin/env perl

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


my $ua = Mojo::UserAgent->new;
#$ua->proxy->http('socks://127.0.0.1:9050');

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

while (<STDIN>) {

    for (split /\n/, $ua->max_redirects(5)->get($_)->res->body)
    {
        next if not $_;

        if (m/Address: .*/ig) {

        my ($location) = $_ =~ m/Address: (^\d+.*\d+)$/g;

        $CACHE{$location}++ if exists $CACHE{$location};
            if (not exists $CACHE{$location}) {
                $CACHE{$location} = 0;
                say $location;
            }
        }
    }
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
