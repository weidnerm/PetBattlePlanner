-- ****************************************************
-- * DECLARE VARIABLES *
-- ****************************************************
local darkGrey   = "|c00252525";
local mediumGrey = "|c00707070";
local lightGrey  = "|c009d9d9d";
local yellow = "|c00FFFF25";
local white  = "|c00FFFFff";
local red    = "|c00FF0000";
local green  = "|c001eff00";
local blue   = "|c000080ff";
local purple = "|c00b048f8";
local orange = "|c00ff8000";
local gold   = "|c00e6cc80";
  



local PetBattlePlanner_lastTargetName;
local PET_OWNER_PLAYER = 1;
local PET_OWNER_OPPONENT = 2;

local PetBattlePlanner_OpponentName = "Kafi";
local PetBattlePlanner_OpponentPetIndex = 1;
local PetBattlePlanner_local_db;
local PetBattlePlanner_CurrentPetIndexInJournal = 0;

local PET_TYPE_TEXT = {
   "Humanoid",    -- 1 
   "Dragonkin",   -- 2 
   "Flying",      -- 3 
   "Undead",      -- 4 
   "Critter",     -- 5 
   "Magic",       -- 6 
   "Elemental",   -- 7 
   "Beast",       -- 8 
   "Aquatic",     -- 9 
   "Mechanical",  -- 10
}

local RARITY_TEXT = {
   mediumGrey.."Poor",       -- "Poor",       
   white.."Common",     -- "Common",     
   green.."Uncommon",   -- "Uncommon",   
   blue.."Rare",       -- "Rare",       
   purple.."Epic",       -- "Epic",       
   orange.."Legendary"   -- "Legendary"   
}

local RARITY_COLOR = {
   mediumGrey,       -- "Poor",       
   white,     -- "Common",     
   green,   -- "Uncommon",   
   blue,       -- "Rare",       
   purple,       -- "Epic",       
   orange   -- "Legendary"   
}
   

local ATTACK_WEAK    = 1;
local ATTACK_NEUTRAL = 2;
local ATTACK_STRONG  = 3;

local ATTACK_RESULT_TEXT = {
   "Weak",     
   "Neutral",
   "Strong"
   }

local ATTACK_RESULT_TEXTURES = {
   "Interface\\PetBattles\\BattleBar-AbilityBadge-Weak", -- "Weak",
   nil,                                                  -- "Neutral",  
   "Interface\\PetBattles\\BattleBar-AbilityBadge-Strong"   -- "Strong" 
}

local ATTACK_RESULT_COLOR = {
   red,     
   yellow,
   green
   }
   
local DEFENSE_RESULT_RATING_TEXT = {
   "Good",  -- ATTACK_WEAK    = 1;
   "Ok",    -- ATTACK_NEUTRAL = 2;
   "Bad"    -- ATTACK_STRONG  = 3;
   }   

local OFFENSE_RESULT_RATING_TEXT = {
   "Bad",   -- ATTACK_WEAK    = 1;
   "Ok",    -- ATTACK_NEUTRAL = 2;
   "Good"   -- ATTACK_STRONG  = 3;
   }   

local PET_TYPE_TEXTURES = {
   "Interface\\TARGETINGFRAME\\PetBadge-Humanoid"     ,  -- "Humanoid",    -- 1  
   "Interface\\TARGETINGFRAME\\PetBadge-Dragon"       ,  -- "Dragonkin",   -- 2  
   "Interface\\TARGETINGFRAME\\PetBadge-Flying"       ,  -- "Flying",      -- 3  
   "Interface\\TARGETINGFRAME\\PetBadge-Undead"       ,  -- "Undead",      -- 4  
   "Interface\\TARGETINGFRAME\\PetBadge-Critter"      ,  -- "Critter",     -- 5  
   "Interface\\TARGETINGFRAME\\PetBadge-Magical"      ,  -- "Magic",       -- 6  
   "Interface\\TARGETINGFRAME\\PetBadge-Elemental"    ,  -- "Elemental",   -- 7  
   "Interface\\TARGETINGFRAME\\PetBadge-Beast"        ,  -- "Beast",       -- 8  
   "Interface\\TARGETINGFRAME\\PetBadge-Water"        ,  -- "Aquatic",     -- 9  
   "Interface\\TARGETINGFRAME\\PetBadge-Mechanical"   ,  -- "Mechanical",  -- 10 
}

local REORDER_ABILITIES_IN_PAIRS = {
   1,
   4,
   2,
   5,
   3,
   6
}  

local NON_DAMAGE_ABILITY_LIST = 
{
	[188] = true,     -- name:"Accuracy"               type:2}
	[197] = true,     -- name:"Adrenal Glands"         type:5}
	[667] = true,     -- name:"Aged Yolk"              type:0}
	[488] = true,     -- name:"Amplify Magic"          type:5}
	[611] = true,     -- name:"Ancient Blessing"       type:1}
	[519] = true,     -- name:"Apocalypse"             type:4}
	[964] = true,     -- name:"Autumn Breeze"          type:6}
	[348] = true,     -- name:"Bash"                   type:7}
	[325] = true,     -- name:"Beaver Dam"             type:4}
	[919] = true,     -- name:"Black Claw"             type:7}
	[227] = true,     -- name:"Blackout Kick"          type:0}
	[539] = true,     -- name:"Bleat"                  type:4}
	[934] = true,     -- name:"Bubble"                 type:0}
	[578] = true,     -- name:"Buried Treasure"        type:4}
	[173] = true,     -- name:"Cauterize"              type:6}
	[936] = true,     -- name:"Caw"                    type:2}
	[230] = true,     -- name:"Cleansing Rain"         type:8}
	[350] = true,     -- name:"Clobber"                type:0}
	[665] = true,     -- name:"Consume Corpse"         type:3}
	[932] = true,     -- name:"Croak"                  type:8}
	[165] = true,     -- name:"Crouch"                 type:4}
	[263] = true,     -- name:"Crystal Overload"       type:6}
	[569] = true,     -- name:"Crystal Prison"         type:7}
	[905] = true,     -- name:"Cute Face"              type:0}
	[794] = true,     -- name:"Dark Rebirth"           type:6}
	[476] = true,     -- name:"Dark Simulacrum"        type:3}
	[366] = true,     -- name:"Dazzling Dance"         type:4}
	[334] = true,     -- name:"Decoy"                  type:9}
	[490] = true,     -- name:"Deflection"             type:0}
	[312] = true,     -- name:"Dodge"                  type:0}
	[835] = true,     -- name:"Eggnog"                 type:0}
	[598] = true,     -- name:"Emerald Dream"          type:1}
	[597] = true,     -- name:"Emerald Presence"       type:1}
	[440] = true,     -- name:"Evanescence"            type:5}
	[305] = true,     -- name:"Exposed Wounds"         type:7}
	[392] = true,     -- name:"Extra Plating"          type:9}
	[568] = true,     -- name:"Feign Death"            type:7}
	[426] = true,     -- name:"Focus"                  type:0}
	[223] = true,     -- name:"Focus Chi"              type:0}
	[580] = true,     -- name:"Food Coma"              type:4}
	[521] = true,     -- name:"Hawk Eye"               type:2}
	[168] = true,     -- name:"Healing Flame"          type:1}
	[922] = true,     -- name:"Healing Stream"         type:8}
	[123] = true,     -- name:"Healing Wave"           type:8}
	[279] = true,     -- name:"Heartbroken"            type:9}
	[945] = true,     -- name:"Heat Up"                type:6}
	[247] = true,     -- name:"Hibernate"              type:7}
	[941] = true,     -- name:"High Fiber"             type:0}
	[766] = true,     -- name:"Holy Justice"           type:0}
	[362] = true,     -- name:"Howl"                   type:7}
	[479] = true,     -- name:"Ice Barrier"            type:6}
	[465] = true,     -- name:"Illusionary Barrier"    type:5}
	[216] = true,     -- name:"Inner Vision"           type:5}
	[298] = true,     -- name:"Inspiring Song"         type:6}
	[259] = true,     -- name:"Invisibility"           type:5}
	[431] = true,     -- name:"Jadeskin"               type:5}
	[277] = true,     -- name:"Life Exchange"          type:5}
	[906] = true,     -- name:"Lightning Shield"       type:6}
	[776] = true,     -- name:"Love Potion"            type:0}
	[772] = true,     -- name:"Lovestruck"             type:0}
	[757] = true,     -- name:"Lucky Dance"            type:4}
	[314] = true,     -- name:"Mangle"                 type:7}
	[573] = true,     -- name:"Nature's Touch"         type:4}
	[574] = true,     -- name:"Nature's Ward"          type:6}
	[522] = true,     -- name:"Nevermore"              type:2}
	[576] = true,     -- name:"Perk Up"                type:4}
	[764] = true,     -- name:"Phase Shift"            type:5}
	[268] = true,     -- name:"Photosynthesis"         type:6}
	[303] = true,     -- name:"Plant"                  type:6}
	[444] = true,     -- name:"Prismatic Barrier"      type:5}
	[536] = true,     -- name:"Prowl"                  type:7}
	[533] = true,     -- name:"Rebuild"                type:9}
	[511] = true,     -- name:"Renewing Mists"         type:8}
	[278] = true,     -- name:"Repair"                 type:9}
	[770] = true,     -- name:"Restoration"            type:0}
	[763] = true,     -- name:"Sear Magic"             type:5}
	[310] = true,     -- name:"Shell Shield"           type:7}
	[760] = true,     -- name:"Shield Block"           type:0}
	[330] = true,     -- name:"Sons of the Flame"      type:6}
	[497] = true,     -- name:"Soothe"                 type:4}
	[396] = true,     -- name:"Soothing Mists"         type:6}
	[751] = true,     -- name:"Soul Ward"              type:0}
	[315] = true,     -- name:"Spiked Skin"            type:1}
	[914] = true,     -- name:"Spirit Spikes"          type:5}
	[225] = true,     -- name:"Staggered Steps"        type:0}
	[527] = true,     -- name:"Stench"                 type:4}
	[791] = true,     -- name:"Stimpack"               type:5}
	[436] = true,     -- name:"Stoneskin"              type:5}
	[208] = true,     -- name:"Supercharge"            type:9}
	[283] = true,     -- name:"Survival"               type:4}
	[318] = true,     -- name:"Thorns"                 type:6}
	[254] = true,     -- name:"Tranquility"            type:4}
	[960] = true,     -- name:"Trihorn Shield"         type:7}
	[252] = true,     -- name:"Uncanny Luck"           type:4}
	[592] = true,     -- name:"Wild Magic"             type:5}
	[273] = true      -- name:"Wish"                   type:5}
}

