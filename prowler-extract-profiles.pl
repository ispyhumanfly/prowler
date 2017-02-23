#!/usr/bin/env perl

use 5.018_000;
use strict;
use warnings;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Mojo::Asset::Memory;
use Try::Tiny;

my %CACHE;

while (<STDIN>) {

    next if not $_;
    s/^\s+|\s+$//g;

    if (m/github.com|facebook.com|twitter.com|instagram.com|myspace.com/g) {
        if (not exists $CACHE{$_}) {
            $CACHE{$_} = 0;
            say $_;
        }
    }
}

exit(0);
