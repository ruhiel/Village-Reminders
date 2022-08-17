-- Constants
local CONTENTS_ID_DATA_MANAGER_TYPE = "snow.data.ContentsIdDataManager"
local ITEM_DATA_TYPE = "snow.data.ItemData"
local MISSION_DEF_TYPE = "snow.quest.MissionDef"
local MISSION_MANAGER_TYPE = "snow.quest.MissionManager"

-- Memo
local contents_id_data_manager_type_def = sdk.find_type_definition(CONTENTS_ID_DATA_MANAGER_TYPE)
local get_item_data_method = contents_id_data_manager_type_def:get_method("getItemData")

local item_data_type_def = sdk.find_type_definition(ITEM_DATA_TYPE)
local get_name_method = item_data_type_def:get_method("getName")

local mission_def_type_def = sdk.find_type_definition(MISSION_DEF_TYPE)
local get_mission_text_method = mission_def_type_def:get_method("getMissionText")

local mission_manager_type_def = sdk.find_type_definition(MISSION_MANAGER_TYPE)
local get_free_mission_data_method = mission_manager_type_def:get_method("getFreeMissionData")

-- Cache
local items = {}
local missions = {}

-- Module
local lookup = {}

function lookup.get_item_name(contents_id_data_manager, id)
  if items[id] then
    return items[id]
  else
    local item_data = get_item_data_method:call(contents_id_data_manager, id)
    items[id] = get_name_method:call(item_data)
    return items[id]
  end

end

function lookup.get_mission_text(mission_manager, index)
  if missions[index] then
    return missions[index]
  else
    local free_mission_data = get_free_mission_data_method:call(mission_manager, index)

    if free_mission_data then
      missions[index] = get_mission_text_method:call(nil, free_mission_data, 0 --[[Title]])
    else
      missions[index] = "Unknown Subquest " .. index
    end

    return missions[index]
  end
end

return lookup