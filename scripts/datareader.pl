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

use Mojo::Asset::Memory;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Mojo::Util qw/ camelize decamelize quote dumper url_escape url_unescape/;

use Mojo::JSON qw/ decode_json encode_json /;

my %RESULTS;

opendir(DIR, "./data/")
    or die "Could not open './data/'\n";

my @xml_files = grep(/collected/, readdir DIR);
closedir DIR;

foreach my $xml_file(@xml_files) {

    open(my $fh, "./data/$xml_file")
        or die "Could not open file '$xml_file' $!";

    while (my $row = <$fh>) {
        chomp $row;
        $RESULTS{$row} = 0;
        say $row;
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

