#!/usr/bin/perl

# usage: perl checkNewContent.pl https://mware-dev.crscreditapi.com/api/mware-docs/all b2b-all.json

use strict;
use warnings;

use WWW::Mechanize;
# use LWP::Simple;
# use Net::SMTP;
# use Storable;
use File::Copy; 
use DateTime;
use feature qw(say);

# START OF CONFIGURATION VARIABLES
# END OF CONFIGURATION VARIABLES
# START OF GLOBAL VARIABLES
my $mech = WWW::Mechanize->new( );
# END OF GLOBAL VARIABLES

########################################################### 
# Reads the file on disk specified by the parameter $file #
########################################################### 
###### START sub GET_FILE_CONTENT ######
sub GET_FILE_CONTENT ($) {
	my $file = shift;

	open (IN, $file) or die $!;

	# Read all file
	my $content = do { local $/; <IN>; };

	close( IN );

	return $content;
}
###### END sub GET_FILE_CONTENT ######

sub GET_URL_CONTENT ($) {
	my $url = shift;

	# Go to specified URL  
	$mech->get ( $url );
	# say "OK: Got URL requested '" . $url;

	my $content = $mech->content( ); 
	# say "OK: Got content from url '" . $url;

	die "ERROR: Get of page content failed" if ( !defined $content );
	say "OK: Got content of URL '" . $url;

	return $content;
}

################################
###### START MAIN PROGRAM ######
################################

die "ERROR: Unexpected number of arguments " . @ARGV if ( @ARGV != 2 );

my $url = $ARGV[ 0 ];
my $file = $ARGV[ 1 ];

die "ERROR: No URL specified on command line." unless ( defined $url );
die "ERROR: No file to download specified on command line." unless ( defined $file );

# STEP 1: Get NEW content downloaded from URL (specified by $url argument)                                             #
########################################################################################################################

my $new_content = GET_URL_CONTENT($url);

# STEP 2: Get OLD content stored with the name (specified by $file argument)                                           #
########################################################################################################################
my $old_content = GET_FILE_CONTENT( $file );

# STEP 3: Compare old content and new content                                                                          #
########################################################################################################################

if ( $old_content ne $new_content ) {

	########################################################
	# STEP 4: Different content on the website.          #
	########################################################
	say "OK: NEWER CONTENT FOUND AT URL";

	# say "OLD CONTENT";
	# say $old_content;
	# say "NEW CONTENT";
	# say $new_content;
	# exit;

	########################################################
	# STEP 4.1: date of new content is today               #
	########################################################
	my $date = DateTime->now();
	say "OK: Update date is : '" . $date;

	########################################################
	# STEP 4.2: Create new file name including date        #
	########################################################
	my $newfilename = $file;
	my $cleandate = $date;

	$cleandate =~ s/[ -\/:]//g;

	if ($newfilename =~ s/json$// ) {
		$newfilename = $newfilename . $cleandate . ".json";
	} elsif ($newfilename =~ s/yaml$// ) {
		$newfilename = $newfilename . $cleandate . ".yaml";
	}

	########################################################
	# STEP 4.3: Download new content                       #
	########################################################
	say "OK: Downloading new content to " . $newfilename;
	$mech->get( $url, ':content_file' => $newfilename );

	########################################################
	# STEP 4.4: Copy new file to standard name (next time) #
	########################################################
	say "OK: Copying " . $newfilename . " to " . $file;
	copy($newfilename, $file);

} else {

	########################################################
	# STEP 5: Same content at the URL.                     #
	########################################################
	say "OK: Content at URL same as previously downloaded";

}

# END
#######################################

##############################
###### END MAIN PROGRAM ######
##############################