-- Constants
local PROGRESS_OWL_NEST_MANAGER_TYPE = "snow.progress.ProgressOwlNestManager"
local PROGRESS_OWL_NEST_SAVE_DATA_TYPE = "snow.progress.ProgressOwlNestSaveData"

-- Memo
local progress_owl_nest_manager_type_def = sdk.find_type_definition(PROGRESS_OWL_NEST_MANAGER_TYPE)
local get_save_data_method = progress_owl_nest_manager_type_def:get_method("get_SaveData")
local stack_item_count_field = progress_owl_nest_manager_type_def:get_field("StackItemCount")

local progress_owl_nest_save_data_type_def = sdk.find_type_definition(PROGRESS_OWL_NEST_SAVE_DATA_TYPE)
local stack_count_field = progress_owl_nest_save_data_type_def:get_field("_StackCount")

-- Module
local cohoot_nest = {}

function cohoot_nest.get_status()
  local progress_owl_nest_manager = sdk.get_managed_singleton(PROGRESS_OWL_NEST_MANAGER_TYPE)

  if not progress_owl_nest_manager then
    return 0, 0
  end

  local save_data = get_save_data_method:call(progress_owl_nest_manager)
  return stack_count_field:get_data(save_data), stack_item_count_field:get_data(progress_owl_nest_manager)
end

return cohoot_nest