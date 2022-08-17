-- Imports
local lookup = require("village_reminders.lookup")

-- Constants
local CHAT_MANAGER_TYPE = "snow.gui.ChatManager"
local FREE_MISSION_WORK_TYPE = "snow.quest.FreeMissionWork"
local MISSION_DEF_TYPE = "snow.quest.MissionDef"
local MISSION_MANAGER_TYPE = "snow.quest.MissionManager"
local MISSION_SAVE_DATA_TYPE = "snow.quest.MissionManager.MissionSaveData"

-- Memo
local chat_manager_type_def = sdk.find_type_definition(CHAT_MANAGER_TYPE)
local request_add_chat_quest_info_method = chat_manager_type_def:get_method("reqAddChatQuestInfo(snow.quest.FreeMissionData, System.Int32, System.Int32, System.Boolean)")

local free_mission_work_type_def = sdk.find_type_definition(FREE_MISSION_WORK_TYPE)
local data_idx_field = free_mission_work_type_def:get_field("_DataIdx")
local get_is_active_method = free_mission_work_type_def:get_method("get_isActive")
local get_is_clear_method = free_mission_work_type_def:get_method("get_isClear")
local progress_field = free_mission_work_type_def:get_field("_Progress")
local target_number_field = free_mission_work_type_def:get_field("_TgtNum")

local mission_def_type_def = sdk.find_type_definition(MISSION_DEF_TYPE)
local free_mission_select_max_field = mission_def_type_def:get_field("FreeMissionSelectMax")

local mission_manager_type_def = sdk.find_type_definition(MISSION_MANAGER_TYPE)
local get_save_data_method = mission_manager_type_def:get_method("get_SaveData")

local mission_save_data_type_def = sdk.find_type_definition(MISSION_SAVE_DATA_TYPE)
local free_mission_work_field = mission_save_data_type_def:get_field("_FreeMissionWork")

-- Module
local subquests = {
  base_status = {
    active = 0,
    completed = 0,
    selectable = 5
  },
  quest_status = {
    progress = {}
  }
}

local function update_base()
  local mission_manager = sdk.get_managed_singleton(MISSION_MANAGER_TYPE)

  if not mission_manager then
    return
  end

  local save_data = get_save_data_method:call(mission_manager)
  local free_mission_work = free_mission_work_field:get_data(save_data)
  local active = 0
  local completed = 0

  for i = 0, free_mission_work:get_size() - 1 do
    local work = free_mission_work:get_element(i)

    if get_is_active_method:call(work) then
      active = active + 1
    end

    if get_is_clear_method:call(work) then
      completed = completed + 1
    end
  end

  subquests.base_status.active = active
  subquests.base_status.completed = completed
  subquests.base_status.selectable = free_mission_select_max_field:get_data()
end

local function update_quest()
  local mission_manager = sdk.get_managed_singleton(MISSION_MANAGER_TYPE)

  if not mission_manager then
    return
  end

  local progress = {}
  local save_data = get_save_data_method:call(mission_manager)
  local free_mission_work = free_mission_work_field:get_data(save_data)
  local select_max = free_mission_select_max_field:get_data()

  for i = 0, free_mission_work:get_size() - 1 do
    local work = free_mission_work:get_element(i)

    if get_is_active_method:call(work) then
      local data_idx = data_idx_field:get_data(work)
      local mission = lookup.get_mission_text(mission_manager, data_idx)
      table.insert(progress, {
        completed = get_is_clear_method:call(work),
        current = progress_field:get_data(work),
        mission = mission,
        target = target_number_field:get_data(work)
      })

      if #progress >= select_max then
        break
      end
    end
  end

  subquests.quest_status.progress = progress
end

function subquests.hook()
  sdk.hook(request_add_chat_quest_info_method, nil, update_quest)
end

function subquests.init_base()
  update_base()
end

function subquests.init_quest()
  update_quest()
end

-- TODO Hook on Subquests GUI close instead
function subquests.on_reset_speech()
  update_base()
end

return subquests