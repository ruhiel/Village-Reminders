-- Constants
local DLC_MANAGER_TYPE = "snow.DlcManager"
local EVENT_MANAGER_TYPE = "snow.eventcut.EventManager"
local GUI_MANAGER = "snow.gui.GuiManager"
local NOW_LOADING_TYPE = "snow.NowLoading"
local SNOW_GAME_MANAGER_TYPE = "snow.SnowGameManager"
local VILLAGE_AREA_MANAGER_TYPE = "snow.VillageAreaManager"

-- Memo
local dlc_manager_type_def = sdk.find_type_definition(DLC_MANAGER_TYPE)
local is_mr_enabled_method = dlc_manager_type_def:get_method("isMREnabled")

local event_manager_type_def = sdk.find_type_definition(EVENT_MANAGER_TYPE)
local get_playing_method = event_manager_type_def:get_method("get_Playing")

local gui_manager_type_def = sdk.find_type_definition(GUI_MANAGER)
local is_calling_owl_method = gui_manager_type_def:get_method("isCallingOwl")
local is_invisible_all_gui_method = gui_manager_type_def:get_method("isInvisibleAllGUI")
local is_open_gui_quest_board_method = gui_manager_type_def:get_method("isOpenGuiQuestBoard")
local is_open_hud_method = gui_manager_type_def:get_method("isOpenHud")
local is_open_owl_menu_method = gui_manager_type_def:get_method("isOpenOwlMenu")
local is_sensor_access_method = gui_manager_type_def:get_method("isSensorAccess")
local is_start_menu_and_submenu_open_method = gui_manager_type_def:get_method("IsStartMenuAndSubmenuOpen")

local now_loading_type_def = sdk.find_type_definition(NOW_LOADING_TYPE)
local get_visible_method = now_loading_type_def:get_method("getVisible")

local snow_game_manager_type_def = sdk.find_type_definition(SNOW_GAME_MANAGER_TYPE)
local get_status_method = snow_game_manager_type_def:get_method("getStatus")

local village_area_manager_type_def = sdk.find_type_definition(VILLAGE_AREA_MANAGER_TYPE)
local get_current_area_no_method = village_area_manager_type_def:get_method("getCurrentAreaNo")

-- Module
local game = {}

function game.get_status()
  local snow_game_manager = sdk.get_managed_singleton(SNOW_GAME_MANAGER_TYPE)
  return snow_game_manager and get_status_method:call(snow_game_manager) or -1
end

function game.is_showing_hud()
  local gui_manager = sdk.get_managed_singleton(GUI_MANAGER)
  return gui_manager and (
    is_open_hud_method:call(gui_manager) and
    not is_start_menu_and_submenu_open_method:call(gui_manager)
  ) or false
end

function game.is_in_training()
  local village_area_manager = sdk.get_managed_singleton(VILLAGE_AREA_MANAGER_TYPE)
  return village_area_manager and get_current_area_no_method:call(village_area_manager) == 5 --[[Training]] or false
end

function game.is_loading()
  local now_loading = sdk.get_managed_singleton(NOW_LOADING_TYPE)
  return now_loading and get_visible_method:call(now_loading) or false
end

function game.is_playing_event()
  local event_manager = sdk.get_managed_singleton(EVENT_MANAGER_TYPE)
  return event_manager and get_playing_method:call(event_manager) or false
end

function game.is_reserving_gui()
  local gui_manager = sdk.get_managed_singleton(GUI_MANAGER)
  return gui_manager and (
    is_invisible_all_gui_method:call(gui_manager) or -- Not actually sure when this is active, but just in case.
    is_start_menu_and_submenu_open_method:call(gui_manager) or
    is_open_gui_quest_board_method:call(gui_manager) or
    is_sensor_access_method:call(gui_manager) or -- Talking, Sitting, Facilities
    is_calling_owl_method:call(gui_manager) or
    is_open_owl_menu_method:call(gui_manager)
  ) or false
end

function game.is_sunbreak_enabled()
  local dlc_manager = sdk.get_managed_singleton(DLC_MANAGER_TYPE)
  return dlc_manager and is_mr_enabled_method:call(dlc_manager) or false
end

return game