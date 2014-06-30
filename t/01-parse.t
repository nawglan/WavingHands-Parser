#!perl -T

use Test::More tests => 9;
use File::Spec;

BEGIN {
    use_ok( 'WavingHands::Parser' );
}

my $directory = File::Spec->catdir('.', 't', 'data', 'testgames');

my $filename = File::Spec->catfile($directory, '101.txt');
is(-f $filename || 0, 1, 'Game 101 test file exists.');

$filename = File::Spec->catfile($directory, '81794.txt');
is(-f $filename || 0, 1, 'Game 81794 test file exists.');

$filename = File::Spec->catfile($directory, '81891.txt');
is(-f $filename || 0, 1, 'Game 81891 test file exists.');

my $parser = new_ok('WavingHands::Parser' => [
    trace => 0,
    usesort => 0,
    bail => 1,
    gametype => 'Warlocks'
]);

$parser->load(directory => $directory);

my ($total, $good) = $parser->parse();
is ($total == $good, 1, 'Game parsed successfully.');

($total, $good) = $parser->parse();
is ($total == $good, 1, 'Game parsed successfully.');

($total, $good) = $parser->parse();
is ($total == $good, 1, 'Game parsed successfully.');

is ($total + $good, 6, 'All games parsed successfully.');
