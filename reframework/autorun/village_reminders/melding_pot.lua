-- Constants
local ALCHEMY_FACILITY_TYPE = "snow.data.AlchemyFacility"
local ALCHEMY_FUNCTION_TYPE = "snow.data.AlchemyFunction"
local EQUIPMENT_INVENTORY_DATA_TYPE = "snow.data.EquipmentInventoryData"
local FACILITY_DATA_MANAGER_TYPE = "snow.data.FacilityDataManager"
local RESERVE_INFO_TYPE = "snow.data.alchemy.ReserveInfo"

-- Memo
local alchemy_facility_type_def = sdk.find_type_definition(ALCHEMY_FACILITY_TYPE)
local get_function_method = alchemy_facility_type_def:get_method("get_Function")

local alchemy_function_type_def = sdk.find_type_definition(ALCHEMY_FUNCTION_TYPE)
local get_inventory_list_method = alchemy_function_type_def:get_method("get_InventoryList")
local get_max_reserve_num_method = alchemy_function_type_def:get_method("get_MaxReserveNum")
local get_remaining_slot_num = alchemy_function_type_def:get_method("getRemainingSlotNum")
local get_reserved_info_list = alchemy_function_type_def:get_method("getReservedInfoList")

local equipment_inventory_data_type_def = sdk.find_type_definition(EQUIPMENT_INVENTORY_DATA_TYPE)
local is_empty_method = equipment_inventory_data_type_def:get_method("isEmpty")

local facility_data_manager_type_def = sdk.find_type_definition(FACILITY_DATA_MANAGER_TYPE)
local get_alchemy_method = facility_data_manager_type_def:get_method("getAlchemy")

local reserve_info_type_def = sdk.find_type_definition(RESERVE_INFO_TYPE)
local get_reserve_status_method = reserve_info_type_def:get_method("getReserveStatus")

-- Module
local melding_pot = {
  status = {
    active = false,
    max_orders = 10,
    max_uncollected = 70,
    orders = 0,
    uncollected = 0
  }
}

local function count_non_empty_inventory(inventory_list, inventory_list_count)
  local non_empty = 0

  for i = 0, inventory_list_count - 1 do
    local inventory = inventory_list:call("get_Item", i)

    if is_empty_method:call(inventory) then
      break
    else
      non_empty = non_empty + 1
    end
  end

  return non_empty
end

local function is_melding_active(reserve_info_list, max_reserve_num)
  for i = 0, max_reserve_num - 1 do
    local reserve_info = reserve_info_list:call("get_Item", i)

    if get_reserve_status_method:call(reserve_info) == 1 then
      return true
    end
  end

  return false
end

local function update()
  local facility_data_manager = sdk.get_managed_singleton(FACILITY_DATA_MANAGER_TYPE)

  if not facility_data_manager then
    return
  end

  local alchemy = get_alchemy_method:call(facility_data_manager)
  local alchemy_function = get_function_method:call(alchemy)
  local remaining_slot_num = get_remaining_slot_num:call(alchemy_function)
  local max_reserve_num = get_max_reserve_num_method:call(alchemy_function)
  local inventory_list = get_inventory_list_method:call(alchemy_function)
  local inventory_list_count = inventory_list:call("get_Count")
  melding_pot.status.active = is_melding_active(get_reserved_info_list:call(alchemy_function), max_reserve_num)
  melding_pot.status.max_orders = max_reserve_num
  melding_pot.status.max_uncollected = inventory_list_count
  melding_pot.status.orders = max_reserve_num - remaining_slot_num
  melding_pot.status.uncollected = count_non_empty_inventory(inventory_list, inventory_list_count)
end

function melding_pot.init()
  update()
end

-- TODO Hook on Melding Pot GUI close instead
function melding_pot.on_reset_speech()
  update()
end

return melding_pot