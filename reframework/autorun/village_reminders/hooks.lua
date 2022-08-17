-- Imports
local argosy = require("village_reminders.argosy")
local buddy_dojo = require("village_reminders.buddy_dojo")
local cohoot_nest = require("village_reminders.cohoot_nest")
local game = require("village_reminders.game")
local items = require("village_reminders.items")
local market = require("village_reminders.market")
local melding_pot = require("village_reminders.melding_pot")
local meowcenaries = require("village_reminders.meowcenaries")
local npcs = require("village_reminders.npcs")
local subquests = require("village_reminders.subquests")

-- Constants
local FACILITY_DATA_MANAGER_TYPE = "snow.data.FacilityDataManager"
local NPC_TALK_MESSAGE_MANAGER_TYPE = "snow.npc.NpcTalkMessageManager"
local QUEST_MANAGER_TYPE = "snow.QuestManager"

-- Memo
local facility_data_manager_type_def = sdk.find_type_definition(FACILITY_DATA_MANAGER_TYPE)
local initialize_before_village_method = facility_data_manager_type_def:get_method("initializeBeforeVillage")

local npc_talk_message_manager_type_def = sdk.find_type_definition(NPC_TALK_MESSAGE_MANAGER_TYPE)
local reset_determine_talk_attribute_method = npc_talk_message_manager_type_def:get_method("resetDetermineTalkAttribute")

local quest_manager_type_def = sdk.find_type_definition(QUEST_MANAGER_TYPE)
local quest_start_method = quest_manager_type_def:get_method("questStart")

-- Module
local hooks = {}

local function init_base_modules()
  argosy.init()
  buddy_dojo.init()
  cohoot_nest.init()
  items.init()
  market.init()
  melding_pot.init()
  meowcenaries.init()
  npcs.init()
  subquests.init_base()
end

local function init_quest_modules()
  subquests.init_quest()
end

function hooks.init()
  sdk.hook(initialize_before_village_method, nil, init_base_modules)
  -- Should also hook on cycle?
  sdk.hook(reset_determine_talk_attribute_method, nil, function()
    if game.get_status() == 1 --[[Base]] then
      argosy.on_reset_speech()
      buddy_dojo.on_reset_speech()
      market.on_reset_speech()
      melding_pot.on_reset_speech()
      meowcenaries.on_reset_speech()
      npcs.on_reset_speech()
      subquests.on_reset_speech()
    end
  end)
  sdk.hook(quest_start_method, nil, init_quest_modules)
  argosy.hook()
  cohoot_nest.hook()
  items.hook()
  subquests.hook()
  local status = game.get_status()

  if status == 1 --[[Base]] and not game.is_in_training() then
    init_base_modules()
  elseif status == 2 --[[Quest]] then
    init_quest_modules()
  end
end

return hooks