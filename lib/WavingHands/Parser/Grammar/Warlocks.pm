package WavingHands::Parser::Grammar::Warlocks;

=head1 NAME

WavingHands::Parser::Grammar::Warlocks - Grammar for games from L<Warlocks|http://games.ravenblack.net>

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our $globals = {};

use Parse::RecDescent;
use JSON;

=head1 SYNOPSIS

    This module provides the grammar for parsing games from L<Warlocks|http://games.ravenblack.net>

=head1 CONSTANTS

    GRAMMAR - Is the Parse::RecDescent grammar in the initial state.  During parsing, the PLAYERNAME rule
              is created to match the player names specific to the game being parsed.

=head1 FUNCTIONS

=head2 new

    Creates a new parser object.

=head2  get_data

    Returns the data hash.  This hash contains information about the game.  An array of turns, etc.

=head2 reset_data

    Resets the data hash.

=head2 parse

    Parses a game.

=head2 trace

    If passed a true value, turns on Parse::RecDescent tracing and hints.

=cut

use constant GRAMMAR => << '_EOGRAMMAR_'
    {
        # autoflush
        $| = 1;

        # skip whitespace, newlines and emptystring
        $Parse::RecDescent::skip = qr/[\s\n]*/s;

        # pull in outer globals variable
        my $globals = $WavingHands::Parser::Grammar::Warlocks::globals;
    }

    INTEGER : /\d+/

    BOWNAME : /\b\w+\b/

    PLAYERNAME : "__NoSuChPlAyEr__"

    ARTICLE : /(the\s)|(an?\s)/i

    PARAFC : PARENDS "ParaFC" PARENDS
    {
        "ParaFC";
    }

    PARAFDF : PARENDS "ParaFDF" PARENDS
    {
        "ParaFDF";
    }

    MALADROIT : PARENDS "Maladroit" PARENDS
    {
        "Maladroit";
    }

    LADDER : "Ladder"
    {
        "Ladder";
    }

    VERYFRIENDLY : VERY FRIENDLY
    {
        "Very Friendly";
    }

    FRIENDLY : "Friendly"
    {
        "Friendly";
    }

    MELEE : "Melee"
    {
        "Melee";
    }

    WOUNDS : "Wounds"

    LIGHT : "Light"

    LIGHTNING : "Lightning"

    ELEMENTAL : /Elementals?/

    MAGIC : /magic/i

    SUMMON : "Summon"

    STORM : "Storm"

    LOOKS : "looks"

    HEAVY : "Heavy"

    AMNESIA : "Amnesia"

    ANTISPELL : "Anti-spell"

    BLINDNESS : "Blindness"

    CAUSEHEAVYWOUNDS : "Cause" HEAVY WOUNDS
    {
        $return = "Cause Heavy Wounds";
    }

    CAUSELIGHTWOUNDS : "Cause" LIGHT WOUNDS
    {
        $return = "Cause Light Wounds";
    }

    CHARMMONSTER : "Charm" "Monster"
    {
        $return = "Charm Monster";
    }

    CHARMPERSON : "Charm" "Person"
    {
        $return = "Charm Person";
    }

    CLAPOFLIGHTNING : "Clap" OF LIGHTNING
    {
        $return = "Clap of Lightning";
    }

    CONFUSION : "Confusion"

    COUNTERSPELL : "Counter" "Spell"
    {
        $return = "Counter Spell";
    }

    CUREHEAVYWOUNDS : "Cure" HEAVY WOUNDS
    {
        $return = "Cure Heavy Wounds";
    }

    CURELIGHTWOUNDS : "Cure" LIGHT WOUNDS
    {
        $return = "Cure Light Wounds";
    }

    DELAYEFFECT : "Delay" "Effect"
    {
        $return = "Delay Effect";
    }

    DISEASE : "Disease"

    DISPELMAGIC : "Dispel" MAGIC
    {
        $return = "Dispel Magic";
    }

    FEAR : "Fear"

    FINGEROFDEATH : "Finger" OF "Death"
    {
        $return = "Finger of Death";
    }

    FIREBALL : "Fireball"

    FIRESTORM : FIRE STORM
    {
        $return = "Fire Storm";
    }

    HASTE : "Haste"

    ICESTORM : ICE STORM
    {
        $return = "Ice Storm";
    }

    INVISIBILITY : "Invisibility"

    LIGHTNINGBOLT : LIGHTNING "Bolt"
    {
        $return = "Lightning Bolt";
    }

    MAGICMIRROR : MAGIC "Mirror"
    {
        $return = $item{MAGIC} . " Mirror";
    }

    MAGICMISSILE : MAGIC /missile/i
    {
        $return = $item{MAGIC} . " " . $item[2];
    }

    MALADROITNESS : "Maladroitness"

    PARALYSIS : "Paralysis"

    PERMANENCY : "Permanency"

    POISON : "Poison"

    PROTECTION : "Protection"

    REMOVEENCHANTMENT : "Remove" "Enchantment"
    {
        $return = "Remove Enchantment";
    }

    RESISTCOLD : "Resist" "Cold"
    {
        $return = "Resist Cold";
    }

    RESISTHEAT : "Resist" "Heat"
    {
        $return = "Resist Heat";
    }

    SHIELDSPELL : "Shield"

    SUMMONFIREELEMENTAL : SUMMON FIRE ELEMENTAL
    {
        $return = "Summon Fire Elemental";
    }

    SUMMONGIANT : SUMMON "Giant"
    {
        $return = "Summon Giant";
    }

    SUMMONGOBLIN : SUMMON "Goblin"
    {
        $return = "Summon Goblin";
    }

    SUMMONICEELEMENTAL : SUMMON ICE ELEMENTAL
    {
        $return = "Summon Ice Elemental";
    }

    SUMMONOGRE : SUMMON "Ogre"
    {
        $return = "Summon Ogre";
    }

    SUMMONTROLL : SUMMON "Troll"
    {
        $return = "Summon Troll";
    }

    TIMESTOP : "Time" "Stop"
    {
        $return = "Time Stop";
    }

    BOWS : "bows"

    COLON : ":"

    CAST : /casts?/

    AT : "at"

    TURN : "Turn"

    LEFT : "left"

    RIGHT : "right"

    HIS : "his"

    APOSS : "'s"

    PUNCT : /[.!,]/

    HAND : "hand"

    FINGERS : "wiggles" THE "fingers" OF
    {
        $return = "F";
    }

    PALM : "proffers" THE "palm" OF
    {
        $return = "P";
    }

    SNAPS : "snaps" THE "fingers" OF
    {
        $return = "S";
    }

    WAVES : "waves"
    {
        $return = "W";
    }

    POINTS : "points" THE "digit" OF
    {
        $return = "D";
    }

    PLAYERSTAB : "stabs"
    {
        $return = ">";
    }

    NOGESTURE : "makes" NO GESTURE
    {
        $return = "-";
    }

    HALFCLAP : "flailingly" "half-claps"
    {
        $return = 'C';
    }

    gesturetype : POINTS | SNAPS | WAVES | FINGERS | PALM | HALFCLAP | PLAYERSTAB | NOGESTURE

    CLAPS : "claps"
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{active_player};

        $globals->{turnlist}[$turn]->{$player}{gesture}{right} = 'C';
        $globals->{turnlist}[$turn]->{$player}{gesture}{left} = 'C';

        $return = "claps";
    }

    GESTURE : /gestures?/

    playertarget : /himself|nobody|everyone|someone/i | PLAYERNAME

    target : playertarget | monstertarget

    monster : MONSTERNAME HEALTH DASH(?) AFFECTEDBY(?) "Owned" "by" COLON playertarget "Attacking" COLON target
    {
        my $dash = $item{DASH} ? ' - ' : '';
        my $affectedby = $item{AFFECTEDBY} ? " " . $item{AFFECTEDBY} : '';

        $return = $item{MONSTERNAME} . " " . $item{HEALTH} . $dash . $affectedby . " Owned by : " . $item{playertarget} . " Attacking : " . $item{target};
    }

    REGISTERED : "Registered" PUNCT
    {
        $return = "Registered!";
    }

    DEAD : "Dead" PUNCT
    {
        $return = "Dead.";
    }

    TURNNUMBERS : INTEGER INTEGER(s?)
    {
        $return = $item[1];
        if ($item[2]) {
            $return .= join(' ', @{$item[2]});
        }
    }

    TURNLIST : TURN COLON TURNNUMBERS
    {
        $return = "Turn:" . $item{TURNNUMBERS};
    }

    PLAYERGESTURES : /\s*LH[:]B(.*?)RH[:]B(.*?)\n(\n|\z)/ms

    PARENDS : /[()]/

    HEALTH : PARENDS(?) "Health" COLON INTEGER PARENDS(?)
    {
        if ($item{PARENDS}) {
            $return = "(Health: " . $item{INTEGER} . ")";
        } else {
            $return = "Health: " . $item{INTEGER};
        }
    }

    SURRENDERED : "Surrendered" PUNCT
    {
        $return = "Surrendered.";
    }

    DASH : "-"

    AFFECTEDBYTYPE : /Afraid|Blindness|Charmed|Coldproof|Confused|Delay|Disease|Fireproof|Forgetful|Haste|Invisibility|Maladroit|MShield|Paralysed|Permanency|Poison|Shield|TimeOut/

    PERMANENT : "permanent"

    DURATION : INTEGER | PERMANENT

    AFFECTEDBYITEM : AFFECTEDBYTYPE PARENDS DURATION PARENDS
    {
        $return = $item{AFFECTEDBYTYPE} . "(" . $item{DURATION} . ")";
    }

    AFFECTEDBY : AFFECTEDBYITEM(s?)
    {
      if ($item{AFFECTEDBYITEM}) {
          $return = join(' ', @{$item{AFFECTEDBYITEM}});
      } else {
          $return = "";
      }
    }

    BANKEDSPELL : PARENDS "Banked" COLON SPELLNAME PARENDS
    {
      $return = "(Banked: " . $item{SPELLNAME} . ")";
    }

    SURRENDERORDEAD : SURRENDERED | DEAD

    player: REGISTERED(?) PLAYERNAME PARENDS INTEGER PARENDS SURRENDERORDEAD(?) HEALTH(?) DASH(?) AFFECTEDBY BANKEDSPELL(?) TURNLIST PLAYERGESTURES
    {
        my $player = $item{PLAYERNAME};
        my $gestures = $item{PLAYERGESTURES};

        ($globals->{$player}{gestures}{left}) = ($gestures =~ /LH[:]B(.*?)\n/s);
        ($globals->{$player}{gestures}{right}) = ($gestures =~ /RH[:]B(.*?)\n+/s);

        if ($item{REGISTERED}) {
            $return = "Registered! ";
        } else {
            $return = "";
        }

        $return .= $item{PLAYERNAME} . "(" . $item{INTEGER} . ")";
        if ($item{SURRENDERORDEAD}) {
            $return .= " $item{SURRENDERORDEAD}";
        }
        if ($item{HEALTH}) {
            $return .= " $item{HEALTH}";
        }
        if ($item{DASH}) {
            $return .= " $item{DASH}";
        }
        if ($item{AFFECTEDBY}) {
            $return .= " $item{AFFECTEDBY}";
        }
        if ($item{BANKEDSPELL}) {
            $return .= " $item{BANKEDSPELL}";
        }
        $return .= "\n$item{TURNLIST}";
        $return .= "\n$item{PLAYERGESTURES}";
    }

    listofplayers : "-ShOuLdNeVeRmAtCh-"

    playerlist : listofplayers

    TURNBODY : TURNBODYTYPES PUNCT
    {
        my $turn = $globals->{current_turn};
        my $turntext = $item{TURNBODYTYPES} . $item{PUNCT};

        $globals->{turnlist}[$turn]->{gametext} .= ($globals->{turnlist}[$turn]->{gametext} ? "\n" : "") . $turntext;
    }

    turnsection : TURNLINE TURNBODY(s?)
    {
        $return = $item{TURNLINE} . "\n";
        if ($item{TURNBODY}) {
            $return .= join("\n", @{$item{TURNBODY}});
        }

        1;
    }

    eofile : /[\n\s]*/ms
    {
        1;
    }

    startrule : preamble turnsection(s) monster(s?) playerlist eofile

    turnsingame : /(?:.*?)Turn \d+ in/ms

    preamble : turnsingame gametype modifier(s?) "Battle" gameid
    {
        $return = $item{turnsingame} . " " . $item{gametype};

        if ($item{modifier}) {
            $return .= " " . $item{modifier};
        }

        $return .= " Battle " . $item{gameid};
    }

    modifier : PARAFC | PARAFDF | MALADROIT
    {
        push @{$globals->{game_modifiers}}, $item[1];

        $return = $item[1];
    }

    formoney : LADDER | MELEE

    forpride : VERYFRIENDLY | FRIENDLY

    gametype : formoney | forpride
    {
        $globals->{gametype} = $item[1];
    }

    gameid : INTEGER
    {
        $globals->{gameid} = $item{INTEGER};
        $return = $item{INTEGER};
    }

    TURNLINE : TURN INTEGER
    {
        my $turn = $item{INTEGER};

        if ($turn == 1) {
            # create regex for matching playernames exactly and replace the generic one.
            my @players =  sort{length "$b" <=> length "$a"} @{$globals->{players}};
            my $playercount = scalar @players;
            if ($playercount > 2) {
                $globals->{melee_game} = 1;
            }
            local ($1);
            my $rule = sprintf ("PLAYERNAME : /\\b\(%s\)\\b/", (join '|', @players));
            my $rule2 = "listofplayers : player($playercount)";
            $rule =~ /^(.*)\z/s;
            eval {
                $rule = $1;
                $thisparser->Extend($rule);
            };
            die $@ if $@;
            $rule2 =~ /^(.*)\z/s;
            eval {
                $rule2 = $1;
                $thisparser->Extend($rule2);
            };
            die $@ if $@;
        }

        $globals->{turnlist}[$turn] = {};
        $globals->{current_turn} = $turn;

        $return = "Turn $turn";
    }

    DIES : "dies"

    VICTORIOUS : IS "victorious"
    {
        $return = "is victorious";
    }

    SURRENDERS : "surrenders"

    IGNOBLEEND : NO "Warlocks" "remaining" PUNCT AN "ignominious" "end" TO A "battle"
    {
        $return = "No Warlocks remaining. An ignominous end to a battle";
    }

    possibleoutcome : DIES | VICTORIOUS | SURRENDERS

    targetoutcome : target possibleoutcome
    {
        if (grep {$_ eq $item{target}} @{$globals->{players}}) {
            if ($item{possibleoutcome} =~ /victorious/) {
                $globals->{$item{target}}{winner} = 1;
                $globals->{winner} = $item{target};
            } elsif ($item{possibleoutcome} =~ /dies/) {
                $globals->{$item{target}}{died} = 1;
            } else {
                $globals->{$item{target}}{surrendered} = 1;
            }
        }

        $return = $item{target} . " " . $item{possibleoutcome};
    }

    gameoutcome : IGNOBLEEND | targetoutcome

    playername : PLAYERNAME
    {
        $globals->{active_player} = $item{PLAYERNAME};
        $item{PLAYERNAME};
    }

    PLAYERSPEECH : "says" /"(.*?)"\.\n/sm
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{active_player};

        local $1;
        $item[2] =~ /"(.*)"/;
        my $speech_text = '';
        eval {
            $speech_text = $1;
        };
        $globals->{turnlist}[$turn]->{$player}{speech} = $speech_text;

        # put the period back on the text block so that PUNCT rule succeeds
        $text = '.' . $text;

        $return = "says \"$speech_text\"";
    }

    playeractiontypes : playergesture | playercast | directmonster | PLAYERSPEECH | CLAPS | notarget | attackmiss | attackline

    playerturn : playername playeractiontypes
    {
        $return = $item{playername} . " " . $item{playeractiontypes};
    }

    PLAYERBOWS : BOWNAME BOWS
    {
        my $player = $item[1];
        push @{$globals->{players}}, $player;

        $globals->{turnlist}[0]->{$player}{gesture}{left} = 'B';
        $globals->{turnlist}[0]->{$player}{gesture}{right} = 'B';
        $return = "$player bows";
    }

    ANORA : AN | A

    STORMRAGES : ANORA STORMTYPE STORM "rages" "through" THE "circle"
    {
        $return = join(' ', ($item{ANORA}, $item{STORMTYPE}, $item{STORM}, "rages through the circle"));
    }

    WOUNDED : WOUNDS "appear" ALL OVER target APOSS "body"
    {
        $return = "Wounds appear all over " . $item{target} . "'s body";
    }

    BOUNCEMISSILE : A MAGICMISSILE "bounces" "off" target APOSS SHIELD
    {
        $return = "A " . $item{MAGICMISSILE} . " bounces off " . $item{target} . "'s shield";
    }

    GOESPOOF : "There" IS A "flash" PUNCT AND PLAYERNAME "disappears"
    {
        $return = "There is a flash, and " . $item{PLAYERNAME} . " disappears";
    }

    SPELLSFAIL : "All" MAGICAL "effects" ARE "erased" PUNCT "All" "other" SPELL "fail"
    {
        $return = "All magical effects are erased! All other spells fail";
    }

    REFLECTSPELL : THE SPELLNAME SPELL IS "reflected" FROM target APOSS MAGICMIRROR
    {
        $return = "The " . $item{SPELLNAME} . " spell is reflected from " . $item{target} . "'s " . $item{MAGICMIRROR};
    }

    SCALESGROW : "Scales" "start" TO "grow" OVER PLAYERNAME APOSS "eyes"
    {
        $return = "Scales start to grow over " . $item{PLAYERNAME} . "'s eyes";
    }

    SCALESREMOVED : THE "scales" ARE "removed" FROM PLAYERNAME APOSS "eyes"
    {
        $return = "The scales are removed from " . $item{PLAYERNAME} . "'s eyes";
    }

    HOLESOPEN : "Holes" "open" UP IN target APOSS SHIELD PUNCT BUT "then" "close" UP "again"
    {
        $return = "Holes open up in " . $item{target} . "'s shield, but then close up again";
    }

    MISSILEFLIES : A MAGICMISSILE "flies" "off" INTO THE "distance"
    {
        $return = "A " . $item{MAGICMISSILE} . " flies off into the distance";
    }

    HAZEENCHANT : THE "haze" OF AN "enchantment" SPELL "drifts" "aimlessly" OVER THE "circle" PUNCT AND "dissipates"
    {
        $return = "The haze of an enchantment spell drifts aimlessly over the circle, and dissipates.";
    }

    LIGHTNINGARCS : A "bolt" OF "lightning" "arcs" TO THE "ground"
    {
        $return = "A bolt of lightning arcs to the ground";
    }

    SPELLDRIFTS : A SPELLNAME "drifts" "away" "aimlessly"
    {
        $return = "A " . $item{SPELLNAME} . " drifts away aimlessly";
    }

    TINYHOLES : "Tiny" "holes" IN target APOSS SHIELD ARE "sealed" UP
    {
        $return = "Tiny holes in " . $item{target} . "'s shield are sealed up";
    }

    FASTGUYS : "players" | "warlocks"

    FASTPLAYERS : "Fast" FASTGUYS "sneak" IN AN "extra" "set" OF GESTURE
    {
        $return = "Fast " . $item{FASTGUYS} . " sneak in an extra set of gestures";
    }

    TURNOUTSIDETIME : "This" "turn" "took" "place" "outside" OF "time"
    {
        $return = "This turn took place outside of time";
    }

    FIREBALLSHIELD: ALL "around" target APOSS SHIELD
    {
        $return = ", and flames roar all around " . $item{target} . "'s shield";
    }

    FIREBALLCALM : "around" target PUNCT CALMINFERNO
    {
        $return = ", and flames roar around " . $item{target} . ". " . $item{CALMINFERNO};
    }

    FIREBALLRESISTTYPE : FIREBALLSHIELD | FIREBALLCALM

    FIREBALLRESIST : PUNCT AND "flames" "roar" FIREBALLRESISTTYPE
    {
        $return = ", and flames roar around " . $item{FIREBALLRESISTTYPE};
    }

    FIREBALLHITS : target PUNCT "burning" "him" FOR INTEGER DAMAGE
    {
        $return = $item{target} . ", burning him for " . $item{INTEGER} . " damage";
    }

    FIREBALLSTRIKETYPE : FIREBALLRESIST | FIREBALLHITS

    FIREBALLSTRIKES : "strikes" FIREBALLSTRIKETYPE
    {
        $return = "strikes " . $item{FIREBALLSTRIKETYPE};
    }

    FIREBALLFLIES : "flies" INTO THE "distance" AND "burns" "itself" "out"
    {
        $return = "flies into the distance and burns itself out";
    }

    FIREBALLOUTCOME : FIREBALLFLIES | FIREBALLSTRIKES

    FIREBALLLANDS : A "fireball" FIREBALLOUTCOME
    {
        $return = "A fireball " . $item{FIREBALLOUTCOME};
    }

    CALMINFERNO : "He" "stands" "calmly" "in" THE "inferno"
    {
        $return = "He stands calmly in the inferno";
    }

    LIGHTNINGSPARKS : LIGHTNING "sparks" ALL "around" target APOSS SHIELD
    {
        $return = $item{LIGHTNING} . " sparks all around " . $item{target} . "'s shield";
    }

    PERMOVERRIDE : THE PERMANENT "enchantment" ON target "overrides" THE SPELLNAME "effect"
    {
        $return = "The permanent enchantment on " . $item{target} . " overrides the " . $item{SPELLNAME} . " effect";
    }

    MIRRORDISSIPATE : A MAGICMIRROR "dissipates" INTO THE "air"
    {
        $return = "A " . $item{MAGICMIRROR} . " dissipates into the air";
    }

    ELEMENTALDESTROY : "Opposing" ELEMENTAL "destroy" "each" "other"
    {
        $return = "Opposing elementals destroy each other";
    }

    SHIMMERSHIELD : THE "shimmer" OF A SHIELD "briefly" "covers" THE "circle" PUNCT "then" "dissolves"
    {
        $return = "The shimmer of a shield briefly covers the circle, then dissolves";
    }

    ELEMENTALMERGE : "Two" STORMTYPE ELEMENTAL "merge" INTO "one"
    {
        $return = "Two " . $item{STORMTYPE} . " elementals merge into one";
    }

    ELEMENTALCANCEL : FIRE AND ICE "storms" "cancel" "each" "other" "out" PUNCT "leaving" "just" "a" "gentle" "breeze"
    {
        $return = "Fire and Ice storms cancel each other out, leaving just a gentle breeze";
    }

    BURSTOFSPEED : IN A "burst" OF "speed" PUNCT
    {
        $return = "In a burst of speed,";
    }

    NOMASTER : A SUMMONED "creature" PUNCT "finding" "no" "master" PUNCT "returns" "from" "whence" IT "came"
    {
        $return = "A summoned creature, finding no master, returns from whence it came";
    }

    specialtypes : NOMASTER | TURNOUTSIDETIME | ELEMENTALCANCEL | ELEMENTALMERGE | FIREBALLLANDS | SHIMMERSHIELD | ELEMENTALDESTROY | MIRRORDISSIPATE | PERMOVERRIDE | LIGHTNINGSPARKS | FASTPLAYERS | TINYHOLES | SPELLDRIFTS | LIGHTNINGARCS | HAZEENCHANT | MISSILEFLIES | SCALESGROW | SCALESREMOVED | HOLESOPEN | REFLECTSPELL | SPELLSFAIL | GOESPOOF | BOUNCEMISSILE | STORMRAGES | WOUNDED

    spellcaster : target
    {
        $globals->{spell_caster} = $item{target};
    }

    defaultresult : OUTSIDETIME(?) BURSTOFSPEED(?) spellcaster SPELLTEXT
    {
        $return = "";
        if ($item{OUTSIDETIME}) {
            $return .= $item{OUTSIDETIME};
        }
        if ($item{BURSTOFSPEED}) {
            $return .= $item{BURSTOFSPEED};
        }
        $return .= $item{spellcaster} . ' ' . $item{SPELLTEXT};
    }

    spellresult : defaultresult | specialtypes

    TURNBODYTYPES : playerturn | spellresult | monsterturn | gameoutcome | PLAYERBOWS

    directmonster : "directs" MONSTERNAME TO ATTACK target
    {
        $return = "directs $item{MONSTERNAME} to attack $item{target}";
    }

    playergesture : gesturetype WITH(?) HIS handed HAND
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{active_player};
        my $hand = $item{handed};
        my $gesture = $item{gesturetype};
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

    attackmiss : "swings" "wildly" FOR target butmisses
    {
        $return = "swings wildy for $item{target}$item{butmisses}";
    }

    blindorinvis : /blindness|invisibility/

    missreason : "due" TO blindorinvis
    {
        $return = "due to $item{blindorinvis}";
    }

    missdeflect : IS "deflected" "by" A SHIELD
    {
        $return = "is deflected by a shield";
    }

    misstrip : "trips" ON "its" "feet"
    {
        $return = "trips on its feet";
    }

    missmisses : "misses" missreason(?)
    {
        $return = "misses" . ($item{missreason} ? " $item{missreason}" : "");
    }

    misstype : missmisses | missdeflect | misstrip

    butmisses : PUNCT BUT misstype
    {
        $return = "$item{PUNCT} but $item{misstype}";
    }

    attackverb : FOR | "does"

    attacksuccess : attackverb INTEGER DAMAGE
    {
        $return = "$item{attackverb} $item{INTEGER} damage"
    }

    attackfruitless : PUNCT "fruitlessly"
    {
        $return = $item{PUNCT} . " fruitlessly";
    }

    attackoutcome : attackfruitless | butmisses | attacksuccess

    attackline : TRIESTO(?) ATTACK target attackoutcome
    {
        $return = ($item{TRIESTO} ? "tries to attack" : "attacks") . " $item{target} $item{attackoutcome}";
    }

    HISBANKED : HIS "banked"
    {
        $return = "his banked";
    }

    ATON : AT | ON

    playercast : CAST HISBANKED(?) SPELLNAME ATON target butmisses(?)
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{active_player};
        my $spell = $item{SPELLNAME};
        my $target = $item{target};
        my $success = $item{butmisses} == undef;

        if ($item{HISBANKED}) {
            $globals->{turnlist}[$turn]->{$player}{spells}{banked}{$spell}{count}++;
            $globals->{turnlist}[$turn]->{$player}{spells}{banked}{$spell}{success} = $success;
            $globals->{turnlist}[$turn]->{$player}{spells}{banked}{$spell}{target} = $target;
        } else {
            $globals->{turnlist}[$turn]->{$player}{spells}{$spell}{count}++;
            $globals->{turnlist}[$turn]->{$player}{spells}{$spell}{success} = $success;
            $globals->{turnlist}[$turn]->{$player}{spells}{$spell}{target} = $target;
        }

        my $hisbanked = " ";
        if ($item{HISBANKED}) {
            $hisbanked = " his banked ";
        }
        my $butmisses = "";
        if ($item{butmisses}) {
            $butmisses = " $item{butmisses}";
        }

        $return = "casts${hisbanked}${spell} $item{ATON} ${target}${butmisses}";
    }

    VERY : "Very"

    GOBLINADJ : /Bearded|Belligerent|Fat|Green|Grey|Horrid|Malodorous|Nasty|Ratty|Small|Smelly|Tricky|Ugly/

    GOBLINNAME : GOBLINADJ(?) "Goblin"
    {
        my $adj = $item{GOBLINADJ} ? "$item{GOBLINADJ} " : "";
        $return = $adj . 'Goblin';
    }

    OGREADJ : /Angry|Black|Burnt|Crazy|Monstrous|Obtuse|Ochre|Stinking|Suicidal|Terrible|Yellow/

    OGRENAME : OGREADJ(?) "Ogre"
    {
        my $adj = $item{OGREADJ} ? "$item{OGREADJ} " : "";
        $return = $adj . 'Ogre';
    }

    TROLLADJ : /Bridge|Green|Hairy|Ham-fisted|Irate|Loud|Mailing-list|Obnoxious|Stupid|Tall/

    TROLLNAME : TROLLADJ(?) "Troll"
    {
        my $adj = $item{TROLLADJ} ? "$item{TROLLADJ} " : "";
        $return = $adj . 'Troll';
    }

    GIANTADJ : /Beanstalk|Big|Gaunt|Golden|Hungry|Large|Norse/

    GIANTNAME : GIANTADJ(?) "Giant"
    {
        my $adj = $item{GIANTADJ} ? "$item{GIANTADJ} " : "";
        $return = $adj . 'Giant';
    }

    ELEMENTALNAME : ARTICLE(?) STORMTYPE ELEMENTAL
    {
        my $article = $item{ARTICLE} ? "$item{ARTICLE} " : "";
        $return = $article . $item{STORMTYPE} . ' ' . $item{ELEMENTAL};
    }

    MONSTERTYPENAME : GOBLINNAME | OGRENAME | TROLLNAME | GIANTNAME | ELEMENTALNAME

    MONSTERNAME : VERY(s?) MONSTERTYPENAME
    {
        $return = "";

        if ($item{VERY}) {
          $return .= join(' ', @{$item{VERY}}) . ' ';
        }

        $return .= $item{MONSTERTYPENAME};
    }

    OUTSIDETIME : "Outside" "time" PUNCT
    {
        $return = "Outside time,";
    }

    TRIESTO : "tries" TO
    {
        $return = "tries to";
    }

    monsterwanders : "wanders" "around" "aimlessly"
    {
        $return = "wanders around aimlessly";
    }

    monsterforgets : "forgets" TO ATTACK "anyone"
    {
        $return = "forgets to attack anyone";
    }

    notarget : "doesn't" ATTACK "anyone"
    {
        $return = "doesn't attack anyone";
    }

    monsterscared : IS "too" "scared" TO ATTACK
    {
        $return = "is too scared to attack";
    }

    monsterelemental : IS SUMMONED "inside" ELEMENTALNAME AND IS "consumed" "instantly"
    {
        $return = "is summoned inside $item{ELEMENTALNAME} and is consumed instantly";
    }

    monsterturnline : attackline | attackmiss | monsterwanders | monsterforgets | notarget | monsterscared | monsterelemental

    monsterturn : OUTSIDETIME(?) BURSTOFSPEED(?) ARTICLE(?) MONSTERNAME monsterturnline
    {
        my $outsidetime = $item{OUTSIDETIME} ? "$item{OUTSIDETIME} " : "";
        my $burstofspeed = $item{BURSTOFSPEED} ? "$item{BURSTOFSPEED} " : "";
        my $article = $item{ARTICLE} ? "$item{ARTICLE} " : "";

        $return = $outsidetime . $burstofspeed . $article . $item{MONSTERNAME} . " " . $item{monsterturnline};
    }

    potentialmonster : THE "monster" PLAYERNAME IS "summoning" WITH HIS handed HAND
    {
        $return = "the monster " . $item{PLAYERNAME} . " is summoning with his " . $item{handed} . " hand";
    }

    monstertarget : potentialmonster | MONSTERNAME

    ATTACK : /attacks?/

    THICK : "thick"

    MAGICAL : "magical"

    APPEARS : "appears"

    IN : /in/i

    A : /a/i

    AN : /an/i

    AS : /as/i

    ARE : /are/i

    IS : "is"

    OF : "of"

    BY : "by"

    TO : "to"

    NO : /no/i

    INTO : "into"

    FROM : "from"

    ON : "on"

    UP : "up"

    AND : "and"

    FOR : "for"

    BUT : "but"

    THE : /the/i

    WITH : "with"

    ALL : "all"

    HIT : "hit"

    SUMMONED : "summoned"

    SHIELD : "shield"

    SPELL : /spells?/

    OVER : "over"

    DAMAGE : "damage"

    IT : "it"

    # these are in order by likelyhood of being cast
    SPELLNAME :
    SHIELDSPELL | PARALYSIS | MAGICMISSILE | COUNTERSPELL | CHARMPERSON |
    SUMMONGOBLIN | PROTECTION | AMNESIA | CAUSELIGHTWOUNDS | CAUSEHEAVYWOUNDS |
    CONFUSION | CHARMMONSTER | CURELIGHTWOUNDS | MALADROITNESS | FEAR |
    SUMMONOGRE | INVISIBILITY | ANTISPELL | CUREHEAVYWOUNDS | LIGHTNINGBOLT |
    MAGICMIRROR | CLAPOFLIGHTNING | SUMMONGIANT | PERMANENCY | BLINDNESS |
    TIMESTOP | SUMMONTROLL | RESISTHEAT | DISPELMAGIC | REMOVEENCHANTMENT |
    FIREBALL | DISEASE | ICESTORM | SUMMONFIREELEMENTAL | FINGEROFDEATH |
    RESISTCOLD | FIRESTORM | POISON | HASTE | SUMMONICEELEMENTAL | DELAYEFFECT


    handed : LEFT | RIGHT

    TOHIT : TO HIT
    {
        $return = "to hit";
    }

    FIRE : "Fire"

    ICE : "Ice"

    STORMTYPE : FIRE | ICE

    FIREENTRANCE : "furious" "roar" OF "flame"
    {
        $return = "furious roar of flame";
    }

    ICEENTRANCE : "sudden" "rush" OF "arctic" "wind"
    {
        $return = "sudden rush of arctic wind";
    }

    ELEMENTALENTRANCE : FIREENTRANCE | ICEENTRANCE

    FIRERYHEAT : "fiery" "heat"
    {
        $return = "fiery heat";
    }

    HEATSTORM : "heat" OF THE FIRESTORM
    {
        $return = "heat of the " . $item{FIRESTORM};
    }

    ELEMENTALRESISTANCE : FIRERYHEAT | HEATSTORM

    FEARQUALIFIER : "cringes" | "quakes"

    SUMMONEDTOSERVE : SUMMONED TO "serve" PLAYERNAME
    {
        my $turn = $globals->{current_turn};

        $globals->{monsters}{$globals->{spell_caster}}{original_owner} = $item{PLAYERNAME};
        $globals->{monsters}{$globals->{spell_caster}}{current_owner} = $item{PLAYERNAME};
        $globals->{monsters}{$globals->{spell_caster}}{turn_summoned} = $turn;
        $globals->{monsters}{$globals->{spell_caster}}{damage_done} = 0;
        $globals->{monsters}{$globals->{spell_caster}}{killed_by} = "";
        $globals->{monsters}{$globals->{spell_caster}}{killed} = [];

        $return = "summoned to serve " . $item{PLAYERNAME};
    }

    ISSPELLTEXT :
          /covered|surrounded|protected/ BY A THICK(?) /magical\sglowing|glowing|reflective|magical|shimmering/ SHIELD |
          HIT BY A MAGICMISSILE PUNCT FOR INTEGER DAMAGE |
          "charmed" INTO "making" THE "wrong" GESTURE WITH HIS handed HAND |
          "charmed" PUNCT BUT "ends" UP "making" THE GESTURE "he" "intended" "anyway" |
          SUMMONEDTOSERVE |
          HIT BY A "bolt" OF "lightning" PUNCT FOR INTEGER DAMAGE |
          HIT BY REMOVEENCHANTMENT PUNCT AND "starts" "coming" "apart" AT THE "seams" |
          HIT BY A "Fireball" AS THE ICESTORM "strikes" PUNCT AND IS "miraculously" LEFT "untouched" |
          HIT BY ARTICLE SPELLNAME SPELL PUNCT AND IS "annihilated" BY THE MAGICAL "overload" |
          A "bit" "nauseous" |
          AT "maximum" "health" |
          "absorbed" BY PLAYERNAME APOSS "counter" SPELL |
          "burnt" FOR INTEGER DAMAGE |
          "burnt" IN THE "raging" FIRESTORM PUNCT FOR INTEGER DAMAGE |
          "covered" BY A "warm" "glow" |
          "covered" IN A "coat" OF "sparkling" "frost" |
          "destroyed" BY A SPELLNAME SPELL |
          "looking" "pale" |
          "having" "difficulty" "breathing" |
          "healed" |
          "frozen" BY THE "raging" ICESTORM PUNCT FOR INTEGER DAMAGE |
          "frozen" FOR INTEGER DAMAGE |
          "rendered" "maladroit" |
          "sweating" "feverishly" |
          "touched" WITH THE "Finger" OF "Death"

    SOLIDSHIELD : "momentarily" "more" "solid"
    {
        $return = "momentarily more solid";
    }

    THICKERSHIELD : "thicker" FOR A "moment" PUNCT "then" "fades" "back"
    {
        $return = "thicker for a moment, then fades back";
    }

    SHIELDAPPEARANCE : SOLIDSHIELD  | THICKERSHIELD

    FIRMSHIELD : PUNCT BUT "remains" "firm"
    {
        $return = ", but remains firm";
    }

    FORAMOMENT : FOR A "moment"
    {
        $return = "for a moment";
    }

    SHIELDFLICKERS : FIRMSHIELD | FORAMOMENT

    SHIELDSPELLTEXT :
          "blurs" FOR A "moment" |
          "disappears" FOR A "moment" |
          "fizzles" "slightly" |
          "flickers" SHIELDFLICKERS |
          /intensifie[ds]/ "momentarily" |
          "keeps" THE STORMTYPE ELEMENTAL AT "bay" |
          LOOKS SHIELDAPPEARANCE |
          "sparkles" "rapidly" FOR A "moment"  |
          "turns" A "greenish" "hue" FOR A "moment"

    LOOKSSPELLTEXT :
          A "bit" "confused" |
          PUNCT "glassy-eyed" PUNCT AT PLAYERNAME |
          "comfortable" IN THE "cooling" ICESTORM |
          "intrigued" BY target

    PLAYERGLOWING : "glowing" "faintly"
    {
        $return = "glowing faintly";
    }

    PLAYERSHIMMER : TO "shimmer"
    {
        $return = "to shimmer";
    }

    PLAYERAPPEARANCE : PLAYERGLOWING | PLAYERSHIMMER

    ICEDESTROYED : PUNCT "calming" AND "cooling" THE FIRESTORM
    {
        $return = $item{PUNCT} . " calming and cooling the " . $item{FIRESTORM};
    }

    FIREDESTROYED : THE "oncoming" ICESTORM PUNCT AND IS "destroyed" BY THE "ensuing" "water"
    {
        $return = "the oncoming " . $item{ICESTORM} . $item{PUNCT} . " and is destroyed by the ensuing water";
    }

    ELEMENTALDESTROYED : ICEDESTROYED | FIREDESTROYED

    ELEMENTALAMOK : "amok"

    ELEMENTALISWILD : "around" "wildly" PUNCT "looking" FOR target TOHIT(?)
    {
        my $tohit = $item{TOHIT} ? " $item{TOHIT}" : "";
        $return = "around wildly" . $item{PUNCT} . " looking for $item{target}${tohit}";
    }

    APOSSSPELLTEXT: SHIELD SHIELDSPELLTEXT |
          "hands" "start" TO "stiffen" |
          handed HAND IS "paralysed" |
          "half-done" SPELL "fizzle" AND "die" |
          "eyes" ARE "covered" WITH "scales" |
          "absorbed" BY target APOSS "counter" SPELL |
          "surrounding" MAGICAL "energies" ARE "grounded" |
          MONSTERNAME IS "absorbed" INTO A "Counterspell" "glow" |
          SPELLNAME IS "absorbed" INTO A "glow" |
          DISEASE IS "fatal" |
          POISON IS "fatal"

    SPELLTEXT : IS ISSPELLTEXT | APOSS APOSSSPELLTEXT | LOOKS LOOKSSPELLTEXT |
          APPEARS "unaffected" BY PLAYERNAME APOSS "intellectual" "charms" |
          APPEARS IN A ELEMENTALENTRANCE |
          "attempts" TO "make" THE SPELL PERMANENT |
          "banks" A SPELL FOR "later" |
          "begins" PLAYERAPPEARANCE |
          "basks" IN THE ELEMENTALRESISTANCE |
          "can't" "move" TO ATTACK |
          "confusedly" "makes" THE "wrong" GESTURE WITH HIS handed HAND |
          FEARQUALIFIER IN "fear" |
          "enjoys" THE "icy" "chill" |
          "fades" "back" INTO "visibility" |
          "flickers" "out" OF "time" |
          "flies" "away" WITH THE "storm" |
          "forgets" "what" "he" APOSS "doing" PUNCT AND "makes" THE "same" GESTURE AS "last" "round" |
          handed HAND "stab" IS "wasted" AT A "monster" "which" "wasn't" SUMMONED |
          "ignores" target APOSS "appeal" TO HIS "baser" "instincts" |
          "makes" A "confused" GESTURE PUNCT BUT "luckily" IT APOSS "what" "he" "intended" "anyway" |
          "makes" THE SPELL PERMANENT |
          "melts" ELEMENTALDESTROYED |
          "runs" ELEMENTALAMOK |
          "runs" ELEMENTALISWILD |
          "shakes" HIS "head" AND "regains" "control" PUNCT AS "enchantments" "cancel" "each" "other" "out" |
          "speeds" UP |
          "staggers" "weakly" |
          "starts" "coughing" UP "blood" |
          "starts" TO "look" /blank|sick/ |
          "starts" TO "lose" "coordination" |
          "stomach" "rumbles" |
          "stops" HIS "heart" "through" "force" OF "will" "alone" |
          "tries" TO CAST "Clap" OF LIGHTNING PUNCT BUT "doesn't" "have" THE "charge" FOR IT

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