local DAMAGE_ABILITY_LIST = 
{
    [756] = true,    -- name:"Acid Touch"             type:8}  aquatic
    [423] = true,    -- name:"Blood in the Water"     type:8}  aquatic
    [448] = true,    -- name:"Creeping Ooze"          type:8}  aquatic
    [564] = true,    -- name:"Dive"                   type:8}  aquatic
    [233] = true,    -- name:"Frog Kiss"              type:8}  aquatic
    [249] = true,    -- name:"Grasp"                  type:8}  aquatic
    [509] = true,    -- name:"Surge"                  type:8}  aquatic
    [276] = true,    -- name:"Swallow You Whole"      type:8}  aquatic
    [424] = true,    -- name:"Tail Slap"              type:8}  aquatic
    [419] = true,    -- name:"Tidal Wave"             type:8}  aquatic
    [118] = true,    -- name:"Water Jet"              type:8}] aquatic
    [297] = true,    -- pump                                   aquatic
    [513] = true,    -- whirlpool                              aquatic
    [352] = true,    -- name:"Banana Barrage"         type:7}  beast
    [110] = true,    -- name:"Bite"                   type:7}  beast
    [917] = true,    -- name:"Bloodfang"              type:7}  beast
    [382] = true,    -- name:"Brittle Webbing"        type:7}  beast
    [159] = true,    -- name:"Burrow"                 type:7}  beast
    [429] = true,    -- name:"Claw"                   type:7}  beast
    [538] = true,    -- name:"Devour"                 type:7}  beast
    [412] = true,    -- name:"Gnaw"                   type:7}  beast
    [916] = true,    -- name:"Haywire"                type:7}  beast
    [376] = true,    -- name:"Headbutt"               type:7}  beast
    [155] = true,    -- name:"Hiss"                   type:7}  beast
    [571] = true,    -- name:"Horn Attack"            type:7}  beast
    [930] = true,    -- name:"Huge Fang"              type:7}  beast
    [849] = true,    -- name:"Huge,Sharp Teeth!"      type:7}  beast
    [921] = true,    -- name:"Hunting Party"          type:7}  beast
    [800] = true,    -- name:"Impale"                 type:7}  beast
    [364] = true,    -- name:"Leap"                   type:7}  beast
    [345] = true,    -- name:"Maul"                   type:7}  beast
    [152] = true,    -- name:"Poison Fang"            type:7}  beast
    [380] = true,    -- name:"Poison Spit"            type:7}  beast
    [535] = true,    -- name:"Pounce"                 type:7}  beast
    [920] = true,    -- name:"Primal Cry"             type:7}  beast
    [492] = true,    -- name:"Rake"                   type:7}  beast
    [124] = true,    -- name:"Rampage"                type:7}  beast
    [802] = true,    -- name:"Ravage"                 type:7}  beast
    [441] = true,    -- name:"Rend"                   type:7}  beast
    [803] = true,    -- name:"Rip"                    type:7}  beast
    [347] = true,    -- name:"Roar"                   type:7}  beast
    [567] = true,    -- name:"Rush"                   type:7}  beast
    [357] = true,    -- name:"Screech"                type:7}  beast
    [929] = true,    -- name:"Slither"                type:7}  beast
    [349] = true,    -- name:"Smash"                  type:7}  beast
    [356] = true,    -- name:"Snap"                   type:7}  beast
    [250] = true,    -- name:"Spiderling Swarm"       type:7}  beast
    [339] = true,    -- name:"Sticky Web"             type:7}  beast
    [378] = true,    -- name:"Strike"                 type:7}  beast
    [202] = true,    -- name:"Thrash"                 type:7}  beast
    [377] = true,    -- name:"Trample"                type:7}  beast
    [958] = true,    -- name:"Trihorn Charge"         type:7}  beast
    [355] = true,    -- name:"Triple Snap"            type:7}  beast
    [375] = true,    -- name:"Trumpet Strike"         type:7}  beast
    [156] = true,    -- name:"Vicious Fang"           type:7}  beast
    [411] = true,    -- name:"Woodchipper"            type:7}] beast
    [354] = true,    -- Barrel Toss                            beast
    [359] = true,    -- Sting                                  beast
    [162] = true,    -- name:"Adrenaline Rush"        type:4}  critter
    [367] = true,    -- name:"Chomp"                  type:4}  critter
    [253] = true,    -- name:"Comeback"               type:4}  critter
    [642] = true,    -- name:"Egg Barrage"            type:4}  critter
    [193] = true,    -- name:"Flank"                  type:4}  critter
    [360] = true,    -- name:"Flurry"                 type:4}  critter
    [579] = true,    -- name:"Gobble Strike"          type:4}  critter
    [493] = true,    -- name:"Hoof"                   type:4}  critter
    [572] = true,    -- name:"Mudslide"               type:4}  critter
    [167] = true,    -- name:"Nut Barrage"            type:4}  critter
    [566] = true,    -- name:"Powerball"              type:4}  critter
    [563] = true,    -- name:"Quick Attack"           type:4}  critter
    [119] = true,    -- name:"Scratch"                type:4}  critter
    [626] = true,    -- name:"Skitter"                type:4}  critter
    [163] = true,    -- name:"Stampede"               type:4}  critter
    [706] = true,    -- name:"Swarm"                  type:4}  critter
    [228] = true,    -- name:"Tongue Lash"            type:4}  critter
    [851] = true,    -- name:"Vicious Streak"         type:4}] critter
    [369] = true,    -- Acidic Goo                             critter
    [541] = true,    -- Chew                                   critter
    [232] = true,    -- Swarm of Flies                         critter
    [115] = true,    -- name:"Breath"                 type:1}  dragonkin
    [607] = true,    -- name:"Cataclysm"              type:1}  dragonkin
    [169] = true,    -- name:"Deep Breath"            type:1}  dragonkin
    [501] = true,    -- name:"Flame Breath"           type:1}  dragonkin
    [782] = true,    -- name:"Frost Breath"           type:1}  dragonkin
    [609] = true,    -- name:"Instability"            type:1}  dragonkin
    [612] = true,    -- name:"Proto-Strike"           type:1}  dragonkin
    [809] = true,    -- name:"Roll"                   type:1}  dragonkin
    [172] = true,    -- name:"Scorched Earth"         type:1}  dragonkin
    [393] = true,    -- name:"Shadowflame"            type:1}  dragonkin
    [784] = true,    -- name:"Shriek"                 type:1}  dragonkin
    [594] = true,    -- name:"Sleeping Gas"           type:1}  dragonkin
    [258] = true,    -- name:"Starfall"               type:1}  dragonkin
    [122] = true,    -- name:"Tail Sweep"             type:1}] dragonkin
    [606] = true,    -- Elementium Bolt                        dragonkin
    [529] = true,    -- name:"Belly Slide"            type:6}  elemental
    [113] = true,    -- name:"Burn"                   type:6}  elemental
    [206] = true,    -- name:"Call Blizzard"          type:6}  elemental
    [179] = true,    -- name:"Conflagrate"            type:6}  elemental
    [792] = true,    -- name:"Darkflame"              type:6}  elemental
    [481] = true,    -- name:"Deep Freeze"            type:6}  elemental
    [405] = true,    -- name:"Early Advantage"        type:6}  elemental
    [901] = true,    -- name:"Fel Immolate"           type:6}  elemental
    [860] = true,    -- name:"Flamethrower"           type:6}  elemental
    [503] = true,    -- name:"Flamethrower"           type:6}  elemental
    [414] = true,    -- name:"Frost Nova"             type:6}  elemental
    [416] = true,    -- name:"Frost Shock"            type:6}  elemental
    [528] = true,    -- name:"Frost Spit"             type:6}  elemental
    [120] = true,    -- name:"Howling Blast"          type:6}  elemental
    [413] = true,    -- name:"Ice Lance"              type:6}  elemental
    [178] = true,    -- name:"Immolate"               type:6}  elemental
    [962] = true,    -- name:"Ironbark"               type:6}  elemental
    [908] = true,    -- name:"Jolt"                   type:6}  elemental
    [394] = true,    -- name:"Lash"                   type:6}  elemental
    [745] = true,    -- name:"Leech Seed"             type:6}  elemental
    [319] = true,    -- name:"Magma Wave"             type:6}  elemental
    [909] = true,    -- name:"Paralyzing Shock"       type:6}  elemental
    [398] = true,    -- name:"Poison Lash"            type:6}  elemental
    [630] = true,    -- name:"Poisoned Branch"        type:6}  elemental
    [912] = true,    -- name:"Quicksand"              type:6}  elemental
    [712] = true,    -- name:"Railgun"                type:6}  elemental
    [628] = true,    -- name:"Rock Barrage"           type:6}  elemental
    [814] = true,    -- name:"Rupture"                type:6}  elemental
    [910] = true,    -- name:"Sand Bolt"              type:6}  elemental
    [575] = true,    -- name:"Slippery Ice"           type:6}  elemental
    [477] = true,    -- name:"Snowball"               type:6}  elemental
    [753] = true,    -- name:"Solar Beam"             type:6}  elemental
    [617] = true,    -- name:"Spark"                  type:6}  elemental
    [371] = true,    -- name:"Sticky Goo"             type:6}  elemental
    [621] = true,    -- name:"Stone Rush"             type:6}  elemental
    [801] = true,    -- name:"Stone Shot"             type:6}  elemental
    [812] = true,    -- name:"Sulfuras Smash"         type:6}  elemental
    [404] = true,    -- name:"Sunlight"               type:6}  elemental
    [631] = true,    -- name:"Super Sticky Goo"       type:6}  elemental
    [779] = true,    -- name:"Thunderbolt"            type:6}] elemental
    [786] = true,    -- Blistering Cold                        elemental
    [400] = true,    -- Entangling roots                       elemental
    [418] = true,    -- Geyser                                 elemental
    [624] = true,    -- Ice tomb                               elemental
    [409] = true,    -- Immolation                             elemental
    [811] = true,    -- Magma Trap                             elemental
    [828] = true,    -- Sons of the Root                       elemental
    [746] = true,    -- Spore Shrooms                          elemental
    [402] = true,    -- Stun Seed                              elemental
    [176] = true,    -- Volcano                                elemental
    [504] = true,    -- name:"Alpha Strike"           type:2}  flying
    [506] = true,    -- name:"Cocoon Strike"          type:2}  flying
    [581] = true,    -- name:"Flock"                  type:2}  flying
    [515] = true,    -- name:"Flyby"                  type:2}  flying
    [170] = true,    -- name:"Lift-Off"               type:2}  flying
    [507] = true,    -- name:"Moth Balls"             type:2}  flying
    [508] = true,    -- name:"Moth Dust"              type:2}  flying
    [870] = true,    -- name:"Murder"                 type:2}  flying
    [517] = true,    -- name:"Nocturnal Strike"       type:2}  flying
    [112] = true,    -- name:"Peck"                   type:2}  flying
    [518] = true,    -- name:"Predatory Strike"       type:2}  flying
    [184] = true,    -- name:"Quills"                 type:2}  flying
    [186] = true,    -- name:"Reckless Strike"        type:2}  flying
    [453] = true,    -- name:"Sandstorm"              type:2}  flying
    [420] = true,    -- name:"Slicing Wind"           type:2}  flying
    [524] = true,    -- name:"Squawk"                 type:2}  flying
    [514] = true,    -- name:"Wild Winds"             type:2}] flying
    [632] = true,    -- Confusing Sting                        flying
    [190] = true,    -- Cyclone                                flying
    [270] = true,    -- Glowing toxin                          flying
    [669] = true,    -- name:"Backflip"               type:0}  Humanoid
    [713] = true,    -- name:"Blitz"                  type:0}  Humanoid
    [532] = true,    -- name:"Body Slam"              type:0}  Humanoid
    [771] = true,    -- name:"Bow Shot"               type:0}  Humanoid
    [452] = true,    -- name:"Broom"                  type:0}  Humanoid
    [256] = true,    -- name:"Call Darkness"          type:0}  Humanoid
    [778] = true,    -- name:"Charge"                 type:0}  Humanoid
    [158] = true,    -- name:"Counterstrike"          type:0}  Humanoid
    [406] = true,    -- name:"Crush"                  type:0}  Humanoid
    [668] = true,    -- name:"Dreadful Breath"        type:0}  Humanoid
    [740] = true,    -- name:"Frenzyheart Brew"       type:0}  Humanoid
    [226] = true,    -- name:"Fury of 1,000 Fists"    type:0}  Humanoid
    [788] = true,    -- name:"Gauss Rifle"            type:0}  Humanoid
    [762] = true,    -- name:"Haymaker"               type:0}  Humanoid
    [761] = true,    -- name:"Heroic Leap"            type:0}  Humanoid
    [767] = true,    -- name:"Holy Charge"            type:0}  Humanoid
    [765] = true,    -- name:"Holy Sword"             type:0}  Humanoid
    [219] = true,    -- name:"Jab"                    type:0}  Humanoid
    [307] = true,    -- name:"Kick"                   type:0}  Humanoid
    [768] = true,    -- name:"Omnislash"              type:0}  Humanoid
    [775] = true,    -- name:"Perfumed Arrow"         type:0}  Humanoid
    [111] = true,    -- name:"Punch"                  type:0}  Humanoid
    [774] = true,    -- name:"Rapid Fire"             type:0}  Humanoid
    [773] = true,    -- name:"Shot Through The Heart" type:0}  Humanoid
    [769] = true,    -- name:"Surge of Light"         type:0}  Humanoid
    [221] = true,    -- name:"Takedown"               type:0}  Humanoid
    [826] = true,    -- name:"Weakening Blow"         type:0}  Humanoid
    [741] = true,    -- name:"Whirlwind"              type:0}] Humanoid
    [421] = true,    -- name:"Arcane Blast"           type:5}  Magic
    [299] = true,    -- name:"Arcane Explosion"       type:5}  Magic
    [589] = true,    -- name:"Arcane Storm"           type:5}  Magic
    [836] = true,    -- name:"Baneling Burst"         type:5}  Magic
    [114] = true,    -- name:"Beam"                   type:5}  Magic
    [472] = true,    -- name:"Blast of Hatred"        type:5}  Magic
    [616] = true,    -- name:"Blinkstrike"            type:5}  Magic
    [838] = true,    -- name:"Centrifugal Hooks"      type:5}  Magic
    [456] = true,    -- name:"Clean-Up"               type:5}  Magic
    [614] = true,    -- name:"Competitive Spirit"     type:5}  Magic
    [447] = true,    -- name:"Corrosion"              type:5}  Magic
    [869] = true,    -- name:"Darkmoon Curse"         type:5}  Magic
    [486] = true,    -- name:"Drain Power"            type:5}  Magic
    [525] = true,    -- name:"Emerald Bite"           type:5}  Magic
    [957] = true,    -- name:"Evolution"              type:5}  Magic
    [450] = true,    -- name:"Expunge"                type:5}  Magic
    [475] = true,    -- name:"Eyeblast"               type:5}  Magic
    [484] = true,    -- name:"Feedback"               type:5}  Magic
    [463] = true,    -- name:"Flash"                  type:5}  Magic
    [473] = true,    -- name:"Focused Beams"          type:5}  Magic
    [586] = true,    -- name:"Gift of Winter's Veil"  type:5}  Magic
    [460] = true,    -- name:"Illuminate"             type:5}  Magic
    [474] = true,    -- name:"Interrupting Gaze"      type:5}  Magic
    [432] = true,    -- name:"Jade Claw"              type:5}  Magic
    [482] = true,    -- name:"Laser"                  type:5}  Magic
    [461] = true,    -- name:"Light"                  type:5}  Magic
    [478] = true,    -- name:"Magic Hat"              type:5}  Magic
    [489] = true,    -- name:"Mana Surge"             type:5}  Magic
    [194] = true,    -- name:"Metabolic Boost"        type:5}  Magic
    [407] = true,    -- name:"Meteor Strike"          type:5}  Magic
    [595] = true,    -- name:"Moonfire"               type:5}  Magic
    [608] = true,    -- name:"Nether Blast"           type:5}  Magic
    [466] = true,    -- name:"Nether Gate"            type:5}  Magic
    [437] = true,    -- name:"Onyx Bite"              type:5}  Magic
    [445] = true,    -- name:"Ooze Touch"             type:5}  Magic
    [483] = true,    -- name:"Psychic Blast"          type:5}  Magic
    [752] = true,    -- name:"Soulrush"               type:5}  Magic
    [913] = true,    -- name:"Spectral Spine"         type:5}  Magic
    [442] = true,    -- name:"Spectral Strike"        type:5}  Magic
    [593] = true,    -- name:"Surge of Power"         type:5}  Magic
    [457] = true,    -- name:"Sweep"                  type:5}  Magic
    [471] = true,    -- name:"Weakness"               type:5}  Magic
    [198] = true,    -- name:"Zergling Rush"          type:5}] Magic
    [323] = true,    -- Gravity                                Magic
    [455] = true,    -- name:"Batter"                 type:9}  Mechanical
    [647] = true,    -- name:"Bombing Run"            type:9}  Mechanical
    [204] = true,    -- name:"Call Lightning"         type:9}  Mechanical
    [943] = true,    -- name:"Chop"                   type:9}  Mechanical
    [390] = true,    -- name:"Demolish"               type:9}  Mechanical
    [282] = true,    -- name:"Explode"                type:9}  Mechanical
    [923] = true,    -- name:"Flux"                   type:9}  Mechanical
    [942] = true,    -- name:"Frying Pan"             type:9}  Mechanical
    [938] = true,    -- name:"Interrupting Jolt"      type:9}  Mechanical
    [209] = true,    -- name:"Ion Cannon"             type:9}  Mechanical
    [645] = true,    -- name:"Launch"                 type:9}  Mechanical
    [384] = true,    -- name:"Metal Fist"             type:9}  Mechanical
    [777] = true,    -- name:"Missile"                type:9}  Mechanical
    [389] = true,    -- name:"Overtune"               type:9}  Mechanical
    [644] = true,    -- name:"Quake"                  type:9}  Mechanical
    [754] = true,    -- name:"Screeching Gears"       type:9}  Mechanical
    [646] = true,    -- name:"Shock and Awe"          type:9}  Mechanical
    [937] = true,    -- name:"Siphon Anima"           type:9}  Mechanical
    [940] = true,    -- name:"Touch of the Animus"    type:9}  Mechanical
    [640] = true,    -- name:"Toxic Smoke"            type:9}  Mechanical
    [387] = true,    -- name:"Tympanic Tantrum"       type:9}  Mechanical
    [789] = true,    -- name:"U-238 Rounds"           type:9}  Mechanical
    [116] = true,    -- name:"Zap"                    type:9}] Mechanical
    [710] = true,    -- Build Turret                           Mechanical
    [293] = true,    -- Launch Rocket                          Mechanical
    [301] = true,    -- Lock on                                Mechanical
    [634] = true,    -- Minefield                              Mechanical
    [670] = true,    -- Snap Trap                              Mechanical
    [636] = true,    -- Sticky Grenade                         Mechanical
    [459] = true,    -- Wind up                                Mechanical
    [386] = true,    -- XE-321 Boombot                         Mechanical
    [449] = true,    -- name:"Absorb"                 type:3}  Undead
    [648] = true,    -- name:"Bone Bite"              type:3}  Undead
    [650] = true,    -- name:"Bone Prison"            type:3}  Undead
    [649] = true,    -- name:"BONESTORM"              type:3}  Undead
    [160] = true,    -- name:"Consume"                type:3}  Undead
    [663] = true,    -- name:"Corpse Explosion"       type:3}  Undead
    [655] = true,    -- name:"Creepy Chomp"           type:3}  Undead
    [121] = true,    -- name:"Death Coil"             type:3}  Undead
    [780] = true,    -- name:"Death Grip"             type:3}  Undead
    [499] = true,    -- name:"Diseased Bite"          type:3}  Undead
    [654] = true,    -- name:"Ghostly Bite"           type:3}  Undead
    [117] = true,    -- name:"Infected Claw"          type:3}  Undead
    [383] = true,    -- name:"Leech Life"             type:3}  Undead
    [657] = true,    -- name:"Plagued Blood"          type:3}  Undead
    [666] = true,    -- name:"Rabid Strike"           type:3}  Undead
    [422] = true,    -- name:"Shadow Shock"           type:3}  Undead
    [210] = true,    -- name:"Shadow Slash"           type:3}  Undead
    [468] = true,    -- Agony                                  Undead
    [743] = true,    -- Creeping Fungus                        Undead
    [218] = true,    -- Curse of Doom                          Undead
    [214] = true,    -- Death and Decay                        Undead
    [652] = true,    -- Haunt                                  Undead
    [212] = true,    -- Siphon Life                            Undead
    [321] = true     -- name:"Unholy Ascension"       type:3}] Undead
}

local PetBattlePlanner_SelAttackVsHim = ATTACK_STRONG;
local PetBattlePlanner_SelAttackVsMe = ATTACK_WEAK;
local playerSortedList = {};


-- ****************************************************
-- * ON_LOAD COMMANDS *
-- ****************************************************
-- * Add any code that needs to be read OnLoad in the section below; for example,
-- * add or delete load messages, and add slash commands here.
--
-- * The first function below prints a small notification in chat to
-- * let you know that the addon successfully loaded.
-- * useful components: how to add load message, pop up error messages, and set slash commands
--
function PetBattlePlanner_OnLoad()
   if( DEFAULT_CHAT_FRAME ) then
--      DEFAULT_CHAT_FRAME:AddMessage("PetBattlePlanner Loaded.");
   end
--   UIErrorsFrame:AddMessage("PetBattlePlanner Loaded.", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);

   SlashCmdList["PETBATTLEPLANNERCOMMAND"] = PetBattlePlanner_Slash_Handler;
   SLASH_PETBATTLEPLANNERCOMMAND1 = "/pbp";

   if ( PetBattlePlanner_db == nil) then
      PetBattlePlanner_ResetDB();
   end
   
   PetBattlePlanner_SetUpGuiFields();
   PetBattlePlanner_UpdateGui();
end



-- ****************************************************
--   * SLASH HANDLER *
-- ****************************************************
-- * The slash handler acts as a link between slash commands and functions, reinstate if you are
-- * interested in seeing this mod's XML frames. If you have the frame code in the
-- * PetBattlePlanner.xml file active (default), this command opens the GUI template when activated.
-- * useful components: strip/interpret command from slash input, activate GUI window, colorize
-- * chat text, output text to chat frame, set variable via slash command and report the change in chat
--
function PetBattlePlanner_Slash_Handler(msg)
   if (msg == "gui") then
      PetBattlePlanner_GenerateReport()
      PetBattlePlanner_UpdateGui()
      PetBattlePlanner_MainForm:Show();
   elseif (msg == "toggle") then
      if ( PetBattlePlanner_MainForm:IsShown() == 1 ) then
         PetBattlePlanner_MainForm:Hide();
      else
         PetBattlePlanner_MainForm:Show();
      end
   elseif (msg == "show") then
      PetBattlePlanner_MainForm:Show();
   elseif (msg == "hide") then
      PetBattlePlanner_MainForm:Hide();
   elseif (msg == "center") then
      PetBattlePlanner_MainForm:ClearAllPoints()
      PetBattlePlanner_MainForm:SetPoint("CENTER", UIParent, "CENTER",0,0)
   elseif (msg == "reset") then
      PetBattlePlanner_ResetDB();
   elseif (msg == "setteam") then
      PetBattlePlanner_SetCurrentTeam();
   elseif (msg == "dbfix") then
      PetBattlePlanner_FixDB();
   elseif (msg == "report") then
      PetBattlePlanner_GenerateReport();
      print("Report generation complete");
   elseif (msg == "test") then
      print("Got to test");
      local lastTargetName = GetUnitName("target");
   
      if ( PetBattlePlanner_lastTargetName ) then
         PetBattlePlanner_lastTargetName = lastTargetName;
         print("UNIT_TARGET->"..PetBattlePlanner_lastTargetName);
      end
   else
      print(green.."PetBattlePlanner:"..white.." Arguments to "..yellow.."/rm");
      print(yellow.." show - "..white.."Shows the main window.");
      print(yellow.." hide - "..white.."Hides the main window.");
      print(yellow.." toggle - "..white.."Toggles the main window.");
      print(yellow.." center - "..white.."Centers the main window.");
   end



end

function PetBattlePlanner_FixDB()
   local name,npcInfo
   for name,npcInfo in pairs(PetBattlePlanner_db.Opponents) do
      
      local myPetIndex, myPetInfo
      
      for myPetIndex, myPetInfo in pairs(npcInfo.MyTeam) do 
         
         if (npcInfo.MyTeam[myPetIndex].PairedWith == nil ) then
           
            if ( npcInfo.Team[myPetIndex] ~= nil ) then -- find out if enemy team has entry in same slot as us.
               npcInfo.MyTeam[myPetIndex].PairedWith = npcInfo.Team[myPetIndex].Name;
   --            print("NPC="..name.." MyTeam["..myPetIndex.."]="..npcInfo.MyTeam[myPetIndex].Name.." paired with "..npcInfo.Team[myPetIndex].Name)
            elseif ( npcInfo.Team[1] ~= nil ) then -- try to use enemy pet [1].
               npcInfo.MyTeam[myPetIndex].PairedWith = npcInfo.Team[1].Name;
   --            print("NPC="..name.." MyTeam["..myPetIndex.."]="..npcInfo.MyTeam[myPetIndex].Name.." paired with "..npcInfo.Team[1].Name)
            end
         end
      end
   end
end



function PetBattlePlanner_handle_PET_BATTLE_CLOSE()
--   print("Got PET_BATTLE_CLOSE");
end

function PetBattlePlanner_handle_PET_BATTLE_OPENING_DONE()
--   print("Got PET_BATTLE_OPENING_DONE");
end

