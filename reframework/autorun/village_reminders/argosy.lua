-- Constants
local ITEM_INVENTORY_DATA_TYPE = "snow.data.ItemInventoryData"
local TRADE_CENTER_FACILITY_TYPE = "snow.facility.TradeCenterFacility"
local TRADE_FUNC_TYPE = "snow.facility.tradeCenter.TradeFunc"
local TRADE_ORDER_DATA_TYPE = "snow.facility.tradeCenter.TradeOrderData"

-- Memo
local item_inventory_data_type_def = sdk.find_type_definition(ITEM_INVENTORY_DATA_TYPE)
local is_empty_method = item_inventory_data_type_def:get_method("isEmpty")

local trade_center_facility_type_def = sdk.find_type_definition(TRADE_CENTER_FACILITY_TYPE)
local get_trade_func_method = trade_center_facility_type_def:get_method("get_TradeFunc")

local trade_func_type_def = sdk.find_type_definition(TRADE_FUNC_TYPE)
local get_acorn_add_count_method = trade_func_type_def:get_method("getAcornAddCount")
local get_unlocked_trading_ship_num_method = trade_func_type_def:get_method("get_UnlockedTradingShipNum")
local get_trade_order_list_method = trade_func_type_def:get_method("get_TradeOrderList")
local is_acorn_method = trade_func_type_def:get_method("isAcorn")

local trade_order_data_type_def = sdk.find_type_definition(TRADE_ORDER_DATA_TYPE)
local departure_type_field = trade_order_data_type_def:get_field("_DepartureType")
local get_inventory_list_method = trade_order_data_type_def:get_method("get_InventoryList")
local get_inventory_num_method = trade_order_data_type_def:get_method("getInventoryNum")
local get_negotiation_count_method = trade_order_data_type_def:get_method("get_NegotiationCount")
local get_negotiation_count_max_method = trade_order_data_type_def:get_method("getNecotiationCountMax")

-- Functions
local function count_non_empty_inventory(inventory_list)
  local inventory_list_size = inventory_list:get_size()
  local non_empty = 0

  for i = 0, inventory_list_size - 1 do
    local inventory = inventory_list:get_element(i)

    if is_empty_method:call(inventory) then
      break
    else
      non_empty = non_empty + 1
    end
  end

  return non_empty
end

-- Module
local argosy = {}

function argosy.get_status()
  local trade_center_facility = sdk.get_managed_singleton(TRADE_CENTER_FACILITY_TYPE)
  local status = {}

  if not trade_center_facility then
    return status
  end

  local trade_func = get_trade_func_method:call(trade_center_facility)
  local is_acorn = is_acorn_method:call(trade_func)
  local acorn_add_count = get_acorn_add_count_method:call(trade_func)
  local trade_order_list = get_trade_order_list_method:call(trade_func)
  local trade_order_list_size = trade_order_list:get_size()

  for i = 0, trade_order_list_size - 1 do
    local trade_order = trade_order_list:get_element(i)
    local inventory_list = get_inventory_list_method:call(trade_order)
    local non_empty = count_non_empty_inventory(inventory_list)
    local negotiation_count = get_negotiation_count_method:call(trade_order)
    local negotiation_count_max = get_negotiation_count_max_method:call(trade_order)

    if is_acorn then
      negotiation_count = math.min(negotiation_count + acorn_add_count, negotiation_count_max)
    end

    table.insert(status, {
      idle = departure_type_field:get_data(trade_order) <= 0,
      max_skill_duration = negotiation_count_max,
      max_uncollected = get_inventory_num_method:call(trade_order),
      skill_duration = negotiation_count,
      uncollected = non_empty
    })
  end

  return get_unlocked_trading_ship_num_method:call(trade_func), status
end

return argosy