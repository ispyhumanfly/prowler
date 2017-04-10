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

use Email::Valid::Loose;

my $ua = Mojo::UserAgent->new;
# $ua->proxy->http('socks://127.0.0.1:9050');

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

my %CACHE;

$ua->max_connections(25);
$ua->request_timeout(10);

while (<STDIN>) {

    next if not $_;

    for ($ua->max_redirects(5)->get($_)->res->dom->find("img")->map(attr => "src")->each)
    {
        next if not $_;

        $_ = normalize_images($_);
        next if $_ eq '1';

        if (exists $CACHE{$_}) {
            $CACHE{$_}++;
        }

        if (not exists $CACHE{$_}) {
            $CACHE{$_} = 0;
            say $_;
        }
    }
}

sub normalize_images {

    my $image = shift;
    ($image) = $image =~ m/^(http.*)/g;

    $image = url_unescape $image;
    return $image unless not $image;
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