function PetBattlePlanner_GetLowestRarity()
   local lowestPetRarity = 1000;
   local petIndex;
   local numPets = C_PetBattles.GetNumPets(PET_OWNER_OPPONENT);
   
   for petIndex=1, numPets do
      local rarity = C_PetBattles.GetBreedQuality(PET_OWNER_OPPONENT, petIndex);
      
      if ( rarity < lowestPetRarity ) then
         lowestPetRarity = rarity;
      end
   end
   
   return lowestPetRarity;
end

function PetBattlePlanner_handle_PET_BATTLE_OPENING_START()
--   print("Got PET_BATTLE_OPENING_START");
   
   if ( (PetBattlePlanner_lastTargetName ~= nil) and                -- we have an opponent name
        ( C_PetBattles.IsPlayerNPC(PET_OWNER_OPPONENT) ) ) then       -- we have an NPC opponent
      
      if ( PetBattlePlanner_db == nil ) then PetBattlePlanner_db = {}; end
      if ( PetBattlePlanner_db["Opponents"] == nil ) then PetBattlePlanner_db["Opponents"] = {}; end
      
      -- determine lowest pet rarity.  we want to only track trainer with good pets.
      if ( PetBattlePlanner_GetLowestRarity() >= 4 ) then -- trainers will have good pets. Number - 1: "Poor", 2: "Common", 3: "Uncommon", 4: "Rare", 5: "Epic", 6: "Legendary"
         local numPets = C_PetBattles.GetNumPets(PET_OWNER_OPPONENT);

         print("Battling "..PetBattlePlanner_lastTargetName);
         
         PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName] = PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName] or {};
         PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"] = {};
         
         
         local petIndex;
         for petIndex=1, numPets do
            local petName, speciesName = C_PetBattles.GetName(PET_OWNER_OPPONENT, petIndex);
            local petType   = C_PetBattles.GetPetType(PET_OWNER_OPPONENT, petIndex)
            local rarity    = C_PetBattles.GetBreedQuality(PET_OWNER_OPPONENT, petIndex);
            local health    = C_PetBattles.GetMaxHealth(PET_OWNER_OPPONENT, petIndex);
            local power     = C_PetBattles.GetPower(PET_OWNER_OPPONENT, petIndex);
            local speed     = C_PetBattles.GetSpeed(PET_OWNER_OPPONENT, petIndex);
            local level     = C_PetBattles.GetLevel(PET_OWNER_OPPONENT, petIndex);
            local icon      = C_PetBattles.GetIcon(PET_OWNER_OPPONENT, petIndex);
            local speciesID = C_PetBattles.GetPetSpeciesID(PET_OWNER_OPPONENT, petIndex);
--            print("speciesID="..speciesID)
            
--            print("pet["..petIndex.."] = "..petName.."   species = "..speciesName.."  rarity="..rarity);
            
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex] = {};
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["Name"] = petName;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["PetType"] = petType;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["Rarity"] = rarity;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["Health"] = health;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["Power"] = power ;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["Speed"] = speed ;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["Level"] = level ;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["Icon"] = icon ;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["SpeciesID"] = speciesID ;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["AbilityList"] = {};

            local abilityIndex;
            for abilityIndex=1, 3 do
               local id, abilityName, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(PET_OWNER_OPPONENT, petIndex, abilityIndex);
   --            print("   ability["..abilityIndex.."] = "..abilityName.."   id = "..id);
               PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["AbilityList"][abilityIndex] = id;
            end
         end
      end
   end
end

function PetBattlePlanner_handle_PLAYER_TARGET_CHANGED()
--   print("Got to PLAYER_TARGET_CHANGED");
   local lastTargetName = GetUnitName("target");

   if ( lastTargetName ) then
      PetBattlePlanner_lastTargetName = lastTargetName;
--      print("PLAYER_TARGET_CHANGED->"..PetBattlePlanner_lastTargetName);


      if ( PetBattlePlanner_db ~= nil ) and
         ( PetBattlePlanner_db["Opponents"] ~= nil ) and
         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName] ~= nil ) then
   
         PetBattlePlanner_SetOpponentNpcName(PetBattlePlanner_lastTargetName);
      end
   end
end

function PetBattlePlanner_SetSelectedPetClickHandler(frameIndex)
   local sliderPos = PetBattlePlanner_PetInfoFrameSlider:GetValue();
   
   if ( sliderPos+frameIndex <= #playerSortedList ) then
      PetBattlePlanner_CurrentPetIndexInJournal = playerSortedList[sliderPos+frameIndex];
   else
      PetBattlePlanner_CurrentPetIndexInJournal = 0;
   end

   PetBattlePlanner_UpdateGui();
end

function PetBattlePlanner_SetSelectedTeamClickHandler(frameIndex,teamSlot)
   local sliderPos = PetBattlePlanner_PetInfoFrameSlider:GetValue();
   
   if ( sliderPos+frameIndex <= #playerSortedList ) then
      petIndexInJournal = playerSortedList[sliderPos+frameIndex];
      
      local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(petIndexInJournal);

      if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil ) and
         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team ~= nil ) then
            
         if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam == nil ) then  -- create team structure if necessary
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam = {}
         end
   
         PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[teamSlot] = {}
         PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[teamSlot].Id = petID;
         PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[teamSlot].Name = speciesName;
         PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[teamSlot].AbilityList = {};

         -- pair with enemy in corresponding slot. or with enemy slot 1 if our corresponding enemy slot is empty
         if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[teamSlot] ~= nil ) then -- find out if enemy team has entry in same slot as us.
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[teamSlot].PairedWith = 
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[teamSlot].Name;
         elseif ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[1] ~= nil ) then -- try to use enemy pet [1].
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[teamSlot].PairedWith = 
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[1].Name;
         end
         
         local abilitySlotIndex;
         for abilitySlotIndex = 1,3 do 
            local abilityId, abilityName, abilityIcon, maxCooldown, unparsedDescription, numTurns, abilityPetType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(petID, abilityIndex);
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[teamSlot].AbilityList[abilitySlotIndex] = abilityId;
         end
      end
   end

   PetBattlePlanner_UpdateGui();
end


--function PetBattlePlanner_handle_UNIT_TARGET()
--   print("Got to UNIT_TARGET");
--   local lastTargetName = GetUnitName("target");
--
--   if ( lastTargetName ) then
--      PetBattlePlanner_lastTargetName = lastTargetName;
--      print("UNIT_TARGET->"..PetBattlePlanner_lastTargetName);
--   end
--end
           
function PetBattlePlanner_ResetDB()

   PetBattlePlanner_db = {};
   PetBattlePlanner_db["Opponents"] = {};
   
end

function PetBattlePlanner_GetAttackStrength(attackerType, defenderType)
   
   local strength = ATTACK_NEUTRAL;
   
   if     ( attackerType == 1 ) then --  "Humanoid",    -- 1 
      if ( defenderType == 8 ) then strength = ATTACK_WEAK; end    --  "Beast",       -- 8 
      if ( defenderType == 2 ) then strength = ATTACK_STRONG; end  --  "Dragonkin",   -- 2 
   elseif ( attackerType == 2 ) then --  "Dragonkin",   -- 2 
      if ( defenderType == 6 ) then strength = ATTACK_STRONG; end  --  "Magic",       -- 6 
      if ( defenderType == 4 ) then strength = ATTACK_WEAK; end    --  "Undead",      -- 4 
   elseif ( attackerType == 3 ) then --  "Flying",      -- 3 
      if ( defenderType == 9 ) then strength = ATTACK_STRONG; end  --  "Aquatic",     -- 9 
      if ( defenderType == 2 ) then strength = ATTACK_WEAK; end    --  "Dragonkin",   -- 2 
   elseif ( attackerType == 4 ) then --  "Undead",      -- 4 
      if ( defenderType == 9 ) then strength = ATTACK_WEAK; end    --  "Aquatic",     -- 9 
      if ( defenderType == 1 ) then strength = ATTACK_STRONG; end  --  "Humanoid",    -- 1 
   elseif ( attackerType == 5 ) then --  "Critter",     -- 5 
      if ( defenderType == 1 ) then strength = ATTACK_WEAK; end    --  "Humanoid",    -- 1 
      if ( defenderType == 4 ) then strength = ATTACK_STRONG; end  --  "Undead",      -- 4 
   elseif ( attackerType == 6 ) then --  "Magic",       -- 6 
      if ( defenderType == 3 ) then strength = ATTACK_STRONG; end  --  "Flying",      -- 3 
      if ( defenderType == 10) then strength = ATTACK_WEAK; end    --  "Mechanical",  -- 10
   elseif ( attackerType == 7 ) then --  "Elemental",   -- 7 
      if ( defenderType == 5 ) then strength = ATTACK_WEAK; end    --  "Critter",     -- 5 
      if ( defenderType == 10) then strength = ATTACK_STRONG; end  --  "Mechanical",  -- 10
   elseif ( attackerType == 8 ) then --  "Beast",       -- 8 
      if ( defenderType == 5 ) then strength = ATTACK_STRONG; end  --  "Critter",     -- 5 
      if ( defenderType == 3 ) then strength = ATTACK_WEAK; end    --  "Flying",      -- 3 
   elseif ( attackerType == 9 ) then --  "Aquatic",     -- 9 
      if ( defenderType == 7 ) then strength = ATTACK_STRONG; end  --  "Elemental",   -- 7 
      if ( defenderType == 6 ) then strength = ATTACK_WEAK; end    --  "Magic",       -- 6 
   elseif ( attackerType == 10) then --  "Mechanical",  -- 10
      if ( defenderType == 8 ) then strength = ATTACK_STRONG; end  --  "Beast",       -- 8 
      if ( defenderType == 7 ) then strength = ATTACK_WEAK; end    --  "Elemental",   -- 7 
   end
   
   return strength
end

function PetBattlePlanner_ResetLocalDB()
   local rowIndex,colIndex;

   PetBattlePlanner_local_db = {}
   for colIndex = 1,3 do
      PetBattlePlanner_local_db[colIndex] = {};
      
      for rowIndex = 1,3 do
         PetBattlePlanner_local_db[colIndex][rowIndex] = {};
      end
   end
   
end


function PetBattlePlanner_GenerateReport()
   
   PetBattlePlanner_ResetLocalDB();
   
   PetBattlePlanner_db["Report"] = {};
   PetBattlePlanner_PetInfoFrameSlider:SetValue(1);

   local printOut = PetBattlePlanner_db["Report"];
   
   local myNumPets;
   local myPetIndex;
   local outputIndex = 1;
   local outputLine = "";
   
   printOut[outputIndex] = "Report of pet info";
   outputIndex = outputIndex+1;
   
   myNumPets, myNumOwned = C_PetJournal.GetNumPets();
   printOut[outputIndex] = "Total pets = "..myNumPets.."  Owned Pets = "..myNumOwned;
   outputIndex = outputIndex+1;
   
   for myPetIndex=1, myNumPets do
      local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(myPetIndex);
      
      local health, maxHealth, power, speed, rarity
      rarity = 1;
      
      if ( petID ~= nil ) then
          health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(petID);
      end

      
      outputLine = "";
      outputLine = outputLine..speciesName.."("..level..") "
      outputLine = outputLine.."("..PET_TYPE_TEXT[petType]..") "
      if ( owned ) then
         outputLine = outputLine.."owned=Yes  "
      else
         outputLine = outputLine.."owned=No  "
      end

      printOut[outputIndex] = outputLine;        outputIndex = outputIndex+1;       outputLine = "";

     
      --
      -- defensive
      --

      printOut[outputIndex] = "   Defensive info";   outputIndex = outputIndex+1;        outputLine = "";
      
      local abilityIndex
      local worstAttackVsMe = ATTACK_WEAK;
      local enemyName = PetBattlePlanner_OpponentName;
      for abilityIndex = 1, 3 do
         local abilityID = PetBattlePlanner_db["Opponents"][enemyName]["Team"][PetBattlePlanner_OpponentPetIndex]["AbilityList"][abilityIndex];
         local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityID)
         
         outputLine = outputLine.."      "..PetBattlePlanner_db["Opponents"][enemyName]["Team"][PetBattlePlanner_OpponentPetIndex]["Name"]
         outputLine = outputLine.."->"..abilityName.."("..PET_TYPE_TEXT[abilityPetType]..")"
         
         if (NON_DAMAGE_ABILITY_LIST[abilityID] == true) then -- only consider damage abilities.
	         outputLine = outputLine.." is ignored since it does no damage";	         
	      else
         
	         local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, petType);
	         outputLine = outputLine.." is "..ATTACK_RESULT_TEXT[attackResult].." vs me("..PET_TYPE_TEXT[petType]..")";
	         if ( attackResult > worstAttackVsMe ) then
	            worstAttackVsMe = attackResult;
	         end
         end
         
         printOut[outputIndex] = outputLine;        outputIndex = outputIndex+1;       outputLine = "";
      end

      --
      -- Offensive
      --
     
      printOut[outputIndex] = "   Offensive info";      outputIndex = outputIndex+1;       outputLine = "";

      local abilityIndex
      local bestAttackVsHim = ATTACK_WEAK;


      local idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesID);
      
      do
         local tableIndex,abilityId;
         for tableIndex, abilityId in pairs(idTable) do
             
            local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityId)
            outputLine = outputLine.."      "..abilityName.."("..PET_TYPE_TEXT[abilityPetType]..")"
   
	         if ( NON_DAMAGE_ABILITY_LIST[abilityId] == true) then -- only consider damage abilities.
		         outputLine = outputLine.." is ignored since it does no damage";	         
		      else
	            local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, PetBattlePlanner_db["Opponents"][enemyName]["Team"][PetBattlePlanner_OpponentPetIndex]["PetType"]);
	            if ( attackResult > bestAttackVsHim ) then
	               bestAttackVsHim = attackResult;
	            end
	            outputLine = outputLine.." is "..ATTACK_RESULT_TEXT[attackResult]
	         end
   
            printOut[outputIndex] = outputLine;        outputIndex = outputIndex+1;       outputLine = "";
         


             
         end
      end


     
      --
      -- Summary
      --
      
      printOut[outputIndex] = "   Summary("..OFFENSE_RESULT_RATING_TEXT[bestAttackVsHim ]..","..DEFENSE_RESULT_RATING_TEXT[worstAttackVsMe]..")("..level..")("..RARITY_TEXT[rarity]..")";   outputIndex = outputIndex+1;       outputLine = "";
--      printOut[outputIndex] = "   Summary("..OFFENSE_RESULT_RATING_TEXT[bestAttackVsHim ]..","..DEFENSE_RESULT_RATING_TEXT[worstAttackVsMe]..")";   outputIndex = outputIndex+1;       outputLine = "";
      

      PetBattlePlanner_UpdatePetLocalDB(myPetIndex, level ,rarity, owned, canBattle, bestAttackVsHim, worstAttackVsMe)

      
   end
end

function PetBattlePlanner_UpdatePetLocalDB(journalIndex,level,rarity,isOwned,canBattle,bestAttackVsHim,worstAttackVsMe)
   local toBeIncluded = true;
   
   -- create default values if necessary.
   if PetBattlePlanner_db.Options == nil then
      PetBattlePlanner_db.Options = {};
   end
   if PetBattlePlanner_db.Options.MinPetLevel == nil then
      PetBattlePlanner_db.Options.MinPetLevel = 1;
   end
   if PetBattlePlanner_db.Options.OnlyIncludeCaptured == nil then
      PetBattlePlanner_db.Options.OnlyIncludeCaptured = false;
   end
   if PetBattlePlanner_db.Options.MinRarity == nil then
      PetBattlePlanner_db.Options.MinRarity = 1; -- grey
   end
   
   
   
   if ( canBattle == false ) then
      toBeIncluded = false;
      
   elseif ( level < PetBattlePlanner_db.Options.MinPetLevel ) then
      toBeIncluded = false;
      
   elseif ( rarity < PetBattlePlanner_db.Options.MinRarity ) then
      toBeIncluded = false;
      
--   elseif ( PetBattlePlanner_db.Options.OnlyIncludeCaptured ) and
--          ( isOwned == false ) then 
--      toBeIncluded = false;
   end
   
   if ( toBeIncluded == true ) then
      
      local numEntriesInSection = #PetBattlePlanner_local_db[bestAttackVsHim][worstAttackVsMe]
      PetBattlePlanner_local_db[bestAttackVsHim][worstAttackVsMe][numEntriesInSection+1] = journalIndex;
   end
   
   -- clear out the selection since the list has been redone.
   PetBattlePlanner_CurrentPetIndexInJournal = 0;

end





--function PetBattlePlanner_SetUpNpcChooserDropDownMenuInitialize(self,level)
--   local info = UIDropDownMenu_CreateInfo()
--   info.text = "Opponent NPC";
--   info.isTitle = 1;
--   UIDropDownMenu_AddButton(info)
--   
--   info = UIDropDownMenu_CreateInfo();
--   info.text = "choice 1";
--   UIDropDownMenu_AddButton(info)
--   
--   info = UIDropDownMenu_CreateInfo();
--   info.text = "choice 2";
--   UIDropDownMenu_AddButton(info)
--end
--
--function PetBattlePlanner_SetUpNpcChooserDropDownMenu_OnLoad(self)
--   UIDropDownMenu_Initialize(self, PetBattlePlanner_SetUpNpcChooserDropDownMenuInitialize );
--end

local petMenuTbl;

function PetBattlePlanner_UpdatePetListMenu()
   local petIndex;
   petMenuTbl = {};
   petMenuTbl[1] = {};
   petMenuTbl[1].text = "Pet Selection";
   petMenuTbl[1].isTitle = true;
   petMenuTbl[1].notCheckable = true;
   
   if ( PetBattlePlanner_db ~= nil ) and
      ( PetBattlePlanner_db["Opponents"] ~= nil ) and
      ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil ) then
      
      local petInfo;
      for petIndex,petInfo in pairs(PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team) do
         petMenuTbl[1+petIndex] = {};
         petMenuTbl[1+petIndex].hasArrow = false;
         petMenuTbl[1+petIndex].notCheckable = true;
         petMenuTbl[1+petIndex].text = petInfo.Name;
         petMenuTbl[1+petIndex].arg1 = petIndex;
         petMenuTbl[1+petIndex].func = function(self, arg)
            PetBattlePlanner_SetOpponentPetIndex(arg);
            end
      end
   end
end

