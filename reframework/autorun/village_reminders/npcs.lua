-- Constants
local ENUM_TYPE = "System.Enum"
local NPC_TALK_MESSAGE_MANAGER_TYPE = "snow.npc.NpcTalkMessageManager"

-- Memo
local enum_type_def = sdk.find_type_definition(ENUM_TYPE)
local get_hash_code_method = enum_type_def:get_method("GetHashCode")

local facility_data_manager_type_def = sdk.find_type_definition(NPC_TALK_MESSAGE_MANAGER_TYPE)
local get_determine_speech_balloon_attribute_for_each_area_method = facility_data_manager_type_def:get_method("get_DetermineSpeechBalloonAttributeForEachArea")

-- Module
local npcs = {}

function npcs.get_status()
  local npc_talk_message_manager = sdk.get_managed_singleton(NPC_TALK_MESSAGE_MANAGER_TYPE)
  local status = {speech_bubble_areas = {}}

  if not npc_talk_message_manager then
    return status
  end

  local talk_attributes = get_determine_speech_balloon_attribute_for_each_area_method:call(npc_talk_message_manager):get_elements()

  for i, talk_attribute in ipairs(talk_attributes) do
    status.speech_bubble_areas[i] = get_hash_code_method:call(talk_attribute) > 0
  end

  return status
end

return npcs