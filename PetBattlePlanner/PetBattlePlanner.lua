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
      if ( PetBattlePlanner_GetLowestRarity() >= 5 ) then -- trainers will have good pets. Number - 1: "Poor", 2: "Common", 3: "Uncommon", 4: "Rare", 5: "Epic", 6: "Legendary"
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
            print("speciesID="..speciesID)
            
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
         
         local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, petType);
         outputLine = outputLine.." is "..ATTACK_RESULT_TEXT[attackResult].." vs me("..PET_TYPE_TEXT[petType]..")";
         if ( attackResult > worstAttackVsMe ) then
            worstAttackVsMe = attackResult;
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
   
            local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, PetBattlePlanner_db["Opponents"][enemyName]["Team"][PetBattlePlanner_OpponentPetIndex]["PetType"]);
            if ( attackResult > bestAttackVsHim ) then
               bestAttackVsHim = attackResult;
            end
   
            outputLine = outputLine.." is "..ATTACK_RESULT_TEXT[attackResult]
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
            -- display enemy team info
            --
            if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil) and
               ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team ~= nil ) and
               ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[slotIndex] ~= nil ) then
   
               local displayLevel   = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[slotIndex].Level or 0;
               local displayName    = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[slotIndex].Name or "unknown";
               local displayRarity  = PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[slotIndex].Rarity or 1;
               local formattedInfo = string.format("%s%d %s%s",yellow,displayLevel,  RARITY_COLOR[displayRarity],displayName );
    
               PetBattlePlanner_EnemyTeamNamesFrame[slotIndex]:SetText(formattedInfo);
            else
               PetBattlePlanner_EnemyTeamNamesFrame[slotIndex]:SetText(nil);
            end
      
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
         
            
      
      
   end