function PetBattlePlanner_SetCurrentTeam()
   
   local reportText = white.."PetBattlePlanner: Team Set to: ";
   local slotIndex
   for slotIndex = 1,3 do
            
      if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil) and
         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam ~= nil ) and
         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[slotIndex] ~= nil ) then
      
         local petGUID        = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[slotIndex].Id;
         local displayName    = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[slotIndex].Name;
                  
         local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petGUID);
         local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(petGUID);
      
         local formattedInfo = string.format("%s(%d)%s%s",yellow,level,  RARITY_COLOR[rarity],name)
         reportText = reportText..formattedInfo;
         
         C_PetJournal.SetPetLoadOutInfo(slotIndex,petGUID);
      end
   end
   print(reportText)
   
end


function PetBattlePlanner_SetOpponentNpcName(opponentName)
   PetBattlePlanner_OpponentName = opponentName;  
   PetBattlePlanner_OpponentPetIndex = 1;
   
   PetBattlePlanner_UpdatePetListMenu();
   
   PetBattlePlanner_GenerateReport(); -- update the grid calculations and create a report
   
   PetBattlePlanner_UpdateGui();
end

function PetBattlePlanner_SetMinimumLevel(level)
   PetBattlePlanner_db.Options.MinPetLevel  = level;

   PetBattlePlanner_GenerateReport(); -- update the grid calculations and create a report
   
   PetBattlePlanner_UpdateGui();
end

function PetBattlePlanner_SetMinimumOwnership(ownership)
   PetBattlePlanner_db.Options.OnlyIncludeCaptured  = ownership;

   PetBattlePlanner_GenerateReport(); -- update the grid calculations and create a report
   
   PetBattlePlanner_UpdateGui();
end

function PetBattlePlanner_SetMinimumRarity(rarity)
   PetBattlePlanner_db.Options.MinRarity  = rarity;

   PetBattlePlanner_GenerateReport(); -- update the grid calculations and create a report
   
   PetBattlePlanner_UpdateGui();
end


function PetBattlePlanner_SetOpponentPetIndex(index)

   if ( PetBattlePlanner_db ~= nil ) and
      ( PetBattlePlanner_db["Opponents"] ~= nil ) and
      ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil ) and
      ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team ~= nil ) and
      ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[index] ~= nil ) then
   
      PetBattlePlanner_OpponentPetIndex = index;
   
      PetBattlePlanner_GenerateReport(); -- update the grid calculations and create a report
      
      PetBattlePlanner_UpdateGui();
   end
end

function PetBattlePlanner_GetCountMatrixCellColor( column, row )
   returnVal = yellow;
   
   if (( column == 2-1 ) and ( row == 3-1 )) or
      (( column == 2-1 ) and ( row == 4-1 )) or
      (( column == 3-1 ) and ( row == 4-1 )) then
      returnVal = red;
   end
   
   if (( column == 3-1 ) and ( row == 2-1 )) or
      (( column == 4-1 ) and ( row == 2-1 )) or
      (( column == 4-1 ) and ( row == 3-1 )) then
      returnVal = green;
   end
   
   return returnVal;
   
end



function PetBattlePlanner_UpdateGui()

   if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil ) then
      PetBattlePlanner_TabPage1_OpponentNPCNameFrame:SetText(white..PetBattlePlanner_OpponentName);
   else
      PetBattlePlanner_TabPage1_OpponentNPCNameFrame:SetText("unknown");      
   end


   if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil ) and
      ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team ~= nil ) and
      ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[PetBattlePlanner_OpponentPetIndex] ~= nil ) and
      ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[PetBattlePlanner_OpponentPetIndex].Name ~= nil ) then

      local enemyPetRarity = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[PetBattlePlanner_OpponentPetIndex].Rarity or 5;
      local enemyPetLevel  = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[PetBattlePlanner_OpponentPetIndex].Level or 1;
      PetBattlePlanner_TabPage1_OpponentPetNameFrame:SetText( string.format("%s%d %s%s",yellow,enemyPetLevel,  RARITY_COLOR[enemyPetRarity],
                    PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[PetBattlePlanner_OpponentPetIndex].Name));
   else
      PetBattlePlanner_TabPage1_OpponentPetNameFrame:SetText(white.."unknown");      
   end

   --
   -- update Grid numbers
   --
   
   if ( PetBattlePlanner_local_db ~= nil ) then
      local columnIndex,rowIndex;
      
      for columnIndex = 1,3 do
         for rowIndex = 1,3 do
            local cellText = PetBattlePlanner_GetCountMatrixCellColor( columnIndex, rowIndex )
            cellText = cellText..#PetBattlePlanner_local_db[columnIndex][rowIndex];
            
            PetBattlePlanner_CountMatrixFrames[columnIndex+1][rowIndex+1]:SetText(cellText);
         end
      end
   end
   
   if ( PetBattlePlanner_db.Options ~= nil ) and
      ( PetBattlePlanner_db.Options.MinPetLevel ~= nil ) then
      PetBattlePlanner_MinLevelSelectorButtons:SetText("Minimum Level:  "..PetBattlePlanner_db.Options.MinPetLevel);
   end
   
   if ( PetBattlePlanner_db.Options ~= nil ) and
      ( PetBattlePlanner_db.Options.MinRarity ~= nil ) then
      PetBattlePlanner_MinRaritySelectorButtons:SetText("Minimum Rarity: "..RARITY_TEXT[PetBattlePlanner_db.Options.MinRarity]);
   end
   
   if ( PetBattlePlanner_db.Options ~= nil ) and
      ( PetBattlePlanner_db.Options.OnlyIncludeCaptured ~= nil ) then
      
      if ( PetBattlePlanner_db.Options.OnlyIncludeCaptured == true ) then
         PetBattlePlanner_MinOwnershipSelectorButtons:SetText("Must Be Owned:  Yes");
      else
         PetBattlePlanner_MinOwnershipSelectorButtons:SetText("Must Be Owned:  No");
      end
   end
 
   --
   -- update list title
   --
   PetBattlePlanner_PetListTitle:SetText("Pet List:    "..yellow.."Defense: "..ATTACK_RESULT_COLOR[4-PetBattlePlanner_SelAttackVsMe]..ATTACK_RESULT_TEXT[4-PetBattlePlanner_SelAttackVsMe]..yellow.."   Attack: "..ATTACK_RESULT_COLOR[PetBattlePlanner_SelAttackVsHim]..ATTACK_RESULT_TEXT[PetBattlePlanner_SelAttackVsHim]);

   --
   -- update Pet information List 
   --

   if ( PetBattlePlanner_local_db ~= nil ) and
      ( PetBattlePlanner_db ~= nil ) and
      ( PetBattlePlanner_db["Opponents"] ~= nil ) and
      ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil ) then
      
      -- set up sorted list
      playerSortedList = PetBattlePlanner_buildPlayerListSort( PetBattlePlanner_local_db[PetBattlePlanner_SelAttackVsHim][PetBattlePlanner_SelAttackVsMe] );

      local numPetsInSubset = #PetBattlePlanner_local_db[PetBattlePlanner_SelAttackVsHim][PetBattlePlanner_SelAttackVsMe]

      local startRow = PetBattlePlanner_PetInfoFrameSlider:GetValue();

      
      
      local subsetIndex;
      for subsetIndex = 1,5 do
         PetBattlePlanner_PetInfoFrameSelectionBoxFrame[subsetIndex]:Hide();
         
         if ( subsetIndex <= numPetsInSubset ) then
            --
            -- update Pet Names
            --
            local myPetIndex = playerSortedList[startRow+subsetIndex-1];
--            local myPetIndex = PetBattlePlanner_local_db[PetBattlePlanner_SelAttackVsHim][PetBattlePlanner_SelAttackVsMe][subsetIndex];
            local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(myPetIndex);
            local health, maxHealth, power, speed, rarity
            rarity = 1;
            
            if ( petID ~= nil ) then
                health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(petID);
            end            
      
            local idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesID);
      
            local enemyType = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName]["Team"][PetBattlePlanner_OpponentPetIndex]["PetType"]
      
            local abilityIndex;
            for abilityIndex = 1,6 do
               local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID( idTable[REORDER_ABILITIES_IN_PAIRS[abilityIndex]] )

               PetBattlePlanner_PetInfoFrameAbilityFrame[subsetIndex][abilityIndex]:SetTexture(abilityIcon);
               PetBattlePlanner_PetInfoFrameAbilityTypeFrame[subsetIndex][abilityIndex]:SetTexture(PET_TYPE_TEXTURES[abilityPetType]);
               local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, enemyType);
               PetBattlePlanner_PetInfoFrameAbilityStrengthFrame[subsetIndex][abilityIndex]:SetTexture(ATTACK_RESULT_TEXTURES[attackResult]);
               
               PetBattlePlanner_PetInfoFrameAbilityFrameButton[subsetIndex][abilityIndex].abilityID      = abilityId;
               PetBattlePlanner_PetInfoFrameAbilityFrameButton[subsetIndex][abilityIndex].speciesID      = speciesID;
               PetBattlePlanner_PetInfoFrameAbilityFrameButton[subsetIndex][abilityIndex].petID          = petID;
               PetBattlePlanner_PetInfoFrameAbilityFrameButton[subsetIndex][abilityIndex].additionalText = nil;
               
            end
            

            PetBattlePlanner_PetPortraitFrameTexture[subsetIndex]:SetTexture(icon);
            PetBattlePlanner_PetInfoFrameName[subsetIndex]:SetText( string.format("%s%d %s%s",yellow,level,  RARITY_COLOR[rarity],speciesName));
            PetBattlePlanner_PetInfoFrameHealthText[subsetIndex]:SetText( string.format("%s%d",white, maxHealth ));
            PetBattlePlanner_PetInfoFrameAttackPwrText[subsetIndex]:SetText( string.format("%s%d",white, power ));
            PetBattlePlanner_PetInfoFrameHasteText[subsetIndex]:SetText( string.format("%s%d",white, speed ));
            PetBattlePlanner_PetInfoFrameHealthIcon[subsetIndex]:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            PetBattlePlanner_PetInfoFrameHealthIcon[subsetIndex]:SetTexCoord(0.5, 1 ,0.5, 1)
            PetBattlePlanner_PetInfoFrameAttackPowerIcon[subsetIndex]:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            PetBattlePlanner_PetInfoFrameAttackPowerIcon[subsetIndex]:SetTexCoord(0, .5 ,0, .5)
            PetBattlePlanner_PetInfoFrameHasteIcon[subsetIndex]:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            PetBattlePlanner_PetInfoFrameHasteIcon[subsetIndex]:SetTexCoord(0, .5 ,0.5, 1)
            PetBattlePlanner_PetInfoFrameTypeIcon[subsetIndex]:SetTexture(PET_TYPE_TEXTURES[petType]);
            PetBattlePlanner_PetPortraitFrame[subsetIndex]:Show();

            --
            -- update selected pet indication.
            --
            if ( myPetIndex == PetBattlePlanner_CurrentPetIndexInJournal ) then
               PetBattlePlanner_PetInfoFrameSelectionBoxFrame[subsetIndex]:Show();
            end

         else
            --
            -- Blank out pet info fields
            --
            PetBattlePlanner_PetPortraitFrame[subsetIndex]:Hide();
--            PetBattlePlanner_PetPortraitFrameTexture[subsetIndex]    :SetTexture( nil );
--            PetBattlePlanner_PetInfoFrameName[subsetIndex]           :SetText( nil );
--            PetBattlePlanner_PetInfoFrameHealthText[subsetIndex]     :SetText( nil );
--            PetBattlePlanner_PetInfoFrameAttackPwrText[subsetIndex]  :SetText( nil );
--            PetBattlePlanner_PetInfoFrameHasteText[subsetIndex]      :SetText( nil );
--            PetBattlePlanner_PetInfoFrameHealthIcon[subsetIndex]     :SetTexture( nil );
--            PetBattlePlanner_PetInfoFrameAttackPowerIcon[subsetIndex]:SetTexture( nil );
--            PetBattlePlanner_PetInfoFrameHasteIcon[subsetIndex]      :SetTexture( nil );
--            PetBattlePlanner_PetInfoFrameTypeIcon[subsetIndex]       :SetTexture( nil );
            
            local abilityIndex;
            for abilityIndex = 1,6 do
               PetBattlePlanner_PetInfoFrameAbilityFrame[subsetIndex][abilityIndex]        :SetTexture( nil );
               PetBattlePlanner_PetInfoFrameAbilityTypeFrame[subsetIndex][abilityIndex]    :SetTexture( nil );
               PetBattlePlanner_PetInfoFrameAbilityStrengthFrame[subsetIndex][abilityIndex]:SetTexture( nil );
            end
            
         end
         
      end
      
      
      --
      -- update enemy info
      --
      
      do
         local enemyInfo   = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName]["Team"][PetBattlePlanner_OpponentPetIndex];
         local enemyType   = enemyInfo["PetType"] or 1;
         local enemyName   = enemyInfo["Name"] or "??";
         local enemyLevel  = enemyInfo["Level"] or 0;
         local enemyRarity = enemyInfo["Rarity"] or 1;
         local enemyHealth = enemyInfo["Health"] or 1;
         local enemyPower  = enemyInfo["Power"] or 1;
         local enemySpeed  = enemyInfo["Speed"] or 1;
         local enemyspeciesID   = enemyInfo["SpeciesID"] or 1;
         local enemyIcon   = enemyInfo["Icon"] or "Interface\\ICONS\\INV_MISC_BONE_HUMANSKULL_02";

         PetBattlePlanner_PetInfoEnemyFrameTypeIcon     :SetTexture(PET_TYPE_TEXTURES[enemyType]);
         PetBattlePlanner_PetPortraitEnemyFrame         :SetTexture(enemyIcon);
         PetBattlePlanner_PetInfoFrameEnemyName         :SetText( string.format("%s%d %s%s",yellow,enemyLevel,  RARITY_COLOR[enemyRarity],enemyName));
         PetBattlePlanner_PetInfoEnemyFrameHealthText   :SetText( string.format("%s%d",white,enemyHealth ));
         PetBattlePlanner_PetInfoEnemyFrameAttackPwrText:SetText( string.format("%s%d",white,enemyPower  ));
         PetBattlePlanner_PetInfoEnemyFrameHasteText    :SetText( string.format("%s%d",white,enemySpeed  ));

         local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable;
         if ( PetBattlePlanner_CurrentPetIndexInJournal ~= 0 ) then
            petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(PetBattlePlanner_CurrentPetIndexInJournal);
         end

         local abilityIndex;
         for abilityIndex = 1,3 do

            local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID( enemyInfo.AbilityList[abilityIndex] )
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrameTexture[abilityIndex]  :SetTexture(abilityIcon);
            PetBattlePlanner_PetInfoEnemyFrameAbilityTypeFrame[abilityIndex]     :SetTexture(PET_TYPE_TEXTURES[abilityPetType]);
            PetBattlePlanner_PetInfoEnemyFrameAbilityStrengthFrame[abilityIndex] :SetTexture(nil);
            
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrameButton[abilityIndex].abilityID      = enemyInfo.AbilityList[abilityIndex];
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrameButton[abilityIndex].speciesID      = enemyspeciesID;
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrameButton[abilityIndex].petID          = nil;
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrameButton[abilityIndex].additionalText = nil;
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrameButton[abilityIndex].attackPower    = enemyPower;
         
            if ( PetBattlePlanner_CurrentPetIndexInJournal ~= 0 ) then
               local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, petType);
               PetBattlePlanner_PetInfoEnemyFrameAbilityStrengthFrame[abilityIndex] :SetTexture(ATTACK_RESULT_TEXTURES[attackResult]);
            end
         end

         
      end
      

      local sliderLimit;
      if ( #playerSortedList < 5 ) then
         sliderLimit = 4;
      else
         sliderLimit = #playerSortedList-4;
      end
      
      PetBattlePlanner_PetInfoFrameSlider:SetMinMaxValues(1, sliderLimit);
      
      --
      -- update team list info
      --
      
      do
         local slotIndex
         for slotIndex = 1,3 do
                  
            --
            -- display My team info
            --
            if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil) and
               ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam ~= nil ) and
               ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[slotIndex] ~= nil ) then
   
               local displaySlotIndex = slotIndex;
               local petGUID        = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[slotIndex].Id;
               local displayName    = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[slotIndex].Name;
               
               -- try to figure out if we are paired with an enemy in a different slot.
               local loopIndex;
               for loopIndex = 1,3 do
                  if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[slotIndex].PairedWith ~= nil ) and
                     
                     ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[loopIndex] ~= nil ) and
                     ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[loopIndex].Name ~= nil ) and
                     
                     ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[slotIndex] ~= nil ) and
                     
                     ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[slotIndex].PairedWith == 
                       PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[loopIndex].Name ) then
                        displaySlotIndex = loopIndex;
                  end
               end
               
               local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petGUID);
               local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(petGUID);
   
               local formattedInfo = string.format("%s%d %s%s",yellow,level,  RARITY_COLOR[rarity],name)
   
               PetBattlePlanner_TeamNamesFrame[displaySlotIndex]:SetText(formattedInfo);
            else
               PetBattlePlanner_TeamNamesFrame[slotIndex]:SetText(nil);
            end
         end
      end
         
      --
      -- Update Team Comparison
      --
      
      do
         local loopIndex
         for loopIndex=1,3 do

	         if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam ~= nil ) and
	            ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[loopIndex] ~= nil ) and
	            ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[loopIndex].Id ~= nil ) and
	            ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[loopIndex].Name ~= nil ) then
	               
               local myTeamMember = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[loopIndex];
	           
               local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(myTeamMember.Id)
               local health, maxHealth, power, speed, rarity;
	            if ( myTeamMember.Id ~= nil ) then
	                health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(myTeamMember.Id);
	            end      

	            local formattedInfo = string.format("%s%d %s%s",yellow,level,  RARITY_COLOR[rarity],myTeamMember.Name );               
	            
	            PetBattlePlanner_TeamListPetInfoFrameName[loopIndex]         :SetText(formattedInfo);
	            PetBattlePlanner_TeamListPetInfoFrameHealthText[loopIndex]   :SetText( string.format("%s%d",white, health) );
	            PetBattlePlanner_TeamListPetInfoFrameAttackPwrText[loopIndex]:SetText( string.format("%s%d",white, power) );
	            PetBattlePlanner_TeamListPetInfoFrameHasteText[loopIndex]    :SetText( string.format("%s%d",white, speed) );
	            PetBattlePlanner_TeamListPetPortraitFrameTexture[loopIndex]  :SetTexture(icon)
	            PetBattlePlanner_TeamListPetPortraitFrame[loopIndex]  :Show();
	            PetBattlePlanner_TeamListPetInfoFrameTypeIcon[loopIndex]     :SetTexture(PET_TYPE_TEXTURES[petType])
	            
	            
					local idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesID);

					local abilityIndex,abilityId;
					for abilityIndex = 1,6 do
                  local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID( idTable[REORDER_ABILITIES_IN_PAIRS[abilityIndex]] )
