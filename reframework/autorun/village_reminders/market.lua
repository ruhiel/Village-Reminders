-- Constants
local FACILITY_DATA_MANAGER_TYPE = "snow.data.FacilityDataManager"
local ITEM_LOT_FUNC_TYPE = "snow.facility.itemShop.ItemLotFunc"
local ITEM_SHOP_FACILITY_TYPE = "snow.data.ItemShopFacility"

-- Memo
local facility_data_manager_type_def = sdk.find_type_definition(FACILITY_DATA_MANAGER_TYPE)
local get_item_shop_method = facility_data_manager_type_def:get_method("getItemShop")
local is_sale_method = facility_data_manager_type_def:get_method("isSale")

local item_lot_func_type_def = sdk.find_type_definition(ITEM_LOT_FUNC_TYPE)
local get_lot_event_done_flag_method = item_lot_func_type_def:get_method("getLotEventDoneFlag")

local item_shop_facility_type_def = sdk.find_type_definition(ITEM_SHOP_FACILITY_TYPE)
local get_item_lot_func_method = item_shop_facility_type_def:get_method("get_ItemLotFunc")

-- Module
local market = {
  status = {
    lottery = false,
    sale = false
  }
}

local function update_lottery(facility_data_manager)
  local item_shop = get_item_shop_method:call(facility_data_manager)
  local item_lot_func = get_item_lot_func_method:call(item_shop)
  market.status.lottery = market.status.sale and not get_lot_event_done_flag_method:call(item_lot_func)
end

local function update_sale(facility_data_manager)
  market.status.sale = is_sale_method:call(facility_data_manager)
end

function market.init()
  local facility_data_manager = sdk.get_managed_singleton(FACILITY_DATA_MANAGER_TYPE)

  if not facility_data_manager then
    return
  end

  update_sale(facility_data_manager)
  update_lottery(facility_data_manager)
end

function market.on_reset_speech()
  local facility_data_manager = sdk.get_managed_singleton(FACILITY_DATA_MANAGER_TYPE)

  if not facility_data_manager then
    return
  end

  update_lottery(facility_data_manager)
end

return market