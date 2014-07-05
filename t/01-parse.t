#!perl -T

use Test::More;
use File::Spec;

# autoflush
$| = 1;

# num_tests counts the tests being run.  Starting with 2 to account for use_ok and new_ok.
my $num_tests = 2;

BEGIN {
    use_ok( 'WavingHands::Parser' );
}

my $directory = File::Spec->catdir('.', 't', 'data', 'testgames');

my $parser = new_ok('WavingHands::Parser' => [
    trace => $ENV{WHP_TRACE} || 0,
    usesort => 0,
    bail => 1,
    gametype => 'Warlocks'
]);

$parser->load(directory => $directory);

diag("Checking " . $parser->queue_size() . " games.");

my $total_games = 0;
my $total_good = 0;

while ($parser->queue_has_items()) {
    $num_tests++;
    $total_games++;
    my $good = $parser->parse();
    $total_good += $good;
    is ($good == 1, 1, 'Game parsed successfuly.');
    last unless $good == 1;
}

$num_tests++;
is ($total_good == $total_games, 1, 'All games parsed successfuly.');

done_testing($num_tests);

