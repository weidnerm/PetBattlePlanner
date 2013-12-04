-- ****************************************************
-- * DECLARE VARIABLES *
-- ****************************************************
local darkGrey   = "|c00252525";
local mediumGrey = "|c00707070";
local lightGrey  = "|c00a0a0a0";
local yellow = "|c00FFFF25";
local white  = "|c00FFFFff";
local red    = "|c00FF0000";
local green  = "|c0000ff00";
local blue   = "|c000000ff";
local purple = "|c00b048f8";
local orange = "|c00ff8000";



local PetBattlePlanner_lastTargetName;
local PET_OWNER_PLAYER = 1;
local PET_OWNER_OPPONENT = 2;

local PetBattlePlanner_OpponentName = "Kafi";
local PetBattlePlanner_OpponentPetIndex = 1;
local PetBattlePlanner_local_db;


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
   

local ATTACK_WEAK    = 1;
local ATTACK_NEUTRAL = 2;
local ATTACK_STRONG  = 3;

local ATTACK_RESULT_TEXT = {
   "Weak",     
   "Neutral",
   "Strong"
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
   
   PetBattlePlanner_SetUpGuiFields()
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
      print(yellow.." cal - "..white.."Fetches the most recently opened Calendar Event.");
      print(yellow.." atlog - "..white.."Manually record log of online player zones.");
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
         
         PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName] = {};
         PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"] = {};
         
         
         local petIndex;
         for petIndex=1, numPets do
            local petName, speciesName = C_PetBattles.GetName(PET_OWNER_OPPONENT, petIndex);
            local petType = C_PetBattles.GetPetType(PET_OWNER_OPPONENT, petIndex)
--            local rarity = C_PetBattles.GetBreedQuality(PET_OWNER_OPPONENT, petIndex);
--            print("pet["..petIndex.."] = "..petName.."   species = "..speciesName.."  rarity="..rarity);
            
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex] = {};
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["Name"] = petName;
            PetBattlePlanner_db["Opponents"][PetBattlePlanner_lastTargetName]["Team"][petIndex]["PetType"] = petType;
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
   end
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
         
      PetBattlePlanner_TabPage1_OpponentPetNameFrame:SetText(white..PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName].Team[PetBattlePlanner_OpponentPetIndex].Name);
   else
      PetBattlePlanner_TabPage1_OpponentPetNameFrame:SetText("unknown");      
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
 




-- local yellow = "|c00FFFF25";
-- local white  = "|c00FFFFff";
-- local red    = "|c00FF0000";
-- local green  = "|c0000ff00";
-- local blue   = "|c000000ff";



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
--               print("clicked");
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


-- xxxx

end









