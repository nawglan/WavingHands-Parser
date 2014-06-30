package WavingHands::Parser;

use strict;
use warnings;

use JSON;
use File::Spec;
use mop;
=head1 NAME

WavingHands::Parser - Parse games for WavingHands ( http://www.gamecabinet.com/rules/WavingHands.html )

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This module provides the main interface for parsing games for WavingHands games.
( http://www.gamecabinet.com/rules/WavingHands.html )

Perhaps a little code snippet.

    use WavingHands::Parser;

    # create a new parser object.
    my $parser = WavingHands::Parser->new(usesort => 0, trace => 0, bail => 1, gametype => 'Warlocks');

    # load a single file
    $parser->load({filename => '1234.txt'});

    # --- or ---

    # load a directory
    $parser->load({dir => './games'});

    # --- or ---

    # load a file and a directory
    $parser->load({filename => '1234.txt', dir => './games'});

    # parse game in the queue
    my ($total_parsed, $number_successful) = $parser->parse();

    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.


=head1 FUNCTIONS

=head2 new

    Creates the parser object.  There are a couple optional parameters: 'bail',
    'usesort' and 'trace'.  'bail' causes the parser to stop when it encounters
    a game that it cannot parse.  'usesort' is only useful when parsing a
    directory of games.  It will parse games in ascending numerical order. 'trace'
    causes the parser to output to STDERR output from Parse::RecDescent as it
    parses the game.  The only required parameter is 'class'.  This is the class name
    in the namespace WavingHands::Parser::Grammar that defines a Parse::RecDescent
    object for parsing the games for that version of Waving Hands. Example:  using 'class'
    => 'Warlocks' would create a parser for the game Warlocks (http://games.ravenblack.net).

=head2 load

    Loads the parser with either a filename or a path that contains files to be
    parsed. Required parameter is a hashref containing either {filename => '1234.txt'} or
    {directory => './games'}.  If both are supplied, the parser will queue both the filename
    and the files in the directory.

=head2 parse

    Parses the games in the queue.

    Each call to parse will pull one game from the queue.

=cut


class WavingHands::Parser {
    has $!trace is rw = 0;
    has $!usesort is rw = 0;
    has $!bail is rw = 1;
    has $!gametype is rw = do{die "Parameter 'gametype' is required.";};
    my $parser;
    my $total;
    my $good;
    my $data;
    my @queue = ();

    method _resetParser {
        $parser->reset_data() if $parser;

        my $module = "WavingHands/Parser/Grammar/$!gametype.pm";
        my $classname = "WavingHands::Parser::Grammar::$!gametype";
        require $module;

        $parser = $classname->new();

        if ($!trace) {
            $parser->trace(1);
        } else {
            $parser->trace(0);
        }
    }

    method load(%options) {
        die('error: load must be called with either directory or filename defined.')
            if (!defined $options{directory} && !defined $options{filename});

        if (defined $options{directory}) {
            # pull all files in current directory
            opendir(my $DIR, $options{directory});
            my @allfiles = readdir($DIR);
            closedir($DIR);
            @queue = map { File::Spec->catfile($options{directory}, $_) } grep {$_ ne '.' && $_ ne '..'} @allfiles;
        }

        if (defined $options{filename}) {
            push @queue, $options{filename};
        }

        if ($!usesort) {
            @queue = sort {
                my ($g1, undef) = split /\./, $a;
                my ($g2, undef) = split /\./, $b;
                if ($g1 =~ /\d+/ && $g2 =~ /\d+/) {
                    $g1 <=> $g2;
                } else {
                   "$g1" cmp "$g2";
                }
            } @queue;
        }

        $total = 0;
        $good = 0;
    }

    method parse {
        $self->_resetParser();
        my $result;

        if (@queue) {
            my $filename = shift @queue;

            open my $INPUT, '<', $filename or die ("Unable to open $filename : $!\n");
            my $buffer;
            do {
                local $/;
                $buffer = <$INPUT>;
            };
            close $INPUT;

            if ($!trace) {
                open my $TRACE, '>>', File::Spec->catfile('/', 'tmp', 'trace.txt');
                local *STDERR = $TRACE;
                $result = $parser->parse($buffer);
                close $TRACE;
            } else {
                $result = $parser->parse($buffer);
            }

            $good += $result ? 1 : 0;
            $total++;

            @queue = qw() if $!bail && !$result;
        }

        if ($result) {
            $data = $parser->get_data();
            #$self->dump();
        }

        return ($total, $good);
    }

    method dump() {
        print encode_json($data);
    }
}

1;

