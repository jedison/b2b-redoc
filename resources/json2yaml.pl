#!/usr/bin/env perl
# json2yaml.pl
#     JSON <--> YAML converter in Perl
# * Synopsis
#     json2yaml.pl [--json2yaml|--j2y] [--yaml2json|--y2j] input_filename output_filename
# * Usage
#     json2yaml.pl --json2yaml all.json all.yaml
#     json2yaml.pl --yaml2json all.yaml all.json
# * Notice
#     * Input and output file in UTF-8
#     * [Null] data in YAML is described by '~'.

# perl json2yaml.pl --json2yaml b2b-all.json b2b-all.yaml

use strict;
use warnings;
use utf8;
use Encode qw( decode encode );
use Scalar::Util qw(blessed reftype);
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use JSON;
use YAML::Tiny;
use feature qw(say);

my( $y2j, $j2y );
GetOptions(
    'yaml2json|y2j' => \$y2j,
    'json2yaml|j2y' => \$j2y,
);

die "ERROR: Unexpected number of arguments " . @ARGV if ( @ARGV != 2 );

my $input = $ARGV[ 0 ];
my $output = $ARGV[ 1 ];

open (IN, $input) or die $!;
open (OUT, '>', $output) or die $!;

my $str = do { local $/; <IN>; };
my $hash;
if ( $j2y || !$y2j ) {
    # json2yaml mode:
    say 'json2yaml mode of ' . $input . " to " . $output;

    $hash = JSON->new->utf8->decode( $str );

    stringifyObjects( $hash );

    print OUT encode( 'utf8', Dump( $hash ) );
} else {
    # yaml2json mode:
    say 'yaml2json mode of ' . $input . " to " . $output;

    $hash = JSON->new->ascii->pretty->encode( $str );

    print OUT my $hash;
}

close(OUT);

sub stringifyObjects {
    for my $val (@_) {
        next unless my $ref = reftype $val;
        if (blessed $val) {
            $val = "$val";
        } elsif ($ref eq 'ARRAY') {
            stringifyObjects(@$val);
        } elsif ($ref eq 'HASH')  {
            stringifyObjects(values %$val);
        }
    }
}