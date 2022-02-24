-- Constants
local OTOMO_SPY_UNIT_MANAGER_TYPE = "snow.data.OtomoSpyUnitManager"

-- Memo
local otomo_spy_unit_manager_type_def = sdk.find_type_definition(OTOMO_SPY_UNIT_MANAGER_TYPE)
local get_is_operating_method = otomo_spy_unit_manager_type_def:get_method("get_IsOperating")
local get_now_step_count_method = otomo_spy_unit_manager_type_def:get_method("get_NowStepCount")
local step_count_in_route_field = otomo_spy_unit_manager_type_def:get_field("StepCountInRoute")

-- Module
local meowcenaries = {}

function meowcenaries.get_status()
  local otomo_spy_unit_manager = sdk.get_managed_singleton(OTOMO_SPY_UNIT_MANAGER_TYPE)

  if not otomo_spy_unit_manager then
    return false, 0, 0
  end

  return get_is_operating_method:call(otomo_spy_unit_manager), get_now_step_count_method:call(otomo_spy_unit_manager), step_count_in_route_field:get_data(otomo_spy_unit_manager)
end

return meowcenaries