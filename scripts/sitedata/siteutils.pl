#!/usr/bin/env perl

use 5.018_000;
use strict;
use warnings;
use utf8;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Net::Whois::Parser;
$Net::Whois::Parser::GET_ALL_VALUES = 1;

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::IOLoop;

use URI;

my $ua = Mojo::UserAgent->new;

$ua->max_connections(60);
$ua->request_timeout(60);
$ua->max_redirects(60);

while (<STDIN>) {

    my $link = $_;

    #say "Inspecting: $link";

    $ua->get($link => sub {

        my ( $ua, $tx ) = @_;

        #if (my $res = $tx->success) {
        #    say $res->code;
        #}

        if (!$tx->success) {

            my $err = $tx->error;

            #if (($err->{code}) and ($err->{code} == 200)) {
            #    say $link;
            #}

            say "\nLink: $link";
            say "Response: $err->{code}\nMessage: $err->{message}" if $err->{code};
            say "Error: $err->{message}" if $err->{message};
            say "Status: Error";
        }
    });

    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}