--	               local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID( abilityId )
	               PetBattlePlanner_TeamListPetInfoFrameAbilityFrame[loopIndex][abilityIndex]            :SetTexture(abilityIcon);
	               PetBattlePlanner_TeamListPetInfoFrameAbilityTypeFrame[loopIndex][abilityIndex]        :SetTexture(PET_TYPE_TEXTURES[abilityPetType]);

                  local enemyIndex = PetBattlePlanner_GetEnemyIndex(loopIndex)
                  local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[enemyIndex].PetType);
                  PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthTexture[loopIndex][abilityIndex] :SetTexture(ATTACK_RESULT_TEXTURES[attackResult]);
                  
                  PetBattlePlanner_TeamListPetInfoFrameAbilityFrameButton[loopIndex][abilityIndex].abilityID      = abilityId;
                  PetBattlePlanner_TeamListPetInfoFrameAbilityFrameButton[loopIndex][abilityIndex].speciesID      = speciesID;
                  PetBattlePlanner_TeamListPetInfoFrameAbilityFrameButton[loopIndex][abilityIndex].petID          = myTeamMember.Id;
                  PetBattlePlanner_TeamListPetInfoFrameAbilityFrameButton[loopIndex][abilityIndex].additionalText = nil;

	            end               
				else
				   -- hide fields.
	            PetBattlePlanner_TeamListPetPortraitFrame[loopIndex]  :Hide();
				   
				end
         end
      end
      
      --
      -- Update Enemy Comparison
      --
      
      do
         local loopIndex
         for loopIndex=1,3 do
	         if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam ~= nil ) and
	            ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[loopIndex] ~= nil ) and
	            ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[loopIndex].Name ~= nil ) and
	            ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[loopIndex].PairedWith ~= nil ) then

               local enemyIndex = PetBattlePlanner_GetEnemyIndex(loopIndex)
	            local enemyTeamMember = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[enemyIndex]
	            
	            local formattedInfo = string.format("%s%d %s%s",yellow,enemyTeamMember.Level,  RARITY_COLOR[enemyTeamMember.Rarity],enemyTeamMember.Name );               
	            
	            PetBattlePlanner_EnemyTeamPetInfoFrameEnemyName[loopIndex]         :SetText(formattedInfo);
	            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthText[loopIndex]   :SetText( string.format("%s%d",white, enemyTeamMember.Health) );
	            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPwrText[loopIndex]:SetText( string.format("%s%d",white, enemyTeamMember.Power) );
	            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteText[loopIndex]    :SetText( string.format("%s%d",white, enemyTeamMember.Speed) );
	            PetBattlePlanner_EnemyTeamPetPortraitEnemyTexture[loopIndex]       :SetTexture(enemyTeamMember.Icon)
	            PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[loopIndex]         :Show();
	            PetBattlePlanner_EnemyTeamListPetInfoFrameTypeIcon[loopIndex]      :SetTexture(PET_TYPE_TEXTURES[enemyTeamMember.PetType])
	            
	            local abilityIndex;
	            for abilityIndex = 1,3 do
	               local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID( enemyTeamMember.AbilityList[abilityIndex] )
	               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameTexture[loopIndex][abilityIndex]       :SetTexture(abilityIcon);
	               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeTexture[loopIndex][abilityIndex]        :SetTexture(PET_TYPE_TEXTURES[abilityPetType]);

                  local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[loopIndex].Id)

                  local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, petType);
                  PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthTexture[loopIndex][abilityIndex] :SetTexture(ATTACK_RESULT_TEXTURES[attackResult]);

                  local enemyPower       = enemyTeamMember.Power or 1;
                  local enemyspeciesID   = enemyTeamMember.SpeciesID or 1;
         
                  PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[loopIndex][abilityIndex].abilityID      = abilityId;
                  PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[loopIndex][abilityIndex].speciesID      = enemyspeciesID;
                  PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[loopIndex][abilityIndex].petID          = nil;
                  PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[loopIndex][abilityIndex].additionalText = nil;
                  PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[loopIndex][abilityIndex].attackPower    = enemyPower;
         


	            end               
				else
	            PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[loopIndex]         :Hide();
				   
				end
         end
      end

      
   end
end


function PetBattlePlanner_GetEnemyIndex(myTeamIndex)
   local loopIndex;
   for loopIndex = 1,3 do
      if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[myTeamIndex].PairedWith ~= nil ) and
         
         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[loopIndex] ~= nil ) and
         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[loopIndex].Name ~= nil ) and
         
         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[myTeamIndex].PairedWith == 
           PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[loopIndex].Name ) then
           	
			return loopIndex;
      end
   end
end

--function PetBattlePlanner_GetMyTeamIndex(enemyTeamIndex)
--   local myTeamIndex;
--   
--   if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[enemyTeamIndex] == nil)
--   	  enemyTeamIndex = 1;
--   end
--  
--   local displaySlotIndex = 0;
--   for myTeamIndex = 1,3 do
--      if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[myTeamIndex].PairedWith ~= nil ) and
--         
--         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[enemyTeamIndex] ~= nil ) and
--         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[enemyTeamIndex].Name ~= nil ) and
--         
--         ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].MyTeam[myTeamIndex].PairedWith == 
--           PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[enemyTeamIndex].Name ) then
--           	
--			   return displaySlotIndex;
--      end
--   end
--end


local PET_JOURNAL_ABILITY_INFO = SharedPetBattleAbilityTooltip_GetInfoTable();


function PET_JOURNAL_ABILITY_INFO:GetAbilityID()
  return self.abilityID;
end

function PET_JOURNAL_ABILITY_INFO:IsInBattle()
  return false;
end

function PET_JOURNAL_ABILITY_INFO:GetHealth(target)
  self:EnsureTarget(target);
  if ( self.petID ) then
    local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(self.petID);
    return health;
  else
    --Do something with self.speciesID?
    return self:GetMaxHealth(target);
  end
end

function PET_JOURNAL_ABILITY_INFO:GetMaxHealth(target)
  self:EnsureTarget(target);
  if ( self.petID ) then
    local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(self.petID);
    return maxHealth;
  else
    --Do something with self.speciesID?
    return 100;
  end
end

function PET_JOURNAL_ABILITY_INFO:GetAttackStat(target)
  self:EnsureTarget(target);
  if ( self.attackPower ) then
--     print("attackPower = "..self.attackPower);
     return self.attackPower;
  end
  if ( self.petID ) then
    local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(self.petID);
    return power;
  else
    --Do something with self.speciesID?
    return 0;
  end
end

function PET_JOURNAL_ABILITY_INFO:GetSpeedStat(target)
  self:EnsureTarget(target);
  if ( self.petID ) then
    local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(self.petID);
    return speed;
  else
    --Do something with self.speciesID?
    return 0;
  end
end

function PET_JOURNAL_ABILITY_INFO:GetPetOwner(target)
  self:EnsureTarget(target);
  return LE_BATTLE_PET_ALLY;
end

function PET_JOURNAL_ABILITY_INFO:GetPetType(target)
  self:EnsureTarget(target);
  if ( not self.speciesID ) then
    GMError("No species id found");
    return 1;
  end
  local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable = C_PetJournal.GetPetInfoBySpeciesID(self.speciesID);
  return petType;
end

function PET_JOURNAL_ABILITY_INFO:EnsureTarget(target)
  if ( target == "default" ) then
    target = "self";
  elseif ( target == "affected" ) then
    target = "enemy";
  end
  if ( target ~= "self" ) then
    GMError("Only \"self\" unit supported out of combat");
  end
end

--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetAbilityID() error("UI: Unimplemented Function") end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetCooldown() return 0 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetRemainingDuration() return 0 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:IsInBattle() error("UI: Unimplemented Function") end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetHealth(target) return 100 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetMaxHealth(target) return 100 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetAttackStat(target) return 0 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetSpeedStat(target) return 0 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetState(stateID, target) return 0 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetWeatherState(stateID) return 0 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetPadState(stateID) return 0 end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetPetOwner(taget) return LE_BATTLE_PET_ALLY end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:HasAura(auraID, target) return false end
--function DEFAULT_PET_BATTLE_ABILITY_INFO:GetPetType(target) if ( self:IsInBattle() ) then error("UI: Unimplemented Function"); else return nil end end

local journalAbilityInfo = {};
setmetatable(journalAbilityInfo, {__index = PET_JOURNAL_ABILITY_INFO});
function PetBattlePlanner_ShowAbilityTooltip(self, abilityID, speciesID, petID, additionalText, attackPower)
  if ( abilityID and abilityID > 0 ) then
--     print("abilityID="..abilityID.." speciesID="..(speciesID or "nospecies").." petID="..(petID or "noPetID"));
    journalAbilityInfo.abilityID = abilityID;
    journalAbilityInfo.speciesID = speciesID;
    journalAbilityInfo.attackPower = attackPower;
    journalAbilityInfo.petID = petID;
    PetBattlePlannerPrimaryAbilityTooltip:ClearAllPoints();
    PetBattlePlannerPrimaryAbilityTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0);
    PetBattlePlannerPrimaryAbilityTooltip.anchoredTo = self;
    SharedPetBattleAbilityTooltip_SetAbility(PetBattlePlannerPrimaryAbilityTooltip, journalAbilityInfo, additionalText);
    PetBattlePlannerPrimaryAbilityTooltip:Show();
  end
end



