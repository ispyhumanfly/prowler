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

use File::Path;
use File::Spec;
use DateTime;

my $sitemap = $ENV{'SITEMAP'} || '.sitemap';
my $timestamp = DateTime->now;

$SIG{'INT'} = sub {
    say "\n$timestamp\tExiting LinkInspector Validator...\n";
    exit 0;
};

my %RECORDS;

for my $domain (@ARGV) {

    opendir(DIR, "$sitemap/$domain")
        or die "Could not open: '$sitemap/$domain'\n";

    push @{ $RECORDS{$domain} }, grep(/processed/, readdir DIR);
    closedir DIR;
}

my %LINKS;

for my $domain (@ARGV) {
    for my $record (sort keys %RECORDS) {
        for my $filepath (@{$RECORDS{$record}}) {

            my $path = File::Spec->canonpath($filepath);

            open my $collected, "$sitemap/$domain/$filepath" or die "Could not open file '$path' $!";

            while (my $link = <$collected>) {
                chomp $link;
                $LINKS{$link} = 0;
            }
            close $collected;
        }
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

                    try {
                        if(my $res = $ua->get($link)->res) {
                            if($res->code) {
                                say "Link Connected: $link";
                            }
                        }
                    }
                    catch {
                        say "Link Error: $link";
                        #say "Inspecting $root\n";
                        #say "$link\n";

                        #my $info = parse_whois( domain => $root );

                        #use Data::Dumper;
                        #say Dumper($info);
                    };
                }
                catch {

                    ### If we're here, URI couldn't get a hostname from the link.

                    my $root = $ARGV[0];

                    unless ($link =~ m/javascript|mailto/g) {
                        if(my $res = $ua->get("$root$link")->res){
                            if($res->code) {
                                say "Link Connected: $root$link";
                            }
                        }
                        else {
                            say "Link Malformed: $link"
                        }
                    }
               }
               finally {
                   my $domain = $ARGV[0];
                   try {
                        #$domain = "http://$domain$link";
                        #if($ua->get($link)->res->body) {
                        #    say "Link Connected: $link";
                        #}
                    }
                    catch {
                        say "Link Malformed: $link";
                    }
               };
            }
        }
    });
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

exit 0;

