-- Constants
local OTOMO_DATA_MANAGER_TYPE = "snow.data.OtomoDataManager"
local OTOMO_DATA_TYPE = "snow.data.OtomoData"
local OTOMO_DOJO_FACILITY_TYPE = "snow.facility.OtomoDojoFacility"
local TRAINING_REPORT_TYPE = "snow.facility.otomoDojo.TrainingReport"

-- Memo
local otomo_data_manager_type_def = sdk.find_type_definition(OTOMO_DATA_MANAGER_TYPE)
local get_ot_lv_cap_method = otomo_data_manager_type_def:get_method("get_OtLvCap")

local otomo_data_type_def = sdk.find_type_definition(OTOMO_DATA_TYPE)
local get_lv_method = otomo_data_type_def:get_method("getLv")

local otomo_dojo_facility_type_def = sdk.find_type_definition(OTOMO_DOJO_FACILITY_TYPE)
local get_boost_num_method = otomo_dojo_facility_type_def:get_method("get_BoostNum")
local get_max_boost_num_method = otomo_dojo_facility_type_def:get_method("get_MaxBoostNum")
local get_charge_num_method = otomo_dojo_facility_type_def:get_method("get_ChargeNum")
local get_max_charge_num_method = otomo_dojo_facility_type_def:get_method("get_MaxChargeNum")
local get_training_otomo_data_list_method = otomo_dojo_facility_type_def:get_method("get_TrainingOtomoDataList")
local get_training_report_list_method = otomo_dojo_facility_type_def:get_method("get_TrainingReportList")
local max_training_otomo_num_field = otomo_dojo_facility_type_def:get_field("MaxTrainingOtomoNum")

local training_report_type_def = sdk.find_type_definition(TRAINING_REPORT_TYPE)
local get_after_lv_method = training_report_type_def:get_method("get_AfterLv")

-- Module
local buddy_dojo = {
  status = {
    boosts = 0,
    buddies = 0,
    max_boosts = 10,
    max_buddies = 6,
    maxed_buddies = 0,
    max_level = 50,
    max_rounds = 10,
    rounds = 0
  }
}

local function count_maxed_buddies(training_otomo_data_list, training_otomo_data_list_size, training_report_list, otomo_max_level)
  local buddies = 0

  for i = 0, training_otomo_data_list_size - 1 do
    local otomo_data = training_otomo_data_list:call("get_Item", i)
    local training_report = training_report_list:get_element(i)

    if get_lv_method:call(otomo_data) >= otomo_max_level or get_after_lv_method:call(training_report) >= otomo_max_level then
      buddies = buddies + 1
    end
  end

  return buddies
end

local function update()
  local otomo_data_manager = sdk.get_managed_singleton(OTOMO_DATA_MANAGER_TYPE)
  local otomo_dojo_facility = sdk.get_managed_singleton(OTOMO_DOJO_FACILITY_TYPE)

  if otomo_data_manager then
    buddy_dojo.status.max_level = get_ot_lv_cap_method:call(otomo_data_manager)
  end

  if otomo_dojo_facility then
    local training_otomo_data_list = get_training_otomo_data_list_method:call(otomo_dojo_facility)
    local training_otomo_data_list_size = training_otomo_data_list:call("get_Count")
    local training_report_list = get_training_report_list_method:call(otomo_dojo_facility)
    buddy_dojo.status.boosts = get_boost_num_method:call(otomo_dojo_facility)
    buddy_dojo.status.buddies = training_otomo_data_list_size
    buddy_dojo.status.max_boosts = get_max_boost_num_method:call(otomo_dojo_facility)
    buddy_dojo.status.max_buddies = max_training_otomo_num_field:get_data(otomo_dojo_facility)
    buddy_dojo.status.maxed_buddies = count_maxed_buddies(training_otomo_data_list, training_otomo_data_list_size, training_report_list, buddy_dojo.status.max_level)
    buddy_dojo.status.max_rounds = get_max_charge_num_method:call(otomo_dojo_facility)
    buddy_dojo.status.rounds = get_charge_num_method:call(otomo_dojo_facility)
  end
end

function buddy_dojo.init()
  update()
end

-- TODO Hook on Dojo GUI close instead
function buddy_dojo.on_reset_speech()
  update()
end

return buddy_dojo