function PetBattlePlanner_SetUpGuiFields()
   
   --
   -- Set up the opponent NPC chooser Header Text
   --
   
   do
      local item = PetBattlePlanner_TabPage1:CreateFontString("PetBattlePlanner_TabPage1_OpponentChooserHeader", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(85);
      item:SetHeight(10);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1", "TOPLEFT", 20,-40);
      item:SetText("Opponent:");
      item:SetJustifyH("LEFT");
      local filename, fontHeight, flags = item:GetFont();
      item:SetFont(filename, fontHeight+2, flags);      
      PetBattlePlanner_TabPage1_OpponentChooserHeader = item;
   end
   


   --
   -- Set up the opponent NPC chooser button
   --
   
   do

      --
      -- Set up the opponent NPC chooser DropDown menu
      --
   
      local menuTbl = {
         {
            text = "NPC Selection",
            isTitle = true,
            notCheckable = true,
         }
      }
      local opponentName, menuIndex, opponentInfo;

      local opponentList = {};
      local opponentIndex=1;
      for opponentName,opponentInfo in pairs(PetBattlePlanner_db["Opponents"]) do
         opponentList[opponentIndex]=opponentName;
         opponentIndex = opponentIndex+1;
      end    
      
      table.sort(opponentList);

        
      menuIndex = 2;
      for opponentIndex=1,#opponentList do
         opponentName = opponentList[opponentIndex]
         menuTbl[menuIndex] = {};
         menuTbl[menuIndex].hasArrow = false;
         menuTbl[menuIndex].notCheckable = true;
         menuTbl[menuIndex].text = opponentName
         menuTbl[menuIndex].arg1 = opponentName
         menuTbl[menuIndex].func = function(self, arg)
            PetBattlePlanner_SetOpponentNpcName(arg);
            end
            
         menuIndex = menuIndex + 1;
      end


      local item = PetBattlePlanner_TabPage1:CreateFontString("PetBattlePlanner_TabPage1_OpponentNPCNameFrame", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(200);
      item:SetHeight(10);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1_OpponentChooserHeader", "TOPRIGHT", 0,0);
      item:SetText("<villan name>");
      item:SetJustifyH("LEFT");
      local filename, fontHeight, flags = item:GetFont();
      item:SetFont(filename, fontHeight+2, flags);      
      PetBattlePlanner_TabPage1_OpponentNPCNameFrame = item;

      local myButton = CreateFrame("Button", "PetBattlePlanner_TabPage1_OpponentNPCChooserButton", PetBattlePlanner_TabPage1 )
      myButton:SetFontString( item )
      myButton:SetWidth(200);
      myButton:SetHeight(10);
      myButton:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_OpponentNPCNameFrame, "TOPLEFT", 0,0);
      myButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Choose your opponent NPC.");
                  GameTooltip:Show()
               end)
      myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
      myButton:SetScript("OnClick", function(self,button,down)
         EasyMenu(menuTbl, PetBattlePlanner_TabPage1, "PetBattlePlanner_TabPage1_OpponentNPCChooserButton" ,0,0, nil, 10)
          
         end)
      PetBattlePlanner_TabPage1_OpponentNPCChooserButton = myButton;

   end
   
   --
   -- Set up the opponent PET chooser Header Text
   --
   
   do
      local item = PetBattlePlanner_TabPage1:CreateFontString("PetBattlePlanner_TabPage1_OpponentPetChooserHeader", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(60);
      item:SetHeight(10);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1", "TOPLEFT", 300,-40);
      item:SetText("Pet:");
      item:SetJustifyH("LEFT");
      local filename, fontHeight, flags = item:GetFont();
      item:SetFont(filename, fontHeight+2, flags);      
      PetBattlePlanner_TabPage1_OpponentPetChooserHeader = item;

   end
   
   --
   -- Set up the opponent PET chooser button
   --
   
   do

      --
      -- Set up the opponent PET chooser DropDown menu
      --
   

      PetBattlePlanner_UpdatePetListMenu();

      local item = PetBattlePlanner_TabPage1:CreateFontString("PetBattlePlanner_TabPage1_OpponentPetNameFrame", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(200);
      item:SetHeight(10);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1_OpponentPetChooserHeader", "TOPRIGHT", 0,0);
      item:SetText("<pet name>");
      item:SetJustifyH("LEFT");
      local filename, fontHeight, flags = item:GetFont();
      item:SetFont(filename, fontHeight+2, flags);      
      PetBattlePlanner_TabPage1_OpponentPetNameFrame = item;

      local myButton = CreateFrame("Button", "PetBattlePlanner_TabPage1_OpponentPetChooserButton", PetBattlePlanner_TabPage1 )
      myButton:SetFontString( item )
      myButton:SetWidth(200);
      myButton:SetHeight(10);
      myButton:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_OpponentPetChooserHeader, "TOPLEFT", 0,0);
      myButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Choose your opponent Pet.");
                  GameTooltip:Show()
               end)
      myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
      myButton:SetScript("OnClick", function(self,button,down)
         EasyMenu(petMenuTbl, PetBattlePlanner_TabPage1, "PetBattlePlanner_TabPage1_OpponentPetChooserButton" ,0,0, nil, 10)
          
         end)
      PetBattlePlanner_TabPage1_OpponentPetChooserButton = myButton;

   end

   --
   -- Set up the summary grid header
   --
   
   do
      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_CountMatrixTitle", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(150);
      item:SetHeight(18);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1_OpponentChooserHeader", "TOPLEFT", 10,-25);
      item:SetText("Me vs them");
      item:SetJustifyH("LEFT");
      local filename, fontHeight, flags = item:GetFont();
      item:SetFont(filename, fontHeight+2, flags);      
      PetBattlePlanner_CountMatrixTitle = item;
   end

   --
   -- Set up the summary grid header
   --
   
   PetBattlePlanner_CountMatrixFrames = {};
   PetBattlePlanner_CountMatrixButtons = {};
   do
      local rowIndex, colIndex;
      local entryWidth = 50;
      local entryHeight = 18;
      
      for colIndex=1,4 do
         PetBattlePlanner_CountMatrixFrames[colIndex] = {};
         PetBattlePlanner_CountMatrixButtons[colIndex] = {};
         
         for rowIndex=1,4 do
            local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_CountMatrixTitle"..colIndex..rowIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(entryWidth);
            item:SetHeight(entryHeight);
            item:SetPoint("TOPLEFT", "PetBattlePlanner_CountMatrixTitle", "BOTTOMLEFT", 0+entryWidth*(colIndex-1),-10-entryHeight*(rowIndex-1));
            item:SetText("0");
            item:SetJustifyH("CENTER");
            PetBattlePlanner_CountMatrixFrames[colIndex][rowIndex] = item;

            local myButton = CreateFrame("Button", "PetBattlePlanner_CountMatrixButtons"..colIndex..rowIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
            myButton:SetFontString( item )
            myButton:SetWidth(entryWidth);
            myButton:SetHeight(entryHeight);
            myButton:SetPoint("TOPLEFT", item, "TOPLEFT", 0,0);
--            myButton:SetScript("OnEnter",
--                     function(this)
--                        GameTooltip_SetDefaultAnchor(GameTooltip, this)
--                        GameTooltip:SetText("grid."..colIndex.."x"..rowIndex);
--                        GameTooltip:Show()
--                     end)
--            myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
--            myButton:SetScript("OnClick", function(self,button,down)
--               print("clicked "..colIndex.."x"..rowIndex);
--               end)
            PetBattlePlanner_CountMatrixButtons[colIndex][rowIndex] = myButton;

         end
      end
   end

   --
   -- Set up the summary grid row/column header text
   --                            
   
   -- [1][1] [2][1] [2][1] [4][1]
   -- [1][2] [2][2] [2][2] [4][2]
   -- [1][3] [2][3] [2][3] [4][3]
   -- [1][4] [2][4] [2][4] [4][4]
   do
      PetBattlePlanner_CountMatrixFrames[1][1]:SetText(yellow.."Def\\Atk");
     
      -- attack info
      PetBattlePlanner_CountMatrixFrames[2][1]:SetText(red.."Weak");
      PetBattlePlanner_CountMatrixFrames[3][1]:SetText(yellow.."Ok");
      PetBattlePlanner_CountMatrixFrames[4][1]:SetText(green.."Strong");
   
      -- defense info
      PetBattlePlanner_CountMatrixFrames[1][2]:SetText(green.."Strong"); 
      PetBattlePlanner_CountMatrixFrames[1][3]:SetText(yellow.."Ok");    
      PetBattlePlanner_CountMatrixFrames[1][4]:SetText(red.."Weak");     
   
   
      -- set up tooltips for attack
      PetBattlePlanner_CountMatrixButtons[2][1]:SetScript("OnEnter",
                        function(this)
                           GameTooltip_SetDefaultAnchor(GameTooltip, this)
                           GameTooltip:SetText("Your pets in this column are weak when attacking this enemy.");
                           GameTooltip:Show()
                        end)
      PetBattlePlanner_CountMatrixButtons[3][1]:SetScript("OnEnter",
                        function(this)
                           GameTooltip_SetDefaultAnchor(GameTooltip, this)
                           GameTooltip:SetText("Your pets in this column are Ok when attacking this enemy.");
                           GameTooltip:Show()
                        end)
      PetBattlePlanner_CountMatrixButtons[4][1]:SetScript("OnEnter",
                        function(this)
                           GameTooltip_SetDefaultAnchor(GameTooltip, this)
                           GameTooltip:SetText("Your pets in this column are Strong when attacking this enemy.");
                           GameTooltip:Show()
                        end)
   
      PetBattlePlanner_CountMatrixButtons[1][2]:SetScript("OnEnter",
                        function(this)
                           GameTooltip_SetDefaultAnchor(GameTooltip, this)
                           GameTooltip:SetText("Your pets in this row are Strong at defending vs this enemy.");
                           GameTooltip:Show()
                        end)
      PetBattlePlanner_CountMatrixButtons[1][3]:SetScript("OnEnter",
                        function(this)
                           GameTooltip_SetDefaultAnchor(GameTooltip, this)
                           GameTooltip:SetText("Your pets in this row are Ok at defending vs this enemy.");
                           GameTooltip:Show()
                        end)
      PetBattlePlanner_CountMatrixButtons[1][4]:SetScript("OnEnter",
                        function(this)
                           GameTooltip_SetDefaultAnchor(GameTooltip, this)
                           GameTooltip:SetText("Your pets in this row are Weak at defending vs this enemy.");
                           GameTooltip:Show()
                        end)

   end

   --
   -- Set up the summary grid click actions
   --                            
   
   -- [1][1] [2][1] [2][1] [4][1]
   -- [1][2] [2][2] [2][2] [4][2]
   -- [1][3] [2][3] [2][3] [4][3]
   -- [1][4] [2][4] [2][4] [4][4]
   PetBattlePlanner_CountMatrixButtons[2][2]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_WEAK   ; PetBattlePlanner_SelAttackVsMe = ATTACK_WEAK   ; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)
   PetBattlePlanner_CountMatrixButtons[2][3]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_WEAK   ; PetBattlePlanner_SelAttackVsMe = ATTACK_NEUTRAL; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)
   PetBattlePlanner_CountMatrixButtons[2][4]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_WEAK   ; PetBattlePlanner_SelAttackVsMe = ATTACK_STRONG ; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)
   PetBattlePlanner_CountMatrixButtons[3][2]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_NEUTRAL; PetBattlePlanner_SelAttackVsMe = ATTACK_WEAK   ; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)
   PetBattlePlanner_CountMatrixButtons[3][3]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_NEUTRAL; PetBattlePlanner_SelAttackVsMe = ATTACK_NEUTRAL; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)
   PetBattlePlanner_CountMatrixButtons[3][4]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_NEUTRAL; PetBattlePlanner_SelAttackVsMe = ATTACK_STRONG ; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)
   PetBattlePlanner_CountMatrixButtons[4][2]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_STRONG ; PetBattlePlanner_SelAttackVsMe = ATTACK_WEAK   ; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)
   PetBattlePlanner_CountMatrixButtons[4][3]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_STRONG ; PetBattlePlanner_SelAttackVsMe = ATTACK_NEUTRAL; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)
   PetBattlePlanner_CountMatrixButtons[4][4]:SetScript("OnClick", function(self,button,down) PetBattlePlanner_SelAttackVsHim = ATTACK_STRONG ; PetBattlePlanner_SelAttackVsMe = ATTACK_STRONG ; PetBattlePlanner_CurrentPetIndexInJournal = 0;PetBattlePlanner_PetInfoFrameSlider:SetValue(1); PetBattlePlanner_UpdateGui(); end)





   --
   -- Set up the minimum level selector
   --                            
   
   do
      local menuTbl = {
         {
            text = "Pet Level Selector",
            isTitle = true,
            notCheckable = true,
         }
      }
      local menuIndex;
      for menuIndex=0,25 do
         menuTbl[2+menuIndex] = {};
         menuTbl[2+menuIndex].hasArrow = false;
         menuTbl[2+menuIndex].notCheckable = true;
         menuTbl[2+menuIndex].text = menuIndex;
         if ( menuIndex == 0 ) then menuTbl[2+menuIndex].text = "Uncaptured"; end
         menuTbl[2+menuIndex].arg1 = menuIndex;
         menuTbl[2+menuIndex].func = function(self, arg)
            PetBattlePlanner_SetMinimumLevel(arg);
            end
      end

      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_MinLevelSelector", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(150);
      item:SetHeight(18);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_CountMatrixTitle14", "BOTTOMLEFT", 0,-10);
      item:SetText("Minimum Level:  xx");
      item:SetJustifyH("LEFT");
      PetBattlePlanner_MinLevelSelector = item;

      local myButton = CreateFrame("Button", "PetBattlePlanner_MinLevelSelectorButtons", PetBattlePlanner_TabPage1_SampleTextTab1 )
      myButton:SetFontString( item )
      myButton:SetWidth(150);
      myButton:SetHeight(18);
      myButton:SetPoint("TOPLEFT", item, "TOPLEFT", 0,0);
      myButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Used to choose the minimum level of the pets for analysis");
                  GameTooltip:Show()
               end)
      myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
      myButton:SetScript("OnClick", function(self,button,down)
         EasyMenu(menuTbl, PetBattlePlanner_TabPage1, "PetBattlePlanner_MinLevelSelectorButtons" ,0,0, nil, 10)
         end)
      PetBattlePlanner_MinLevelSelectorButtons = myButton;





   end
   
   --
   -- Set up the minimum rarity selector
   --                            
   
   do
      local menuTbl = {
         {
            text = "Minimum Rarity",
            isTitle = true,
            notCheckable = true,
         }
      }
      local menuIndex;
      for menuIndex=2,1+7 do
         menuTbl[menuIndex] = {};
         menuTbl[menuIndex].hasArrow = false;
         menuTbl[menuIndex].notCheckable = true;
         menuTbl[menuIndex].text = RARITY_TEXT[menuIndex-1]
         menuTbl[menuIndex].arg1 = menuIndex-1
         menuTbl[menuIndex].func = function(self, arg)
            PetBattlePlanner_SetMinimumRarity(arg);
            end
      end

      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_MinRaritySelector", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(150);
      item:SetHeight(18);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_MinLevelSelector", "BOTTOMLEFT", 0,-10);
      item:SetText("Minimum Rarity: xx");
      item:SetJustifyH("LEFT");
      PetBattlePlanner_MinRaritySelector = item;

      local myButton = CreateFrame("Button", "PetBattlePlanner_MinRaritySelectorButtons", PetBattlePlanner_TabPage1_SampleTextTab1 )
      myButton:SetFontString( item )
      myButton:SetWidth(150);
      myButton:SetHeight(18);
      myButton:SetPoint("TOPLEFT", item, "TOPLEFT", 0,0);
      myButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Used to choose the minimum rarity of the pet for analysis.");
                  GameTooltip:Show()
               end)
      myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
      myButton:SetScript("OnClick", function(self,button,down)
         EasyMenu(menuTbl, PetBattlePlanner_TabPage1, "PetBattlePlanner_MinRaritySelectorButtons" ,0,0, nil, 10)
         end)
      PetBattlePlanner_MinRaritySelectorButtons = myButton;
   end

   --
   -- Set up the minimum ownership selector
   --                            
   
   do
      local menuTbl = {
         {
            text = "Pet Owned",
            isTitle = true,
            notCheckable = true,
         },
         {
            text = "Yes",
            notCheckable = true,
            func = function(self)
               PetBattlePlanner_SetMinimumOwnership(true);
               end,
         },
         {
            text = "No",
            notCheckable = true,
            func = function(self)
               PetBattlePlanner_SetMinimumOwnership(false);
               end,
         }
      }

      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_MinOwnershipSelector", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(150);
      item:SetHeight(18);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_MinRaritySelector", "BOTTOMLEFT", 0,-10);
      item:SetText("Must Be Owned:  xx");
      item:SetJustifyH("LEFT");
      PetBattlePlanner_MinOwnershipSelector = item;

      local myButton = CreateFrame("Button", "PetBattlePlanner_MinOwnershipSelectorButtons", PetBattlePlanner_TabPage1_SampleTextTab1 )
      myButton:SetFontString( item )
      myButton:SetWidth(150);
      myButton:SetHeight(18);
      myButton:SetPoint("TOPLEFT", item, "TOPLEFT", 0,0);
      myButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Used to specify if pets must be owned by the player.");
                  GameTooltip:Show()
               end)
      myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
      myButton:SetScript("OnClick", function(self,button,down)
         EasyMenu(menuTbl, PetBattlePlanner_TabPage1, "PetBattlePlanner_MinOwnershipSelectorButtons" ,0,0, nil, 10)
         end)
      PetBattlePlanner_MinOwnershipSelectorButtons = myButton;
   end


   --
   -- Set up the Pet List text header
   --
   
   do
      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_PetListTitle", "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(300);
      item:SetHeight(18);
      item:SetPoint("TOPLEFT", "PetBattlePlanner_CountMatrixTitle", "TOPLEFT", 210,0);
      item:SetText("Pet List");
      item:SetJustifyH("LEFT");
      local filename, fontHeight, flags = item:GetFont();
      item:SetFont(filename, fontHeight+2, flags);      
      PetBattlePlanner_PetListTitle = item;
   end

   --
   -- Set up the Class Icons.
   --

   local frameVerticalSpacing = 75;
   
   PetBattlePlanner_PetPortraitFrame = {};
   PetBattlePlanner_PetPortraitFrameTexture = {}
   PetBattlePlanner_PetInfoFrameName = {}
   PetBattlePlanner_PetInfoFrameHealthIcon = {}
   PetBattlePlanner_PetInfoFrameHealthText = {}
   PetBattlePlanner_PetInfoFrameAttackPowerIcon = {}
   PetBattlePlanner_PetInfoFrameAttackPwrText = {}
   PetBattlePlanner_PetInfoFrameHasteIcon = {}
   PetBattlePlanner_PetInfoFrameHasteText = {}
   PetBattlePlanner_PetInfoFrameAbilityFrame = {}
   PetBattlePlanner_PetInfoFrameAbilityFrameButton = {};
   PetBattlePlanner_PetInfoFrameAbilityTypeFrame = {}
   PetBattlePlanner_PetInfoFrameAbilityStrengthFrame = {}
   PetBattlePlanner_PetInfoFrameTypeIcon = {}
   PetBattlePlanner_PetInfoFrameSelectionBoxTexture = {}
   PetBattlePlanner_PetInfoFrameSelectionBoxFrame = {}
   PetBattlePlanner_PetPortraitFrameButton = {}

   do
      local frameIndex;
      for frameIndex = 1,5 do
         
         --
         -- set up character portrait frame
         --
         
         do
            local menuTbl = {
               {
                  text = "Pet Selection",
                  isTitle = true,
                  notCheckable = true,
               },
               {
                  text = "Select for comparison",
                  notCheckable = true,
                  func = function(self, arg)
                     PetBattlePlanner_SetSelectedPetClickHandler(arg);
                     end
               },
               {
                  text = "Add to team slot 1",
                  notCheckable = true,
                  func = function(self, arg)
                     PetBattlePlanner_SetSelectedTeamClickHandler(arg,1);
                     end
               },
               {
                  text = "Add to team slot 2",
                  notCheckable = true,
                  func = function(self, arg)
                     PetBattlePlanner_SetSelectedTeamClickHandler(arg,2);
                     end
               },
               {
                  text = "Add to team slot 3",
                  notCheckable = true,
                  func = function(self, arg)
                     PetBattlePlanner_SetSelectedTeamClickHandler(arg,3);
                     end
               }
            }

            menuTbl[2].arg1 = frameIndex-1;
            menuTbl[3].arg1 = frameIndex-1;
            menuTbl[4].arg1 = frameIndex-1;
            menuTbl[5].arg1 = frameIndex-1;
            
            local item = CreateFrame("Frame", "PetBattlePlanner_PetPortraitFrame"..frameIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
            item:SetWidth(50)
            item:SetHeight(50)
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetListTitle, "TOPLEFT", 0,-30-frameVerticalSpacing*(frameIndex-1))
            local texture = item:CreateTexture("PetBattlePlanner_PetPortraitFrameTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\DeadPetIcon")
