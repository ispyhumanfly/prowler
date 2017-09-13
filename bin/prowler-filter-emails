#!/usr/bin/env perl

BEGIN {

    die "You must set the PROWLER_ROOT envivironment variable."
      unless exists $ENV{PROWLER_ROOT};
}

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

use Email::Valid::Loose;

my $ua = Mojo::UserAgent->new;
$ua->proxy->http('socks://127.0.0.1:9050');

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

while (<STDIN>) {

    for ($ua->max_redirects(5)->get($_)->res->dom->find("a")->map(attr => "href")->each)
    {
        next if not $_;

        if (m/mailto/g) {
            s/mailto://g;

            if(exists $CACHE{$_}) {
                $CACHE{$_}++;
            }

            if (not exists $CACHE{$_}) {
                $CACHE{$_} = 0;
                say $_ if Email::Valid::Loose->address($_);
            }
        }
    }
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
