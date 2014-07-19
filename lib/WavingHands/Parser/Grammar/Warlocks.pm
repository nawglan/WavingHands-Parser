package WavingHands::Parser::Grammar::Warlocks;

=head1 NAME

WavingHands::Parser::Grammar::Warlocks - Grammar for games from L<Warlocks|http://games.ravenblack.net>

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.001';
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
    # initializing action
    {
        # autoflush
        $| = 1;

        # skip whitespace, newlines and emptystring
        $Parse::RecDescent::skip = qr/[\s\n]*/s;

        # pull in outer globals variable
        my $globals = $WavingHands::Parser::Grammar::Warlocks::globals;
    }

    # single terms
    APOSS : "'s"
    APOST : "'t"
    BOWNAME : /\b\w+\b/
    COLON : ":"
    DASH : "-"
    INTEGER : /\d+/
    PLAYERLIST : LISTOFPLAYERS
    LISTOFPLAYERS : "-ShOuLdNeVeRmAtCh-"
    PLAYERGESTURES : /\s*LH[:]B(.*?)RH[:]B(.*?)\n(\n|\z)/ms
    PARENDS : /[()]/
    PLAYERNAME : "__NoSuChPlAyEr__"
    PUNCT : /[.!,]/

    # complex rules

    HANDED : "left" | "right"

    target : PLAYERTARGET | MONSTERTARGET

    PLAYERTARGET : /himself|nobody|everyone|someone/i | PLAYERNAME
    {
        if ($item{PLAYERNAME}) {
          $return = "1:$item{PLAYERNAME}";
        } else {
          $return = "1:$item[1]";
        }
    }

    # these are in order by likelyhood of being cast
    SPELLNAME :
        "Shield" | "Paralysis" | MAGICMISSILE | COUNTERSPELL | CHARMPERSON |
        SUMMONGOBLIN | "Protection" | "Amnesia" | CAUSELIGHTWOUNDS | CAUSEHEAVYWOUNDS |
        "Confusion" | CHARMMONSTER | CURELIGHTWOUNDS | "Maladroitness" | "Fear" |
        SUMMONOGRE | "Invisibility" | "Anti-spell" | CUREHEAVYWOUNDS | LIGHTNINGBOLT |
        MAGICMIRROR | CLAPOFLIGHTNING | SUMMONGIANT | "Permanency" | "Blindness" |
        TIMESTOP | SUMMONTROLL | RESISTHEAT | DISPELMAGIC | REMOVEENCHANTMENT |
        "Fireball" | "Disease" | ICESTORM | SUMMONFIREELEMENTAL | FINGEROFDEATH |
        RESISTCOLD | FIRESTORM | "Poison" | "Haste" | SUMMONICEELEMENTAL | DELAYEFFECT

    MAGICMISSILE : "Magic" "Missile"
    {
        $return = "Magic Missile";
    }

    TURNBODYLINES : OUTSIDETIME(?) BURSTOFSPEED(?) ACTOR TURNBODYLINETYPES
    {
        my ($is_player, $actorname) = split /:/, $item{ACTOR};

        $return = '';
        $return .= "$item{OUTSIDETIME} " if $item{OUTSIDETIME};
        $return .= "$item{BURSTOFSPEED} " if $item{BURSTOFSPEED};
        $return .= "$actorname $item{TURNBODYLINETYPES}";
    }

    TURNBODYLINETYPES : NORMALTURNBODYLINES | OTHERTURNBODYLINES

    # these are in order by likelyhood of happening
    SPECIALTURNBODYLINES : MISSILERESULT2 | MISSILERESULT3 | COUNTERSPELLRESULT3 | CHARMMONSTERRESULT3 |
        CAUSEWOUNDSRESULT | CAUSEWOUNDSRESULT2 | CUREWOUNDSRESULT3 | INVISRESULT2 | BLINDNESSRESULT2 | TIMESTOPEFFECT |
        DISPELMAGICRESULT | FIREBALLRESULT | FIREBALLRESULT2 | MAGICMIRRORRESULT2 | ICESTORMRESULT | SUMMONFIRERESULT |
        SUMMONFIRERESULT2 | FIRESTORMRESULT | HASTEEFFECT | HASTEEFFECT2 | SUMMONICERESULT | SUMMONICERESULT3 |
        SUMMONICERESULT6

    # EFFECTS are text the turn after the spell is cast
    PARAEFFECT : APOSS HANDED "hand" "is" "paralysed"
    {
        $return = "'s $item{HANDED} hand is paralysed";
    }

    PARAEFFECT2 : "can" APOST "move" "to" "attack"
    {
        $return = "can't move to attack";
    }

    CHARMPERSONEFFECT : "is" "charmed" "into" "making" "the" "wrong" "gesture" "with" "his" HANDED "hand"
    {
        $return = "is charmed into making the wrong gesture with his " . $item{HANDED} . " hand";
    }

    CHARMPERSONEFFECT2 : "is" "charmed" PUNCT "but" "ends" "up" "making" "the" "gestures" "he" "intended" "anyway"
    {
        $return = "is charmed, but ends up making the gestures he intended anyway";
    }

    PERMANENCYEFFECT : "makes" "the" "spell" "permanent"
    {
        $return = "makes the spell permanent";
    }

    TIMESTOPEFFECT : "This" "turn" "took" "place" "outside" "of" "time"
    {
        $return = "This turn took place outside of time";
    }

    DISEASEEFFECT1 : "is" "a" "bit" "nauseous"
    {
        $return = "is a bit nauseous";
    }

    DISEASEEFFECT2 : "is" "looking" "pale"
    {
        $return = "is looking pale";
    }

    DISEASEEFFECT3 : "is" "having" "difficulty" "breathing"
    {
        $return = "is having difficulty breathing";
    }

    DISEASEEFFECT4 : "is" "sweating" "feverishly"
    {
        $return = "is sweating feverishly";
    }

    DISEASEEFFECT5 : "staggers" "weakly"
    {
        $return = "staggers weakly";
    }

    DISEASEEFFECT6 : "starts" "coughing" "up" "blood"
    {
        $return = "starts coughing up blood";
    }

    DISEASEEFFECT7 : APOSS "Disease" "is" "fatal"
    {
        $return = "'s Disease is fatal";
    }

    POISONEFFECT : APOSS "Poison" "is" "fatal"
    {
        $return = "'s Poison is fatal";
    }

    HASTEEFFECT : "Fast" "players" "sneak" "in" "an" "extra" "set" "of" "gestures"
    {
        $return = "Fast players sneak in an extra set of gestures";
    }

    HASTEEFFECT2 : "Fast" "warlocks" "sneak" "in" "an" "extra" "set" "of" "gestures"
    {
        $return = "Fast warlocks sneak in an extra set of gestures";
    }

    # RESULTS are text the same turn as the spell is cast
    SHIELDRESULT : "is" "covered" "by" "a" "shimmering" "shield"
    {
        $return = "is covered by a shimmering shield";
    }

    PARARESULT : APOSS "hands" "start" "to" "stiffen"
    {
        $return = "'s hands start to stiffen";
    }

    MISSILERESULT : "is" "hit" "by" "a" MAGICMISSILE PUNCT "for" INTEGER "damage"
    {
        $return = "is hit by a Magic Missile, for " . $item{INTEGER} . " damage";
    }

    COUNTERSPELLRESULT : "is" "covered" "by" "a" "magical" "glowing" "shield"
    {
        $return = "is covered by a magical glowing shield";
    }

    COUNTERSPELLRESULT3 : "A" SPELLNAME "drifts" "away" "aimlessly"
    {
        $return = "A " . $item{SPELLNAME} . " drifts away aimlessly";
    }

    CHARMPERSONRESULT : "looks" "intrigued" "by" target
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "looks intrigued by $targetname";
    }

    MISSILERESULT2 : "A" "magic" "missile" "bounces" "off" target APOSS "shield"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "A magic missile bounces off ${targetname}'s shield";
    }

    MISSILERESULT3 : "A" "magic" "missile" "flies" "off" "into" "the" "distance"
    {
        $return = "A magic missile flies off into the distance";
    }

    SUMMONMONSTERRESULT : "is" "summoned" "to" "serve" PLAYERNAME
    {
        my $turn = $globals->{current_turn};
        my $playername = $item{PLAYERNAME};

        $globals->{monsters}{$globals->{actor}}{original_owner} = $playername;
        $globals->{monsters}{$globals->{actor}}{owned_by_length}{$playername} = 1;
        $globals->{monsters}{$globals->{actor}}{current_owner} = $playername;
        $globals->{monsters}{$globals->{actor}}{turn_summoned} = $turn;
        $globals->{monsters}{$globals->{actor}}{damage_done} = 0;
        $globals->{monsters}{$globals->{actor}}{killed_by} = "";
        $globals->{monsters}{$globals->{actor}}{killed} = [];

        $return = "is summoned to serve " . $item{PLAYERNAME};
    }

    PROTECTIONRESULT : "is" "surrounded" "by" "a" "thick" "shimmering" "shield"
    {
        $return = "is surrounded by a thick shimmering shield";
    }

    AMNESIARESULT : "starts" "to" "look" "blank"
    {
        $return = "starts to look blank";
    }

    AMNESIAEFFECT : "forgets" "what" "he" APOSS "doing" PUNCT "and" "makes" "the" "same" "gestures" "as" "last" "round"
    {
        $return = "forgets what he's doing, and makes the same gestures as last round";
    }

    CAUSEWOUNDSRESULT : "Wounds" "appear" "all" "over" target APOSS "body"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "Wounds appear all over ${targetname}'s body";
    }

    CAUSEWOUNDSRESULT2 : "Holes" "open" "up" "in" target APOSS "shield" PUNCT "but" "then" "close" "up" "again"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "Holes open up in ${targetname}'s shield, but then close up again";
    }

    CONFUSIONRESULT : "looks" "a" "bit" "confused"
    {
        $return = "looks a bit confused";
    }

    CONFUSIONRESULT2 : APOSS "shield" "blurs" "for" "a" "moment"
    {
        $return = "'s shield blurs for a moment";
    }

    CONFUSIONEFFECT : "confusedly" "makes" "the" "wrong" "gesture" "with" "his" HANDED "hand"
    {
        $return = "confusedly makes the wrong gesture with his " . $item{HANDED} . " hand";
    }

    CONFUSIONEFFECT2 : "makes" "a" "confused" "gesture" PUNCT "but" "luckily" "it" APOSS "what" "he" "intended" "anyway"
    {
        $return = "makes a confused gesture, but luckily it's what he intended anyway";
    }

    CHARMMONSTERRESULT : "looks" PUNCT "glassy-eyed" PUNCT "at" PLAYERNAME
    {
        $globals->{monsters}{$globals->{actor}}{current_owner} = $item{PLAYERNAME};
        $globals->{monsters}{$globals->{actor}}{owned_by_length}{$item{PLAYERNAME}} += 1;
        $return = "looks, glassy-eyed, at " . $item{PLAYERNAME};
    }

    CUREWOUNDSRESULT : "is" "healed"
    {
        $return = "is healed";
    }

    CUREWOUNDSRESULT3 : "Tiny" "holes" "in" target APOSS "shield" "are" "sealed" "up"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "Tiny holes in ${targetname}'s shield are sealed up";
    }

    CUREWOUNDSRESULT2 : "is" "at" "maximum" "health"
    {
        $return = "is at maximum health";
    }

    MALADROITRESULT : "starts" "to" "lose" "coordination"
    {
        $return = "starts to lose coordination";
    }

    CANCELENCHANTMENT : "shakes" "his" "head" "and" "regains" "control" PUNCT "as" "enchantments" "cancel" "each" "other" "out"
    {
        $return = "shakes his head and regains control, as enchantments cancel each other out";
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

    SUMMONMONSTERRESULT2 : APOSS MONSTERNAME "is" "absorbed" "into" "a" "Counterspell" "glow"
    {
        $return = "'s $item{MONSTERNAME} is absorbed into a Counterspell glow";
    }

    INVISRESULT2 : "There" "is" "a" "flash" PUNCT "and" PLAYERNAME "disappears"
    {
        $return = "There is a flash, and " . $item{PLAYERNAME} . " disappears";
    }

    ANTISPELLRESULT : APOSS "half-done" "spells" "fizzle" "and" "die"
    {
        $return = "'s half-done spells fizzle and die";
    }

    LIGHTNINGBOLTRESULT : "is" "hit" "by" "a" "bolt" "of" "lightning" PUNCT "for" INTEGER "damage"
    {
        $return = "is hit by a bolt of lightning, for " . $item{INTEGER} . " damage";
    }

    MAGICMIRRORRESULT : "is" "covered" "by" "a" "reflective" "shield"
    {
        $return = "is covered by a reflective shield";
    }

    MAGICMIRRORRESULT2 : "The" SPELLNAME "spell" "is" "reflected" "from" target APOSS "Magic" "Mirror"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "The $item{SPELLNAME} spell is reflected from ${targetname}'s Magic Mirror";
    }

    CLAPOFLIGHTNINGRESULT : "tries" "to" "cast" "Clap" "of" "Lightning" PUNCT "but" "doesn't" "have" "the" "charge" "for" "it"
    {
        $return = "tries to cast Clap of Lightning, but doesn't have the charge for it";
    }

    PERMANENCYRESULT : "begins" "glowing" "faintly"
    {
        $return = "begins glowing faintly";
    }

    PERMANENCYRESULT2 : APOSS "shield" "intensified" "momentarily"
    {
        $return = "'s shield intensified momentarily";
    }

    BLINDNESSRESULT : APOSS "eyes" "are" "covered" "with" "scales"
    {
        $return = "'s eyes are covered with scales";
    }

    BLINDNESSRESULT2 : "Scales" "start" "to" "grow" "over" PLAYERNAME APOSS "eyes"
    {
        $return = "Scales start to grow over $item{PLAYERNAME}'s eyes";
    }

    TIMESTOPRESULT : "flickers" "out" "of" "time"
    {
        $return = "flickers out of time";
    }

    ATTACKRESULT : "attacks" target "for" INTEGER "damage"
    {
        my ($is_player, $targetname) = split /:/, $item{target};

        unless ($is_player) {
            my $currentowner =  $globals->{monsters}{$globals->{actor}}{current_owner};

            $globals->{monsters}{$globals->{actor}}{damage_done} += $item{INTEGER};
            $globals->{monsters}{$globals->{actor}}{owned_by_length}{$currentowner} += 1;
        }

        $return = "attacks $targetname for " . $item{INTEGER} . " damage";
    }

    ATTACKRESULT2 : "attacks" target PUNCT "but" "is" "deflected" "by" "a" "shield"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "attacks $targetname, but is deflected by a shield";
    }

    RESISTHEATRESULT : "is" "covered" "in" "a" "coat" "of" "sparkling" "frost"
    {
        $return = "is covered in a coat of sparkling frost";
    }

    CHARMMONSTERRESULT2  : "ignores" target APOSS "appeal" "to" "his" "baser" "instincts"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "ignores ${targetname}'s appeal to his baser instincts";
    }

    CHARMMONSTERRESULT3  : "The" "haze" "of" "an" "enchantment" "spell" "drifts" "aimlessly" "over" "the" "circle" PUNCT "and" "dissipates"
    {
        $return = "The haze of an enchantment spell drifts aimlessly over the circle, and dissipates";
    }

    DISPELMAGICRESULT : "All" "magical" "effects" "are" "erased" PUNCT "All" "other" "spells" "fail"
    {
        $return = "All magical effects are erased! All other spells fail";
    }

    REMOVEENCHANTRESULT : APOSS "surrounding" "magical" "energies" "are" "grounded"
    {
        $return = "'s surrounding magical energies are grounded";
    }

    REMOVEENCHANTRESULT2 : APOSS "shield" "flickers" PUNCT "but" "remains" "firm"
    {
        $return = "'s shield flickers, but remains firm";
    }

    FIREBALLRESULT : "A" "fireball" "strikes" target PUNCT "burning" "him" "for" INTEGER "damage"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "A fireball strikes $targetname, burning him for " . $item{INTEGER} . " damage";
    }

    FIREBALLRESULT2 : "A" "fireball" "strikes" PUNCT "and" "flames" "roar" "all" "around" target APOSS "shield"
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "A fireball strikes, and flames roar all around ${targetname}'s shield";
    }

    DISEASERESULT : "starts" "to" "look" "sick"
    {
        $return = "starts to look sick";
    }

    ICESTORMRESULT : "An" "Ice" "Storm" "rages" "through" "the" "circle"
    {
        $return = "An Ice Storm rages through the circle";
    }

    ICESTORMRESULT2 : "is" "frozen" "by" "the" "raging" "Ice" "Storm" PUNCT "for" INTEGER "damage"
    {
        $return = "is frozen by the raging Ice Storm, for " . $item{INTEGER} . " damage";
    }

    ICESTORMRESULT3 : "looks" "comfortable" "in" "the" "cooling" "Ice" "Storm"
    {
        $return = "looks comfortable in the cooling Ice Storm";
    }

    SUMMONFIRERESULT : "A" "Fire" "Elemental" "appears" "in" "a" "furious" "roar" "of" "flame"
    {
        $return = "A Fire Elemental appears in a furious roar of flame";
    }

    SUMMONFIRERESULT2 : "A" "Fire" "Elemental" "flies" "away" "with" "the" "storm"
    {
        $return = "A Fire Elemental flies away with the storm";
    }

    FIRESTORMRESULT3 : "basks" "in" "the" "heat" "of" "the" "Fire" "Storm"
    {
        $return = "basks in the heat of the Fire Storm";
    }

    SUMMONMONSTERRESULT3 : "is" "hit" "by" "an" "Invisibility" "spell" PUNCT "and" "is" "annihilated" "by" "the" "magical" "overload"
    {
        $return = "is hit by an Invisibility spell, and is annihilated by the magical overload";
    }

    BLINDNESSRESULT3 : "is" "hit" "by" "a" "Blindness" "spell" PUNCT "and" "is" "annihilated" "by" "the" "magical" "overload"
    {
        $return = "is hit by a Blindness spell, and is annihilated by the magical overload";
    }

    FINGEROFDEATHRESULT : "is" "touched" "with" "the" "Finger" "of" "Death"
    {
        $return = "is touched with the Finger of Death";
    }

    RESISTCOLDRESULT : "is" "covered" "by" "a" "warm" "glow"
    {
        $return = "is covered by a warm glow";
    }

    COUNTERSPELLRESULT2 : APOSS "shield" "looks" "thicker" "for" "a" "moment" PUNCT "then" "fades" "back"
    {
        $return = "'s shield looks thicker for a moment, then fades back";
    }

    FIRESTORMRESULT : "A" "Fire" "Storm" "rages" "through" "the" "circle"
    {
        $return = "A Fire Storm rages through the circle";
    }

    FIRESTORMRESULT2 : "is" "burnt" "in" "the" "raging" "Fire" "Storm" PUNCT "for" INTEGER "damage"
    {
        $return = "is burnt in the raging Fire Storm, for " . $item{INTEGER} . " damage";
    }

    POISONRESULT : "starts" "to" "look" "sick"
    {
        $return = "starts to look sick";
    }

    HASTERESULT : "speeds" "up"
    {
        $return = "speeds up";
    }

    SUMMONICERESULT : "An" "Ice" "Elemental" "appears" "in" "a" "sudden" "rush" "of" "arctic" "wind"
    {
        $return = "An Ice Elemental appears in a sudden rush of arctic wind";
    }

    SUMMONICERESULT2 : "enjoys" "the" "icy" "chill"
    {
        $return = "enjoys the icy chill";
    }

    SUMMONICERESULT3 : "The" "Ice" "Elemental" "runs" "amok"
    {
        $return = "The Ice Elemental runs amok";
    }

    SUMMONICERESULT4 : "is" "frozen" "for" INTEGER "damage"
    {
        $return = "is frozen for $item{INTEGER} damage";
    }

    SUMMONICERESULT5 : APOSS "shield" "keeps" "the" "Ice" "Elemental" "at" "bay"
    {
        $return = "'s shield keeps the Ice Elemental at bay";
    }

    SUMMONICERESULT6 : "The" "Ice" "Elemental" "flies" "away" "with" "the" "storm"
    {
        $return = "The Ice Elemental flies away with the storm";
    }

    DELAYEFFECTRESULT : "banks" "a" "spell" "for" "later"
    {
        $return = "banks a spell for later";
    }

    NORMALTURNBODYLINES : PLAYERACTIONTYPES | MONSTERTURNLINE

    PLAYERACTIONTYPES : PLAYERGESTURE | PLAYERCAST | PLAYERDIRECTS | PLAYERSPEECH | CLAPS

    GESTUREF : "wiggles" "the" "fingers" "of"
    {
        $return = "F";
    }

    GESTUREP : "proffers" "the" "palm" "of"
    {
        $return = "P";
    }

    GESTURES : "snaps" "the" "fingers" "of"
    {
        $return = "S";
    }

    GESTUREW : "waves"
    {
        $return = "W";
    }

    GESTURED : "points" "the" "digit" "of"
    {
        $return = "D";
    }

    GESTUREC : "flailingly" "half-claps"
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

    GESTURETYPE : GESTURED | GESTURES | GESTUREW | GESTUREF | GESTUREP | GESTUREC | PLAYERSTAB | NOGESTURE

    WITH : "with"

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

    PLAYERSUICIDE : "stops" "his" "heart" "through" "force" "of" "will" "alone"
    {
        $return = "stops his heart through force of will alone";
    }

    # preceded by target, these are in order by likelyhood of being cast / happening
    OTHERTURNBODYLINES : SHIELDRESULT | PARARESULT | PARAEFFECT | PARAEFFECT2 | MISSILERESULT | COUNTERSPELLRESULT |
        COUNTERSPELLRESULT2 | CHARMPERSONRESULT | CHARMPERSONEFFECT | CHARMPERSONEFFECT2 | SUMMONMONSTERRESULT |
        SUMMONMONSTERRESULT2 | SUMMONMONSTERRESULT3 | ATTACKRESULT | ATTACKRESULT2 | PROTECTIONRESULT |
        AMNESIARESULT | AMNESIAEFFECT | CONFUSIONRESULT | CONFUSIONRESULT2 | CONFUSIONEFFECT | CONFUSIONEFFECT2 |
        CHARMMONSTERRESULT | CHARMMONSTERRESULT2 | CUREWOUNDSRESULT | CUREWOUNDSRESULT2 | MALADROITRESULT |
        CANCELENCHANTMENT | FEARRESULT | FEAREFFECT | INVISRESULT | INVISEFFECT | ANTISPELLRESULT | LIGHTNINGBOLTRESULT |
        MAGICMIRRORRESULT | CLAPOFLIGHTNINGRESULT | PERMANENCYRESULT | PERMANENCYRESULT2 | PERMANENCYEFFECT |
        BLINDNESSRESULT | BLINDNESSRESULT3 | TIMESTOPRESULT | RESISTHEATRESULT |
        REMOVEENCHANTRESULT | REMOVEENCHANTRESULT2 | DISEASERESULT | DISEASEEFFECT1 | DISEASEEFFECT2 |
        DISEASEEFFECT3 | DISEASEEFFECT4 | DISEASEEFFECT5 | DISEASEEFFECT6 | DISEASEEFFECT7 | ICESTORMRESULT2 |
        ICESTORMRESULT3 | FINGEROFDEATHRESULT | RESISTCOLDRESULT | FIRESTORMRESULT2 | FIRESTORMRESULT3 | POISONRESULT |
        POISONEFFECT | HASTERESULT | SUMMONICERESULT2 | SUMMONICERESULT4 | SUMMONICERESULT5 | DELAYEFFECTRESULT |
        PLAYERSUICIDE

    PARAFCOPT : PARENDS "ParaFC" PARENDS
    {
        $return = "ParaFC";
    }

    PARAFDFOPT : PARENDS "ParaFDF" PARENDS
    {
        $return = "ParaFDF";
    }

    MALADROITOPT : PARENDS "Maladroit" PARENDS
    {
        $return = "Maladroit";
    }

    CAUSEHEAVYWOUNDS : "Cause" "Heavy" "Wounds"
    {
        $return = "Cause Heavy Wounds";
    }

    CAUSELIGHTWOUNDS : "Cause" "Light" "Wounds"
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

    CLAPOFLIGHTNING : "Clap" "of" "Lightning"
    {
        $return = "Clap of Lightning";
    }

    COUNTERSPELL : "Counter" "Spell"
    {
        $return = "Counter Spell";
    }

    CUREHEAVYWOUNDS : "Cure" "Heavy" "Wounds"
    {
        $return = "Cure Heavy Wounds";
    }

    CURELIGHTWOUNDS : "Cure" "Light" "Wounds"
    {
        $return = "Cure Light Wounds";
    }

    DELAYEFFECT : "Delay" "Effect"
    {
        $return = "Delay Effect";
    }

    DISPELMAGIC : "Dispel" "Magic"
    {
        $return = "Dispel Magic";
    }

    FINGEROFDEATH : "Finger" "of" "Death"
    {
        $return = "Finger of Death";
    }

    FIRESTORM : "Fire" "Storm"
    {
        $return = "Fire Storm";
    }

    ICESTORM : "Ice" "Storm"
    {
        $return = "Ice Storm";
    }

    LIGHTNINGBOLT : "Lightning" "Bolt"
    {
        $return = "Lightning Bolt";
    }

    MAGICMIRROR : "Magic" "Mirror"
    {
        $return = "Magic Mirror";
    }

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

    SUMMONFIREELEMENTAL : "Summon" "Fire" "Elemental"
    {
        $return = "Summon Fire Elemental";
    }

    SUMMONGIANT : "Summon" "Giant"
    {
        $return = "Summon Giant";
    }

    SUMMONGOBLIN : "Summon" "Goblin"
    {
        $return = "Summon Goblin";
    }

    SUMMONICEELEMENTAL : "Summon" "Ice" "Elemental"
    {
        $return = "Summon Ice Elemental";
    }

    SUMMONOGRE : "Summon" "Ogre"
    {
        $return = "Summon Ogre";
    }

    SUMMONTROLL : "Summon" "Troll"
    {
        $return = "Summon Troll";
    }

    TIMESTOP : "Time" "Stop"
    {
        $return = "Time Stop";
    }

    CLAPS : "claps"
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{actor};

        $globals->{turnlist}[$turn]->{$player}{gesture}{right} = 'C';
        $globals->{turnlist}[$turn]->{$player}{gesture}{left} = 'C';

        $return = "claps";
    }

    MONSTERLIST : MONSTERNAME HEALTH DASH(?) AFFECTEDBYITEM(s?) "Owned" "by" COLON PLAYERTARGET "Attacking" COLON target
    {
        my $dash = $item{DASH} ? ' - ' : '';
        my ($is_player_target, $targetname) = split /:/, $item{target};
        my ($is_player_owner, $playername) = split /:/, $item{PLAYERTARGET};

        $return = $item{MONSTERNAME} . " " . $item{HEALTH} . $dash;
        if ($item{AFFECTEDBYITEM}) {
            $return .= join(' ', @{$item{AFFECTEDBYITEM}});
        }
        $return .= " Owned by : $playername Attacking : $targetname";

    }

    PLAYERREGISTERED : "Registered" PUNCT
    {
        $return = "Registered!";
    }

    PLAYERDEAD : "Dead" PUNCT
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

    TURNLIST : "Turn" COLON TURNNUMBERS
    {
        $return = "Turn:" . $item{TURNNUMBERS};
    }

    HEALTH : PARENDS(?) "Health" COLON INTEGER PARENDS(?)
    {
        if ($item{PARENDS}) {
            $return = "(Health: " . $item{INTEGER} . ")";
        } else {
            $return = "Health: " . $item{INTEGER};
        }
    }

    PLAYERSURRENDERED : "Surrendered" PUNCT
    {
        $return = "Surrendered.";
    }

    AFFECTEDBYTYPE : /Afraid|Blindness|Charmed|Coldproof|Confused|Delay|Disease|Fireproof|Forgetful|Haste|Invisibility|Maladroit|MShield|Paralysed|Permanency|Poison|Shield|TimeOut/

    DURATION : INTEGER | /permanent/i

    AFFECTEDBYITEM : AFFECTEDBYTYPE PARENDS DURATION PARENDS
    {
        $return = $item{AFFECTEDBYTYPE} . "(" . $item{DURATION} . ")";
    }

    BANKEDSPELL : PARENDS "Banked" COLON SPELLNAME PARENDS
    {
      $return = "(Banked: " . $item{SPELLNAME} . ")";
    }

    SURRENDERORDEAD : PLAYERSURRENDERED | PLAYERDEAD

    PLAYERLINES : PLAYERREGISTERED(?) PLAYERNAME PARENDS INTEGER PARENDS SURRENDERORDEAD(?) HEALTH(?) DASH(?) AFFECTEDBYITEM(s?) BANKEDSPELL(?) TURNLIST PLAYERGESTURES
    {
        my $player = $item{PLAYERNAME};
        my $gestures = $item{PLAYERGESTURES};

        ($globals->{$player}{gestures}{left}) = ($gestures =~ /LH[:]B(.*?)\n/s);
        ($globals->{$player}{gestures}{right}) = ($gestures =~ /RH[:]B(.*?)\n+/s);

        if ($item{PLAYERREGESTERED}) {
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
        if ($item{AFFECTEDBYITEM}) {
            $return .= join(' ', @{$item{AFFECTEDBYITEM}});
        }
        if ($item{BANKEDSPELL}) {
            $return .= " $item{BANKEDSPELL}";
        }
        $return .= "\n$item{TURNLIST}";
        $return .= "\n$item{PLAYERGESTURES}";
    }

    TURNBODY : TURNBODYTYPES PUNCT
    {
        my $turn = $globals->{current_turn};
        my $turntext = $item{TURNBODYTYPES} . $item{PUNCT};

        $globals->{turnlist}[$turn]->{gametext} .= ($globals->{turnlist}[$turn]->{gametext} ? "\n" : "") . $turntext;
    }

    TURNSECTION : TURNLINE TURNBODY(s?)
    {
        $return = $item{TURNLINE} . "\n";
        if ($item{TURNBODY}) {
            $return .= join("\n", @{$item{TURNBODY}});
        } else {
            $return = 1;
        }
    }

    EOFILE : /[\n\s]*/ms
    {
        1;
    }

    startrule : PREAMBLE TURNSECTION(s) MONSTERLIST(s?) PLAYERLIST EOFILE

    TURNSINGAME : /(?:.*?)Turn \d+ in/ms

    PREAMBLE : TURNSINGAME GAMETYPE MODIFIER(s?) "Battle" GAMEID
    {
        $return = $item{TURNSINGAME} . " " . $item{GAMETYPE};

        if ($item{MODIFIER}) {
            $return .= " " . $item{MODIFIER};
        }

        $return .= " Battle " . $item{GAMEID};
    }

    MODIFIER : PARAFCOPT | PARAFDFOPT | MALADROITOPT
    {
        push @{$globals->{game_modifiers}}, $item[1];

        $return = $item[1];
    }

    FORMONEY : "Ladder" | "Melee"

    VERYFRIENDLY : "Very" "Friendly"
    {
        $return = "Very Friendly";
    }

    FORPRIDE : VERYFRIENDLY | "Friendly"

    GAMETYPE : FORMONEY | FORPRIDE
    {
        $globals->{gametype} = $item[1];
    }

    GAMEID : INTEGER
    {
        $globals->{gameid} = $item{INTEGER};
        $return = $item{INTEGER};
    }

    TURNLINE : "Turn" INTEGER
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
            my $rule2 = "LISTOFPLAYERS : PLAYERLINES($playercount)";
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

    ISVICTORIOUS : "is" "victorious"
    {
        $return = "is victorious";
    }

    IGNOBLEEND : "No" "Warlocks" "remaining" PUNCT "An" "ignominious" "end" "to" "a" "battle"
    {
        $return = "No Warlocks remaining. An ignominious end to a battle";
    }

    POSSIBLEOUTCOME : "dies" | ISVICTORIOUS | "surrenders"

    TARGETOUTCOME : target POSSIBLEOUTCOME
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        if (grep {$_ eq $targetname} @{$globals->{players}}) {
            if ($item{possibleoutcome} =~ /victorious/) {
                $globals->{$targetname}{winner} = 1;
                $globals->{winner} = $targetname;
            } elsif ($item{possibleoutcome} =~ /dies/) {
                $globals->{$targetname}{died} = 1;
            } else {
                $globals->{$targetname}{surrendered} = 1;
            }
        }

        $return = $targetname . " " . $item{POSSIBLEOUTCOME};
    }

    GAMEOUTCOME : IGNOBLEEND | TARGETOUTCOME

    PLAYERSPEECH : "says" /"(.*?)"\.\n/sm
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{actor};

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


    PLAYERBOWS : BOWNAME "bows"
    {
        my $player = $item[1];
        push @{$globals->{players}}, $player;

        $globals->{turnlist}[0]->{$player}{gesture}{left} = 'B';
        $globals->{turnlist}[0]->{$player}{gesture}{right} = 'B';
        $return = "$player bows";
    }

    ACTOR : target
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $globals->{actor} = $targetname;
        $globals->{actor_is_player} = $is_player;
    }

    TURNBODYTYPES : PLAYERBOWS | TURNBODYLINES | SPECIALTURNBODYLINES | GAMEOUTCOME

    ATTACKRESULT3 : "swings" "wildly" "for" target BUTMISSES
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "swings wildy for ${targetname}$item{BUTMISSES}";
    }

    BLINDORINVIS : /blindness|invisibility/

    MISSREASON : "due" "to" BLINDORINVIS
    {
        $return = "due to $item{BLINDORINVIS}";
    }

    MISSDEFLECT : "is" "deflected" "by" "a" "shield"
    {
        $return = "is deflected by a shield";
    }

    MISSTRIP : "trips" "on" "its" "feet"
    {
        $return = "trips on its feet";
    }

    MISSMISSES : "misses" MISSREASON(?)
    {
        $return = "misses" . ($item{MISSREASON} ? " $item{MISSREASON}" : "");
    }

    MISSTYPE : MISSMISSES | MISSDEFLECT | MISSTRIP

    BUTMISSES : PUNCT "but" MISSTYPE
    {
        $return = "$item{PUNCT} but $item{misstype}";
    }

    ATTACKVERB : "for" | "does"

    ATTACKSUCCESS : ATTACKVERB INTEGER "damage"
    {
        $return = "$item{attackverb} $item{INTEGER} damage"
    }

    ATTACKFRUITLESS : PUNCT "fruitlessly"
    {
        $return = $item{PUNCT} . " fruitlessly";
    }

    ATTACKOUTCOME : ATTACKFRUITLESS | BUTMISSES | ATTACKSUCCESS

    ATTACKLINE : TRIESTO(?) "attack" target ATTACKOUTCOME
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = ($item{TRIESTO} ? "tries to attack" : "attacks") . " $targetname $item{ATTACKOUTCOME}";
    }

    HISBANKED : "his" "banked"
    {
        $return = "his banked";
    }

    ATON : "at" | "on"

    VERY : "Very"

    GOBLINADJ : /Bearded|Belligerent|Fat|Green|Grey|Horrid|Malodorous|Nasty|Ratty|Small|Smelly|Tricky|Ugly/ | #nothing

    GOBLINNAME : GOBLINADJ "Goblin"
    {
        my $adj = $item{GOBLINADJ} ? "$item{GOBLINADJ} " : "";
        $return = $adj . "Goblin";
    }

    OGREADJ : /Angry|Black|Burnt|Crazy|Monstrous|Obtuse|Ochre|Stinking|Terrible|Yellow/ | #nothing

    OGRENAME : OGREADJ "Ogre"
    {
        my $adj = $item{OGREADJ} ? "$item{OGREADJ} " : "";
        $return = $adj . "Ogre";
    }

    TROLLADJ : /Bridge|Green|Hairy|Ham-fisted|Irate|Loud|Mailing-list|Obnoxious|Stupid|Tall/ | #nothing

    TROLLNAME : TROLLADJ "Troll"
    {
        my $adj = $item{TROLLADJ} ? "$item{TROLLADJ} " : "";
        $return = $adj . "Troll";
    }

    GIANTADJ : /Beanstalk|Big|Gaunt|Golden|Hungry|Large|Norse/ | #nothing

    GIANTNAME : GIANTADJ "Giant"
    {
        my $adj = $item{GIANTADJ} ? "$item{GIANTADJ} " : "";
        $return = $adj . "Giant";
    }

    ARTICLE : /the|an|a/i | #nothing

    STORMTYPE : "Ice" | "Fire"

    ELEMENTALNAME : ARTICLE STORMTYPE "Elemental"
    {
        my $article = $item{ARTICLE} ? "$item{ARTICLE} " : "";
        $return = $article . $item{STORMTYPE} . " Elemental";
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

    BURSTOFSPEED : "In" "a" "burst" "of" "speed" PUNCT
    {
        $return = "In a burst of speed,";
    }

    OUTSIDETIME : "Outside" "time" PUNCT
    {
        $return = "Outside time,";
    }

    TRIESTO : "tries" "to"
    {
        $return = "tries to";
    }

    MONSTERWANDERS : "wanders" "around" "aimlessly"
    {
        $return = "wanders around aimlessly";
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

    MONSTERELEMENTAL : "is" "summoned" "inside" ELEMENTALNAME "and" "is" "consumed" "instantly"
    {
        $return = "is summoned inside $item{ELEMENTALNAME} and is consumed instantly";
    }

    MONSTERTURNLINE : ATTACKRESULT3 | MONSTERWANDERS | MONSTERFORGETS | NOTARGET | MONSTERSCARED | MONSTERELEMENTAL

    POTENTIALMONSTER : "the" "monster" PLAYERNAME "is" "summoning" "with" "his" HANDED "hand"
    {
        $return = "the monster " . $item{PLAYERNAME} . " is summoning with his " . $item{HANDED} . " hand";
    }

    MONSTERTARGET : POTENTIALMONSTER | MONSTERNAME
    {
        $return = "0:$item[1]";
    }

    PLAYERCAST : "casts" HISBANKED(?) SPELLNAME ATON target BUTMISSES(?)
    {
        my $turn = $globals->{current_turn};
        my $player = $globals->{actor};
        my $spell = $item{SPELLNAME};
        my ($is_player, $targetname) = split /:/, $item{target};
        my $success = $item{BUTMISSES} == undef;

        if ($item{HISBANKED}) {
            $globals->{turnlist}[$turn]->{$player}{spells}{banked}{$spell}{count}++;
            $globals->{turnlist}[$turn]->{$player}{spells}{banked}{$spell}{success} = $success;
            $globals->{turnlist}[$turn]->{$player}{spells}{banked}{$spell}{target} = $targetname;
        } else {
            $globals->{turnlist}[$turn]->{$player}{spells}{$spell}{count}++;
            $globals->{turnlist}[$turn]->{$player}{spells}{$spell}{success} = $success;
            $globals->{turnlist}[$turn]->{$player}{spells}{$spell}{target} = $targetname;
        }

        my $hisbanked = " ";
        if ($item{HISBANKED}) {
            $hisbanked = " his banked ";
        }
        my $butmisses = "";
        if ($item{BUTMISSES}) {
            $butmisses = " $item{BUTMISSES}";
        }

        $return = "casts${hisbanked}${spell} $item{ATON} ${targetname}${butmisses}";
    }

    PLAYERDIRECTS : "directs" MONSTERNAME "to" "attack" target
    {
        my ($is_player, $targetname) = split /:/, $item{target};
        $return = "directs " . $item{MONSTERNAME} . " to attack $targetname";
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
        undef $::RD_HINT; undef $::RD_TRACE;
    }

    return $self;
}

1;

