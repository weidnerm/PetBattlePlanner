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

local PetBattlePlanner_lastTargetName;
local PET_OWNER_PLAYER = 1;
local PET_OWNER_OPPONENT = 2;

local PetBattlePlanner_OpponentName = "none";

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
   "Grey",       -- "Poor",       
   "White",     -- "Common",     
   "Green",   -- "Uncommon",   
   "Blue",       -- "Rare",       
   "Purple",       -- "Epic",       
   "Orange"   -- "Legendary"   
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

function PetBattlePlanner_GenerateReport()
   
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
      local enemyName = "Dos-Ryga"
      for abilityIndex = 1, 3 do
         local abilityID = PetBattlePlanner_db["Opponents"][enemyName]["Team"][1]["AbilityList"][abilityIndex];
         local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityID)
         
         outputLine = outputLine.."      "..PetBattlePlanner_db["Opponents"][enemyName]["Team"][1]["Name"]
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
      local enemyName = "Dos-Ryga"


      local idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesID);
      
      do
         local tableIndex,abilityId;
         for tableIndex, abilityId in pairs(idTable) do
             
            local abilityId, abilityName, abilityIcon, abilitymaxCooldown, abilityunparsedDescription, abilitynumTurns, abilityPetType, abilitynoStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityId)
            outputLine = outputLine.."      "..abilityName.."("..PET_TYPE_TEXT[abilityPetType]..")"
   
            local attackResult = PetBattlePlanner_GetAttackStrength(abilityPetType, PetBattlePlanner_db["Opponents"][enemyName]["Team"][1]["PetType"]);
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
      printOut[outputIndex] = "   Summary("..OFFENSE_RESULT_RATING_TEXT[bestAttackVsHim ]..","..DEFENSE_RESULT_RATING_TEXT[worstAttackVsMe]..")";   outputIndex = outputIndex+1;       outputLine = "";
      



      
   end
   
   
   print("Report generation complete");
   
   
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


function PetBattlePlanner_SetOpponentNpcName(opponentName)
   PetBattlePlanner_OpponentName = opponentName;
   
   PetBattlePlanner_UpdateGui();
end

function PetBattlePlanner_UpdateGui()
   
   if ( PetBattlePlanner_db["Opponents"][PetBattlePlanner_OpponentName] ~= nil ) then
      PetBattlePlanner_TabPage1_OpponentNPCNameFrame:SetText(PetBattlePlanner_OpponentName);
   else
      PetBattlePlanner_TabPage1_OpponentNPCNameFrame:SetText("unknown");      
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
   
      local petMenuTbl = {
         {
            text = "Pet Selection",
            isTitle = true,
            notCheckable = true,
         }
      }

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
         print("Pet clicked button");
         EasyMenu(petMenuTbl, PetBattlePlanner_TabPage1, "PetBattlePlanner_TabPage1_OpponentPetChooserButton" ,0,0, nil, 10)
          
         end)
      PetBattlePlanner_TabPage1_OpponentPetChooserButton = myButton;

   end


end








