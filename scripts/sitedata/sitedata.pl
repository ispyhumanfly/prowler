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

my $sitedata = $ENV{'SITEDATA'} || '.sitedata';

opendir(DIR, $sitedata)
    or die "Could not open '$sitedata'\n";

my @records = grep(/collected/, readdir DIR);
closedir DIR;

for my $record (@records) {

    open(my $collected, "$sitedata/$record")
        or die "Could not open file '$record' $!";

    while (my $entry = <$collected>) {
        chomp $entry;
        $RESULTS{$entry} = 0;
        print $entry;
    }
}

my $ua = Mojo::UserAgent->new;

for (sort keys %RESULTS) {
    try {

        my $video = $ua->get($_)->res->dom->at('title')->text;
        $video =~ s/[^\x00-\x7f]//g;
        say $video;
        $_ =~ s/[^\x00-\x7f]//g;
        say "\t$_\n" and sleep 1;
    }
}

exit 0;

