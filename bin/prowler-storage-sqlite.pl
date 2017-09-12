#!/usr/bin/env perl

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
use File::Temp;
use File::Path;

use Moo;
use MooX::Options;
use Perl6::Attributes;

option name => (is => 'rw', short => 'n', required => 1, format => 's', doc => 'Tell me the name of this transaction.');
option path => (is => 'rw', short => 'p', required => 1, format => 's', doc => 'Tell me where to store the name.');
option echo => (is => 'ro', short => 'e', doc => 'Echo to STDOUT the input from STDIN to the screen.');

sub run {

    my $self = shift;

    unless (-e "$.path/$.name.db") {
        exit(1) if not -d $.path;
        system "sqlite3 $.path/$.name.db < lib/Prowler/Model/Result/Record.sql"
    }


    my %CACHE;

    while (<STDIN>) {

        print $_ if $.echo;

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