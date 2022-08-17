-- Constants
local OTOMO_SPY_UNIT_MANAGER_TYPE = "snow.data.OtomoSpyUnitManager"

-- Memo
local otomo_spy_unit_manager_type_def = sdk.find_type_definition(OTOMO_SPY_UNIT_MANAGER_TYPE)
local get_is_operating_method = otomo_spy_unit_manager_type_def:get_method("get_IsOperating")
local get_now_step_count_method = otomo_spy_unit_manager_type_def:get_method("get_NowStepCount")
local step_count_in_route_field = otomo_spy_unit_manager_type_def:get_field("StepCountInRoute")

-- Module
local meowcenaries = {
  status = {
    operating = false,
    step = 0,
    steps = 5
  }
}

local function update()
  local otomo_spy_unit_manager = sdk.get_managed_singleton(OTOMO_SPY_UNIT_MANAGER_TYPE)

  if not otomo_spy_unit_manager then
    return
  end

  meowcenaries.status.operating = get_is_operating_method:call(otomo_spy_unit_manager)
  meowcenaries.status.step = get_now_step_count_method:call(otomo_spy_unit_manager)
  meowcenaries.status.steps = step_count_in_route_field:get_data(otomo_spy_unit_manager)
end

function meowcenaries.init()
  update()
end

-- TODO Hook Meowcenaries GUI close instead
function meowcenaries.on_reset_speech()
  update()
end

return meowcenaries