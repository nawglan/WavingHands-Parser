package WavingHands::Parser;

use strict;
use warnings;

use JSON;
use File::Spec;
use List::Util qw(shuffle);
=head1 NAME

WavingHands::Parser - Parse games for WavingHands ( http://www.gamecabinet.com/rules/WavingHands.html )

=head1 VERSION

Version 0.001

=cut

our $VERSION = "0.001";

=head1 SYNOPSIS

This module provides the main interface for parsing games for WavingHands games.
( http://www.gamecabinet.com/rules/WavingHands.html )


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

=head2 untaint_str

    Untaints a string returning the untainted string.

=cut

sub untaint_str {
    my $str = shift;
    my $retval;

    local $1;
    $str =~ /^(.*)\z/s;
    eval {
        $retval = $1;
    };

    die $@ if $@;

    return $retval;
}

use mop;

class WavingHands::Parser {
    has $!trace is rw = 0;
    has $!usesort is rw = 0;
    has $!bail is rw = 1;
    has $!gametype is rw = do{die "Parameter 'gametype' is required.";};
    has $!tracedir is rw = File::Spec->catdir('/', 'tmp');
    has $!dumpdir is rw;
    has $!cachefile is rw;
    has $!queue is ro;
    has $!parser is ro;
    has $!cache is ro;

    method _resetParser {
        $!parser->reset_data() if $!parser;

        my $module = File::Spec->catfile('WavingHands', 'Parser', 'Grammar', $!gametype . '.pm');
        my $classname = "WavingHands::Parser::Grammar::$!gametype";
        require $module;

        $!parser = $classname->new();

        if ($!trace) {
            $!parser->trace(1);
        } else {
            $!parser->trace(0);
        }
    }

    method load(%options) {
        die('error: load must be called with either directory or filename defined.')
            if (!defined $options{directory} && !defined $options{filename});

        if (defined $options{directory}) {
            # pull all files in current directory except vi swap files and
            # hidden files (ones starting with dot)
            opendir(my $DIR, $options{directory});
            my @allfiles = grep {$_ !~ /^\./ && $_ !~ /\.swp$/} readdir($DIR);
            closedir($DIR);
            @{$!queue} = map { File::Spec->catfile($options{directory}, $_) } @allfiles;
        }

        if (defined $options{filename}) {
            push @{$!queue}, $options{filename};
        }

        if ($!usesort) {
            @{$!queue} = sort {
                my (undef,undef,$aname) = File::Spec->splitpath($a);
                my (undef,undef,$bname) = File::Spec->splitpath($b);

                my ($g1, undef) = split /\./, $aname;
                my ($g2, undef) = split /\./, $bname;

                if ($g1 =~ /^\d+$/ && $g2 =~ /^\d+$/) {
                    $g1 <=> $g2;
                } else {
                   "$g1" cmp "$g2";
                }
            } @{$!queue};
        } else {
            @{$!queue} = shuffle @{$!queue};
        }

        if ($!cachefile) {
            $!cachefile = untaint_str($!cachefile);
            if (-f $!cachefile) {
                my $cachecount = 0;
                open my $CACHEFILE, '<', $!cachefile;
                if ($CACHEFILE) {
                    while (my $fname = <$CACHEFILE>) {
                        chomp $fname;
                        $!cache->{$fname} = 1;
                        $cachecount++;
                    }
                }
                close $CACHEFILE;
                warn "Loaded $cachecount cached results\n" if $ENV{WHP_DEBUG} && $cachecount;
            }
        }
    }

    method parse {
        $self->_resetParser();
        my $result;
        my $good = 0;

        if ($self->queue_has_items()) {
            my $filename = shift @{$!queue};
            return 1 if $!cache->{$filename};

            open my $INPUT, '<', $filename or die ("Unable to open $filename : $!\n");
            my $buffer;
            do {
                local $/;
                $buffer = <$INPUT>;
            };
            close $INPUT;

            my $TRACE;
            if ($!trace) {
                my $tracefile = untaint_str(File::Spec->catfile($!tracedir, 'trace.txt'));
                open $TRACE, '>', $tracefile;
                local *STDERR = $TRACE;
                $result = $!parser->parse($buffer);
                close $TRACE;
            } else {
                $result = $!parser->parse($buffer);
            }

            if (defined $result) {
                $good = ($result == 1 ? 1 : 0);
                $!cache->{$filename} = 1 if $good;
            }

            @{$!queue} = qw() if $!bail && !$result;

            if ($good) {
                $self->dump() if $ENV{WHP_DEBUG_DUMP};
                if ($!cachefile) {
                  open my $CACHEFILE, '>>', $!cachefile;
                  print $CACHEFILE "$filename\n";
                  close $CACHEFILE;
                }
                warn "Success: $filename parsed correctly." if $ENV{WHP_DEBUG};
            } else {
                warn "Warning: $filename did not parse correctly.";
            }
        }

        return $good;
    }

    method queue_has_items() {
        return (scalar @{$!queue} > 0);
    }

    method queue_size() {
        return scalar @{$!queue};
    }

    method dump() {
        if ($!dumpdir) {
            my $data = $!parser->get_data();
            my $json = JSON->new->allow_nonref->pretty;
            my $dumpfile = untaint_str(File::Spec->catfile($!dumpdir, "dump_$data->{gameid}.json"));

            open my $DUMP, '>', $dumpfile or die "ERROR: Unable to open $dumpfile: $!";
            print $DUMP $json->encode($data);
            close $DUMP;
        }
    }

}

1;

# vi: softtabstop=4 shiftwidth=4 et!: #
