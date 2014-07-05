package WavingHands::Parser::Grammar::Warlocks;

=head1 NAME

WavingHands::Parser::Grammar::Warlocks - Grammar for games from L<Warlocks|http://games.ravenblack.net>

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our $globals = {};

use Parse::RecDescent;

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

    ARTICLE : /(the\s)|(an?\s)/i | #nothing

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
    {
        "Amnesia";
    }
    ANTISPELL : "Anti-spell"
    {
        "Anti-spell";
    }
    BLINDNESS : "Blindness"
    {
        "Blindness";
    }
    CAUSEHEAVYWOUNDS : "Cause" HEAVY WOUNDS
    {
        "Cause Heavy Wounds";
    }
    CAUSELIGHTWOUNDS : "Cause" LIGHT WOUNDS
    {
        "Cause Light Wounds";
    }
    CHARMMONSTER : "Charm" "Monster"
    {
        "Charm Monster";
    }
    CHARMPERSON : "Charm" "Person"
    {
        "Charm Person";
    }
    CLAPOFLIGHTNING : "Clap" OF LIGHTNING
    {
        "Clap of Lightning";
    }
    CONFUSION : "Confusion"
    {
        "Confusion";
    }
    COUNTERSPELL : "Counter" "Spell"
    {
        "Counter Spell";
    }
    CUREHEAVYWOUNDS : "Cure" HEAVY WOUNDS
    {
        "Cure Heavy Wounds";
    }
    CURELIGHTWOUNDS : "Cure" LIGHT WOUNDS
    {
        "Cure Light Wounds";
    }
    DELAYEFFECT : "Delay" "Effect"
    {
        "Delay Effect";
    }
    DISEASE : "Disease"
    {
        "Disease";
    }
    DISPELMAGIC : "Dispel" MAGIC
    {
        "Dispel Magic";
    }
    FEAR : "Fear"
    {
        "Fear";
    }
    FINGEROFDEATH : "Finger" OF "Death"
    {
        "Finger of Death";
    }
    FIREBALL : "Fireball"
    {
        "Fireball";
    }
    FIRESTORM : FIRE STORM
    {
        "Fire Storm";
    }
    HASTE : "Haste"
    {
        "Haste";
    }
    ICESTORM : ICE STORM
    {
        "Ice Storm";
    }
    INVISIBILITY : "Invisibility"
    {
        "Invisibility";
    }
    LIGHTNINGBOLT : LIGHTNING "Bolt"
    {
        "Lightning Bolt";
    }
    MAGICMIRROR : MAGIC "Mirror"
    {
        "Magic Mirror";
    }
    MAGICMISSILE : MAGIC /missile/i
    {
        "Magic Missile";
    }
    MALADROITNESS : "Maladroitness"
    {
        "Maladroitness";
    }
    PARALYSIS : "Paralysis"
    {
        "Paralysis";
    }
    PERMANENCY : "Permanency"
    {
        "Permanency";
    }
    POISON : "Poison"
    {
        "Poison";
    }
    PROTECTION : "Protection"
    {
        "Protection";
    }
    REMOVEENCHANTMENT : "Remove" "Enchantment"
    {
        "Remove Enchantment";
    }
    RESISTCOLD : "Resist" "Cold"
    {
        "Resist Cold";
    }
    RESISTHEAT : "Resist" "Heat"
    {
        "Resist Heat";
    }
    SHIELDSPELL : "Shield"
    {
        "Shield";
    }
    SUMMONFIREELEMENTAL : SUMMON FIRE ELEMENTAL
    {
        "Summon Fire Elemental";
    }
    SUMMONGIANT : SUMMON "Giant"
    {
        "Summon Giant";
    }
    SUMMONGOBLIN : SUMMON "Goblin"
    {
        "Summon Goblin";
    }
    SUMMONICEELEMENTAL : SUMMON ICE ELEMENTAL
    {
        "Summon Ice Elemental";
    }
    SUMMONOGRE : SUMMON "Ogre"
    {
        "Summon Ogre";
    }
    SUMMONTROLL : SUMMON "Troll"
    {
        "Summon Troll";
    }
    TIMESTOP : "Time" "Stop"
    {
        "Time Stop";
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

    STABS : "stabs"
    {
        $return = ">";
    }

    NOGESTURE : "makes" NO GESTURE
    {
        $return = "-";
    }

    PLAYERSTAB : STABS
    {
        $return = '>';
    }

    HALFCLAP : "flailingly" "half-claps"
    {
        $return = 'C';
    }

    gesturetype : POINTS | SNAPS | WAVES | FINGERS | PALM | HALFCLAP | PLAYERSTAB | NOGESTURE

    CLAPS : "claps"
    {
        my $turn = $globals->{data}{current_turn};
        my $player = $globals->{data}{active_player};

        $globals->{data}{turn}[$turn]->{$player}{gesture}{right} = 'C';
        $globals->{data}{turn}[$turn]->{$player}{gesture}{left} = 'C';
    }

    GESTURE : /gestures?/

    playertarget : /himself|nobody|everyone|someone/i | PLAYERNAME
    {
        $return = $item[1];
    }

    target : playertarget | monstertarget
    {
        $return = $item[1];
    }

    monster : MONSTERNAME HEALTH DASH AFFECTEDBY "Owned" "by" COLON playertarget "Attacking" COLON target

    REGISTERED : "Registered" PUNCT | #nothing
    DEAD : "Dead" PUNCT | #nothing
    TURNLIST : TURN COLON INTEGER(s)

    #GESTURECHARACTER : "F" | "P" | "S" | "W" | "D" | "C" | ">" | "?" | "-" | " "
    #LEFTHANDGESTURES : "LH:B" GESTURECHARACTER(s)
    #RIGHTHANDGESTURES : "RH:B" GESTURECHARACTER(s)
    #PLAYERGESTURES : LEFTHANDGESTURES RIGHTHANDGESTURES

    PLAYERGESTURES : /\s*LH[:]B(.*?)RH[:]B(.*?)\n(\n|\z)/ms

    PARENDS : /[()]/ | #match either or nothing

    HEALTH : PARENDS "Health" COLON INTEGER PARENDS | #nothing
    SURRENDERED : "Surrendered" PUNCT | #nothing
    DASH : "-" | #nothing

    AFFECTEDBYTYPE : /Afraid|Blindness|Charmed|Coldproof|Confused|Delay|Disease|Fireproof|Forgetful|Haste|Invisibility|Maladroit|MShield|Paralysed|Permanency|Poison|Shield|TimeOut/

    PERMANENT : "permanent"

    DURATION : INTEGER | PERMANENT

    AFFECTEDBYITEM : AFFECTEDBYTYPE PARENDS DURATION PARENDS

    AFFECTEDBY : AFFECTEDBYITEM(s?)

    BANKEDSPELL : PARENDS "Banked" COLON SPELLNAME PARENDS | #nothing

    playerladder: PLAYERNAME PARENDS INTEGER PARENDS

    player: REGISTERED playerladder SURRENDERED DEAD HEALTH DASH AFFECTEDBY BANKEDSPELL TURNLIST PLAYERGESTURES
    {
        my $player = $item{PLAYERNAME};
        my $gestures = $item{PLAYERGESTURES};

        ($globals->{data}{$player}{gestures}{left}) = ($gestures =~ /LH[:]B(.*?)\n/s);
        ($globals->{data}{$player}{gestures}{right}) = ($gestures =~ /RH[:]B(.*?)\n+/s);
    }

    listofplayers : "-ShOuLdNeVeRmAtCh-"
    playerlist : listofplayers

    turnbody : TURNBODY | #nothing

    turnsection : TURNLINE turnbody(s)
    {
        my $turn = $globals->{data}{current_turn};

        $globals->{data}{turn}[$turn]->{gametext} = $item{turnbody};

        1;
    }

    eofile : /[\n\s]*/ms
    {
        1;
    }

    startrule : preamble turnsection(s) monster(s?) playerlist eofile

    turnsingame : /(?:.*?)Turn \d+ in/ms

    preamble : turnsingame gametype modifier(s?) "Battle" gameid

    modifier : PARAFC | PARAFDF | MALADROIT
    {
        push @{$globals->{data}{game_modifiers}}, $item[1];
    }

    formoney : LADDER | MELEE
    {
        $return = $item[1];
    }

    forpride : VERYFRIENDLY | FRIENDLY
    {
        $return = $item[1];
    }

    gametype : formoney | forpride
    {
        $globals->{data}{gametype} = $item[1];
    }

    gameid : INTEGER
    {
        $globals->{data}{gameid} = $item{INTEGER};
    }

    TURNLINE : TURN INTEGER
    {
        my $turn = $item{INTEGER};

        if ($turn == 1) {
            # create regex for matching playernames exactly and replace the generic one.
            my @players =  sort{length "$b" <=> length "$a"} @{$globals->{data}{players}};
            my $playercount = scalar @players;
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

        $globals->{data}{turn}[$turn] = {};
        $globals->{data}{current_turn} = $turn;
    }

    DIES : "dies"
    VICTORIOUS : IS "victorious"
    SURRENDERS : "surrenders"
    IGNOBLEEND : NO "Warlocks" "remaining" PUNCT AN "ignominious" "end" TO A "battle"

    targetoutcome : DIES | VICTORIOUS | SURRENDERS

    possibleoutcome : IGNOBLEEND | target targetoutcome

    gameoutcome : possibleoutcome PUNCT

    playername : PLAYERNAME
    {
        $globals->{data}{active_player} = $item{PLAYERNAME};
        $item{PLAYERNAME};
    }

    playerdefault : playergesture | playercast | directmonster | CLAPS | playernotarget | playermiss | playerhit

    PLAYERSPEECH : "says" /"(.*?)"\.\n/sm
    {
        my $turn = $globals->{data}{current_turn};
        my $player = $globals->{data}{active_player};
        my $speech = $item[2];

        $globals->{data}{turn}[$turn]->{$player}{speech} = $speech;
    }

    playeractiontypes : PLAYERSPEECH | playerdefault PUNCT

    playerturn : playername playeractiontypes

    PLAYERBOWS : BOWNAME BOWS PUNCT
    {
        my $player = $item[1];
        push @{$globals->{data}{players}}, $player;

        $globals->{data}{turn}[0]->{$player}{gesture}{left} = 'B';
        $globals->{data}{turn}[0]->{$player}{gesture}{right} = 'B';
    }

    ANORA : AN | A
    STORMRAGES : ANORA STORMTYPE STORM "rages" "through" THE "circle"

    WOUNDED : WOUNDS "appear" ALL OVER target APOSS "body"
    BOUNCEMISSILE : A MAGICMISSILE "bounces" "off" target APOSS SHIELD
    GOESPOOF : "There" IS A "flash" PUNCT AND PLAYERNAME "disappears"
    SPELLSFAIL : "All" MAGICAL "effects" ARE "erased!" "All" "other" SPELL "fail"
    REFLECTSPELL : THE SPELLNAME SPELL IS "reflected" FROM target APOSS MAGICMIRROR
    SCALESGROW : "Scales" "start" TO "grow" OVER PLAYERNAME APOSS "eyes"
    SCALESREMOVED : THE "scales" ARE "removed" FROM PLAYERNAME APOSS "eyes"
    HOLESOPEN : "Holes" "open" UP IN target APOSS SHIELD PUNCT BUT "then" "close" UP "again"
    MISSILEFLIES : A MAGICMISSILE "flies" "off" INTO THE "distance"
    HAZEENCHANT : THE "haze" OF AN "enchantment" SPELL "drifts" "aimlessly" OVER THE "circle" PUNCT AND "dissipates"
    LIGHTNINGARCS : A "bolt" OF "lightning" "arcs" TO THE "ground"
    SPELLDRIFTS : A SPELLNAME "drifts" "away" "aimlessly"
    TINYHOLES : "Tiny" "holes" IN target APOSS SHIELD ARE "sealed" UP

    FASTGUYS : "players" | "warlocks"
    FASTPLAYERS : "Fast" FASTGUYS "sneak" IN AN "extra" "set" OF GESTURE 

    TURNOUTSIDETIME : "This" "turn" "took" "place" "outside" OF "time"
    FIREBALLSTRIKETYPE : PUNCT AND "flames" "roar" ALL(?) "around" target APOSS(?) SHIELD(?) CALMINFERNO(?) | target PUNCT "burning" "him" FOR INTEGER DAMAGE
    FIREBALLSTRIKES : "strikes" FIREBALLSTRIKETYPE
    FIREBALLFLIES : "flies" INTO THE "distance" AND "burns" "itself" "out"
    FIREBALLOUTCOME : FIREBALLFLIES | FIREBALLSTRIKES
    FIREBALLLANDS : A "fireball" FIREBALLOUTCOME
    CALMINFERNO : "He" "stands" "calmly" "in" THE "inferno"
    LIGHTNINGSPARKS : LIGHTNING "sparks" ALL "around" target APOSS SHIELD
    PERMOVERRIDE : THE PERMANENT "enchantment" ON target "overrides" THE SPELLNAME "effect"
    MIRRORDISSIPATE : A MAGICMIRROR "dissipates" INTO THE "air"
    ELEMENTALDESTROY : "Opposing" ELEMENTAL "destroy" "each" "other"
    SHIMMERSHIELD : THE "shimmer" OF A SHIELD "briefly" "covers" THE "circle" PUNCT "then" "dissolves"
    ELEMENTALMERGE : "Two" STORMTYPE ELEMENTAL "merge" INTO "one"
    ELEMENTALCANCEL : "Fire" AND "Ice" "storms" "cancel" "each" "other" "out" PUNCT "leaving" "just" "a" "gentle" "breeze"
    BURSTOFSPEED : IN A "burst" OF "speed" PUNCT | #nothing
    NOMASTER : A SUMMONED "creature" PUNCT "finding" "no" "master" PUNCT "returns" "from" "whence" "it" "came"

    specialtypes : NOMASTER | TURNOUTSIDETIME | ELEMENTALCANCEL | ELEMENTALMERGE | FIREBALLLANDS | SHIMMERSHIELD | ELEMENTALDESTROY | MIRRORDISSIPATE | PERMOVERRIDE | LIGHTNINGSPARKS | FASTPLAYERS | TINYHOLES | SPELLDRIFTS | LIGHTNINGARCS | HAZEENCHANT | MISSILEFLIES | SCALESGROW | SCALESREMOVED | HOLESOPEN | REFLECTSPELL | SPELLSFAIL | GOESPOOF | BOUNCEMISSILE | STORMRAGES | WOUNDED
    specialresult : specialtypes PUNCT

    defaultresult : OUTSIDETIME BURSTOFSPEED target SPELLTEXT PUNCT

    spellresult : defaultresult | specialresult

    TURNBODYTYPES : playerturn | spellresult | monsterturn | gameoutcome | PLAYERBOWS

    TURNBODY : TURNBODYTYPES(s)

    directmonster : "directs" MONSTERNAME TO ATTACK target

    playernotarget : monsternotarget

    playergesture : gesturetype WITH(?) HIS handed HAND
    {
        my $turn = $globals->{data}{current_turn};
        my $player = $globals->{data}{active_player};
        my $hand = $item{handed};

        $globals->{data}{turn}[$turn]->{$player}{gesture}{$hand} = $item{gesturetype};
    }

    playerhitoutcomes : FOR INTEGER DAMAGE | butmisses
    playerhit : ATTACK target playerhitoutcomes

    missreason: "due" TO /blindness|invisibility/
    misstype: "misses" missreason(?) | IS "deflected" "by" A SHIELD
    butmisses : PUNCT BUT misstype

    HISBANKED : HIS "banked"

    ATON : AT | ON

    playercast : CAST HISBANKED(?) SPELLNAME ATON target butmisses(?)
    {
        my $turn = $globals->{data}{current_turn};
        my $player = $globals->{data}{active_player};
        my $spell = $item{SPELLNAME};
        my $target = $item{target};
        my $success = $item{butmisses};

        $globals->{data}{turn}[$turn]->{$player}{spells}{$spell}{count}++;
        $globals->{data}{turn}[$turn]->{$player}{spells}{$spell}{success} = $success;
        $globals->{data}{turn}[$turn]->{$player}{spells}{$spell}{target} = $target;
    }

    VERY : "Very"

    VERYLIST : VERY(s?)
    #NAMEENDING : APOSS PUNCT | APOSS | PUNCT | #nothing

    GOBLINADJ : /Bearded|Belligerent|Fat|Green|Grey|Horrid|Malodorous|Nasty|Ratty|Small|Smelly|Tricky|Ugly/ | #nothing
    GOBLINNAME : GOBLINADJ "Goblin"

    OGREADJ : /Angry|Black|Burnt|Crazy|Monstrous|Obtuse|Ochre|Stinking|Suicidal|Terrible|Yellow/ | #nothing
    OGRENAME : OGREADJ "Ogre"

    TROLLADJ : /Bridge|Green|Hairy|Ham-fisted|Irate|Loud|Mailing-list|Obnoxious|Stupid|Tall/ | #nothing
    TROLLNAME : TROLLADJ "Troll"

    GIANTADJ : /Beanstalk|Big|Gaunt|Golden|Hungry|Large|Norse/ | #nothing
    GIANTNAME : GIANTADJ "Giant"

    ELEMENTALNAME : ARTICLE STORMTYPE ELEMENTAL

    MONSTERTYPENAME : GOBLINNAME | OGRENAME | TROLLNAME | GIANTNAME | ELEMENTALNAME

    MONSTERNAME : VERYLIST MONSTERTYPENAME

    OUTSIDETIME : "Outside" "time" PUNCT | #nothing
    TRIESTO : "tries" TO | #nothing

    monsterdmg : "does" INTEGER DAMAGE TO target
    monstermiss : "swings" "wildly" FOR target butmisses
    playermiss : monstermiss

    monsterhitresult : FOR INTEGER DAMAGE | PUNCT BUT IS "deflected" BY A SHIELD | PUNCT BUT "trips" ON "its" "feet" | "fruitlessly"
    monsterhit : TRIESTO ATTACK target monsterhitresult
    monsterwanders : "wanders" "around" "aimlessly"
    monsterforgets : "forgets" TO ATTACK "anyone"
    monsternotarget : "doesn't" ATTACK "anyone"
    monsterscared : IS "too" "scared" TO ATTACK
    monsterelemental : IS SUMMONED "inside" ELEMENTALNAME AND IS "consumed" "instantly"

    monsterturnline : monsterhit | monstermiss | monsterwanders | monsterforgets | monsternotarget | monsterscared | monsterelemental

    monsterturn : OUTSIDETIME BURSTOFSPEED ARTICLE MONSTERNAME monsterturnline PUNCT

    potentialmonster : THE "monster" PLAYERNAME IS "summoning" WITH HIS handed HAND
    {
        $return = "monster " . $item[3] . " " . $item{handed};
    }

    monstertarget : potentialmonster | MONSTERNAME
    {
        $return = $item[1];
    }

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
    TOHIT : TO HIT | #nothing
    FIRE : "Fire"
    ICE : "Ice"
    STORMTYPE : FIRE | ICE
    ELEMENTALENTRANCE : "furious" "roar" OF "flame" | "sudden" "rush" OF "arctic" "wind"
    ELEMENTALRESISTANCE : "fiery" "heat" | "heat" OF THE FIRESTORM
    FEARQUALIFIER : "cringes" | "quakes"

    ISSPELLTEXT : 
          /covered|surrounded|protected/ BY A THICK(?) /magical\sglowing|glowing|reflective|magical|shimmering/ SHIELD |
          HIT BY A MAGICMISSILE PUNCT FOR INTEGER DAMAGE |
          "charmed" INTO "making" THE "wrong" GESTURE WITH HIS handed HAND |
          "charmed" PUNCT BUT "ends" UP "making" THE GESTURE "he" "intended" "anyway" |
          SUMMONED TO "serve" PLAYERNAME |
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

    SHIELDAPPEARANCE : "momentarily" "more" "solid"  | "thicker" FOR A "moment" PUNCT "then" "fades" "back"
    SHIELDFLICKERS : PUNCT BUT "remains" "firm" | FOR A "moment"
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

    PLAYERAPPEARANCE :"glowing" "faintly" | TO "shimmer"
    ELEMENTALDESTROYED : PUNCT "calming" AND "cooling" THE FIRESTORM | THE "oncoming" ICESTORM PUNCT AND IS "destroyed" BY THE "ensuing" "water"
    ELEMENTALISWILD : "amok" | "around" "wildly" PUNCT "looking" FOR target TOHIT

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
          "makes" A "confused" GESTURE PUNCT BUT "luckily" "it" APOSS "what" "he" "intended" "anyway" |
          "makes" THE SPELL PERMANENT |
          "melts" ELEMENTALDESTROYED |
          "runs" ELEMENTALISWILD |
          "shakes" HIS "head" AND "regains" "control" PUNCT AS "enchantments" "cancel" "each" "other" "out" |
          "speeds" UP |
          "staggers" "weakly" |
          "starts" "coughing" UP "blood" |
          "starts" TO "look" /blank|sick/ |
          "starts" TO "lose" "coordination" |
          "stomach" "rumbles" |
          "stops" HIS "heart" "through" "force" OF "will" "alone" |
          "tries" TO CAST "Clap" OF LIGHTNING PUNCT BUT "doesn't" "have" THE "charge" FOR "it"

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
    return $globals->{data};
}

sub reset_data
{
    $globals->{data} = {};
    $globals->{data}{turn} = [];
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

