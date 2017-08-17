#!/usr/bin/env perl

use 5.018_000;
use strict;
use warnings;
use utf8;

no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";

use Moo;
use MooX::Options;
use Perl6::Attributes;
use Try::Tiny;

option expression => (is => 'rw', short => 'e', required => 1, format => 's', doc => 'Perl regular expression to use as a filter.');

my %CACHE;

sub run {

    my $self = shift;

    while (<STDIN>) {

        next if not $_;
        s/^\s+|\s+$//g;

        if ($.expression) {
            if (not exists $CACHE{$_}) {
                $CACHE{$_} = 0;
                say $_;
            }
        }
    }
}
main->new_with_options->run;

exit(0);