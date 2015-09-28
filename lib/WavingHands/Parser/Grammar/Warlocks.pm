package WavingHands::Parser::Grammar::Warlocks;

=head1 NAME

WavingHands::Parser::Grammar::Warlocks - Grammar for games from L<Warlocks|http://games.ravenblack.net>

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.001';
our $globals = {};

use Parse::RecDescent;
use WavingHands::Parser;

undef $::RD_WARN;

=head1 SYNOPSIS

    This module provides the grammar for parsing games from L<Warlocks|http://games.ravenblack.net>

=head1 CONSTANTS

    GRAMMAR - Is the Parse::RecDescent grammar in the initial state.  During
              parsing, the PLAYERNAME rule is modified to match the player
              names specific to the game being parsed.

=head1 FUNCTIONS

=head2 new

    Creates a new parser object.

=head2  get_data

    Returns the data hash.  This hash contains information about the game.
    An array of turns, etc.

=head2 reset_data

    Resets the data hash.

=head2 parse

    Parses a game.

=head2 trace

    If passed a true value, turns on Parse::RecDescent tracing and hints,
    otherwise turns off tracing and hints.

=cut

use constant GRAMMAR => << '_EOGRAMMAR_'
    # initializing action
    {
        # autoflush
        $| = 1;

        # skip whitespace, newlines and emptystring
        $Parse::RecDescent::skip = qr/[\s\n]*/s;

        # pull in outer globals variable
        my $globals = $WavingHands::Parser::Grammar::Warlocks::globals;
    }

    startrule : PREAMBLE TURNSECTION(s) MONSTERLIST(s?) PLAYERLIST EOFILE

    PREAMBLE : TURNSINGAME GAMETYPE MODIFIER(s?) "Battle" GAMEID
    {
        $return = $item{TURNSINGAME} . " " . $item{GAMETYPE};

        if ($item{MODIFIER}) {
            $return .= " " . $item{MODIFIER};
        }

        $return .= " Battle " . $item{GAMEID};
    }

    TURNSINGAME : /(?:.*?)Turn \d+ in/ms

    GAMETYPE : FORMONEY | FORPRIDE
    {
        $globals->{gametype} = $item[1];
    }

    FORMONEY : "Ladder" | "Melee"

    FORPRIDE : VERYFRIENDLY | "Friendly"

    VERYFRIENDLY : "Very" "Friendly"
    {
        $return = "Very Friendly";
    }

    MODIFIER : PARAFCOPT | PARAFDFOPT | MALADROITOPT
    {
        push @{$globals->{game_modifiers}}, $item[1];

        $return = $item[1];
    }

    PARAFCOPT : PARENDS "ParaFC" PARENDS
    {
        $return = "ParaFC";
    }

    PARENDS : /[()]/

    PARAFDFOPT : PARENDS "ParaFDF" PARENDS
    {
        $return = "ParaFDF";
    }

    MALADROITOPT : PARENDS "Maladroit" PARENDS
    {
        $return = "Maladroit";
    }

    GAMEID : INTEGER
    {
        $globals->{gameid} = $item{INTEGER};
        warn "Processing Game $globals->{gameid}\n" if defined $ENV{WHP_VERBOSE};
        $return = $item{INTEGER};
    }

    INTEGER : /\d+/

    TURNSECTION : TURNLINE TURNBODY(s?)
    {
        $return = $item{TURNLINE} . "\n";
        if ($item{TURNBODY}) {
            $return .= join("\n", @{$item{TURNBODY}});
        } else {
            $return = 1;
        }
    }

    TURNLINE : "Turn" INTEGER
    {
        my $turn = $item{INTEGER};

        if ($turn == 1) {
            # create regex for matching playernames exactly and replace the
            # generic one.
            my @players = sort{length "$b" <=> length "$a"}
                              @{$globals->{players}};
            my $playercount = scalar @players;

            $globals->{melee_game} = ($playercount > 2) ? 1 : 0;

            my $rule = sprintf ("PLAYERNAME : /\\b\(%s\)\\b/\n%s",
                (join '|', @players),
                '{ $return = "1:$item[1]"; }'
                );
            my $rule2 = "LISTOFPLAYERS : PLAYERLINES($playercount)";

            $rule = WavingHands::Parser::untaint_str($rule);
            $rule2 = WavingHands::Parser::untaint_str($rule2);

            $thisparser->Extend($rule);
            $thisparser->Extend($rule2);
        }

        $globals->{turnlist}[$turn] = {};
        $globals->{current_turn} = $turn;

        $return = "Turn $turn";
    }

    TURNBODY : TURNBODYTYPES PUNCT
    {
        my $turn = $globals->{current_turn};
        my $turntext = $item{TURNBODYTYPES} . $item{PUNCT};

        $globals->{turnlist}[$turn]->{gametext} .=
            ($globals->{turnlist}[$turn]->{gametext} ? "\n" : "") . $turntext;

        $return = $item{TURNBODYTYPES} . $item{PUNCT};
    }

    TURNBODYTYPES : PLAYERBOWS | TURNBODYLINES | SPECIALTURNBODYLINES |
        GAMEOUTCOME

    PLAYERBOWS : BOWNAME "bows"
    {
        my $player = $item[1];

        push @{$globals->{players}}, $player;

        $globals->{turnlist}[0]->{$player}{gesture}{left} = 'B';
        $globals->{turnlist}[0]->{$player}{gesture}{right} = 'B';
        $return = "$player bows";
    }

    BOWNAME : /\b\w+\b/

    TURNBODYLINES : OUTSIDETIME(?) BURSTOFSPEED(?) ACTOR TURNBODYLINETYPES
    {
        my ($is_player, $actorname) = split /:/, $item{ACTOR};

        $return = '';
        $return .= "$item{OUTSIDETIME} " if $item{OUTSIDETIME};
        $return .= "$item{BURSTOFSPEED} " if $item{BURSTOFSPEED};
        $return .= "$actorname $item{TURNBODYLINETYPES}";

        if ($is_player == 2) {
            my $currentowner = $globals->{monsters}{$actorname}{current_owner};
            $currentowner = 'none' if $currentowner == "";
            $globals->{monsters}{$actorname}{owned_by_length}{$currentowner} += 1;
        }
    }

    OUTSIDETIME : "Outside" "time" PUNCT
    {
        $return = "Outside time,";
    }

    BURSTOFSPEED : "In" "a" "burst" "of" "speed" PUNCT
    {
        $return = "In a burst of speed,";
    }

    ACTOR : TARGET
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $globals->{actor} = $targetname;
        $globals->{actor_is_player} = $is_player;
        $return = $item{TARGET};
    }

    TARGET : PLAYERTARGET | MONSTERTARGET
    {
        if ($item{PLAYERTARGET}) {
            $return = $item{PLAYERTARGET};
        } else {
            $return = $item{MONSTERTARGET};
        }
    }

    PLAYERTARGET : GENERICTARGET | PLAYERNAME

    GENERICTARGET : /himself|nobody|everyone|someone/i
    {
        if ($item[1] =~ /himself|someone|everyone/) {
            $return = "1:$item[1]";
        } else {
            $return = "2:$item[1]";
        }
    }

    MONSTERTARGET : POTENTIALMONSTER | MONSTERNAME
    {
        $return = "2:$item{POTENTIALMONSTER}" if $item{POTENTIALMONSTER};
        $return = "2:$item{MONSTERNAME}" if $item{MONSTERNAME};
    }

    POTENTIALMONSTER : "the" "monster" PLAYERNAME "is" "summoning" "with"
        "his" HANDED "hand"
    {
        my ($is_player, $playername) = split /:/, $item{PLAYERNAME};

        $return = "the monster $playername is summoning with his" .
            " $item{HANDED} hand";
    }

    MONSTERNAME : VERY(s?) MONSTERTYPENAME
    {
        $return = "";

        if ($item{VERY}) {
          $return .= join(' ', @{$item{VERY}}) . ' ';
        }

        $return .= $item{MONSTERTYPENAME};
    }

    VERY : "Very"

    MONSTERTYPENAME : GOBLINNAME | OGRENAME | TROLLNAME | GIANTNAME |
        ELEMENTALNAME

    GOBLINNAME : ARTICLE(?) GOBLINADJ "Goblin"
    {
        my $art = $item{ARTICLE} ? "$item{ARTICLE} " : "";
        my $adj = $item{GOBLINADJ} ? "$item{GOBLINADJ} " : "";

        $return = $art . $adj . "Goblin";
    }

    ARTICLE : /(the|an|a)\b/i

    GOBLINADJ : "Bearded" | "Belligerent" | "Fat" | "Green" | "Grey" |
        "Horrid" | "Malodorous" | "Nasty" | "Ratty" | "Small" | "Smelly" |
        "Tricky" | "Ugly" | #nothing

    OGRENAME : ARTICLE(?) OGREADJ "Ogre"
    {
        my $art = $item{ARTICLE} ? "$item{ARTICLE} " : "";
        my $adj = $item{OGREADJ} ? "$item{OGREADJ} " : "";

        $return = $art . $adj . "Ogre";
    }

    OGREADJ : "Angry" | "Black" | "Burnt" | "Crazy" | "Monstrous" |
        "Obtuse" | "Ochre" | "Stinking" | "Terrible" | "Yellow" | #nothing

    TROLLNAME : ARTICLE(?) TROLLADJ "Troll"
    {
        my $art = $item{ARTICLE} ? "$item{ARTICLE} " : "";
        my $adj = $item{TROLLADJ} ? "$item{TROLLADJ} " : "";

        $return = $art . $adj . "Troll";
    }

    TROLLADJ : "Bridge" | "Green" | "Hairy" | HAMFISTED | "Irate" |
        "Loud" | "Mailing-list" | "Obnoxious" | "Stupid" | "Tall" | #nothing

    HAMFISTED : "Ham" DASH "fisted"
    {
        $return = "Ham-fisted";
    }

    DASH : "-"

    GIANTNAME : ARTICLE(?) GIANTADJ "Giant"
    {
        my $art = $item{ARTICLE} ? "$item{ARTICLE} " : "";
        my $adj = $item{GIANTADJ} ? "$item{GIANTADJ} " : "";

        $return = $art . $adj . "Giant";
    }

    GIANTADJ : /Beanstalk|Big|Gaunt|Golden|Hungry|Large|Norse/ | #nothing

    ELEMENTALNAME : ARTICLE(?) STORMTYPE "Elemental"
    {
        my $article = $item{ARTICLE} ? "$item{ARTICLE} " : "";

        $return = $article . $item{STORMTYPE} . " Elemental";
    }

    STORMTYPE : "Ice" | "Fire"

    TURNBODYLINETYPES : NORMALTURNBODYLINES | OTHERTURNBODYLINES

    NORMALTURNBODYLINES : PLAYERACTIONTYPES | MONSTERTURNLINE

    PLAYERACTIONTYPES : PLAYERGESTURE | PLAYERCAST | PLAYERDIRECTS |
        PLAYERSPEECH | CLAPS

    PLAYERGESTURE : GESTURETYPE WITH(?) "his" HANDED "hand"
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{actor};
        my $hand = $item{HANDED};
        my $gesture = $item{GESTURETYPE};
        my $gesturemap = {
            'D' => "points the digit of his $hand hand",
            'S' => "snaps the fingers of his $hand hand",
            'W' => "waves with his $hand hand",
            'F' => "wiggles the fingers of his $hand hand",
            'P' => "proffers the palm of his $hand hand",
            'C' => "flailingly half-claps with his $hand hand",
            '>' => "stabs with his $hand hand",
            '-' => "makes no gesture with his $hand hand"
        };

        $globals->{turnlist}[$turn]->{$player}{gesture}{$hand} = $gesture;

        $return = $gesturemap->{$gesture};
    }

    GESTURETYPE : GESTURED | GESTURES | GESTUREW | GESTUREF | GESTUREP |
        GESTUREC | PLAYERSTAB | NOGESTURE

    GESTURED : "points" "the" "digit" "of"
    {
        $return = "D";
    }

    GESTURES : "snaps" "the" "fingers" "of"
    {
        $return = "S";
    }

    GESTUREW : "waves"
    {
        $return = "W";
    }

    GESTUREF : "wiggles" "the" "fingers" "of"
    {
        $return = "F";
    }

    GESTUREP : "proffers" "the" "palm" "of"
    {
        $return = "P";
    }

    GESTUREC : "flailingly" "half" DASH "claps"
    {
        $return = 'C';
    }

    PLAYERSTAB : "stabs"
    {
        $return = ">";
    }

    NOGESTURE : "makes" "no" "gesture"
    {
        $return = "-";
    }

    WITH : "with"

    HANDED : "left" | "right"

    PLAYERCAST : "casts" HISBANKED(?) SPELLNAME ATON TARGET BUTMISSES(?)
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{actor};
        my $spell = $item{SPELLNAME};
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $success = $item{BUTMISSES} == undef;
        my $pturn = $globals->{turnlist}[$turn]->{$player};
        my $hisbanked = " ";
        my $butmisses = "";

        if ($item{HISBANKED}) {
            $globals->{$player}{spells}{banked}{$spell}{count}++;
            push @{$pturn->{spells}{banked}{$spell}}, {
                success => $success,
                target => $targetname,
                target_type => $is_player
            };
        } else {
            $globals->{$player}{spells}{$spell}{count}++;
            push @{$pturn->{spells}{$spell}}, {
                success => $success,
                target => $targetname,
                target_type => $is_player
            };
        }

        if ($item{HISBANKED}) {
            $hisbanked = " his banked ";
        }

        if ($item{BUTMISSES}) {
            $butmisses = " $item{BUTMISSES}";
        }

        $return = "casts${hisbanked}${spell} $item{ATON}" .
            " ${targetname}${butmisses}";
    }

    HISBANKED : "his" "banked"
    {
        $return = "his banked";
    }

    # these are in order by likelyhood of being cast
    SPELLNAME :
        "Shield" | "Paralysis" | MAGICMISSILE | COUNTERSPELL | CHARMPERSON |
        SUMMONGOBLIN | "Protection" | "Amnesia" | CAUSELIGHTWOUNDS |
        CAUSEHEAVYWOUNDS | "Confusion" | CHARMMONSTER | CURELIGHTWOUNDS |
        "Maladroitness" | "Fear" | SUMMONOGRE | "Invisibility" |
        "Anti-spell" | CUREHEAVYWOUNDS | LIGHTNINGBOLT | MAGICMIRROR |
        CLAPOFLIGHTNING | SUMMONGIANT | "Permanency" | "Blindness" |
        TIMESTOP | SUMMONTROLL | RESISTHEAT | DISPELMAGIC |
        REMOVEENCHANTMENT | "Fireball" | "Disease" | ICESTORM |
        SUMMONFIREELEMENTAL | FINGEROFDEATH | RESISTCOLD | FIRESTORM |
        "Poison" | "Haste" | SUMMONICEELEMENTAL | DELAYEFFECT

    MAGICMISSILE : "Magic" "Missile"
    {
        $return = "Magic Missile";
    }

    COUNTERSPELL : "Counter" "Spell"
    {
        $return = "Counter Spell";
    }

    CHARMPERSON : "Charm" "Person"
    {
        $return = "Charm Person";
    }

    SUMMONGOBLIN : "Summon" "Goblin"
    {
        $return = "Summon Goblin";
    }

    CAUSELIGHTWOUNDS : "Cause" "Light" "Wounds"
    {
        $return = "Cause Light Wounds";
    }

    CAUSEHEAVYWOUNDS : "Cause" "Heavy" "Wounds"
    {
        $return = "Cause Heavy Wounds";
    }

    CHARMMONSTER : "Charm" "Monster"
    {
        $return = "Charm Monster";
    }

    CURELIGHTWOUNDS : "Cure" "Light" "Wounds"
    {
        $return = "Cure Light Wounds";
    }

    SUMMONOGRE : "Summon" "Ogre"
    {
        $return = "Summon Ogre";
    }

    CUREHEAVYWOUNDS : "Cure" "Heavy" "Wounds"
    {
        $return = "Cure Heavy Wounds";
    }

    LIGHTNINGBOLT : "Lightning" "Bolt"
    {
        $return = "Lightning Bolt";
    }

    MAGICMIRROR : "Magic" "Mirror"
    {
        $return = "Magic Mirror";
    }

    CLAPOFLIGHTNING : "Clap" "of" "Lightning"
    {
        $return = "Clap of Lightning";
    }

    SUMMONGIANT : "Summon" "Giant"
    {
        $return = "Summon Giant";
    }

    TIMESTOP : "Time" "Stop"
    {
        $return = "Time Stop";
    }

    SUMMONTROLL : "Summon" "Troll"
    {
        $return = "Summon Troll";
    }

    RESISTHEAT : "Resist" "Heat"
    {
        $return = "Resist Heat";
    }

    DISPELMAGIC : "Dispel" "Magic"
    {
        $return = "Dispel Magic";
    }

    REMOVEENCHANTMENT : "Remove" "Enchantment"
    {
        $return = "Remove Enchantment";
    }

    ICESTORM : "Ice" "Storm"
    {
        $return = "Ice Storm";
    }

    SUMMONFIREELEMENTAL : "Summon" "Fire" "Elemental"
    {
        $return = "Summon Fire Elemental";
    }

    FINGEROFDEATH : "Finger" "of" "Death"
    {
        $return = "Finger of Death";
    }

    RESISTCOLD : "Resist" "Cold"
    {
        $return = "Resist Cold";
    }

    FIRESTORM : "Fire" "Storm"
    {
        $return = "Fire Storm";
    }

    SUMMONICEELEMENTAL : "Summon" "Ice" "Elemental"
    {
        $return = "Summon Ice Elemental";
    }

    DELAYEFFECT : "Delay" "Effect"
    {
        $return = "Delay Effect";
    }

    ATON : "at" | "on"

    BUTMISSES : PUNCT "but" MISSTYPE
    {
        $return = "$item{PUNCT} but $item{MISSTYPE}";
    }

    MISSTYPE : MISSMISSES | MISSDEFLECT | MISSTRIP

    MISSMISSES : "misses" MISSREASON(?)
    {
        $return = "misses" . ($item{MISSREASON} ? " $item{MISSREASON}" : "");
    }

    MISSREASON : "due" "to" BLINDORINVIS
    {
        $return = "due to $item{BLINDORINVIS}";
    }

    BLINDORINVIS : /blindness|invisibility/

    MISSDEFLECT : "is" "deflected" "by" "a" "shield"
    {
        $return = "is deflected by a shield";
    }

    MISSTRIP : "trips" "on" "its" "feet"
    {
        $return = "trips on its feet";
    }

    PLAYERDIRECTS : "directs" MONSTERNAME "to" "attack" TARGET
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "directs " . $item{MONSTERNAME} . " to attack $targetname";
    }

    PLAYERSPEECH : "says" /"(.*?)"\.\n/sm
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{actor};

        local $1;
        $item[2] =~ /"(.*)"/;

        my $speech_text = WavingHands::Parser::untaint_str($1);

        $globals->{turnlist}[$turn]->{$player}{speech} = $speech_text;

        # put the period back on the text block so that PUNCT rule succeeds
        $text = '.' . $text;

        $return = "says \"$speech_text\"";
    }

    CLAPS : "claps"
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{actor};

        $globals->{turnlist}[$turn]->{$player}{gesture}{right} = 'C';
        $globals->{turnlist}[$turn]->{$player}{gesture}{left} = 'C';

        $return = "claps";
    }

    MONSTERTURNLINE : ATTACKRESULT3 | ATTACKRESULT4 | ATTACKRESULT5 |
        ATTACKRESULT7 | MONSTERWANDERS | MONSTERRUNS | MONSTERFORGETS |
        NOTARGET | MONSTERSCARED | MONSTERELEMENTAL | REMOVEENCHANTRESULT3

    ATTACKRESULT3 : "swings" "wildly" "for" TARGET BUTMISSES
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "swings wildy for ${targetname} $item{BUTMISSES}";
    }

    ATTACKRESULT4 : "does" INTEGER "damage" "to" TARGET
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $actor = $globals->{actor};
        my $damage = $item{INTEGER};

        if ($globals->{actor_is_player} == 2) {
          $globals->{monsters}{$actor}{damage_done}{$targetname} += $damage;
        }

        $return = "does $damage damage to $targetname";
    }

    ATTACKRESULT5 : "tries" "to" "attack" TARGET PUNCT "but" "trips" "on"
        "its" "feet"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "tries to attack $targetname, but trips on its feet";
    }

    ATTACKRESULT7 : "tries" "to" "attack" TARGET PUNCT "fruitlessly"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "tries to attack $targetname, fruitlessly";
    }

    MONSTERWANDERS : "wanders" "around" "aimlessly"
    {
        $return = "wanders around aimlessly";
    }

    MONSTERRUNS : "runs" "around" "wildly" PUNCT "looking" "for" "someone"
        "to" "hit"
    {
        $return = "runs around wildly, looking for someone to hit";
    }

    MONSTERFORGETS : "forgets" "to" "attack" "anyone"
    {
        $return = "forgets to attack anyone";
    }

    NOTARGET : "doesn't" "attack" "anyone"
    {
        $return = "doesn't attack anyone";
    }

    MONSTERSCARED : "is" "too" "scared" "to" "attack"
    {
        $return = "is too scared to attack";
    }

    MONSTERELEMENTAL : "is" "summoned" "inside" ELEMENTALNAME PUNCT "and"
        "is" "consumed" "instantly"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /^Summon/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $item{ELEMENTALNAME};
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        if ($globals->{actor_is_player} == 2) {
          $globals->{monsters}{$actor}{killed_by} = $item{ELEMENTALNAME};
        }

        $return = "is summoned inside $item{ELEMENTALNAME}, and is" .
            " consumed instantly";
    }

    REMOVEENCHANTRESULT3 : "is" "hit" "by" "Remove" "Enchantment" PUNCT "and"
        "starts" "coming" "apart" "at" "the" "seams"
    {
        my $actor = $globals->{actor};
        if ($globals->{actor_is_player} == 2) {
          $globals->{monsters}{$actor}{killed_by} = 'Remove Enchantment';
        }

        $return = "is hit by Remove Enchantment, and starts coming apart" .
            " at the seams";
    }

    # preceded by target, these are in order by likelyhood of being
    # cast / happening
    OTHERTURNBODYLINES : SHIELDRESULT | SHIELDRESULT3 | PARARESULT |
        PARAEFFECT | PARAEFFECT2 | MISSILERESULT | COUNTERSPELLRESULT |
        COUNTERSPELLRESULT2 | COUNTERSPELLRESULT4 | CHARMPERSONRESULT |
        CHARMPERSONRESULT2 | CHARMPERSONEFFECT | CHARMPERSONEFFECT2 |
        SUMMONMONSTERRESULT | SUMMONMONSTERRESULT2 | SUMMONMONSTERRESULT3 |
        SUMMONMONSTERRESULT5 | ATTACKRESULT | ATTACKRESULT2 | ATTACKRESULT6 |
        PROTECTIONRESULT | PROTECTIONRESULT2 | AMNESIARESULT | AMNESIAEFFECT |
        CONFUSIONRESULT | CONFUSIONRESULT2 | CONFUSIONEFFECT |
        CONFUSIONEFFECT2 | CHARMMONSTERRESULT | CHARMMONSTERRESULT2 |
        CUREWOUNDSRESULT | CUREWOUNDSRESULT2 | MALADROITRESULT |
        MALADROITEFFECT | CANCELENCHANTMENT | FEARRESULT | FEAREFFECT |
        INVISRESULT | INVISEFFECT | ANTISPELLRESULT | ANTISPELLRESULT2 |
        LIGHTNINGBOLTRESULT | MAGICMIRRORRESULT | CLAPOFLIGHTNINGRESULT |
        PERMANENCYRESULT | PERMANENCYRESULT2 | PERMANENCYEFFECT |
        PERMANENCYEFFECT2 | BLINDNESSRESULT | BLINDNESSRESULT3 |
        BLINDNESSRESULT4 | TIMESTOPRESULT | TIMESTOPRESULT2 |
        RESISTHEATRESULT | RESISTHEATRESULT2 | REMOVEENCHANTRESULT |
        REMOVEENCHANTRESULT2 | DISEASERESULT | DISEASEEFFECT1 |
        DISEASEEFFECT2 | DISEASEEFFECT3 | DISEASEEFFECT4 | DISEASEEFFECT5 |
        DISEASEEFFECT6 | DISEASEEFFECT7 | DISEASEEFFECT8 | ICESTORMRESULT2 |
        ICESTORMRESULT3 | ICESTORMRESULT4 | ICESTORMRESULT5 |
        SUMMONFIRERESULT | SUMMONFIRERESULT2 | SUMMONFIRERESULT3 |
        SUMMONFIRERESULT4 | SUMMONFIRERESULT5 | SUMMONFIRERESULT6 |
        SUMMONFIRERESULT7 | SUMMONFIRERESULT10 | FINGEROFDEATHRESULT |
        RESISTCOLDRESULT | FIRESTORMRESULT2 | FIRESTORMRESULT3 |
        FIRESTORMRESULT4 | FIRESTORMRESULT5 | POISONRESULT | POISONRESULT2 |
        POISONEFFECT | HASTERESULT | HASTERESULT2 | SUMMONICERESULT |
        SUMMONICERESULT2 | SUMMONICERESULT3 | SUMMONICERESULT4 |
        SUMMONICERESULT5 | SUMMONICERESULT6 | SUMMONICERESULT8 |
        DELAYEFFECTRESULT | PLAYERSUICIDE

    # RESULTS are text the same turn as the spell is cast
    SHIELDRESULT : "is" "covered" "by" "a" "shimmering" "shield"
    {
        $return = "is covered by a shimmering shield";
    }

    SHIELDRESULT3 : APOSS "shield" "intensified" "momentarily"
    {
        $return = "'s shield intensified momentarily";
    }

    APOSS : "'s"

    PARARESULT : APOSS "hands" "start" "to" "stiffen"
    {
        $return = "'s hands start to stiffen";
    }

    # EFFECTS are text the turn after the spell is cast
    PARAEFFECT : APOSS HANDED "hand" "is" "paralysed"
    {
        $return = "'s $item{HANDED} hand is paralysed";
    }

    PARAEFFECT2 : "can" APOST "move" "to" "attack"
    {
        $return = "can't move to attack";
    }

    APOST : "'t"

    MISSILERESULT : "is" "hit" "by" "a" MAGICMISSILE PUNCT "for" INTEGER
        "damage"
    {
        $return = "is hit by a Magic Missile, for $item{INTEGER} damage";
    }

    COUNTERSPELLRESULT : "is" "covered" "by" "a" "magical" "glowing" "shield"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next if $spell eq 'Counter Spell' || $spell eq 'Dispel Magic';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless ($spell_info->{target} eq $actor) || ($actor eq $player && $spell_info->{target} =~ /himself/i);
                        $spell_info->{success} = 0;
                    }
                }
            }
        }

        $return = "is covered by a magical glowing shield";
    }

    COUNTERSPELLRESULT2 : APOSS "shield" "looks" "thicker" "for" "a" "moment"
        PUNCT "then" "fades" "back"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            next unless $player eq $actor;
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Shield';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s shield looks thicker for a moment, then fades back";
    }

    COUNTERSPELLRESULT4 : APOSS SPELLNAME "is" "absorbed" "into" "a" "glow"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            next unless $player eq $actor;
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq $item{SPELLNAME};
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s $item{SPELLNAME} is absorbed into a glow";
    }

    CHARMPERSONRESULT : "looks" "intrigued" "by" TARGET
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "looks intrigued by $targetname";
    }

    CHARMPERSONRESULT2 : "appears" "unaffected" "by" TARGET APOSS
        "intellectual" "charms"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            next unless $player eq $targetname;
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Charm Person';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "appears unaffected by ${targetname}'s intellectual charms";
    }

    CHARMPERSONEFFECT : "is" "charmed" "into" "making" "the" "wrong"
        "gesture" "with" "his" HANDED "hand"
    {
        $return = "is charmed into making the wrong gesture with his" .
            " $item{HANDED} hand";
    }

    CHARMPERSONEFFECT2 : "is" "charmed" PUNCT "but" "ends" "up" "making"
        "the" "gestures" "he" "intended" "anyway"
    {
        $return = "is charmed, but ends up making the gestures he intended" .
            " anyway";
    }

    SUMMONMONSTERRESULT : "is" "summoned" "to" "serve" PLAYERNAME
    {
        my $turn = $globals->{current_turn};
        my ($is_player, $playername) = split /:/, $item{PLAYERNAME};
        my $actor = $globals->{actor};

        $globals->{monsters}{$actor}{original_owner} = $playername;
        $globals->{monsters}{$actor}{owned_by_length}{$playername} = 1;
        $globals->{monsters}{$actor}{current_owner} = $playername;
        $globals->{monsters}{$actor}{turn_summoned} = $turn;
        $globals->{monsters}{$actor}{damage_done} = {};
        $globals->{monsters}{$actor}{killed_by} = "";

        $return = "is summoned to serve $playername";
    }

    SUMMONMONSTERRESULT2 : APOSS MONSTERNAME "is" "absorbed" "into" "a"
        "Counterspell" "glow"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            next unless $player eq $actor;
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /Summon (\w+)/;
                    my ($mtype) = ($spell =~ /Summon (\w+)/);
                    next unless $item{MONSTERNAME} =~ /$mtype/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "'s $item{MONSTERNAME} is absorbed into a Counterspell" .
            " glow";
    }

    SUMMONMONSTERRESULT3 : "is" "hit" "by" "an" "Invisibility" "spell" PUNCT
        "and" "is" "annihilated" "by" "the" "magical" "overload"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next if $spell =~ /Elemental/;
                    my ($mtype) = ($spell =~ /Summon (\w+)/);
                    next unless $actor =~ /$mtype/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "is hit by an Invisibility spell, and is annihilated by" .
            " the magical overload";
    }

    SUMMONMONSTERRESULT5 : "is" "absorbed" "by" TARGET APOSS "counter" "spell"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            next unless $player eq $targetname;
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /^Summon/;
                    next if $spell =~ /Elemental/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "is absorbed by ${targetname}'s counter spell";
    }

    ATTACKRESULT : "attacks" TARGET "for" INTEGER "damage"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $actor = $globals->{actor};
        my $damage = $item{INTEGER};

        if ($globals->{actor_is_player} == 2) {
            $globals->{monsters}{$actor}{damage_done}{$targetname} += $damage;
        }

        $return = "attacks $targetname for $damage damage";
    }

    ATTACKRESULT2 : "attacks" TARGET PUNCT "but" "is" "deflected" "by" "a"
        "shield"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "attacks $targetname, but is deflected by a shield";
    }

    ATTACKRESULT6 : APOSS HANDED "hand" "stab" "is" "wasted" "at" "a"
        "monster" "which" "wasn" APOST "summoned"
    {
        $return = "'s $item{HANDED} hand stab is wasted at a monster" .
            " which wasn't summoned";
    }

    PROTECTIONRESULT : "is" "surrounded" "by" "a" "thick" "shimmering"
        "shield"
    {
        $return = "is surrounded by a thick shimmering shield";
    }

    PROTECTIONRESULT2 : APOSS "shield" "looks" "momentarily" "more" "solid"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Protection';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s shield looks momentarily more solid";
    }

    AMNESIARESULT : "starts" "to" "look" "blank"
    {
        $return = "starts to look blank";
    }

    AMNESIAEFFECT : "forgets" "what" "he" APOSS "doing" PUNCT "and" "makes"
        "the" "same" "gestures" "as" "last" "round"
    {
        $return = "forgets what he's doing, and makes the same gestures as" .
            " last round";
    }

    CONFUSIONRESULT : "looks" "a" "bit" "confused"
    {
        $return = "looks a bit confused";
    }

    CONFUSIONRESULT2 : APOSS "shield" "blurs" "for" "a" "moment"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Confusion';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s shield blurs for a moment";
    }

    CONFUSIONEFFECT : "confusedly" "makes" "the" "wrong" "gesture" "with"
        "his" HANDED "hand"
    {
        $return = "confusedly makes the wrong gesture with his" .
            " $item{HANDED} hand";
    }

    CONFUSIONEFFECT2 : "makes" "a" "confused" "gesture" PUNCT "but" "luckily"
        "it" APOSS "what" "he" "intended" "anyway"
    {
        $return = "makes a confused gesture, but luckily it's what he" .
            " intended anyway";
    }

    CHARMMONSTERRESULT : "looks" PUNCT "glassy-eyed" PUNCT "at" PLAYERNAME
    {
        my $actor = $globals->{actor};
        my ($is_player, $playername) = split /:/, $item{PLAYERNAME};

        $globals->{monsters}{$actor}{current_owner} = $playername;
        $globals->{monsters}{$actor}{owned_by_length}{$playername} += 1;
        $return = "looks, glassy-eyed, at $playername";
    }

    CHARMMONSTERRESULT2  : "ignores" TARGET APOSS "appeal" "to" "his"
        "baser" "instincts"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            next unless $player eq $targetname;
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Charm Monster';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "ignores ${targetname}'s appeal to his baser instincts";
    }

    CUREWOUNDSRESULT : "is" "healed"
    {
        $return = "is healed";
    }

    CUREWOUNDSRESULT2 : "is" "at" "maximum" "health"
    {
        $return = "is at maximum health";
    }

    MALADROITRESULT : "starts" "to" "lose" "coordination"
    {
        $return = "starts to lose coordination";
    }

    MALADROITEFFECT : "is" "rendered" "maladroit"
    {
        $return = "is rendered maladroit";
    }

    CANCELENCHANTMENT : "shakes" "his" "head" "and" "regains" "control" PUNCT
        "as" "enchantments" "cancel" "each" "other" "out"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
