#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WavingHands::Parser' );
}

diag( "Testing WavingHands::Parser $WavingHands::Parser::VERSION, Perl $], $^X" );