function PetBattlePlanner_SetUpGuiFields_RaidMakerExample()
   local index;

   --
   -- Set up the Main Field grid
   --

   PetBattlePlanner_TabPage1_SampleTextTab1_GroupedState_Objects = {};
   for index=1,22 do
      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_GroupedState_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(50);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1_SampleTextTab1", "TOPLEFT", 0,0);
         item:SetText("In Raid");
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_GroupedState_Objects[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_GroupedState_Objects[index] = item;
   end

   -- Set up row separators
   PetBattlePlanner_RaidBuilder_row_frame_Objects = {};
   PetBattlePlanner_RaidBuilder_row_frameTexture_Objects = {};
   for index=1,10 do
      local myFrame = CreateFrame("Frame", "PetBattlePlanner_RaidBuilder_row_frame"..index, PetBattlePlanner_TabPage1_SampleTextTab1 )
      myFrame:SetWidth(546)
      local frameLevel = myFrame:GetFrameLevel();
      myFrame:SetFrameLevel(frameLevel -1);
      myFrame:SetHeight(18)
      myFrame:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_GroupedState_Objects[2*index], "TOPLEFT", 0,0)
      local myTexture = myFrame:CreateTexture("PetBattlePlanner_RaidBuilder_row_frameTexture"..index, "BACKGROUND")
      myTexture:SetAllPoints()
      myTexture:SetTexture(0.15, 0.15, 0.15, .25);
      PetBattlePlanner_RaidBuilder_row_frame_Objects[index] = myFrame;
      PetBattlePlanner_RaidBuilder_row_frameTexture_Objects[index] = myTexture;
   end


   PetBattlePlanner_TabPage1_SampleTextTab1_OnlineState_Objects = {};
   for index=1,22 do
      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_OnlineState_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(100);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_GroupedState_Objects[1], "TOPRIGHT", 0,0);
         item:SetText("Online");
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_OnlineState_Objects[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_OnlineState_Objects[index] = item;
   end

   PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatus_Objects = {};
   for index=1,22 do
      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatus_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(75);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_OnlineState_Objects[1], "TOPRIGHT", 0,0);
         item:SetText("Response");
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatus_Objects[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatus_Objects[index] = item;
   end

   PetBattlePlanner_TabPage1_SampleTextTab1_PlayerName_Objects = {};
   for index=1,22 do
      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_PlayerName_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(100);
      item:SetHeight(18);
      item:ClearAllPoints();
      if ( index == 1 ) then
         item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatus_Objects[1], "TOPRIGHT", 0,0);
         item:SetText("Char Name");
      elseif ( index == 22 ) then
         item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_PlayerName_Objects[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_PlayerName_Objects[index] = item;
   end

   PetBattlePlanner_TabPage1_SampleTextTab1_TankFlag_ButtonObjects = {};
   for index=1,22 do
      local myButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_TankButton_"..index-1);
      local myFontString = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_TankFlag_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      myButton:SetFontString( myFontString )
      myButton:SetWidth(38);
      myButton:SetHeight(18);
      myButton:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatus_Objects[index], "TOPRIGHT", 100,0);
      if ( index == 1 ) then
         myButton:SetText("Tank");
      else
         myButton:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_TankFlag_ButtonObjects[index] = myButton;
   end

   PetBattlePlanner_TabPage1_SampleTextTab1_HealFlag_ButtonObjects = {};
   for index=1,22 do
      local myButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_HealButton_"..index-1);
      local myFontString = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_HealFlag_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      myButton:SetFontString( myFontString )
      myButton:SetWidth(38);
      myButton:SetHeight(18);
      myButton:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_TankFlag_ButtonObjects[index], "TOPRIGHT", 0,0);
      if ( index == 1 ) then
         myButton:SetText("Heal");
      else
         myButton:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_HealFlag_ButtonObjects[index] = myButton;
   end

   PetBattlePlanner_TabPage1_SampleTextTab1_mDpsFlag_ButtonObjects = {};
   for index=1,22 do
      local myButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_mDpsButton_"..index-1);
      local myFontString = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_mDpsFlag_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      myButton:SetFontString( myFontString )
      myButton:SetWidth(37);
      myButton:SetHeight(18);
      myButton:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_HealFlag_ButtonObjects[index], "TOPRIGHT", 0,0);
      if ( index == 1 ) then
         myButton:SetText("mDPS");
      else
         myButton:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_mDpsFlag_ButtonObjects[index] = myButton;
   end

   PetBattlePlanner_TabPage1_SampleTextTab1_rDpsFlag_ButtonObjects = {};
   for index=1,22 do
      local myButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_rDpsButton_"..index-1);
      local myFontString = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_rDpsFlag_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      myButton:SetFontString( myFontString )
      myButton:SetWidth(37);
      myButton:SetHeight(18);
      myButton:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_mDpsFlag_ButtonObjects[index], "TOPRIGHT", 0,0);
      if ( index == 1 ) then
         myButton:SetText("rDPS");
      else
         myButton:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_rDpsFlag_ButtonObjects[index] = myButton;
   end

   PetBattlePlanner_TabPage1_SampleTextTab1_Class_Objects = {};
   for index=1,22 do
      local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_TabPage1_SampleTextTab1_Class_"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(75);
      item:SetHeight(18);
      item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_rDpsFlag_ButtonObjects[index], "TOPRIGHT", 0,0);
      if ( index == 1 ) then
         item:SetText("Class");
      else
         item:SetText(" ");
      end
      PetBattlePlanner_TabPage1_SampleTextTab1_Class_Objects[index] = item;
   end



   --
   -- Set up player name buttons
   --


   local menuTbl = {
      {
         text = "Alantodne",
         isTitle = true,
         notCheckable = true,
      },
      {
         text = "Invite",
         notCheckable = true,
         func = function(self)
            InviteUnit(PetBattlePlanner_menu_playerName);
            end,
      },
      {
         text = "Whisper",
         notCheckable = true,
         func = function()
            print(red.."whisper "..white..PetBattlePlanner_menu_playerName..red.." not yet implemented.") end,
      },
      {
         text = "Raid History",
         notCheckable = true,
         hasArrow = true,
         menuList = {
            { text = "raid 1", },
            { text = "raid 2", },
            { text = "raid 3", },
         },
      },
   }

   --
   -- build raid history menu
   --


   local numMenuEntries, menuIndex;
   if ( PetBattlePlanner_RaidParticipantLog ~= nil ) then
      numMenuEntries = #PetBattlePlanner_RaidParticipantLog
      if ( numMenuEntries > 5 ) then
         numMenuEntries = 5; -- limit the number of histories to 10.
      end
      local raidIndexOffset = #PetBattlePlanner_RaidParticipantLog-numMenuEntries;  -- difference in index between menu and corresponding history entry


      local tempMenuList = {};
      for menuIndex=1,numMenuEntries do
         tempMenuList[menuIndex] = {};
         tempMenuList[menuIndex].hasArrow = true;
         tempMenuList[menuIndex].notCheckable = true;
         tempMenuList[menuIndex].text = PetBattlePlanner_RaidParticipantLog[menuIndex+raidIndexOffset].title
         tempMenuList[menuIndex].arg1 = menuIndex+raidIndexOffset
         tempMenuList[menuIndex].func = function(self, arg)
            PetBattlePlanner_repeatLoggedRaid(arg);
            end



         local tempPlayerList = {};
         local currentPlayerIndex = 1;
         local menuPlayerName, menuPlayerNameInfo
         for menuPlayerName, menuPlayerNameInfo in pairs(PetBattlePlanner_RaidParticipantLog[menuIndex+raidIndexOffset].playerInfo) do
            if ( menuPlayerNameInfo.tank == 1 ) or
               ( menuPlayerNameInfo.heals == 1 ) or
               ( menuPlayerNameInfo.mDps == 1 ) or
               ( menuPlayerNameInfo.rDps == 1 ) then


               tempPlayerList[currentPlayerIndex] = {};
               tempPlayerList[currentPlayerIndex].hasArrow = false;
               tempPlayerList[currentPlayerIndex].notCheckable = true;

               tempPlayerList[currentPlayerIndex].text = yellow;
               if ( menuPlayerNameInfo.tank == 1 ) then
                  tempPlayerList[currentPlayerIndex].text = tempPlayerList[currentPlayerIndex].text.." tank"
               end
               if ( menuPlayerNameInfo.heals == 1 ) then
                  tempPlayerList[currentPlayerIndex].text = tempPlayerList[currentPlayerIndex].text.." heal"
               end
               if ( menuPlayerNameInfo.mDps == 1 ) then
                  tempPlayerList[currentPlayerIndex].text = tempPlayerList[currentPlayerIndex].text.." mDps"
               end
               if ( menuPlayerNameInfo.rDps == 1 ) then
                  tempPlayerList[currentPlayerIndex].text = tempPlayerList[currentPlayerIndex].text.." rDps"
               end
               tempPlayerList[currentPlayerIndex].text = tempPlayerList[currentPlayerIndex].text.."  - "..white..menuPlayerName

               currentPlayerIndex = currentPlayerIndex + 1;
            end
         end
         tempMenuList[menuIndex].menuList = tempPlayerList;


      end
