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
use Mojo::CSV;
use Try::Tiny;

my $ua = Mojo::UserAgent->new;
#$ua->proxy->http('socks://127.0.0.1:9050');

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

while (<STDIN>) {

    next if not $_;
    s/^\s+|\s+$//g;

    # GitHub
    if (m/https:\/\/www.github.com\/\w+$/g) {
        if (not exists $CACHE{$_}) {
            $CACHE{$_} = 0;
            say $_;
        }
    }

    # Facebook
    if (m/https:\/\/www.facebook.com\/\w+$/g) {
        if (not exists $CACHE{$_}) {
            $CACHE{$_} = 0;
            say $_;
        }
    }

    # Twitter
    if (m/https:\/\/www.twitter.com\/\w+$/g) {
        if (not exists $CACHE{$_}) {
            $CACHE{$_} = 0;
            say $_;
        }
    }

    # Myspace
    if (m/https:\/\/www.myspace.com\/\w+$/g) {
        if (not exists $CACHE{$_}) {
            $CACHE{$_} = 0;
            say $_;
        }
    }
}

exit(1);
