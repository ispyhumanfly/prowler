#!/usr/bin/env perl

BEGIN {

    die "You must set the PROWLER_ROOT variable."
      unless exists $ENV{PROWLER_ROOT};
}

use 5.018_000;
use strict;
use warnings;
use utf8;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use lib 'lib/';
use Prowler::Model;

use Mojo::Util qw/ md5_sum /;
use Try::Tiny;
use DateTime;

use Moo;
use MooX::Options;
use Perl6::Attributes;

option name => (is => 'rw', required => 1, format => 's', doc => 'Tell me the name of this transaction.');
option path => (is => 'rw', required => 1, format => 's', doc => 'Tell me where to store the name.');

sub run {

    my $self = shift;

    system "sqlite3 $.path/$.name.db < lib/Prowler/Model/Result/Record.sql"
        unless -e "$.path/$.name.db";

    my %CACHE;

    while (<STDIN>) {

        my $sql = Prowler::Model->connect("dbi:SQLite:$.path/$.name.db");

        my $checksum = md5_sum $_;

        unless (exists $CACHE{$_} and $CACHE{$_} eq $checksum) {

            my $timestamp = DateTime->now;

            $sql->resultset('Record')->create(

                {   datetime => $timestamp,
                    checksum => $checksum,
                    output => $_
                }
            );
        }
        $CACHE{$_} = $checksum;
    }
}

main->new_with_options->run;

exit(0);