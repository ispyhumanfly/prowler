#!/usr/bin/env perl

use 5.018_000;
use strict;
use warnings;
use utf8;

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use IO::File;
use Try::Tiny;
use URI;

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;

use Net::Whois::Parser;
$Net::Whois::Parser::GET_ALL_VALUES = 1;

use File::Path;
use File::Spec;

my @RECORDS;

my $sitemap = $ENV{'SITEMAP'} || '.sitemap';

for my $domain (@ARGV) {

    my $path = File::Spec->canonpath("$sitemap/$domain");

    opendir(DIR, "$sitemap/$domain")
        or die "Could not open: '$sitemap/$domain'\n";

    push @RECORDS, grep(/processed/, readdir DIR);
    closedir DIR;
}

my %LINKS;

for my $domain (@ARGV) {
    for my $record (@RECORDS) {

        open my $collected, "$sitemap/$record"
            or die "Could not open file '$record' $!";

        while (my $link = <$collected>) {
            chomp $link;
            $LINKS{$link} = 0;
        }
        close $collected;
    }
}

my $ua = Mojo::UserAgent->new;

$ua->max_connections(60);
$ua->request_timeout(60);
$ua->connect_timeout(60);

for my $entry (sort keys %LINKS) {
    $ua->get($entry => sub {

        my ( $ua, $tx ) = @_;

        for my $link ($tx->res->dom->find("a")->map( attr => 'href' )->each) {

            my $uri = URI->new($link);

            if ($uri) {
                try {
                    my $root = $uri->host;

                    #$link = URI->new_abs( $link, "http://" . $root);
                    #$link = URI->new_abs($link, "http://$root");
                    #$link = normalize_link($link);

                    try {
                        $ua->get($link);
                        say "Link Connected: $link";
                    }
                    catch {
                        say "Link Connection Error: $link";
                        #say "Inspecting $root\n";
                        #say "$link\n";

                        #my $info = parse_whois( domain => $root );

                        #use Data::Dumper;
                        #say Dumper($info);
                    };
                }
                catch {
                    ### Mostly relative URLs so we can dismiss these...
                };
            }
        }

        sub normalize_link {
            my $link = shift;

            try {
                my $uri = URI->new($link);
                my $root = $uri->host;
                $link = URI->new_abs( $link, "http://" . $uri->host);
            };
            return $link;
        }
    });
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
exit 0;
