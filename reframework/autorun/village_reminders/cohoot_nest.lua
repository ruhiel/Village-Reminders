-- Constants
local PROGRESS_OWL_NEST_MANAGER_TYPE = "snow.progress.ProgressOwlNestManager"
local PROGRESS_OWL_NEST_SAVE_DATA_TYPE = "snow.progress.ProgressOwlNestSaveData"

-- Memo
local progress_owl_nest_manager_type_def = sdk.find_type_definition(PROGRESS_OWL_NEST_MANAGER_TYPE)
local get_save_data_method = progress_owl_nest_manager_type_def:get_method("get_SaveData")
local stack_item_count_field = progress_owl_nest_manager_type_def:get_field("StackItemCount")
local supply_method = progress_owl_nest_manager_type_def:get_method("supply")

local progress_owl_nest_save_data_type_def = sdk.find_type_definition(PROGRESS_OWL_NEST_SAVE_DATA_TYPE)
local stack_count_field = progress_owl_nest_save_data_type_def:get_field("_StackCount")
local stack_count_2_field = progress_owl_nest_save_data_type_def:get_field("_StackCount2")

-- Module
local cohoot_nest = {
  status = {
    max_uncollected = 5,
    uncollected_elgado = 0,
    uncollected_kamura = 0
  }
}

local function update()
  local progress_owl_nest_manager = sdk.get_managed_singleton(PROGRESS_OWL_NEST_MANAGER_TYPE)

  if not progress_owl_nest_manager then
    return
  end

  local save_data = get_save_data_method:call(progress_owl_nest_manager)
  cohoot_nest.status.max_uncollected = stack_item_count_field:get_data(progress_owl_nest_manager)
  cohoot_nest.status.uncollected_kamura = stack_count_field:get_data(save_data)
  cohoot_nest.status.uncollected_elgado = stack_count_2_field:get_data(save_data)
end

function cohoot_nest.hook()
  sdk.hook(supply_method, nil, update)
end

function cohoot_nest.init()
  update()
end

return cohoot_nest