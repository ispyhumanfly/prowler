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

use Net::Whois::Parser;
$Net::Whois::Parser::GET_ALL_VALUES = 1;

my $sitemap = $ENV{'SITEMAP'} || '.sitemap';

$SIG{'INT'} = sub {
    my $timestamp = DateTime->now;
    say "\n$timestamp\tExiting LinkInspector Validator...\n";
    exit 0;
};

my %RECORDS;

for my $domain (@ARGV) {

    opendir(DIR, "$sitemap/$domain")
        or die "Could not open: '$sitemap/$domain'\n";

    push @{ $RECORDS{$domain} }, grep(/cleaned/, readdir DIR);
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

my %CACHE = ();

for my $entry (sort keys %LINKS) {

    $ua->get($entry => sub {

        my ( $ua, $tx ) = @_;

        for my $link ($tx->res->dom->find("a")->map( attr => 'href' )->each) {

            ## For now, don't show the same link twice...
            next if exists $CACHE{$link};
            $CACHE{$link} = 0;

            my $uri = URI->new($link);
            my $timestamp = DateTime->now;

            try {

                my $root = $uri->host;

                ### This appears to be a fully qualified URL...

                try {
                    if(my $res = $ua->get($link)->res) {
                        if(my $code = $res->code) {

                            ## There needs to be finer checking done here.

                            say "$timestamp $code $link";
                            sleep 1 if $code != 200;
                        }
                        else {
                            say "$timestamp XXX $link";
                            sleep 1;
                        }
                    }
                    else {
                        say "$timestamp XXX $link";
                        sleep 1;
                    }
                };
            }
            catch {

                ### If we're here, URI couldn't get a hostname from the link.

                try {
                    my $root = $ARGV[0];
                    $link = URI->new_abs($link, $root);

                    unless ($link =~ m/javascript|mailto/g) {
                        if(my $res = $ua->get($link)->res){
                            if(my $code = $res->code) {
                                say "$timestamp $code $link";
                                sleep 1;
                            }
                            else {
                                say "$timestamp XXX $link";
                                sleep 1;
                            }
                        }
                        else {
                            say "$timestamp XXX $link";
                            sleep 1;
                        }
                    }
                    else {
                        say "$timestamp XXX $link";
                        sleep 1;
                    }
                }
                catch {

                    ### If we're here, it's likely this is a relative path...

                    my $domain = $ARGV[0];

                    if ($link =~ m/^\//g){
                        if (my $res = $ua->get("$domain$link")->res) {
                            if (my $code = $res->code) {

                                $link = "$domain$link";

                                say "$timestamp $code $link";
                                sleep 1;
                            }
                            else {

                                ### If we're here, we still couldn't get a status code.

                                say "$timestamp XXX $link";
                                sleep 1;
                            }
                        }
                        else {

                            ## If we're here, we couldn't resolve the host
                            ## even with prepending the domain name.

                            say "$timestamp XXX $link";
                            sleep 1;
                        }
                    }
                };
            }
            finally {

                ### Run Whois lookup against specific status codes.

                #my $info = parse_whois( domain => $root );
                #use Data::Dumper;
                #say Dumper($info);

            };
        }
    });
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

exit 0;