--            texture:SetTexture("Interface\\PetBattles\\PetIcon-Magical")
--            texture:SetTexCoord(0.5,0.8,0.5,0.65)
            PetBattlePlanner_PetPortraitFrame[frameIndex] = item;
            PetBattlePlanner_PetPortraitFrameTexture[frameIndex] = texture;

            local myButton = CreateFrame("Button", "PetBattlePlanner_PetPortraitFrameButton"..frameIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
            myButton:SetWidth(50);
            myButton:SetHeight(50);
            myButton:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitFrameTexture[frameIndex], "TOPLEFT", 0,0);
            myButton:SetScript("OnEnter",
                     function(this)
                        GameTooltip_SetDefaultAnchor(GameTooltip, this)
                        GameTooltip:SetText("Choose your opponent Pet to be compared with the enemy pet.");
                        GameTooltip:Show()
                     end)
            myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
            myButton:RegisterForClicks( "LeftButtonUp","RightButtonUp" );
            myButton:SetScript("OnClick", function(self,button,down)
                  if ( button == "LeftButton" ) then
                     PetBattlePlanner_SetSelectedPetClickHandler(frameIndex-1);
                  elseif ( button == "RightButton" ) then                  
                     EasyMenu(menuTbl, PetBattlePlanner_TabPage1, "PetBattlePlanner_PetPortraitFrameButton"..frameIndex ,0,0, nil, 10)
                  end
               end)
            PetBattlePlanner_PetPortraitFrameButton[frameIndex] = myButton;


         end

         --
         -- set up character name fontstring
         --
         do
            local item = PetBattlePlanner_PetPortraitFrame[frameIndex]:CreateFontString("PetBattlePlanner_PetInfoFrameName"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(265);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitFrameTexture[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(yellow.."25"..blue.." Pet Name");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_PetInfoFrameName[frameIndex] = item;
         end
         
         --
         -- set up health icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameHealthIcon"..frameIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameName[frameIndex], "TOPRIGHT", 2,0)
            local texture = item:CreateTexture("PetBattlePlanner_PetPortraitFrameTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0.5, 1 ,0.5, 1)
            PetBattlePlanner_PetInfoFrameHealthIcon[frameIndex] = texture;
         end
         
         --
         -- set up Health FontString
         --
         do
            local item = PetBattlePlanner_PetPortraitFrame[frameIndex]:CreateFontString("PetBattlePlanner_PetInfoFrameHealthText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameHealthIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."1234");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_PetInfoFrameHealthText[frameIndex] = item;
         end

         --
         -- set up Attack power icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameAttackPowerIcon"..frameIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameHealthIcon[frameIndex], "BOTTOMLEFT", 0,-2)
            local texture = item:CreateTexture("PetBattlePlanner_PetPortraitFrameTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0, .5 ,0, .5)
            PetBattlePlanner_PetInfoFrameAttackPowerIcon[frameIndex] = texture;
         end
         
         --
         -- set up Attack power FontString
         --
         do
            local item = PetBattlePlanner_PetPortraitFrame[frameIndex]:CreateFontString("PetBattlePlanner_PetInfoFrameAttackPwrText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameAttackPowerIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."1234");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_PetInfoFrameAttackPwrText[frameIndex] = item;
         end
         
         --
         -- set up Haste icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameHasteIcon"..frameIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameAttackPowerIcon[frameIndex], "BOTTOMLEFT", 0,-2)
            local texture = item:CreateTexture("PetBattlePlanner_PetPortraitFrameTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0, .5 ,0.5, 1)
            PetBattlePlanner_PetInfoFrameHasteIcon[frameIndex] = texture;
         end
         
         --
         -- set up Haste FontString
         --
         do
            local item = PetBattlePlanner_PetPortraitFrame[frameIndex]:CreateFontString("PetBattlePlanner_PetInfoFrameHasteText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameHasteIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."1234");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_PetInfoFrameHasteText[frameIndex] = item;
         end
         


         local abilityIndex;
         PetBattlePlanner_PetInfoFrameAbilityFrame[frameIndex] = {};
         PetBattlePlanner_PetInfoFrameAbilityFrameButton[frameIndex] = {};
         PetBattlePlanner_PetInfoFrameAbilityTypeFrame[frameIndex] = {};
         PetBattlePlanner_PetInfoFrameAbilityStrengthFrame[frameIndex] = {};
         
         local abilityIconSize = 32
         
         local extraGap = 0;
         for abilityIndex = 1,6 do
            
            --
            -- set up Ability Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameAbilityFrame"..frameIndex..abilityIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
               item:SetWidth(abilityIconSize)
               item:SetHeight(abilityIconSize)
               extraGap = extraGap + 4;
               if ((abilityIndex==3) or (abilityIndex==5)) then extraGap = extraGap + 15; end
               item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameName[frameIndex], "BOTTOMLEFT", 2+(abilityIndex-1)*(abilityIconSize)+extraGap,-4)
               local texture = item:CreateTexture("PetBattlePlanner_PetPortraitFrameTexture"..frameIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\ICONS\\INV_Misc_MonsterTail_05")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_PetInfoFrameAbilityFrame[frameIndex][abilityIndex] = texture;
               
               local myButton = CreateFrame("Button", "PetBattlePlanner_PetInfoFrameAbilityFrameButton"..frameIndex..abilityIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
               myButton:SetWidth(abilityIconSize);
               myButton:SetHeight(abilityIconSize);
               myButton:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameAbilityFrame[frameIndex][abilityIndex], "TOPLEFT", 0,0);
               myButton:SetScript("OnEnter",
                  function(self)
              PetBattlePlanner_ShowAbilityTooltip(self, self.abilityID, self.speciesID, self.petID, self.additionalText);
                  end)
               myButton:SetScript("OnLeave", function() PetBattlePlannerPrimaryAbilityTooltip:Hide() end)
               PetBattlePlanner_PetInfoFrameAbilityFrameButton[frameIndex][abilityIndex] = myButton;
               
            end

            --
            -- set up Ability Type Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameAbilityTypeFrame"..frameIndex..abilityIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
               item:SetWidth(20)
               item:SetHeight(20)
               item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameAbilityFrame[frameIndex][abilityIndex], "TOPLEFT", -6,6)
               item:SetFrameLevel( item:GetFrameLevel() +10 );
               local texture = item:CreateTexture("PetBattlePlanner_PetPortraitFrameTexture"..frameIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Beast")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_PetInfoFrameAbilityTypeFrame[frameIndex][abilityIndex] = texture;
            end
            
            --
            -- set up Ability Strength Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameAbilityStrengthFrame"..frameIndex..abilityIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
               item:SetWidth(20)
               item:SetHeight(20)
               item:SetPoint("BOTTOMRIGHT", PetBattlePlanner_PetInfoFrameAbilityFrame[frameIndex][abilityIndex], "BOTTOMRIGHT",6,-4)
               item:SetFrameLevel( item:GetFrameLevel() +10 );
               local texture = item:CreateTexture("PetBattlePlanner_PetInfoFrameAbilityStrengthTexture"..frameIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_PetInfoFrameAbilityStrengthFrame[frameIndex][abilityIndex] = texture;
            end
         end
         
         --
         -- set up Pet Type Icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameTypeIcon"..frameIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
            item:SetWidth(32)
            item:SetHeight(32)
--            item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameAbilityFrame[frameIndex][6], "TOPRIGHT", 15,0)
            item:SetFrameLevel( item:GetFrameLevel() +10 );
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitFrameTexture[frameIndex], "TOPLEFT", -12,8)
            local texture = item:CreateTexture("PetBattlePlanner_PetInfoFrameTypeIconTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Elemental")
            texture:SetTexCoord(0, 1 ,0, 1)
            PetBattlePlanner_PetInfoFrameTypeIcon[frameIndex] = texture;
         end
         
         --
         -- set up Selection Box Frame
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameSelectionBoxTexture"..frameIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
            item:SetWidth(400)
            item:SetHeight(75)
            item:SetFrameLevel( item:GetFrameLevel() +10 );
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitFrameTexture[frameIndex], "TOPLEFT", -12,12)
            PetBattlePlanner_PetInfoFrameSelectionBoxFrame[frameIndex] = item;
            local texture = item:CreateTexture("PetBattlePlanner_PetInfoFrameTypeIconTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattleHud")
            texture:SetTexCoord(0.5625, 0.7285 ,0.7656, 0.8516)
            PetBattlePlanner_PetInfoFrameSelectionBoxTexture[frameIndex] = texture;
            item:Hide();
         end
         

      end
   end
      
  --
  -- Set up Enemy information
  --

   do         
      --
      -- set up Enemy name fontstring
      --
      do
         local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_PetInfoFrameEnemyName", "OVERLAY", "GameFontNormalSmall" )
         item:SetWidth(175);
         item:SetHeight(18);
         item:SetPoint("TOPLEFT", PetBattlePlanner_MinRaritySelectorButtons, "BOTTOMLEFT", 15,-60 )
         item:SetText(yellow.."25"..orange.." Meanie-Bo-Beanie");
         item:SetJustifyH("LEFT");
         local filename, fontHeight, flags = item:GetFont();
         item:SetFont(filename, fontHeight+2, flags);      
         PetBattlePlanner_PetInfoFrameEnemyName = item;
      end
      
      --
      -- set up Enemy portrait frame
      --
      do
         local item = CreateFrame("Frame", "PetBattlePlanner_PetPortraitEnemyFrame", PetBattlePlanner_TabPage1_SampleTextTab1 )
         item:SetWidth(50)
         item:SetHeight(50)
         item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameEnemyName, "BOTTOMLEFT", 6,-10);
         local texture = item:CreateTexture("PetBattlePlanner_PetPortraitEnemyFrameTexture")
         texture:SetAllPoints()
         texture:SetTexture("Interface\\ICONS\\INV_MISC_BONE_HUMANSKULL_02")
--            texture:SetTexCoord(0.5,0.8,0.5,0.65)
         PetBattlePlanner_PetPortraitEnemyFrame = texture;
      end

      --
      -- set up Enemy health icon
      --
      do
         local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoEnemyFrameHealthIcon", PetBattlePlanner_TabPage1_SampleTextTab1 )
         item:SetWidth(18)
         item:SetHeight(18)
         item:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitEnemyFrame, "TOPRIGHT", 15,0)
         local texture = item:CreateTexture("PetBattlePlanner_PetInfoEnemyFrameHealthIconTexture")
         texture:SetAllPoints()
         texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
         texture:SetTexCoord(0.5, 1 ,0.5, 1)
         PetBattlePlanner_PetInfoEnemyFrameHealthIcon = texture;
      end
      
      --
      -- set up Enemy Health FontString
      --
      do
         local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_PetInfoEnemyFrameHealthText", "OVERLAY", "GameFontNormalSmall" )
         item:SetWidth(40);
         item:SetHeight(18);
         item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoEnemyFrameHealthIcon, "TOPRIGHT", 2,0);
         item:SetText(white.."4321");
         item:SetJustifyH("LEFT");
         local filename, fontHeight, flags = item:GetFont();
         item:SetFont(filename, fontHeight+2, flags);      
         PetBattlePlanner_PetInfoEnemyFrameHealthText = item;
      end

      --
      -- set up Enemy Attack power icon
      --
      do
         local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoEnemyFrameAttackPowerIcon", PetBattlePlanner_TabPage1_SampleTextTab1 )
         item:SetWidth(18)
         item:SetHeight(18)
         item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoEnemyFrameHealthIcon, "BOTTOMLEFT", 0,-2)
         local texture = item:CreateTexture("PetBattlePlanner_PetInfoEnemyFrameAttackPowerIconTexture")
         texture:SetAllPoints()
         texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
         texture:SetTexCoord(0, .5 ,0, .5)
         PetBattlePlanner_PetInfoEnemyFrameAttackPowerIcon = texture;
      end
      
      --
      -- set up Enemy Attack power FontString
      --
      do
         local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_PetInfoEnemyFrameAttackPwrText", "OVERLAY", "GameFontNormalSmall" )
         item:SetWidth(40);
         item:SetHeight(18);
         item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoEnemyFrameAttackPowerIcon, "TOPRIGHT", 2,0);
         item:SetText(white.."4321");
         item:SetJustifyH("LEFT");
         local filename, fontHeight, flags = item:GetFont();
         item:SetFont(filename, fontHeight+2, flags);      
         PetBattlePlanner_PetInfoEnemyFrameAttackPwrText = item;
      end
      
      --
      -- set up Enemy Haste icon
      --
      do
         local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoEnemyFrameHasteIcon", PetBattlePlanner_TabPage1_SampleTextTab1 )
         item:SetWidth(18)
         item:SetHeight(18)
         item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoEnemyFrameAttackPowerIcon, "BOTTOMLEFT", 0,-2)
         local texture = item:CreateTexture("PetBattlePlanner_PetInfoEnemyFrameHasteIconTexture")
         texture:SetAllPoints()
         texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
         texture:SetTexCoord(0, .5 ,0.5, 1)
         PetBattlePlanner_PetInfoEnemyFrameHasteIcon = texture;
      end
      
      --
      -- set up Enemy Haste FontString
      --
      do
         local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_PetInfoEnemyFrameHasteText", "OVERLAY", "GameFontNormalSmall" )
         item:SetWidth(40);
         item:SetHeight(18);
         item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoEnemyFrameHasteIcon, "TOPRIGHT", 2,0);
         item:SetText(white.."4321");
         item:SetJustifyH("LEFT");
         local filename, fontHeight, flags = item:GetFont();
         item:SetFont(filename, fontHeight+2, flags);      
         PetBattlePlanner_PetInfoEnemyFrameHasteText = item;
      end
      


      local abilityIndex;
      PetBattlePlanner_PetInfoEnemyFrameAbilityFrame = {};
      PetBattlePlanner_PetInfoEnemyFrameAbilityFrameTexture = {};
      PetBattlePlanner_PetInfoEnemyFrameAbilityFrameButton = {};
      PetBattlePlanner_PetInfoEnemyFrameAbilityTypeFrame = {};
      PetBattlePlanner_PetInfoEnemyFrameAbilityStrengthFrame = {};
      
      local abilityIconSize = 32
      
      for abilityIndex = 1,3 do
         
         --
         -- set up Ability Icon
         --
         
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoEnemyFrameAbilityFrame"..abilityIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
            item:SetWidth(abilityIconSize)
            item:SetHeight(abilityIconSize)
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitEnemyFrame, "BOTTOMLEFT", (abilityIndex-1)*(abilityIconSize+6),-20)
            local texture = item:CreateTexture("PetBattlePlanner_PetInfoEnemyFrameAbilityFrameTexture"..abilityIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\ICONS\\INV_Misc_MonsterTail_05")
            texture:SetTexCoord(0, 1 ,0, 1)
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrame[abilityIndex] = item;
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrameTexture[abilityIndex] = texture;

            local myButton = CreateFrame("Button", "PetBattlePlanner_PetInfoEnemyFrameAbilityFrameButton"..abilityIndex, PetBattlePlanner_PetInfoEnemyFrameAbilityFrame[abilityIndex] )
            myButton:SetWidth(abilityIconSize);
            myButton:SetHeight(abilityIconSize);
            myButton:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoEnemyFrameAbilityFrame[abilityIndex], "TOPLEFT", 0,0);
            myButton:SetScript("OnEnter",
               function(self)
            PetBattlePlanner_ShowAbilityTooltip(self, self.abilityID, self.speciesID, self.petID, self.additionalText, self.attackPower);
               end)
            myButton:SetScript("OnLeave", function() PetBattlePlannerPrimaryAbilityTooltip:Hide() end)
            PetBattlePlanner_PetInfoEnemyFrameAbilityFrameButton[abilityIndex] = myButton;
         end

         --
         -- set up Ability Type Icon
         --
         
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoEnemyFrameAbilityTypeFrame"..abilityIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
            item:SetWidth(20)
            item:SetHeight(20)
            item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoEnemyFrameAbilityFrame[abilityIndex], "TOPLEFT", -6,6)
            item:SetFrameLevel( item:GetFrameLevel() +10 );
            local texture = item:CreateTexture("PetBattlePlanner_PetPortraitFrameTexture"..abilityIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Beast")
            texture:SetTexCoord(0, 1 ,0, 1)
            PetBattlePlanner_PetInfoEnemyFrameAbilityTypeFrame[abilityIndex] = texture;
         end
         
         --
         -- set up Ability Strength Icon
         --
         
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoEnemyFrameAbilityStrengthFrame"..abilityIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
            item:SetWidth(20)
            item:SetHeight(20)
            item:SetPoint("BOTTOMRIGHT", PetBattlePlanner_PetInfoEnemyFrameAbilityFrame[abilityIndex], "BOTTOMRIGHT",6,-4)
            item:SetFrameLevel( item:GetFrameLevel() +10 );
            local texture = item:CreateTexture("PetBattlePlanner_PetInfoEnemyFrameAbilityStrengthFrameTexture"..abilityIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong")
            texture:SetTexCoord(0, 1 ,0, 1)
            PetBattlePlanner_PetInfoEnemyFrameAbilityStrengthFrame[abilityIndex] = texture;
         end
      end
      
      --
      -- set up Pet Type Icon
      --
      do
         local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoEnemyFrameTypeIcon", PetBattlePlanner_TabPage1_SampleTextTab1 )
         item:SetWidth(32)
         item:SetHeight(32)
         item:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitEnemyFrame, "TOPLEFT", -12,8)
         item:SetFrameLevel( item:GetFrameLevel() +10 );
         local texture = item:CreateTexture("PetBattlePlanner_PetInfoEnemyFrameTypeIconTexture")
         texture:SetAllPoints()
         texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Elemental")
         texture:SetTexCoord(0, 1 ,0, 1)
         PetBattlePlanner_PetInfoEnemyFrameTypeIcon = texture;
      end
      

   end

      
   
   --
   -- set up slide bar
   --
   
   do
      local backdrop = {
         -- path to the background texture
         bgFile = "Interface\\Buttons\\UI-SliderBar-Background",  
         -- path to the border texture
         edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
         -- true to repeat the background texture to fill the frame, false to scale it
         tile = true,
         -- size (width or height) of the square repeating background tiles (in pixels)
         tileSize = 8,
         -- thickness of edge segments and square size of edge corners (in pixels)
         edgeSize = 8,
         -- distance from the edges of the frame to those of the background texture (in pixels)
         insets = {
            left = 3,
            right = 3,
            top = 6,
            bottom = 6
         }
      }
     
      local item = CreateFrame("Slider", "PetBattlePlanner_PetInfoFrameSlider", PetBattlePlanner_TabPage1_SampleTextTab1 )
      item:SetWidth(25);
      item:SetHeight(360);
      item:SetOrientation("VERTICAL");
      item:SetPoint("TOPLEFT", PetBattlePlanner_PetInfoFrameHealthText[1], "TOPRIGHT", 5,0);
      item:SetBackdrop(backdrop);
      local texture = item:CreateTexture("PetBattlePlanner_PetInfoFrameSliderTexture");
      texture:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
      texture:SetWidth(25);
      texture:SetHeight(25);
      item:SetThumbTexture(texture);
      item.thumb = texture;
      item:SetScript("OnValueChanged", PetBattlePlanner_UpdateGui );
      PetBattlePlanner_PetInfoFrameSlider = item;


      -- 
      -- setup scroll wheel
      --
      PetBattlePlanner_TabPage1:EnableMouseWheel(true);
      PetBattlePlanner_TabPage1:SetScript("OnMouseWheel", function(self,delta) PetBattlePlanner_OnMouseWheel(self, delta) end );
      item:SetMinMaxValues(1, 5)
      item:SetValueStep(1.0)
      item:SetValue(1)      
   end
   
   --
   -- set up team selection
   --
   do
      PetBattlePlanner_TeamNamesFrame = {};
--      PetBattlePlanner_EnemyTeamNamesFrame = {};
--      PetBattlePlanner_EnemyTeamNamesFrameButton = {};
      
      local teamSlotIndex;
      for teamSlotIndex=1,3 do 
         

         do
            local item = PetBattlePlanner_TabPage1:CreateFontString("PetBattlePlanner_TeamNamesFrame"..teamSlotIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(200);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1_OpponentChooserHeader", "TOPLEFT", 20,65-435-18*(teamSlotIndex-1));
            item:SetText(string.format("%s%d %s%s",yellow,25,  RARITY_COLOR[3],"Pet "..teamSlotIndex.." Name"));
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_TeamNamesFrame[teamSlotIndex] = item;
         end
         
      end
   end
   
   --
   -- Set up team selection button
   --
   do
      local myButton = CreateFrame("Button", "PetBattlePlanner_TeamNamesFrameButton", PetBattlePlanner_TabPage1 )
--      myButton:SetFontString( item )
      myButton:SetWidth(200);
      myButton:SetHeight(18*3);
      myButton:SetPoint("TOPLEFT", PetBattlePlanner_TeamNamesFrame[1], "TOPLEFT", 0,0);
      myButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Click to set this team.");
                  GameTooltip:Show()
               end)
      myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
      myButton:SetScript("OnClick", function(self,button,down)
         PetBattlePlanner_SetCurrentTeam();
         end)
      PetBattlePlanner_TeamNamesFrameButton = myButton;
   end
   
   --
   -- Set up Floating Abiltiy Tooltip frame
   --
   do
      local item = CreateFrame("Frame", "PetBattlePlannerPrimaryAbilityTooltip", PetBattlePlanner_TabPage1_SampleTextTab1, "SharedPetBattleAbilityTooltipTemplate" )
      PetBattlePlannerPrimaryAbilityTooltip = item;
   end



   PetBattlePlanner_TeamListPetPortraitFrame = {};
   PetBattlePlanner_TeamListPetPortraitFrameTexture = {};
   PetBattlePlanner_TeamListPetInfoFrameName = {};
   PetBattlePlanner_TeamListPetInfoFrameName = {};
   PetBattlePlanner_TeamListPetInfoFrameHealthIcon = {};
   PetBattlePlanner_TeamListPetInfoFrameHealthText = {};
   PetBattlePlanner_TeamListPetInfoFrameAttackPowerIcon = {};
   PetBattlePlanner_TeamListPetInfoFrameAttackPwrText = {};
   PetBattlePlanner_TeamListPetInfoFrameHasteIcon = {};
   PetBattlePlanner_TeamListPetInfoFrameHasteText = {};
   PetBattlePlanner_TeamListPetInfoFrameAbilityFrame = {};
   PetBattlePlanner_TeamListPetInfoFrameAbilityFrameButton = {};
   PetBattlePlanner_TeamListPetInfoFrameAbilityTypeFrame = {};
   PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthFrame = {};
   PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthTexture = {};
   PetBattlePlanner_TeamListPetInfoFrameTypeIcon = {};
   PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame = {};
   PetBattlePlanner_EnemyTeamPetPortraitEnemyTexture = {};
   PetBattlePlanner_EnemyTeamListPetInfoFrameTypeIcon = {};
   PetBattlePlanner_EnemyTeamPetInfoFrameEnemyName = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameTexture = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeFrame = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeTexture = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrame = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthTexture = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthIcon = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthText = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPowerIcon = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPwrText = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteIcon = {};
   PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteText = {};
         
         
             
                       
    --
    -- Set up team Summary
    --  
   
   do
      do
         local backdrop = {
            bgFile = "Interface/DialogFrame/UI-DialogBox-Background",  
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {
               left = 5,
               right = 5,
               top = 5,
               bottom = 5
            }
         }
         
         local item = CreateFrame("Frame", "PetBattlePlanner_TeamListBackdrop", PetBattlePlanner_TabPage1_SampleTextTab1 )
         item:SetWidth(640)
         item:SetHeight(210)
         item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1GroupFrame, "BOTTOMLEFT", 0,-2)
         item:SetBackdrop(backdrop);
