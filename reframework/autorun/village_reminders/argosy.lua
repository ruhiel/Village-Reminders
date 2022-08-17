-- Imports
local lookup = require("village_reminders.lookup")

-- Constants
local CONTENTS_ID_DATA_MANAGER_TYPE = "snow.data.ContentsIdDataManager"
local EXCHANGE_FUNC_TYPE = "snow.facility.tradeCenter.ExchangeFunc"
local EXCHANGE_ITEM_DATA_TYPE = "snow.facility.tradeCenter.ExchangeItemData"
local GUI_TRADE_POINT_ITEM_TYPE = "snow.gui.GuiTradePointItem"
local ITEM_INVENTORY_DATA_TYPE = "snow.data.ItemInventoryData"
local TRADE_CENTER_FACILITY_TYPE = "snow.facility.TradeCenterFacility"
local TRADE_FUNC_TYPE = "snow.facility.tradeCenter.TradeFunc"
local TRADE_ORDER_DATA_TYPE = "snow.facility.tradeCenter.TradeOrderData"

-- Memo
local exchange_func_type_def = sdk.find_type_definition(EXCHANGE_FUNC_TYPE)
local get_all_exchange_item_data_list_method = exchange_func_type_def:get_method("get_AllExchangeItemDataList")
local get_stock_num_method = exchange_func_type_def:get_method("getStockNum")

local exchange_item_data_type_def = sdk.find_type_definition(EXCHANGE_ITEM_DATA_TYPE)
local get_is_listable_method = exchange_item_data_type_def:get_method("get_IsListable")
local get_item_id_method = exchange_item_data_type_def:get_method("get_ItemId")
local get_item_type_method = exchange_item_data_type_def:get_method("get_ItemType")

local gui_trade_point_item_type_def = sdk.find_type_definition(GUI_TRADE_POINT_ITEM_TYPE)
local end_method = gui_trade_point_item_type_def:get_method("end")

local item_inventory_data_type_def = sdk.find_type_definition(ITEM_INVENTORY_DATA_TYPE)
local is_empty_method = item_inventory_data_type_def:get_method("isEmpty")

local trade_center_facility_type_def = sdk.find_type_definition(TRADE_CENTER_FACILITY_TYPE)
local get_exchange_func_method = trade_center_facility_type_def:get_method("get_ExchangeFunc")
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

-- Module
local argosy = {
  status = {
    exchange = {
      rare_finds = {}
    },
    trade = {
      requests = {}
    }
  }
}

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

local function update_exchange(trade_center_facility)
  if not trade_center_facility then
    return
  end

  local exchange_func = get_exchange_func_method:call(trade_center_facility)
  local exchange_item_data_list = get_all_exchange_item_data_list_method:call(exchange_func)
  local exchange_item_data_list_size = exchange_item_data_list:get_size()
  local contents_id_data_manager = sdk.get_managed_singleton(CONTENTS_ID_DATA_MANAGER_TYPE)
  local rare_finds = {}

  for i = 0, exchange_item_data_list_size - 1 do
    local exchange_item_data = exchange_item_data_list:get_element(i)

    if get_is_listable_method:call(exchange_item_data) and get_item_type_method:call(exchange_item_data) == 2 --[[Rare]] and get_stock_num_method:call(exchange_func, exchange_item_data) > 0 then
      table.insert(rare_finds, lookup.get_item_name(contents_id_data_manager, get_item_id_method:call(exchange_item_data)))
    end
  end

  argosy.status.exchange.rare_finds = rare_finds
end

local function update_trade(trade_center_facility)
  if not trade_center_facility then
    return
  end

  local requests = {}
  local trade_func = get_trade_func_method:call(trade_center_facility)
  local is_acorn = is_acorn_method:call(trade_func)
  local acorn_add_count = get_acorn_add_count_method:call(trade_func)
  local trade_order_list = get_trade_order_list_method:call(trade_func)
  local trade_order_list_size = trade_order_list:get_size()
  local unlocked_trading_ship_num = get_unlocked_trading_ship_num_method:call(trade_func)

  for i = 0, math.min(unlocked_trading_ship_num, trade_order_list_size) - 1 do
    local trade_order = trade_order_list:get_element(i)
    local inventory_list = get_inventory_list_method:call(trade_order)
    local non_empty = count_non_empty_inventory(inventory_list)
    local negotiation_count = get_negotiation_count_method:call(trade_order)
    local negotiation_count_max = get_negotiation_count_max_method:call(trade_order)

    if is_acorn then
      negotiation_count = math.min(negotiation_count + acorn_add_count, negotiation_count_max)
    end

    table.insert(requests, {
      idle = departure_type_field:get_data(trade_order) <= 0,
      max_skill_duration = negotiation_count_max,
      max_uncollected = get_inventory_num_method:call(trade_order),
      skill_duration = negotiation_count,
      uncollected = non_empty
    })
  end

  argosy.status.trade.requests = requests
end

function argosy.hook()
  sdk.hook(end_method, nil, function()
    local trade_center_facility = sdk.get_managed_singleton(TRADE_CENTER_FACILITY_TYPE)

    if not trade_center_facility then
      return
    end

    update_exchange(trade_center_facility)
  end)
end

function argosy.init()
  local trade_center_facility = sdk.get_managed_singleton(TRADE_CENTER_FACILITY_TYPE)

  if not trade_center_facility then
    return
  end

  update_exchange(trade_center_facility)
  update_trade(trade_center_facility)
end

function argosy.on_reset_speech()
  local trade_center_facility = sdk.get_managed_singleton(TRADE_CENTER_FACILITY_TYPE)

  if not trade_center_facility then
    return
  end

  update_trade(trade_center_facility)
end

return argosy