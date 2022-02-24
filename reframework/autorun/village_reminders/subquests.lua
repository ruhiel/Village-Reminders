-- Constants
local FREE_MISSION_WORK_TYPE = "snow.quest.FreeMissionWork"
local MISSION_DEF_TYPE = "snow.quest.MissionDef"
local MISSION_MANAGER_TYPE = "snow.quest.MissionManager"
local MISSION_SAVE_DATA_TYPE = "snow.quest.MissionManager.MissionSaveData"

-- Memo
local free_mission_work_type_def = sdk.find_type_definition(FREE_MISSION_WORK_TYPE)
local get_is_active_method = free_mission_work_type_def:get_method("get_isActive")
local get_is_clear_method = free_mission_work_type_def:get_method("get_isClear")

local mission_def_type_def = sdk.find_type_definition(MISSION_DEF_TYPE)
local free_mission_select_max_field = mission_def_type_def:get_field("FreeMissionSelectMax")

local mission_manager_type_def = sdk.find_type_definition(MISSION_MANAGER_TYPE)
local get_save_data_method = mission_manager_type_def:get_method("get_SaveData")

local mission_save_data_type_def = sdk.find_type_definition(MISSION_SAVE_DATA_TYPE)
local free_mission_work_field = mission_save_data_type_def:get_field("_FreeMissionWork")

-- Module
local subquests = {}

function subquests.get_status()
  local mission_manager = sdk.get_managed_singleton(MISSION_MANAGER_TYPE)

  if not mission_manager then
    return 0, 0, 0
  end

  local save_data = get_save_data_method:call(mission_manager)
  local free_mission_work = free_mission_work_field:get_data(save_data)
  local active = 0
  local completed = 0

  for i = 0, free_mission_work:get_size() - 1 do
    work = free_mission_work:get_element(i)

    if get_is_active_method:call(work) then
      active = active + 1
    end

    if get_is_clear_method:call(work) then
      completed = completed + 1
    end
  end

  return active, free_mission_select_max_field:get_data(), completed
end

return subquests