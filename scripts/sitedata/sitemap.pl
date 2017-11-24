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

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;

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

for (sort keys %RESULTS) {
    say $_;
}

exit 0;

