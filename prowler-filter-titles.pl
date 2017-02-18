#!/usr/bin/env perl

use 5.018_000;
use strict;
use warnings;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;
use Try::Tiny;

use Email::Valid::Loose;

my $ua = Mojo::UserAgent->new;
#$ua->proxy->http('socks://127.0.0.1:9050');

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

while (<STDIN>) {

    next if not $_;

    try {

        next if not eval{$ua->max_redirects(5)->get($_)->res->dom->at("title")->text};

        if($ua->max_redirects(5)->get($_)->res->dom->at("title")->text) {

            my $title = $ua->max_redirects(5)->get($_)->res->dom->at("title")->text;

            next if $title =~ m/^404|Access Denied|Error|Forbidden|Redirect/g;

            if (not exists $CACHE{$title}) {
                $CACHE{$title} = 0;
                say $title;
            }
        }
    }
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