--         local texture = item:CreateTexture("PetBattlePlanner_TeamListBackdropTexture")
--         texture:SetAllPoints()
--         texture:SetTexture("Interface\\PetBattles\\DeadPetIcon")
      end
  
--                 <Frame name="$parentGroupFrame">
--                  <Size><AbsDimension x="640" y="420" /></Size>
--                  <Anchors>
--                     <Anchor point="TOPLEFT" relativeTo="$parent">
--                        <Offset>
--                           <AbsDimension x="20" y="-55"/>
--                        </Offset>
--                     </Anchor>
--                  </Anchors>
--                  <Backdrop bgFile="Interface\DialogFrame\UI-DialogBox-Background" edgeFile="Interface\Tooltips\UI-Tooltip-Border" tile="true">
--                     <BackgroundInsets><AbsInset left="5" right="5" top="5" bottom="5" /></BackgroundInsets>
--                     <TileSize><AbsValue val="16" /></TileSize>
--                     <EdgeSize><AbsValue val="16" /></EdgeSize>
--                  </Backdrop>
--               </Frame> 
   
      local frameIndex;
      for frameIndex = 1,3 do
         
         --
         -- set up character portrait frame
         --
         
         do
            
            local item = CreateFrame("Frame", "PetBattlePlanner_TeamListPetPortraitFrame"..frameIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
            item:SetWidth(50)
            item:SetHeight(50)
            item:SetPoint("TOPLEFT", PetBattlePlanner_CountMatrixTitle, "TOPLEFT", 0,-420-65*(frameIndex-1))
            local texture = item:CreateTexture("PetBattlePlanner_TeamListPetPortraitFrameTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\DeadPetIcon")
--            texture:SetTexture("Interface\\PetBattles\\PetIcon-Magical")
--            texture:SetTexCoord(0.5,0.8,0.5,0.65)
            PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] = item;
            PetBattlePlanner_TeamListPetPortraitFrameTexture[frameIndex] = texture;

--            local myButton = CreateFrame("Button", "PetBattlePlanner_PetPortraitFrameButton"..frameIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
--            myButton:SetWidth(50);
--            myButton:SetHeight(50);
--            myButton:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitFrameTexture[frameIndex], "TOPLEFT", 0,0);
--            myButton:SetScript("OnEnter",
--                     function(this)
--                        GameTooltip_SetDefaultAnchor(GameTooltip, this)
--                        GameTooltip:SetText("Choose your opponent Pet to be compared with the enemy pet.");
--                        GameTooltip:Show()
--                     end)
--            myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
--            myButton:RegisterForClicks( "LeftButtonUp","RightButtonUp" );
--            myButton:SetScript("OnClick", function(self,button,down)
--                  if ( button == "LeftButton" ) then
--                     PetBattlePlanner_SetSelectedPetClickHandler(frameIndex-1);
--                  elseif ( button == "RightButton" ) then                  
--                     EasyMenu(menuTbl, PetBattlePlanner_TabPage1, "PetBattlePlanner_PetPortraitFrameButton"..frameIndex ,0,0, nil, 10)
--                  end
--               end)
--            PetBattlePlanner_PetPortraitFrameButton[frameIndex] = myButton;


         end

         --
         -- set up character name fontstring
         --
         do
            local item = PetBattlePlanner_TeamListPetPortraitFrame[frameIndex]:CreateFontString("PetBattlePlanner_TeamListPetInfoFrameName"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(265);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetPortraitFrameTexture[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(yellow.."25"..blue.." Pet Name");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_TeamListPetInfoFrameName[frameIndex] = item;
         end
         
         --
         -- set up health icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_TeamListPetInfoFrameHealthIcon"..frameIndex, PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameName[frameIndex], "TOPRIGHT", 2,0)
            local texture = item:CreateTexture("PetBattlePlanner_TeamListPetPortraitFrameTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0.5, 1 ,0.5, 1)
            PetBattlePlanner_TeamListPetInfoFrameHealthIcon[frameIndex] = texture;
         end
         
         --
         -- set up Health FontString
         --
         do
            local item = PetBattlePlanner_TeamListPetPortraitFrame[frameIndex]:CreateFontString("PetBattlePlanner_TeamListPetInfoFrameHealthText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameHealthIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."1234");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_TeamListPetInfoFrameHealthText[frameIndex] = item;
         end

         --
         -- set up Attack power icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_TeamListPetInfoFrameAttackPowerIcon"..frameIndex, PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameHealthIcon[frameIndex], "BOTTOMLEFT", 0,-2)
            local texture = item:CreateTexture("PetBattlePlanner_TeamListPetPortraitFrameTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0, .5 ,0, .5)
            PetBattlePlanner_TeamListPetInfoFrameAttackPowerIcon[frameIndex] = texture;
         end
         
         --
         -- set up Attack power FontString
         --
         do
            local item = PetBattlePlanner_TeamListPetPortraitFrame[frameIndex]:CreateFontString("PetBattlePlanner_TeamListPetInfoFrameAttackPwrText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameAttackPowerIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."1234");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_TeamListPetInfoFrameAttackPwrText[frameIndex] = item;
         end
         
         --
         -- set up Haste icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_TeamListPetInfoFrameHasteIcon"..frameIndex, PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameAttackPowerIcon[frameIndex], "BOTTOMLEFT", 0,-2)
            local texture = item:CreateTexture("PetBattlePlanner_TeamListPetPortraitFrameTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0, .5 ,0.5, 1)
            PetBattlePlanner_TeamListPetInfoFrameHasteIcon[frameIndex] = texture;
         end
         
         --
         -- set up Haste FontString
         --
         do
            local item = PetBattlePlanner_TeamListPetPortraitFrame[frameIndex]:CreateFontString("PetBattlePlanner_TeamListPetInfoFrameHasteText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameHasteIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."1234");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_TeamListPetInfoFrameHasteText[frameIndex] = item;
         end
         


         local abilityIndex;
         PetBattlePlanner_TeamListPetInfoFrameAbilityFrame[frameIndex] = {};
         PetBattlePlanner_TeamListPetInfoFrameAbilityFrameButton[frameIndex] = {};
         PetBattlePlanner_TeamListPetInfoFrameAbilityTypeFrame[frameIndex] = {};
         PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthFrame[frameIndex] = {};
         PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthTexture[frameIndex] = {};
         PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame[frameIndex] = {};
         PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameTexture[frameIndex] = {};
         PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[frameIndex] = {};
         PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeFrame[frameIndex] = {};
         PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeTexture[frameIndex] = {};
         PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrame[frameIndex] = {};       
         PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthTexture[frameIndex] = {};       
        
         local abilityIconSize = 32
         
         local abilityIndex;
         local extraGap = 0;
         for abilityIndex = 1,6 do
            
            --
            -- set up Ability Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_TeamListPetInfoFrameAbilityFrame"..frameIndex..abilityIndex, PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] )
               item:SetWidth(abilityIconSize)
               item:SetHeight(abilityIconSize)
               extraGap = extraGap + 4;
               if ((abilityIndex==3) or (abilityIndex==5)) then extraGap = extraGap + 15; end
               item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameName[frameIndex], "BOTTOMLEFT", 2+(abilityIndex-1)*(abilityIconSize)+extraGap,-4)
               local texture = item:CreateTexture("PetBattlePlanner_TeamListPetPortraitFrameTexture"..frameIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\ICONS\\INV_Misc_MonsterTail_05")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_TeamListPetInfoFrameAbilityFrame[frameIndex][abilityIndex] = texture;
               
               local myButton = CreateFrame("Button", "PetBattlePlanner_TeamListPetInfoFrameAbilityFrameButton"..frameIndex..abilityIndex, PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] )
               myButton:SetWidth(abilityIconSize);
               myButton:SetHeight(abilityIconSize);
               myButton:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameAbilityFrame[frameIndex][abilityIndex], "TOPLEFT", 0,0);
               myButton:SetScript("OnEnter",
                  function(self)
                     PetBattlePlanner_ShowAbilityTooltip(self, self.abilityID, self.speciesID, self.petID, self.additionalText);
                  end)
               myButton:SetScript("OnLeave", function() PetBattlePlannerPrimaryAbilityTooltip:Hide() end)
               PetBattlePlanner_TeamListPetInfoFrameAbilityFrameButton[frameIndex][abilityIndex] = myButton;
               
            end

            --
            -- set up Ability Type Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_TeamListPetInfoFrameAbilityTypeFrame"..frameIndex..abilityIndex, PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] )
               item:SetWidth(20)
               item:SetHeight(20)
               item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameAbilityFrame[frameIndex][abilityIndex], "TOPLEFT", -6,6)
               item:SetFrameLevel( item:GetFrameLevel() +10 );
               local texture = item:CreateTexture("PetBattlePlanner_TeamListPetPortraitFrameTexture"..frameIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Beast")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_TeamListPetInfoFrameAbilityTypeFrame[frameIndex][abilityIndex] = texture;
            end
            
            --
            -- set up Ability Strength Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthFrame"..frameIndex..abilityIndex, PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] )
               item:SetWidth(20)
               item:SetHeight(20)
               item:SetPoint("BOTTOMRIGHT", PetBattlePlanner_TeamListPetInfoFrameAbilityFrame[frameIndex][abilityIndex], "BOTTOMRIGHT",6,-4)
               item:SetFrameLevel( item:GetFrameLevel() +10 );
               local texture = item:CreateTexture("PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthTexture"..frameIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthFrame[frameIndex][abilityIndex] = item;
               PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthTexture[frameIndex][abilityIndex] = texture;
            end
         end
         
         --
         -- set up Pet Type Icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_TeamListPetInfoFrameTypeIcon"..frameIndex, PetBattlePlanner_TeamListPetPortraitFrame[frameIndex] )
            item:SetWidth(32)
            item:SetHeight(32)
--            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameAbilityFrame[frameIndex][6], "TOPRIGHT", 15,0)
            item:SetFrameLevel( item:GetFrameLevel() +10 );
            item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetPortraitFrameTexture[frameIndex], "TOPLEFT", -12,8)
            local texture = item:CreateTexture("PetBattlePlanner_TeamListPetInfoFrameTypeIconTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Elemental")
            texture:SetTexCoord(0, 1 ,0, 1)
            PetBattlePlanner_TeamListPetInfoFrameTypeIcon[frameIndex] = texture;
         end
         
--         --
--         -- set up Selection Box Frame
--         --
--         do
--            local item = CreateFrame("Frame", "PetBattlePlanner_PetInfoFrameSelectionBoxTexture"..frameIndex, PetBattlePlanner_PetPortraitFrame[frameIndex] )
--            item:SetWidth(400)
--            item:SetHeight(75)
--            item:SetFrameLevel( item:GetFrameLevel() +10 );
--            item:SetPoint("TOPLEFT", PetBattlePlanner_PetPortraitFrameTexture[frameIndex], "TOPLEFT", -12,12)
--            PetBattlePlanner_PetInfoFrameSelectionBoxFrame[frameIndex] = item;
--            local texture = item:CreateTexture("PetBattlePlanner_PetInfoFrameTypeIconTexture"..frameIndex)
--            texture:SetAllPoints()
--            texture:SetTexture("Interface\\PetBattles\\PetBattleHud")
--            texture:SetTexCoord(0.5625, 0.7285 ,0.7656, 0.8516)
--            PetBattlePlanner_PetInfoFrameSelectionBoxTexture[frameIndex] = texture;
--            item:Hide();
--         end
         
      --
      -- Set up Enemy information
      --


        --
        -- set up Enemy portrait frame
        --
        do
           local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame", PetBattlePlanner_TabPage1_SampleTextTab1 )
           item:SetWidth(50)
           item:SetHeight(50)
           item:SetPoint("TOPLEFT", PetBattlePlanner_TeamListPetInfoFrameHealthText[frameIndex], "TOPRIGHT", 15,0);
           local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetPortraitEnemyFrameTexture")
           texture:SetAllPoints()
           texture:SetTexture("Interface\\ICONS\\INV_MISC_BONE_HUMANSKULL_02")
  --            texture:SetTexCoord(0.5,0.8,0.5,0.65)
           PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] = item;
           PetBattlePlanner_EnemyTeamPetPortraitEnemyTexture[frameIndex] = texture;
      end
      
      --
      -- set up Enemy Type Icon
      --
      do
         local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamListPetInfoFrameTypeIcon"..frameIndex, PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] )
         item:SetWidth(32)
         item:SetHeight(32)
         item:SetFrameLevel( item:GetFrameLevel() +10 );
         item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex], "TOPLEFT", -12,8)
         local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamListPetInfoFrameTypeIconTexture"..frameIndex)
         texture:SetAllPoints()
         texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Elemental")
         texture:SetTexCoord(0, 1 ,0, 1)
         PetBattlePlanner_EnemyTeamListPetInfoFrameTypeIcon[frameIndex] = texture;
      end

      --
      -- set up Enemy name fontstring
      --
      do
         local item = PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex]:CreateFontString("PetBattlePlanner_EnemyTeamPetInfoFrameEnemyName"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
         item:SetWidth(125);
         item:SetHeight(18);
         item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex], "TOPRIGHT", 2,0 )
         item:SetText(yellow.."25"..orange.." Meanie-Bo-Beanie");
         item:SetJustifyH("LEFT");
         local filename, fontHeight, flags = item:GetFont();
         item:SetFont(filename, fontHeight+2, flags);
         PetBattlePlanner_EnemyTeamPetInfoFrameEnemyName[frameIndex] = item;
      end
      
         for abilityIndex = 1,3 do
            
            --
            -- set up Ability Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame"..frameIndex..abilityIndex, PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] )
               item:SetWidth(abilityIconSize)
               item:SetHeight(abilityIconSize)
               item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoFrameEnemyName[frameIndex], "BOTTOMLEFT", (abilityIndex-1)*(abilityIconSize+6)+3,-2)
               local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameTexture"..frameIndex..abilityIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\ICONS\\INV_Misc_MonsterTail_05")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame[frameIndex][abilityIndex] = item;
               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameTexture[frameIndex][abilityIndex] = texture;
   
               local myButton = CreateFrame("Button", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton"..frameIndex..abilityIndex, PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame[frameIndex][abilityIndex] )
               myButton:SetWidth(abilityIconSize);
               myButton:SetHeight(abilityIconSize);
               myButton:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame[frameIndex][abilityIndex], "TOPLEFT", 0,0);
               myButton:SetScript("OnEnter",
                  function(self)
                     PetBattlePlanner_ShowAbilityTooltip(self, self.abilityID, self.speciesID, self.petID, self.additionalText, self.attackPower);
                  end)
               myButton:SetScript("OnLeave", function() PetBattlePlannerPrimaryAbilityTooltip:Hide() end)
               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[frameIndex][abilityIndex] = myButton;
            end
   
            --
            -- set up Ability Type Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeFrame"..frameIndex..abilityIndex, PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] )
               item:SetWidth(20)
               item:SetHeight(20)
               item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame[frameIndex][abilityIndex], "TOPLEFT", -6,6)
               item:SetFrameLevel( item:GetFrameLevel() +10 );
               local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetPortraitFrameTexture"..frameIndex..abilityIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Beast")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeFrame[frameIndex][abilityIndex] = item;
               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeTexture[frameIndex][abilityIndex] = texture;
            end
            
            --
            -- set up Ability Strength Icon
            --
            
            do
               local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrame"..frameIndex..abilityIndex, PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] )
               item:SetWidth(20)
               item:SetHeight(20)
               item:SetPoint("BOTTOMRIGHT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[frameIndex][abilityIndex], "BOTTOMRIGHT",6,-4)
               item:SetFrameLevel( item:GetFrameLevel() +10 );
               local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrameTexture"..frameIndex..abilityIndex)
               texture:SetAllPoints()
               texture:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong")
               texture:SetTexCoord(0, 1 ,0, 1)
               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrame[frameIndex][abilityIndex] = item;
               PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthTexture[frameIndex][abilityIndex] = texture;
            end
         end
 
         --
         -- set up Enemy health icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthIcon"..frameIndex, PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoFrameEnemyName[frameIndex], "TOPRIGHT", 0,0)
            local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthIconTexture")
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0.5, 1 ,0.5, 1)
            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthIcon[frameIndex] = texture;
         end
         
         --
         -- set up Enemy Health FontString
         --
         do
            local item = PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex]:CreateFontString("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."4321");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthText[frameIndex] = item;
         end
   
 				--
 				-- set up Enemy Attack power icon
 				--
 				do
            local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPowerIcon"..frameIndex, PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthIcon[frameIndex], "BOTTOMLEFT", 0,-2)
            local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPowerIconTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0, .5 ,0, .5)
            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPowerIcon[frameIndex] = texture;
         end
       
         --
         -- set up Enemy Attack power FontString
         --
         do
            local item = PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex]:CreateFontString("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPwrText", "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPowerIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."4321");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPwrText[frameIndex] = item;
         end
       
         --
         -- set up Enemy Haste icon
         --
         do
            local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteIcon"..frameIndex, PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] )
            item:SetWidth(18)
            item:SetHeight(18)
            item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPowerIcon[frameIndex], "BOTTOMLEFT", 0,-2)
            local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteIconTexture"..frameIndex)
            texture:SetAllPoints()
            texture:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
            texture:SetTexCoord(0, .5 ,0.5, 1)
            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteIcon[frameIndex] = texture;
         end
         
         --
         -- set up Enemy Haste FontString
         --
         do
            local item = PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex]:CreateFontString("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(40);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteIcon[frameIndex], "TOPRIGHT", 2,0);
            item:SetText(white.."4321");
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteText[frameIndex] = item;
         end
          
         
         
         
         

      end
   end
   
   
   
   
   
   
end


function PetBattlePlanner_OnMouseWheel(self, delta)
   local current = PetBattlePlanner_PetInfoFrameSlider:GetValue()

   if (delta<0) and (current<#playerSortedList-4) then
      PetBattlePlanner_PetInfoFrameSlider:SetValue(current+1)
   elseif (delta>0) and (current>1) then
      PetBattlePlanner_PetInfoFrameSlider:SetValue(current-1)
   end
end



function PetBattlePlanner_buildPlayerListSort(inputList)
   local playerCount = 1;
   local playerList = {};

   local index;
   for index = 1,#inputList do
      playerList[index] = inputList[index];
   end
   
   return playerList;

end
