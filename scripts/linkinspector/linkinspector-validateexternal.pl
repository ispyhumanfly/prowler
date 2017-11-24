#!/usr/bin/env perl

$ENV{MOJO_MAX_MESSAGE_SIZE} = '0';

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

my %RESULTS;

my $sitemap = $ENV{'SITEMAP'} || '.sitemap';

opendir(DIR, $sitemap)
    or die "Could not open '$sitemap'\n";

my @records = grep(/processed/, readdir DIR);
closedir DIR;

for my $record (@records) {

    open my $collected, "$sitemap/$record"
        or die "Could not open file '$record' $!";

    while (my $entry = <$collected>) {
        chomp $entry;
        $RESULTS{$entry} = 0;
    }
    close $collected;
}

my $ua = Mojo::UserAgent->new;

$ua->max_connections(60);
$ua->request_timeout(60);
$ua->connect_timeout(60);

for my $record (sort keys %RESULTS) {

    $ua->get($record => sub {

        my ( $ua, $tx ) = @_;

        for my $link ($tx->res->dom->find("a")->map( attr => 'href' )->each) {

            my $uri = URI->new($link);

            if ($uri) {
                try {
                    my $root = $uri->host;
                    #$link = URI->new_abs( $link, "http://" . $root);
                    $link = URI->new_abs($link, "http://$root");

                    if (!$link =~ m/$root/g) {

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
                        }
                    }
                }
                catch {
                    say "Link Invalid: $link";
                };
            }
        }
    });

}
Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
exit 0;