end



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
--	   print("attackPower = "..self.attackPower);
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
--	   print("abilityID="..abilityID.." speciesID="..(speciesID or "nospecies").." petID="..(petID or "noPetID"));
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
      local opponentName, menuIndex;
      menuIndex = 2;
      for opponentName,opponentInfo in pairs(PetBattlePlanner_db["Opponents"]) do
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
--      item:SetScript("OnLoad",
--               function(self)
--                      self:SetMinMaxValues(1, 5)
--                      self:SetValueStep(1.0)
--                      self:SetValue(1)
--               end)
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
      PetBattlePlanner_EnemyTeamNamesFrame = {};
      PetBattlePlanner_EnemyTeamNamesFrameButton = {};
      
      local teamSlotIndex;
      for teamSlotIndex=1,3 do 
         
         do
            local item = PetBattlePlanner_TabPage1:CreateFontString("PetBattlePlanner_EnemyTeamNamesFrame"..teamSlotIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(200);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1_OpponentChooserHeader", "TOPLEFT", -200+20,65-435-18*(teamSlotIndex-1));
            item:SetText(string.format("%s%d %s%s",yellow,25,  RARITY_COLOR[6],"Enemy Pet "..teamSlotIndex.." Name"));
            item:SetJustifyH("LEFT");
            local filename, fontHeight, flags = item:GetFont();
            item:SetFont(filename, fontHeight+2, flags);      
            PetBattlePlanner_EnemyTeamNamesFrame[teamSlotIndex] = item;

            local myButton = CreateFrame("Button", "PetBattlePlanner_EnemyTeamNamesFrameButton"..teamSlotIndex, PetBattlePlanner_TabPage1 )
            myButton:SetFontString( item )
            myButton:SetWidth(200);
            myButton:SetHeight(18);
            myButton:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamNamesFrame[teamSlotIndex], "TOPLEFT", 0,0);
            myButton:SetScript("OnEnter",
                     function(this)
                        GameTooltip_SetDefaultAnchor(GameTooltip, this)
                        local petName = this:GetText();
                        if (petName == nil) then
                           petName = "unknown Name";
                        end
                        GameTooltip:SetText("Click to set "..petName.." as the pet for comparison");
                        GameTooltip:Show()
                     end)
            myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
            myButton:SetScript("OnClick", function(self,button,down)
                  local petName = self:GetText();
                  if ( petName ~= nil ) then
                     local index
                     for index=1,3 do 
                        if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[index] ~= nil ) and
                           ( string.find( petName, PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[index].Name ) ) then
                           PetBattlePlanner_SetOpponentPetIndex(index);
                           break;
                        end
                     end
                  end
               end)
            PetBattlePlanner_EnemyTeamNamesFrameButton[teamSlotIndex] = myButton;


         end

         do
            local item = PetBattlePlanner_TabPage1:CreateFontString("PetBattlePlanner_TeamNamesFrame"..teamSlotIndex, "OVERLAY", "GameFontNormalSmall" )
            item:SetWidth(200);
            item:SetHeight(18);
            item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamNamesFrame[teamSlotIndex], "TOPRIGHT", 10,0);
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
	PetBattlePlanner_TeamListPetInfoFrameTypeIcon = {};
	PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame = {};
	PetBattlePlanner_EnemyTeamPetInfoFrameEnemyName = {};
	PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame = {};
	PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameTexture = {};
	PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton = {};
	PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeFrame = {};
	PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrame = {};
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
			PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame[frameIndex] = {};
			PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameTexture[frameIndex] = {};
			PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[frameIndex] = {};
			PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeFrame[frameIndex] = {};
			PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrame[frameIndex] = {};       
			  
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
               PetBattlePlanner_TeamListPetInfoFrameAbilityStrengthFrame[frameIndex][abilityIndex] = texture;
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
	         PetBattlePlanner_EnemyTeamPetPortraitEnemyFrame[frameIndex] = texture;
	      end

			--
			-- set up Enemy name fontstring
			--
			do
				local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_EnemyTeamPetInfoFrameEnemyName"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
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
	            local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame"..frameIndex..abilityIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
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
	            local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeFrame"..frameIndex..abilityIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
	            item:SetWidth(20)
	            item:SetHeight(20)
	            item:SetPoint("TOPLEFT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrame[frameIndex][abilityIndex], "TOPLEFT", -6,6)
	            item:SetFrameLevel( item:GetFrameLevel() +10 );
	            local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetPortraitFrameTexture"..frameIndex..abilityIndex)
	            texture:SetAllPoints()
	            texture:SetTexture("Interface\\TARGETINGFRAME\\PetBadge-Beast")
	            texture:SetTexCoord(0, 1 ,0, 1)
	            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityTypeFrame[frameIndex][abilityIndex] = texture;
	         end
	         
	         --
	         -- set up Ability Strength Icon
	         --
	         
	         do
	            local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrame"..frameIndex..abilityIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
	            item:SetWidth(20)
	            item:SetHeight(20)
	            item:SetPoint("BOTTOMRIGHT", PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityFrameButton[frameIndex][abilityIndex], "BOTTOMRIGHT",6,-4)
	            item:SetFrameLevel( item:GetFrameLevel() +10 );
	            local texture = item:CreateTexture("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrameTexture"..frameIndex..abilityIndex)
	            texture:SetAllPoints()
	            texture:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong")
	            texture:SetTexCoord(0, 1 ,0, 1)
	            PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAbilityStrengthFrame[frameIndex][abilityIndex] = texture;
	         end
	      end

	      --
	      -- set up Enemy health icon
	      --
	      do
	         local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthIcon"..frameIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
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
	         local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHealthText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
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
         local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPowerIcon"..frameIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
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
         local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameAttackPwrText", "OVERLAY", "GameFontNormalSmall" )
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
         local item = CreateFrame("Frame", "PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteIcon"..frameIndex, PetBattlePlanner_TabPage1_SampleTextTab1 )
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
         local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_EnemyTeamPetInfoEnemyFrameHasteText"..frameIndex, "OVERLAY", "GameFontNormalSmall" )
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