--         xxx = yellow.."\nResponded on:\n"..white..format(FULLDATE, CALENDAR_WEEKDAY_NAMES[weekday],CALENDAR_FULLDATE_MONTH_NAMES[month],day, year, month ).."\n"..GameTime_GetFormattedTime(hour, minute, true)



      menuTbl[4].menuList = tempMenuList;
   end

   --
   -- set up player name menu
   --

   PetBattlePlanner_PlayerName_Button_Objects = {};
   for index=1,20 do
      local item = CreateFrame("Button", "PetBattlePlanner_PlayerName_Button_"..index-1, PetBattlePlanner_TabPage1_SampleTextTab1 )
      item:SetFontString( PetBattlePlanner_TabPage1_SampleTextTab1_PlayerName_Objects[index+1] )
      item:SetWidth(100);
      item:SetHeight(18);
      item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatus_Objects[index+1], "TOPRIGHT", 0,0);
      item:SetText("X");
      item:SetScript("OnClick", function(self,button)
         local myText = self:GetText();
         local startIndex1,endIndex1,playerName = strfind(myText, "c%x%x%x%x%x%x%x%x(.*)");
         if ( playerName ~= nil ) then
            menuTbl[1].text = playerName;
            PetBattlePlanner_menu_playerName = playerName;
            EasyMenu(menuTbl, PetBattlePlanner_TabPage1_SampleTextTab1, "PetBattlePlanner_PlayerName_Button_"..index-1 ,0,0, nil, 10)
         end
      end)
      item:SetScript("OnEnter",
         function(self)
            local myText = self:GetText();
            local startIndex1,endIndex1,playerName = strfind(myText, "c%x%x%x%x%x%x%x%x(.*)");
            if ( playerName ~= nil ) then
               if ( raidPlayerDatabase ~= nil ) then -- only process if there is a database to parse.
                  if ( raidPlayerDatabase.playerInfo ~= nil ) then
                     if ( raidPlayerDatabase.playerInfo[playerName] ~= nil ) then
                        local currentTime = time()
                        if ( currentTime - previousGuildRosterUpdateTime > 15 ) then
                           GuildRoster(); -- trigger a GUILD_ROSTER_UPDATE event so we can get the online/offline status of players.
                        end

                        if ( raidPlayerDatabase.playerInfo[playerName].zone ~= nil ) then

                           local signupText = ""
                           GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT",0,0)
                           if ( raidPlayerDatabase.playerInfo[playerName].signupInfo ~= nil ) then

                              local weekday = raidPlayerDatabase.playerInfo[playerName].signupInfo.weekday;
                              local month   = raidPlayerDatabase.playerInfo[playerName].signupInfo.month  ;
                              local day     = raidPlayerDatabase.playerInfo[playerName].signupInfo.day    ;
                              local year    = raidPlayerDatabase.playerInfo[playerName].signupInfo.year   ;
                              local hour    = raidPlayerDatabase.playerInfo[playerName].signupInfo.hour   ;
                              local minute  = raidPlayerDatabase.playerInfo[playerName].signupInfo.minute ;

                              if ( weekday ~= nil ) and
                                 ( weekday ~= 0 ) then
                                 signupText = yellow.."\nResponded on:\n"..white..format(FULLDATE, CALENDAR_WEEKDAY_NAMES[weekday],CALENDAR_FULLDATE_MONTH_NAMES[month],day, year, month ).."\n"..GameTime_GetFormattedTime(hour, minute, true)
                              end
                           end
                           GameTooltip:SetText(white..playerName..yellow.." last seen in "..green..raidPlayerDatabase.playerInfo[playerName].zone..signupText);
                           GameTooltip:Show()
                        end
                     end
                  end
               end
            end
         end)
      item:SetScript("OnLeave", function() GameTooltip:Hide() end)



      PetBattlePlanner_PlayerName_Button_Objects[index] = item;


   end



   --
   -- Set up class totals text fields.
   --

   PetBattlePlanner_WarriorCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_WarriorCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_WarriorCount_Object:SetWidth(18);
   PetBattlePlanner_WarriorCount_Object:SetHeight(18);
   PetBattlePlanner_WarriorCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_SampleTextTab1_Class_1, "TOPRIGHT", 55,-7);
   PetBattlePlanner_WarriorCount_Object:SetText(" ");

   PetBattlePlanner_MageCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_MageCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_MageCount_Object:SetWidth(18);
   PetBattlePlanner_MageCount_Object:SetHeight(18);
   PetBattlePlanner_MageCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_WarriorCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_MageCount_Object:SetText(" ");

   PetBattlePlanner_RogueCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_RogueCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_RogueCount_Object:SetWidth(18);
   PetBattlePlanner_RogueCount_Object:SetHeight(18);
   PetBattlePlanner_RogueCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_MageCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_RogueCount_Object:SetText(" ");

   PetBattlePlanner_DruidCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_DruidCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_DruidCount_Object:SetWidth(18);
   PetBattlePlanner_DruidCount_Object:SetHeight(18);
   PetBattlePlanner_DruidCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_RogueCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_DruidCount_Object:SetText(" ");

   PetBattlePlanner_HunterCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_HunterCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_HunterCount_Object:SetWidth(18);
   PetBattlePlanner_HunterCount_Object:SetHeight(18);
   PetBattlePlanner_HunterCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_DruidCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_HunterCount_Object:SetText(" ");

   PetBattlePlanner_ShamanCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_ShamanCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_ShamanCount_Object:SetWidth(18);
   PetBattlePlanner_ShamanCount_Object:SetHeight(18);
   PetBattlePlanner_ShamanCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_HunterCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_ShamanCount_Object:SetText(" ");

   PetBattlePlanner_PriestCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_PriestCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_PriestCount_Object:SetWidth(18);
   PetBattlePlanner_PriestCount_Object:SetHeight(18);
   PetBattlePlanner_PriestCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_ShamanCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_PriestCount_Object:SetText(" ");

   PetBattlePlanner_WarlockCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_WarlockCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_WarlockCount_Object:SetWidth(18);
   PetBattlePlanner_WarlockCount_Object:SetHeight(18);
   PetBattlePlanner_WarlockCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_PriestCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_WarlockCount_Object:SetText(" ");

   PetBattlePlanner_PaladinCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_PaladinCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_PaladinCount_Object:SetWidth(18);
   PetBattlePlanner_PaladinCount_Object:SetHeight(18);
   PetBattlePlanner_PaladinCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_WarlockCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_PaladinCount_Object:SetText(" ");

   PetBattlePlanner_DeathknightCount_Object = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_DeathknightCount", "OVERLAY", "GameFontNormalSmall" )
   PetBattlePlanner_DeathknightCount_Object:SetWidth(18);
   PetBattlePlanner_DeathknightCount_Object:SetHeight(18);
   PetBattlePlanner_DeathknightCount_Object:SetPoint("TOPLEFT", PetBattlePlanner_PaladinCount_Object, "BOTTOMLEFT", 0,-18);
   PetBattlePlanner_DeathknightCount_Object:SetText(" ");

   --
   -- Set up the Class Icons.
   --

   -- take the Blizzard UI graphic with a grid of 4x4 class icons and crop out the desired class one at a time.
   -- Warrior
   CreateFrame("Frame", "PetBattlePlanner_WarriorClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_WarriorClassPicture:SetWidth(25)
   PetBattlePlanner_WarriorClassPicture:SetHeight(25)
   PetBattlePlanner_WarriorClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_WarriorCount, "TOPLEFT", 0,3)
   PetBattlePlanner_WarriorClassPicture:CreateTexture("PetBattlePlanner_WarriorClassPictureTexture")
   PetBattlePlanner_WarriorClassPictureTexture:SetAllPoints()
   PetBattlePlanner_WarriorClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_WarriorClassPictureTexture:SetTexCoord(0,0.25,0,0.25)
   -- mage
   CreateFrame("Frame", "PetBattlePlanner_MageClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_MageClassPicture:SetWidth(25)
   PetBattlePlanner_MageClassPicture:SetHeight(25)
   PetBattlePlanner_MageClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_MageCount, "TOPLEFT", 0,3)
   PetBattlePlanner_MageClassPicture:CreateTexture("PetBattlePlanner_MageClassPictureTexture")
   PetBattlePlanner_MageClassPictureTexture:SetAllPoints()
   PetBattlePlanner_MageClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_MageClassPictureTexture:SetTexCoord(.25,0.5,0,0.25)
   -- rogue
   CreateFrame("Frame", "PetBattlePlanner_RogueClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_RogueClassPicture:SetWidth(25)
   PetBattlePlanner_RogueClassPicture:SetHeight(25)
   PetBattlePlanner_RogueClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_RogueCount, "TOPLEFT", 0,3)
   PetBattlePlanner_RogueClassPicture:CreateTexture("PetBattlePlanner_RogueClassPictureTexture")
   PetBattlePlanner_RogueClassPictureTexture:SetAllPoints()
   PetBattlePlanner_RogueClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_RogueClassPictureTexture:SetTexCoord(0.5,0.75,0,0.25)
   -- druid
   CreateFrame("Frame", "PetBattlePlanner_DruidClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_DruidClassPicture:SetWidth(25)
   PetBattlePlanner_DruidClassPicture:SetHeight(25)
   PetBattlePlanner_DruidClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_DruidCount, "TOPLEFT", 0,3)
   PetBattlePlanner_DruidClassPicture:CreateTexture("PetBattlePlanner_DruidClassPictureTexture")
   PetBattlePlanner_DruidClassPictureTexture:SetAllPoints()
   PetBattlePlanner_DruidClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_DruidClassPictureTexture:SetTexCoord(0.75,1.0,0,0.25)
   -- hunter
   CreateFrame("Frame", "PetBattlePlanner_HunterClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_HunterClassPicture:SetWidth(25)
   PetBattlePlanner_HunterClassPicture:SetHeight(25)
   PetBattlePlanner_HunterClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_HunterCount, "TOPLEFT", 0,3)
   PetBattlePlanner_HunterClassPicture:CreateTexture("PetBattlePlanner_HunterClassPictureTexture")
   PetBattlePlanner_HunterClassPictureTexture:SetAllPoints()
   PetBattlePlanner_HunterClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_HunterClassPictureTexture:SetTexCoord(0,0.25,0.25,0.5)
   -- shaman
   CreateFrame("Frame", "PetBattlePlanner_ShamanClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_ShamanClassPicture:SetWidth(25)
   PetBattlePlanner_ShamanClassPicture:SetHeight(25)
   PetBattlePlanner_ShamanClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_ShamanCount, "TOPLEFT", 0,3)
   PetBattlePlanner_ShamanClassPicture:CreateTexture("PetBattlePlanner_ShamanClassPictureTexture")
   PetBattlePlanner_ShamanClassPictureTexture:SetAllPoints()
   PetBattlePlanner_ShamanClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_ShamanClassPictureTexture:SetTexCoord(.25,0.5,0.25,0.5)
   -- priest
   CreateFrame("Frame", "PetBattlePlanner_PriestClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_PriestClassPicture:SetWidth(25)
   PetBattlePlanner_PriestClassPicture:SetHeight(25)
   PetBattlePlanner_PriestClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_PriestCount, "TOPLEFT", 0,3)
   PetBattlePlanner_PriestClassPicture:CreateTexture("PetBattlePlanner_PriestClassPictureTexture")
   PetBattlePlanner_PriestClassPictureTexture:SetAllPoints()
   PetBattlePlanner_PriestClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_PriestClassPictureTexture:SetTexCoord(0.5,0.75,0.25,0.5)
   -- warlock
   CreateFrame("Frame", "PetBattlePlanner_WarlockClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_WarlockClassPicture:SetWidth(25)
   PetBattlePlanner_WarlockClassPicture:SetHeight(25)
   PetBattlePlanner_WarlockClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_WarlockCount, "TOPLEFT", 0,3)
   PetBattlePlanner_WarlockClassPicture:CreateTexture("PetBattlePlanner_WarlockClassPictureTexture")
   PetBattlePlanner_WarlockClassPictureTexture:SetAllPoints()
   PetBattlePlanner_WarlockClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_WarlockClassPictureTexture:SetTexCoord(0.75,1.0,0.25,0.5)
   --   paladin
   CreateFrame("Frame", "PetBattlePlanner_PaladinClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_PaladinClassPicture:SetWidth(25)
   PetBattlePlanner_PaladinClassPicture:SetHeight(25)
   PetBattlePlanner_PaladinClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_PaladinCount, "TOPLEFT", 0,3)
   PetBattlePlanner_PaladinClassPicture:CreateTexture("PetBattlePlanner_PaladinClassPictureTexture")
   PetBattlePlanner_PaladinClassPictureTexture:SetAllPoints()
   PetBattlePlanner_PaladinClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_PaladinClassPictureTexture:SetTexCoord(0,0.25,0.5,0.75)
   --   deathknight
   CreateFrame("Frame", "PetBattlePlanner_DeathKnightClassPicture", PetBattlePlanner_TabPage1_SampleTextTab1 )
   PetBattlePlanner_DeathKnightClassPicture:SetWidth(25)
   PetBattlePlanner_DeathKnightClassPicture:SetHeight(25)
   PetBattlePlanner_DeathKnightClassPicture:SetPoint("TOPRIGHT", PetBattlePlanner_DeathknightCount, "TOPLEFT", 0,3)
   PetBattlePlanner_DeathKnightClassPicture:CreateTexture("PetBattlePlanner_DeathKnightClassPictureTexture")
   PetBattlePlanner_DeathKnightClassPictureTexture:SetAllPoints()
   PetBattlePlanner_DeathKnightClassPictureTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   PetBattlePlanner_DeathKnightClassPictureTexture:SetTexCoord(.25,0.5,0.5,0.75)


   --
   -- Position the raid maker buttons.
   --
   local localButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_GroupedStateHeaderButton");
   localButton:SetPoint("TOPRIGHT", "PetBattlePlanner_TabPage1_SampleTextTab1_GroupedState_0", "TOPRIGHT", 0,3)

   local localButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_OnlineStateHeaderButton");
   localButton:SetPoint("TOPRIGHT", "PetBattlePlanner_TabPage1_SampleTextTab1_OnlineState_0", "TOPRIGHT", 0,3)

   local localButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatusHeaderButton");
   localButton:SetPoint("TOPRIGHT", "PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatus_0", "TOPRIGHT", 0,3)

   local localButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_PlayerNameHeaderButton");
   localButton:SetPoint("TOPRIGHT", "PetBattlePlanner_TabPage1_SampleTextTab1_PlayerName_0", "TOPRIGHT", 0,3)

   local localButton = getglobal("PetBattlePlanner_TabPage1_SampleTextTab1_ClassHeaderButton");
   localButton:SetPoint("TOPRIGHT", "PetBattlePlanner_TabPage1_SampleTextTab1_Class_0", "TOPRIGHT", 0,3)


   local localButton = getglobal("PetBattlePlanner_FetchCalendarButton");
   localButton:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1_SampleTextTab1_GroupedState_21", "BOTTOMLEFT", 0,-12)



   --
   -- Set up the tooltips for the buttons.
   --
   PetBattlePlanner_FetchCalendarButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Fetches most recently opened calander and resets role selections.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_FetchCalendarButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_SendAnnouncementButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Announces to /guild that invites will be coming soon.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_SendAnnouncementButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_SendInvitesButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sends group invites to all checked players and forms raid group.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_SendInvitesButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_SendInvDoneMsgButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sends msg to /guild indicating that all invites are sent.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_SendInvDoneMsgButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_SendRolesButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sends the list of tanks, healers, and dps to /raid.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_SendRolesButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_ButtonRefresh:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Forces refresh on player online status and last zone.  Throttled by server.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_ButtonRefresh:SetScript("OnLeave", function() GameTooltip:Hide() end)


   --
   -- Set Up tooltips for roll tab buttons
   --

   PetBattlePlanner_RollResetButton4:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Purge all roll entries that are older than 4 minutes in age.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_RollResetButton4:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_RollResetButton3:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Purge all roll entries that are older than 3 minutes in age.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_RollResetButton3:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_RollResetButton2:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Purge all roll entries that are older than 2 minutes in age.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_RollResetButton2:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_RollResetButton1:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Purge all roll entries that are older than 1 minutes in age.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_RollResetButton1:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_RollResetButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Purge all roll entries.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_RollResetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)


   --
   -- Set Up tooltips for column header buttons
   --
   PetBattlePlanner_TabPage1_SampleTextTab1_GroupedStateHeaderButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by Grouped status; Event Response status; Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_TabPage1_SampleTextTab1_GroupedStateHeaderButton:SetScript("OnLeave", function() GameTooltip:Hide() end)


   PetBattlePlanner_TabPage1_SampleTextTab1_OnlineStateHeaderButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by Online status; Event Response status; Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_TabPage1_SampleTextTab1_OnlineStateHeaderButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatusHeaderButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by Event Response status; Response Time; Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_TabPage1_SampleTextTab1_InviteStatusHeaderButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_TabPage1_SampleTextTab1_PlayerNameHeaderButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_TabPage1_SampleTextTab1_PlayerNameHeaderButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_TabPage1_SampleTextTab1_ClassHeaderButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by Class name; Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_TabPage1_SampleTextTab1_ClassHeaderButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_TabPage1_SampleTextTab1_TankButton_0:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by Tank status; Healer status; DPS status; Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_TabPage1_SampleTextTab1_TankButton_0:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_TabPage1_SampleTextTab1_HealButton_0:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by Healer status; Tank status; DPS status; Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_TabPage1_SampleTextTab1_HealButton_0:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_TabPage1_SampleTextTab1_mDpsButton_0:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by DPS status; Tank status; Healer status; Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_RollResetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

   PetBattlePlanner_TabPage1_SampleTextTab1_rDpsButton_0:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Sort by DPS status; Tank status; Healer status; Player Name.");
                  GameTooltip:Show()
               end)
   PetBattlePlanner_RollResetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)


   --
   -- Set up the RM button on the blizzard calendar event and calendar view screens.
   --

   -- create the button for the Raid Edit screen
   PetBattlePlannerLaunchCalEditButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
   PetBattlePlannerLaunchCalEditButton:SetHeight(20)

   PetBattlePlannerLaunchCalEditButton:RegisterForClicks("LeftButtonUp")
   PetBattlePlannerLaunchCalEditButton:SetScript("OnClick",
               function(self, button, down)

                  if PetBattlePlanner_MainForm:IsVisible() then
                     PetBattlePlanner_MainForm:Hide()
                  else
                     PetBattlePlanner_MainForm:Show()
                     PetBattlePlanner_HandleFetchCalButton()
                  end
               end)

   PetBattlePlannerLaunchCalEditButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("show PetBattlePlanner gui. Same as /rm toggle")
                  GameTooltip:Show()
               end)
   PetBattlePlannerLaunchCalEditButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
   PetBattlePlannerLaunchCalEditButton:SetText("RM")


   -- create the button for the Raid Viewer screen
   PetBattlePlannerLaunchCalViewButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
   PetBattlePlannerLaunchCalViewButton:SetHeight(20)

   PetBattlePlannerLaunchCalViewButton:RegisterForClicks("LeftButtonUp")
   PetBattlePlannerLaunchCalViewButton:SetScript("OnClick",
               function(self, button, down)

                  if PetBattlePlanner_MainForm:IsVisible() then
                     PetBattlePlanner_MainForm:Hide()
                  else
                     PetBattlePlanner_MainForm:Show()
                     PetBattlePlanner_HandleFetchCalButton()
                  end
               end)

   PetBattlePlannerLaunchCalViewButton:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("show PetBattlePlanner gui. Same as /rm toggle")
                  GameTooltip:Show()
               end)
   PetBattlePlannerLaunchCalViewButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
   PetBattlePlannerLaunchCalViewButton:SetText("RM")
   -- must wait for the CALENDAR_OPEN_EVENT event to complete the initialization.


   --
   -- Set up FontString fields from the Roll Log area
   --

   PetBattlePlanner_LogTab_Rolls_FieldPlayerNames = {}
   PetBattlePlanner_LogTab_Rolls_FieldRollValues = {}
   PetBattlePlanner_LogTab_Rolls_FieldRollAges = {}
   for index=1,11 do
      local item = PetBattlePlanner_GroupRollFrame:CreateFontString("PetBattlePlanner_LogTab_Rolls_FieldNamesField"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(100);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetPoint("TOPLEFT", PetBattlePlanner_GroupRollFrame, "TOPLEFT", 5,-5);
         item:SetText("Player");
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Rolls_FieldPlayerNames[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_LogTab_Rolls_FieldPlayerNames[index] = item;
   end
   for index=1,11 do
      local item = PetBattlePlanner_GroupRollFrame:CreateFontString("PetBattlePlanner_LogTab_Rolls_RollValue"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(100);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Rolls_FieldPlayerNames[1], "TOPRIGHT", 0,0);
         item:SetText("Roll Value");
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Rolls_FieldRollValues[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_LogTab_Rolls_FieldRollValues[index] = item;
   end
   for index=1,11 do
      local item = PetBattlePlanner_GroupRollFrame:CreateFontString("PetBattlePlanner_LogTab_Rolls_RollAges"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(100);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Rolls_FieldRollValues[1], "TOPRIGHT", 0,0);
         item:SetText("Roll Age");
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Rolls_FieldRollAges[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_LogTab_Rolls_FieldRollAges[index] = item;
   end

   --
   -- Set up text fields from the Loot Log area
   --
   PetBattlePlanner_LogTab_Loot_FieldNames = {}
   PetBattlePlanner_LogTab_Loot_FieldRollValues = {}
   PetBattlePlanner_LogTab_Loot_FieldRollAges = {}
   PetBattlePlanner_LogTab_Loot_FieldItemLink = {}
   PetBattlePlanner_LogTab_Loot_FieldItemLinkButton = {}
   for index=1,11 do
      local item = PetBattlePlanner_GroupRollFrame:CreateFontString("PetBattlePlanner_LogTab_Loot_FieldNamesField"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(100);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetPoint("TOPLEFT", PetBattlePlanner_GroupLootFrame, "TOPLEFT", 5,-5);
         item:SetText("Player");
         local myButton = CreateFrame("Button", "PetBattlePlanner_LogTab_Loot_PlayerNameButton", PetBattlePlanner_GroupLootFrame )
         myButton:SetFontString( item )
         myButton:SetWidth(100);
         myButton:SetHeight(18);
         myButton:SetPoint("TOPLEFT", PetBattlePlanner_GroupLootFrame, "TOPLEFT", 5,-5);
         myButton:SetScript("OnEnter",
                  function(this)
                     GameTooltip_SetDefaultAnchor(GameTooltip, this)
                     GameTooltip:SetText("Sort by player name.");
                     GameTooltip:Show()
                  end)
         myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
         myButton:SetScript("OnClick", function(self,button)
            PetBattlePlanner_LootLog_ClickHandler_PlayerName();
            end)
         PetBattlePlanner_LogTab_Loot_PlayerNameButtonObject = myButton;
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Loot_FieldNames[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_LogTab_Loot_FieldNames[index] = item;
   end




   for index=1,11 do
      local myFontString = PetBattlePlanner_GroupRollFrame:CreateFontString("PetBattlePlanner_LogTab_Loot_ItemLink"..index-1, "OVERLAY", "GameFontNormalSmall" )
      local myButton = CreateFrame("Button", "PetBattlePlanner_LogTab_Loot_ItemLinkButton_"..index-1, PetBattlePlanner_GroupRollFrame )
      myButton:SetFontString( myFontString )
      myButton:SetWidth(200);
      myButton:SetHeight(18);
      if ( index == 1 ) then
         myButton:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Loot_FieldNames[1], "TOPRIGHT", 0,0);
         myButton:SetText("Item Name");

         myButton:SetScript("OnEnter",
                  function(this)
                     GameTooltip_SetDefaultAnchor(GameTooltip, this)
                     GameTooltip:SetText("Sort by Item name.");
                     GameTooltip:Show()
                  end)
         myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
         myButton:SetScript("OnClick", function(self,button)
            PetBattlePlanner_LootLog_ClickHandler_ItemName();
            end)
      else
         myButton:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Loot_FieldItemLinkButton[index-1], "BOTTOMLEFT", 0,0);
         myButton:SetText(" ");
         myButton:SetScript("OnEnter",
                  function(this)
                     GameTooltip_SetDefaultAnchor(GameTooltip, this)
                     local myText = this:GetText();
                     local startIndex,endIndex,itemID = strfind(myText, "(%d+):")
                     if ( itemID ~= nil ) then
                        GameTooltip:SetHyperlink(myText);
                        GameTooltip:Show()
                     end
                  end)
         myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
      end

      PetBattlePlanner_LogTab_Loot_FieldItemLinkButton[index] = myButton;
      PetBattlePlanner_LogTab_Loot_FieldItemLink[index] = myFontString;
   end

   for index=1,11 do
      local item = PetBattlePlanner_GroupRollFrame:CreateFontString("PetBattlePlanner_LogTab_Loot_RollValue"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(100);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetText("Roll Value");
         local myButton = CreateFrame("Button", "PetBattlePlanner_LogTab_Loot_RollValueButton", PetBattlePlanner_GroupLootFrame )
         myButton:SetFontString( item )
         myButton:SetWidth(100);
         myButton:SetHeight(18);

         myButton:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Loot_FieldItemLinkButton[1], "TOPRIGHT", 0,0);
         myButton:SetScript("OnEnter",
                  function(this)
                     GameTooltip_SetDefaultAnchor(GameTooltip, this)
                     GameTooltip:SetText("Sort by Roll Value name.");
                     GameTooltip:Show()
                  end)
         myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
         myButton:SetScript("OnClick", function(self,button)
            PetBattlePlanner_LootLog_ClickHandler_RollValue();
            end)
         PetBattlePlanner_LogTab_Loot_RollValueButtonObject = myButton;
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Loot_FieldRollValues[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_LogTab_Loot_FieldRollValues[index] = item;
   end
   
   for index=1,11 do
      local item = PetBattlePlanner_GroupRollFrame:CreateFontString("PetBattlePlanner_LogTab_Loot_RollAges"..index-1, "OVERLAY", "GameFontNormalSmall" )
      item:SetWidth(100);
      item:SetHeight(18);
      if ( index == 1 ) then
         item:SetText("Roll Age");
         local myButton = CreateFrame("Button", "PetBattlePlanner_LogTab_Loot_RollAgeButton", PetBattlePlanner_GroupLootFrame )
         myButton:SetFontString( item )
         myButton:SetWidth(100);
         myButton:SetHeight(18);

         myButton:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Loot_FieldRollValues[1], "TOPRIGHT", 0,0);
         myButton:SetScript("OnEnter",
                  function(this)
                     GameTooltip_SetDefaultAnchor(GameTooltip, this)
                     GameTooltip:SetText("Sort by Roll Age name.");
                     GameTooltip:Show()
                  end)
         myButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
         myButton:SetScript("OnClick", function(self,button)
            PetBattlePlanner_LootLog_ClickHandler_RollAge();
            end)
         PetBattlePlanner_LogTab_Loot_RollAgeButtonObject = myButton;
      else
         item:SetPoint("TOPLEFT", PetBattlePlanner_LogTab_Loot_FieldRollAges[index-1], "BOTTOMLEFT", 0,0);
         item:SetText(" ");
      end
      PetBattlePlanner_LogTab_Loot_FieldRollAges[index] = item;
   end


   --
   -- Set up the Lootlog slider
   --
   PetBattlePlanner_LootLog_Slider:SetPoint("TOPLEFT", "PetBattlePlanner_LogTab_Loot_RollAges1", "TOPRIGHT", 0,0);
   PetBattlePlanner_LootLog_Slider:SetScript("OnValueChanged", PetBattlePlanner_DisplayLootDatabase );

   if ( #PetBattlePlanner_lootLogData <= 10 ) then
      PetBattlePlanner_LootLog_Slider:SetMinMaxValues(#PetBattlePlanner_lootLogData-9,#PetBattlePlanner_lootLogData-9);
      PetBattlePlanner_LootLog_Slider:SetValue(#PetBattlePlanner_lootLogData-9);
   else
      PetBattlePlanner_LootLog_Slider:SetMinMaxValues(1,#PetBattlePlanner_lootLogData-9);
      PetBattlePlanner_LootLog_Slider:SetValue(#PetBattlePlanner_lootLogData-9);
   end


   --
   -- Set up the Rolllog slider
   --
   PetBattlePlanner_RollLog_Slider:SetPoint("TOPLEFT", "PetBattlePlanner_LogTab_Rolls_RollAges1", "TOPRIGHT", 0,0);
   PetBattlePlanner_RollLog_Slider:SetScript("OnValueChanged", PetBattlePlanner_DisplayRollsDatabase );


   --
   -- Set up the PetBattlePlanner slider
   --
   PetBattlePlanner_VSlider:SetPoint("TOPLEFT", "PetBattlePlanner_TabPage1_SampleTextTab1_Class_1", "TOPRIGHT", 0,0);
   PetBattlePlanner_VSlider:SetScript("OnValueChanged", PetBattlePlanner_TextTableUpdate );

   --
   -- Set up the mouse wheel to scroll
   --
   PetBattlePlanner_GroupRollFrame:EnableMouseWheel(true);
   PetBattlePlanner_GroupRollFrame:SetScript("OnMouseWheel", function(self,delta) PetBattlePlanner_OnMouseWheelRollLog(self, delta) end );
   PetBattlePlanner_GroupLootFrame:EnableMouseWheel(true);
   PetBattlePlanner_GroupLootFrame:SetScript("OnMouseWheel", function(self,delta) PetBattlePlanner_OnMouseWheelLootLog(self, delta) end );
   PetBattlePlanner_TabPage1:EnableMouseWheel(true);
   PetBattlePlanner_TabPage1:SetScript("OnMouseWheel", function(self,delta) PetBattlePlanner_OnMouseWheel(self, delta) end );

   PetBattlePlanner_RollLog_Slider:SetMinMaxValues(1,1);
   PetBattlePlanner_RollLog_Slider:SetValue(1);

   --
   -- Create sync checkbox
   --
   PetBattlePlanner_sync_enabled = 0;
   local frame = CreateFrame("CheckButton", "PetBattlePlanner_Sync_Checkbutton", PetBattlePlanner_TabPage1_SampleTextTab1, "UICheckButtonTemplate")
   frame:ClearAllPoints();
   frame:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_RaidIdText, "TOPLEFT", 480,12);
   _G[frame:GetName().."Text"]:SetText("Sync")
   frame:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Clicking checkbox will request raid configuration from other raid planners\nwho have sync enabled and will auto-sync further raid configuration edits.");
                  GameTooltip:Show()
                  PetBattlePlanner_RaidPlannerListDisplayActive = 1;

                  if ( PetBattlePlanner_sync_enabled == 1 ) then
                     if ( PetBattlePlanner_RaidPlannerList ~= nil ) then
                        local charName,charFields;
                        for charName,charFields in pairs(PetBattlePlanner_RaidPlannerList) do
                           PetBattlePlanner_RaidPlannerList[charName].active = 0; -- clear out the database for a fresh ping result set
                        end
                        local selfName = GetUnitName("player",true);
                        PetBattlePlanner_updateRaidPlannerList_active(selfName)
                     end
                     PetBattlePlanner_generatePingRequest()

                     local tipText;
                     tipText = PetBattlePlanner_buildRaidPlannerTooltipText()
                     GameTooltip:SetText(tipText);

                  end
               end)
   frame:SetChecked( PetBattlePlanner_sync_enabled == 1 )
   frame:SetScript("OnLeave", function()
                                 GameTooltip:Hide()
                                 PetBattlePlanner_RaidPlannerListDisplayActive = 0;
                              end)
   frame:SetScript("OnClick", function(self,button)
      if ( self:GetChecked() ) then
         PetBattlePlanner_sync_enabled = 1
         if ( raidPlayerDatabase ~= nil ) and
            ( raidPlayerDatabase.textureIndex ~= nil ) then
            SendAddonMessage(PetBattlePlanner_appSyncPrefix, PetBattlePlanner_appInstanceId..":"..
                                                      PetBattlePlanner_syncProtocolVersion..":"..
                                                      "SyncReq:"..
                                                      raidPlayerDatabase.textureIndex, "GUILD" );
--print("sending sync request.");               
         end
      else
         PetBattlePlanner_sync_enabled = 0;
      end
   end)


   --
   -- Create Raid Group Number selection field
   --

   local menuTbl = {
      {
         text = "Group Selection",
         isTitle = true,
         notCheckable = true,
      },
      {
         text = "Group 1",
         isTitle = false,
         notCheckable = true,
         func = function(self)
            PetBattlePlanner_SetGroupNumber(1);
            end,
      },
      {
         text = "Group 2",
         isTitle = flase,
         notCheckable = true,
         func = function(self)
            PetBattlePlanner_SetGroupNumber(2);
            end,
      },
      {
         text = "Group 3",
         isTitle = false,
         notCheckable = true,
         func = function(self)
            PetBattlePlanner_SetGroupNumber(3);
            end,
      },
      {
         text = "Group 4",
         isTitle = false,
         notCheckable = true,
         func = function(self)
            PetBattlePlanner_SetGroupNumber(4);
            end,
      },
   }


   local item = PetBattlePlanner_TabPage1_SampleTextTab1:CreateFontString("PetBattlePlanner_GroupNumber_FontString", "OVERLAY", "GameFontNormalSmall" )
   item:ClearAllPoints();
   PetBattlePlanner_GroupNumber_FontStringObject = item;

   local item = CreateFrame("Button", "PetBattlePlanner_GroupNumber_Button", PetBattlePlanner_TabPage1_SampleTextTab1 )
   item:SetFontString( PetBattlePlanner_GroupNumber_FontStringObject )
   item:SetWidth(25);
   item:SetHeight(18);
   item:SetPoint("TOPLEFT", PetBattlePlanner_TabPage1_RaidIdText, "TOPLEFT", 555,5);
   item:SetText("Group "..PetBattlePlanner_currentGroupNumber);
   item:SetScript("OnClick", function(self,button)
--      print("Button pushed");
      EasyMenu(menuTbl, PetBattlePlanner_TabPage1_SampleTextTab1, "PetBattlePlanner_GroupNumber_Button" ,0,0, nil, 10)
      end)
--   item:SetScript("OnClick", function(self,button)
--      local myText = self:GetText();
--      local startIndex1,endIndex1,playerName = strfind(myText, "c%x%x%x%x%x%x%x%x(.*)");
--      if ( playerName ~= nil ) then
--         menuTbl[1].text = playerName;
--         PetBattlePlanner_menu_playerName = playerName;
--         EasyMenu(menuTbl, PetBattlePlanner_TabPage1_SampleTextTab1, "PetBattlePlanner_PlayerName_Button_"..index-1 ,0,0, nil, 10)
--      end
--   end)
   item:SetScript("OnEnter",
               function(this)
                  GameTooltip_SetDefaultAnchor(GameTooltip, this)
                  GameTooltip:SetText("Shows currently selected group.\nClick this to bring up menu to allow group selection.\nThis is used when creating multiple groups.");
                  GameTooltip:Show()
               end)
   item:SetScript("OnLeave", function() GameTooltip:Hide() end)
   PetBattlePlanner_GroupNumber_ButtonObject = item;

end


