WavingHands-Parser
==================

This module provides the main interface for parsing games for [WavingHands](http://www.gamecabinet.com/rules/WavingHands.html) games.

```
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
    my $success = $parser->parse();

    ...
```

#FUNCTIONS

##new

    Creates the parser object.  There are a couple optional parameters: 'bail',
    'usesort' and 'trace'.  'bail' causes the parser to stop when it encounters
    a game that it cannot parse.  'usesort' is only useful when parsing a
    directory of games.  It will parse games in ascending numerical order. 'trace'
    causes the parser to output to STDERR output from Parse::RecDescent as it
    parses the game.  The only required parameter is 'class'.  This is the class name
    in the namespace WavingHands::Parser::Grammar that defines a Parse::RecDescent
    object for parsing the games for that version of Waving Hands. Example:  using 'class'
    => 'Warlocks' would create a parser for the game Warlocks (http://games.ravenblack.net).

##load

    Loads the parser with either a filename or a path that contains files to be
    parsed. Required parameter is a hashref containing either {filename => '1234.txt'} or
    {directory => './games'}.  If both are supplied, the parser will queue both the filename
    and the files in the directory.

##parse

    Parses the games in the queue.

    Each call to parse will pull one game from the queue.

##queue_has_items

    Returns 1 if there are items in the queue, 0 otherwise.

##queue_size

    Returns the size of the queue.

##dump

    Dumps the data collected during the parse.