#DEZ                    next unless $spell eq '';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "shakes his head and regains control, as enchantments" .
            " cancel each other out";
    }

    FEARRESULT : "cringes" "in" "fear"
    {
        $return = "cringes in fear";
    }

    FEAREFFECT : "quakes" "in" "fear"
    {
        $return = "quakes in fear";
    }

    INVISRESULT : "begins" "to" "shimmer"
    {
        $return = "begins to shimmer";
    }

    INVISEFFECT : "fades" "back" "into" "visibility"
    {
        $return = "fades back into visibility";
    }

    ANTISPELLRESULT : APOSS "half-done" "spells" "fizzle" "and" "die"
    {
        $return = "'s half-done spells fizzle and die";
    }

    # counter antispell
    ANTISPELLRESULT2 : APOSS "shield" "fizzles" "slightly"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Anti-spell';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s shield fizzles slightly";
    }

    LIGHTNINGBOLTRESULT : "is" "hit" "by" "a" "bolt" "of" "lightning" PUNCT
        "for" INTEGER "damage"
    {
        $return = "is hit by a bolt of lightning, for $item{INTEGER} damage";
    }

    MAGICMIRRORRESULT : "is" "covered" "by" "a" "reflective" "shield"
    {
        $return = "is covered by a reflective shield";
    }

    CLAPOFLIGHTNINGRESULT : "tries" "to" "cast" "Clap" "of" "Lightning" PUNCT
        "but" "doesn't" "have" "the" "charge" "for" "it"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            next unless $player eq $actor;
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Clap of Lightning';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "tries to cast Clap of Lightning, but doesn't have the" .
            " charge for it";
    }

    PERMANENCYRESULT : "begins" "glowing" "faintly"
    {
        $return = "begins glowing faintly";
    }

    PERMANENCYRESULT2 : APOSS "shield" "intensifies" "momentarily"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Permanency';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s shield intensifies momentarily";
    }

    PERMANENCYEFFECT : "makes" "the" "spell" "permanent"
    {
        $return = "makes the spell permanent";
    }

    PERMANENCYEFFECT2 : "attempts" "to" "make" "the" "spell" "permanent"
    {
        $return = "attempts to make the spell permanent";
    }

    BLINDNESSRESULT : APOSS "eyes" "are" "covered" "with" "scales"
    {
        $return = "'s eyes are covered with scales";
    }

    BLINDNESSRESULT3 : "is" "hit" "by" "a" "Blindness" "spell" PUNCT "and"
        "is" "annihilated" "by" "the" "magical" "overload"
    {
        my $actor = $globals->{actor};
        if ($globals->{actor_is_player} == 2) {
          $globals->{monsters}{$actor}{killed_by} = 'Blindness';
        }
        $return = "is hit by a Blindness spell, and is annihilated by the" .
            " magical overload";
    }

    BLINDNESSRESULT4 : APOSS "shield" "disappears" "for" "a" "moment"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Blindness';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s shield disappears for a moment";
    }

    TIMESTOPRESULT : "flickers" "out" "of" "time"
    {
        $return = "flickers out of time";
    }

    TIMESTOPRESULT2 : APOSS "shield" "flickers" "for" "a" "moment"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Time Stop';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s shield flickers for a moment";
    }

    RESISTHEATRESULT : "is" "covered" "in" "a" "coat" "of" "sparkling" "frost"
    {
        $return = "is covered in a coat of sparkling frost";
    }

    RESISTHEATRESULT2 : "is" "destroyed" "by" "a" "Resist" "Heat" "spell"
    {
        my $actor = $globals->{actor};
        if ($globals->{actor_is_player} == 2) {
          $globals->{monsters}{$actor}{killed_by} = 'Resist Heat';
        }
        $return = "is destroyed by a Resist Heat spell";
    }

    REMOVEENCHANTRESULT : APOSS "surrounding" "magical" "energies" "are"
        "grounded"
    {
        $return = "'s surrounding magical energies are grounded";
    }

    REMOVEENCHANTRESULT2 : APOSS "shield" "flickers" PUNCT "but" "remains"
        "firm"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Remove Enchantment';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "'s shield flickers, but remains firm";
    }

    DISEASERESULT : "starts" "to" "look" "sick"
    {
        $return = "starts to look sick";
    }

    DISEASEEFFECT1 : APOSS "stomach" "rumbles"
    {
        $return = "'s stomach rumbles";
    }

    DISEASEEFFECT2 : "is" "a" "bit" "nauseous"
    {
        $return = "is a bit nauseous";
    }

    DISEASEEFFECT3 : "is" "looking" "pale"
    {
        $return = "is looking pale";
    }

    DISEASEEFFECT4 : "is" "having" "difficulty" "breathing"
    {
        $return = "is having difficulty breathing";
    }

    DISEASEEFFECT5 : "is" "sweating" "feverishly"
    {
        $return = "is sweating feverishly";
    }

    DISEASEEFFECT6 : "staggers" "weakly"
    {
        $return = "staggers weakly";
    }

    DISEASEEFFECT7 : "starts" "coughing" "up" "blood"
    {
        $return = "starts coughing up blood";
    }

    DISEASEEFFECT8 : APOSS "Disease" "is" "fatal"
    {
        $return = "'s Disease is fatal";
    }

    ICESTORMRESULT2 : "is" "frozen" "by" "the" "raging" "Ice" "Storm" PUNCT
        "for" INTEGER "damage"
    {
        $return = "is frozen by the raging Ice Storm, for $item{INTEGER}" .
            " damage";
    }

    ICESTORMRESULT3 : "looks" "comfortable" "in" "the" "cooling" "Ice" "Storm"
    {
        $return = "looks comfortable in the cooling Ice Storm";
    }

    ICESTORMRESULT4 : "is" "protected" "by" "a" "magical" "shield"
    {
        $return = "is protected by a magical shield";
    }

    ICESTORMRESULT5 : "is" "hit" "by" "a" "Fireball" "as" "the" "Ice" "Storm"
        "strikes" PUNCT "and" "is" "miraculously" "left" "untouched"
    {
        $return = "is hit by a Fireball as the Ice Storm strikes, and is" .
            " miraculously left untouched";
    }

    SUMMONFIRERESULT : "appears" "in" "a" "furious" "roar" "of" "flame"
    {
        $return = "appears in a furious roar of flame";
    }

    SUMMONFIRERESULT2 : "flies" "away" "with" "the" "storm"
    {
        $return = "flies away with the storm";
    }

    SUMMONFIRERESULT3 : "runs" "amok"
    {
        $return = "runs amok";
    }

    SUMMONFIRERESULT4 : "basks" "in" "the" "fiery" "heat"
    {
        $return = "basks in the fiery heat";
    }

    SUMMONFIRERESULT5 : APOSS "shield" "keeps" "the" "Fire" "Elemental" "at"
        "bay"
    {
        $return = "'s shield keeps the Fire Elemental at bay";
    }

    SUMMONFIRERESULT6 : "is" "burnt" "for" INTEGER "damage"
    {
        my $actor = $globals->{actor};
        my $damage = $item{INTEGER};
        $globals->{monsters}{'Fire Elemental'}{damage_done}{$actor} += $damage;

        $return = "is burnt for $damage damage";
    }

    SUMMONFIRERESULT7 : "melts" "the" "oncoming" "Ice" "Storm" PUNCT "and" "is"
        "destroyed" "by" "the" "ensuing" "water"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Ice Storm';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "melts the oncoming Ice Storm, and is destroyed by the" .
            " ensuing water";
    }

    SUMMONFIRERESULT10 : "runs" "around" "wildly" PUNCT "looking" "for"
        TARGET
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "runs around wildly, looking for $targetname";
    }

    FINGEROFDEATHRESULT : "is" "touched" "with" "the" "Finger" "of" "Death"
    {
        $return = "is touched with the Finger of Death";
    }

    RESISTCOLDRESULT : "is" "covered" "by" "a" "warm" "glow"
    {
        $return = "is covered by a warm glow";
    }

    FIRESTORMRESULT2 : "is" "burnt" "in" "the" "raging" "Fire" "Storm" PUNCT
        "for" INTEGER "damage"
    {
        $return = "is burnt in the raging Fire Storm, for $item{INTEGER}" .
            " damage";
    }

    FIRESTORMRESULT3 : "basks" "in" "the" "heat" "of" "the" "Fire" "Storm"
    {
        $return = "basks in the heat of the Fire Storm";
    }

    FIRESTORMRESULT4 : "flies" "away" "with" "the" "storm"
    {
        $return = "flies away with the storm";
    }

    FIRESTORMRESULT5 : "melts" PUNCT "calming" "and" "cooling" "the" "Fire"
        "Storm"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Fire Storm';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "melts, calming and cooling the Fire Storm";
    }

    POISONRESULT : "starts" "to" "look" "sick"
    {
        $return = "starts to look sick";
    }

    POISONRESULT2 : APOSS "shield" "turns" "a" "greenish" "hue" "for" "a"
        "moment"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Poison';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "'s shield turns a greenish hue for a moment";
    }

    POISONEFFECT : APOSS "Poison" "is" "fatal"
    {
        $return = "'s Poison is fatal";
    }

    HASTERESULT : "speeds" "up"
    {
        $return = "speeds up";
    }

    HASTERESULT2 : APOSS "shield" "sparkles" "rapidly" "for" "a" "moment"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};
        my $actor = $globals->{actor};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Haste';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $actor;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "'s shield sparkles rapidly for a moment";
    }

    SUMMONICERESULT : "appears" "in" "a" "sudden" "rush" "of" "arctic" "wind"
    {
        $return = "appears in a sudden rush of arctic wind";
    }

    SUMMONICERESULT2 : "enjoys" "the" "icy" "chill"
    {
        $return = "enjoys the icy chill";
    }

    SUMMONICERESULT3 : "runs" "amok"
    {
        $return = "runs amok";
    }

    SUMMONICERESULT4 : "is" "frozen" "for" INTEGER "damage"
    {
        my $actor = $globals->{actor};
        my $damage = $item{INTEGER};
        $globals->{monsters}{'Ice Elemental'}{damage_done}{$actor} += $damage;
        $return = "is frozen for $damage damage";
    }

    SUMMONICERESULT5 : APOSS "shield" "keeps" "the" "Ice" "Elemental" "at"
        "bay"
    {
        $return = "'s shield keeps the Ice Elemental at bay";
    }

    SUMMONICERESULT6 : "flies" "away" "with" "the" "storm"
    {
        $return = "flies away with the storm";
    }

    SUMMONICERESULT8 : "is" "destroyed" "by" "a" "Resist" "Cold" "spell"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /Summon Ice Elemental/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "is destroyed by a Resist Cold spell";
    }

    DELAYEFFECTRESULT : "banks" "a" "spell" "for" "later"
    {
        $return = "banks a spell for later";
    }

    PLAYERSUICIDE : "stops" "his" "heart" "through" "force" "of" "will"
        "alone"
    {
        $return = "stops his heart through force of will alone";
    }

    # these are in order by likelyhood of happening
    SPECIALTURNBODYLINES :
        SHIELDRESULT2 | MISSILERESULT2 | MISSILERESULT3 |
        COUNTERSPELLRESULT3 | SUMMONMONSTERRESULT4 | CHARMMONSTERRESULT3 |
        CAUSEWOUNDSRESULT | CAUSEWOUNDSRESULT2 | CUREWOUNDSRESULT3 |
        LIGHTNINGBOLTRESULT2 | LIGHTNINGBOLTRESULT3 | INVISRESULT2 |
        PERMANENCYEFFECT3 | BLINDNESSRESULT2 | BLINDNESSEFFECT |
        TIMESTOPEFFECT | DISPELMAGICRESULT | FIREBALLRESULT |
        FIREBALLRESULT2 | FIREBALLRESULT3 | FIREBALLRESULT4 |
        MAGICMIRRORRESULT2 | MAGICMIRRORRESULT3 | ICESTORMRESULT |
        ICESTORMRESULT6 | SUMMONFIRERESULT8 | SUMMONFIRERESULT9 |
        FIRESTORMRESULT | HASTEEFFECT | HASTEEFFECT2 | SUMMONICERESULT |
        SUMMONICERESULT3 | SUMMONICERESULT7

    SHIELDRESULT2 : "The" "shimmer" "of" "a" "shield" "briefly" "covers"
        "the" "circle" PUNCT "then" "dissolves"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Shield';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} =~ /nobody/i;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "The shimmer of a shield briefly covers the circle," .
            " then dissolves"
    }

    MISSILERESULT2 : "A" "magic" "missile" "bounces" "off" TARGET APOSS
        "shield"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Magic Missile';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $targetname;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A magic missile bounces off ${targetname}'s shield";
    }

    MISSILERESULT3 : "A" "magic" "missile" "flies" "off" "into" "the"
        "distance"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Magic Missile';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} =~ /nobody/i;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A magic missile flies off into the distance";
    }

    COUNTERSPELLRESULT3 : "A" SPELLNAME "drifts" "away" "aimlessly"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq $item{SPELLNAME};
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} =~ /nobody/i;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A " . $item{SPELLNAME} . " drifts away aimlessly";
    }

    SUMMONMONSTERRESULT4 : "A" "summoned" "creature" PUNCT "finding" "no"
        "master" PUNCT "returns" "from" "whence" "it" "came"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /^Summon/;
                    next if $spell =~ /Elemental/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} =~ /nobody/i;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A summoned creature, finding no master, returns from" .
            " whence it came";
    }

    CHARMMONSTERRESULT3  : "The" "haze" "of" "an" "enchantment" "spell"
        "drifts" "aimlessly" "over" "the" "circle" PUNCT "and" "dissipates"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Charm Monster';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} =~ /nobody/i;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "The haze of an enchantment spell drifts aimlessly" .
            " over the circle, and dissipates";
    }

    CAUSEWOUNDSRESULT : "Wounds" "appear" "all" "over" TARGET APOSS "body"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        $return = "Wounds appear all over ${targetname}'s body";
    }

    CAUSEWOUNDSRESULT2 : "Holes" "open" "up" "in" TARGET APOSS "shield" PUNCT
        "but" "then" "close" "up" "again"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /Cause (Light|Heavy) Wounds/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $targetname;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "Holes open up in ${targetname}'s shield, but then close" .
            " up again";
    }

    CUREWOUNDSRESULT3 : "Tiny" "holes" "in" TARGET APOSS "shield" "are"
        "sealed" "up"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /Cure (Light|Heavy) Wounds/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $targetname;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "Tiny holes in ${targetname}'s shield are sealed up";
    }

    LIGHTNINGBOLTRESULT2 : "A" "bolt" "of" "lightning" "arcs" "to" "the"
        "ground"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /Lightning/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} =~ /nobody/i;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A bolt of lightning arcs to the ground";
    }

    LIGHTNINGBOLTRESULT3 : "Lightning" "sparks" "all" "around" TARGET APOSS
        "shield"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /Lightning/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $targetname;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "Lightning sparks all around ${targetname}'s shield";
    }

    INVISRESULT2 : "There" "is" "a" "flash" PUNCT "and" PLAYERNAME
        "disappears"
    {
        my ($is_player, $playername) = split /:/, $item{PLAYERNAME};
        $return = "There is a flash, and $playername disappears";
    }

    PERMANENCYEFFECT3 : "The" "permanent" "enchantment" "on" TARGET
        "overrides" "the" SPELLNAME "effect"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq $item{SPELLNAME};
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $targetname;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "The permanent enchantment on $targetname overrides" .
            " the $item{SPELLNAME} effect";
    }

    BLINDNESSRESULT2 : "Scales" "start" "to" "grow" "over" PLAYERNAME APOSS
        "eyes"
    {
        my ($is_player, $playername) = split /:/, $item{PLAYERNAME};
        $return = "Scales start to grow over ${playername}'s eyes";
    }

    BLINDNESSEFFECT : "The" "scales" "are" "removed" "from" PLAYERNAME APOSS
        "eyes"
    {
        my ($is_player, $playername) = split /:/, $item{PLAYERNAME};
        $return = "The scales are removed from ${playername}'s eyes";
    }

    TIMESTOPEFFECT : "This" "turn" "took" "place" "outside" "of" "time"
    {
        $return = "This turn took place outside of time";
    }

    DISPELMAGICRESULT : "All" "magical" "effects" "are" "erased" PUNCT "All"
        "other" "spells" "fail"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next if $spell eq 'Dispel Magic';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        $spell_info->{success} = 0;
                    }
                }
            }
        }

        $return = "All magical effects are erased! All other spells fail";
    }

    FIREBALLRESULT : "A" "fireball" "strikes" TARGET PUNCT "burning" "him"
        "for" INTEGER "damage"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "A fireball strikes $targetname, burning him for" .
            " $item{INTEGER} damage";
    }

    FIREBALLRESULT2 : "A" "fireball" "strikes" PUNCT "and" "flames" "roar"
        "all" "around" TARGET APOSS "shield"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Fireball';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $targetname;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A fireball strikes, and flames roar all around" .
            " ${targetname}'s shield";
    }

    FIREBALLRESULT3 : "A" "fireball" "strikes" PUNCT "and" "flames" "roar"
        "around" TARGET PUNCT "He" "stands" "calmly" "in" "the" "inferno"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Fireball';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} eq $targetname;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A fireball strikes, and flames roar around" .
            " $targetname. He stands calmly in the inferno";
    }

    FIREBALLRESULT4 : "A" "fireball" "flies" "into" "the" "distance" "and"
        "burns" "itself" "out"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Fireball';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} =~ /nobody/i;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A fireball flies into the distance and burns itself out";
    }

    MAGICMIRRORRESULT2 : "The" SPELLNAME "spell" "is" "reflected" "from"
        TARGET APOSS "Magic" "Mirror"
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        $return = "The $item{SPELLNAME} spell is reflected from" .
            " ${targetname}'s Magic Mirror";
    }

    MAGICMIRRORRESULT3 : "A" "Magic" "Mirror" "dissipates" "into" "the" "air"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell eq 'Magic Mirror';
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        next unless $spell_info->{target} =~ /nobody/i;
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                            last;
                        }
                    }
                }
            }
        }

        $return = "A Magic Mirror dissipates into the air";
    }

    ICESTORMRESULT : "An" "Ice" "Storm" "rages" "through" "the" "circle"
    {
        $return = "An Ice Storm rages through the circle";
    }

    ICESTORMRESULT6 : "Fire" "and" "Ice" "storms" "cancel" "each" "other"
        "out" PUNCT "leaving" "just" "a" "gentle" "breeze"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /Storm/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "Fire and Ice storms cancel each other out, leaving just" .
            " a gentle breeze";
    }

    SUMMONFIRERESULT8 : "Opposing" "Elementals" "destroy" "each" "other"
    {
        my $turn = $globals->{current_turn};
        my $turnlist = $globals->{turnlist};

        foreach my $player (keys %{$turnlist->[$turn]}) {
            next if $player eq 'gametext';
            my $spell_list = $turnlist->[$turn]{$player}{spells};
            if ($spell_list) {
                foreach my $spell (keys %{$spell_list}) {
                    next unless $spell =~ /Summon (\w+) Elemental/;
                    my $slength = scalar @{$spell_list->{$spell}};
                    while ($slength) {
                        my $spell_info = $spell_list->{$spell}->[--$slength];
                        if ($spell_info->{success}) {
                            $spell_info->{success} = 0;
                        }
                    }
                }
            }
        }

        $return = "Opposing Elementals destroy each other";
    }

    SUMMONFIRERESULT9 : "Two" "Fire" "Elementals" "merge" "into" "one"
    {
        $return = "Two Fire Elementals merge into one";
    }

    FIRESTORMRESULT : "A" "Fire" "Storm" "rages" "through" "the" "circle"
    {
        $return = "A Fire Storm rages through the circle";
    }

    HASTEEFFECT : "Fast" "players" "sneak" "in" "an" "extra" "set" "of"
        "gestures"
    {
        $return = "Fast players sneak in an extra set of gestures";
    }

    HASTEEFFECT2 : "Fast" "warlocks" "sneak" "in" "an" "extra" "set" "of"
        "gestures"
    {
        $return = "Fast warlocks sneak in an extra set of gestures";
    }

    SUMMONICERESULT7 : "Two" "Ice" "Elementals" "merge" "into" "one"
    {
        $return = "Two Ice Elementals merge into one";
    }

    GAMEOUTCOME : IGNOBLEEND | TARGETOUTCOME

    IGNOBLEEND : "No" "Warlocks" "remaining" PUNCT "An" "ignominious" "end"
        "to" "a" "battle"
    {
        $return = "No Warlocks remaining. An ignominious end to a battle";
    }

    TARGETOUTCOME : TARGET POSSIBLEOUTCOME
    {
        my ($is_player, $targetname) = split /:/, $item{TARGET};

        if ($is_player == 1 && grep {$_ eq $targetname} @{$globals->{players}}) {
            $globals->{$targetname}{num_turns} = $globals->{current_turn};
            if ($item{POSSIBLEOUTCOME} =~ /victorious/) {
                $globals->{$targetname}{winner} = 1;
                $globals->{winner} = $targetname;
            } elsif ($item{POSSIBLEOUTCOME} =~ /dies/) {
                $globals->{$targetname}{died} = 1;
            } else {
                $globals->{$targetname}{surrendered} = 1;
            }
        }

        $return = $targetname . " " . $item{POSSIBLEOUTCOME};
    }

    POSSIBLEOUTCOME : "dies" | ISVICTORIOUS | "surrenders"

    ISVICTORIOUS : "is" "victorious"
    {
        $return = "is victorious";
    }

    PUNCT : /[.!,]/

    MONSTERLIST : MONSTERNAME HEALTH DASH(?) AFFECTEDBYITEM(s?) "Owned" "by"
        COLON PLAYERTARGET "Attacking" COLON TARGET
    {
        my $dash = $item{DASH} ? ' - ' : '';
        my ($is_player_target, $targetname) = split /:/, $item{TARGET};
        my ($is_player_owner, $playername) = split /:/, $item{PLAYERTARGET};

        $return = $item{MONSTERNAME} . " " . $item{HEALTH} . $dash;
        if ($item{AFFECTEDBYITEM}) {
            $return .= join(' ', @{$item{AFFECTEDBYITEM}});
        }
        $return .= " Owned by : $playername Attacking : $targetname";

    }

    HEALTH : PARENDS(?) "Health" COLON INTEGER PARENDS(?)
    {
        if ($item{PARENDS}) {
            $return = "(Health: " . $item{INTEGER} . ")";
        } else {
            $return = "Health: " . $item{INTEGER};
        }
    }

    COLON : ":"

    AFFECTEDBYITEM : AFFECTEDBYTYPE PARENDS DURATION PARENDS
    {
        $return = $item{AFFECTEDBYTYPE} . "(" . $item{DURATION} . ")";
    }

    AFFECTEDBYTYPE : "Afraid" | "Blindness" | "Charmed" | "Coldproof" |
        "Confused" | "Delay" | "Disease" | "Fireproof" | "Forgetful" |
        "Haste" | "Invisibility" | "Maladroit" | "MShield" | "Paralysed" |
        "Permanency" | "Poison" | "Shield" | "TimeOut"

    DURATION : INTEGER | /permanent/i

    PLAYERLIST : LISTOFPLAYERS

    PLAYERLINES : PLAYERREGISTERED(?) PLAYERNAME PARENDS INTEGER PARENDS
        SURRENDERORDEAD(?) HEALTH(?) DASH(?) AFFECTEDBYITEM(s?) BANKEDSPELL(?)
        TURNLIST PLAYERGESTURES
    {
        my ($is_player, $player) = split /:/, $item{PLAYERNAME};
        my $gestures = $item{PLAYERGESTURES};

        ($globals->{$player}{gestures}{left}) =
            ($gestures =~ /LH[:]B(.*?)\n/s);
        ($globals->{$player}{gestures}{right}) =
            ($gestures =~ /RH[:]B(.*?)\n+/s);

        if ($item{PLAYERREGESTERED}) {
            $return = "Registered! ";
        } else {
            $return = "";
        }

        $return .= $player . "(" . $item{INTEGER} . ")";
        if ($item{SURRENDERORDEAD}) {
            $return .= " $item{SURRENDERORDEAD}";
        }
        if ($item{HEALTH}) {
            $return .= " $item{HEALTH}";
        }
        if ($item{DASH}) {
            $return .= " $item{DASH}";
        }
        if ($item{AFFECTEDBYITEM}) {
            $return .= join(' ', @{$item{AFFECTEDBYITEM}});
        }
        if ($item{BANKEDSPELL}) {
            $return .= " $item{BANKEDSPELL}";
        }
        $return .= "\n$item{TURNLIST}";
        $return .= "\n$item{PLAYERGESTURES}";
    }

    PLAYERREGISTERED : "Registered" PUNCT
    {
        $return = "Registered!";
    }

    SURRENDERORDEAD : PLAYERSURRENDERED | PLAYERDEAD

    PLAYERSURRENDERED : "Surrendered" PUNCT
    {
        $return = "Surrendered.";
    }

    PLAYERDEAD : "Dead" PUNCT
    {
        $return = "Dead.";
    }

    BANKEDSPELL : PARENDS "Banked" COLON SPELLNAME PARENDS
    {
      $return = "(Banked: " . $item{SPELLNAME} . ")";
    }

    TURNLIST : "Turn" COLON TURNNUMBERS
    {
        $return = "Turn:" . $item{TURNNUMBERS};
    }

    TURNNUMBERS : INTEGER INTEGER(s?)
    {
        $return = $item[1];
        if ($item[2]) {
            $return .= join(' ', @{$item[2]});
        }
    }

    PLAYERGESTURES : /\s*LH[:]B(.*?)RH[:]B(.*?)\n(\n|\z)/ms

    EOFILE : /[\n\s]*/ms
    {
        1;
    }

_EOGRAMMAR_
;

sub new
{
    my $class = shift;

    my $self = {};

    bless $self, $class;

    return $self;
}

sub get_data
{
    delete $globals->{actor_is_player};
    delete $globals->{actor};
    return $globals;
}

sub reset_data
{
    $globals = {};
    $globals->{turnlist} = [];
}

sub parse
{
    my $parser;

    eval {
        $parser = Parse::RecDescent->new(GRAMMAR);
    };

    if ($@) {
        die($@);
    }

    return $parser->startrule($_[1]);
}

sub trace
{
    my ($self, $setting) = @_;

    if ($setting) {
        $::RD_HINT = 'defined';
        $::RD_TRACE = 'defined';
    } else {
        undef $::RD_HINT;
        undef $::RD_TRACE;
    }

    return $self;
}

1;

# vi: set shiftwidth=4 softtabstop=4 et!: #
