-- Imports
local game = require("village_reminders.game")

-- Constants
local BOOLEAN_TYPE = "System.Boolean"
local CACHE_FILE = "village_reminders/cache/npcs.json"
local COMMERCIAL_STUFF_FACILITY_TYPE = "snow.data.CommercialStuffFacility"
local FACILITY_DATA_MANAGER_TYPE = "snow.data.FacilityDataManager"
local GUI_LOBBY_HUD_MAP_WINDOW_TYPE = "snow.gui.GuiLobbyHudMapWindow"
local GUI_MANAGER_TYPE = "snow.gui.GuiManager"

-- Memo
local boolean_type_def = sdk.find_type_definition(BOOLEAN_TYPE)
local m_value_field = boolean_type_def:get_field("mValue")

local commercial_stuff_facility_type_def = sdk.find_type_definition(COMMERCIAL_STUFF_FACILITY_TYPE)
local get_can_obtain_item_method = commercial_stuff_facility_type_def:get_method("get_CanObtainlItem")
local get_commercial_stuff_id_method = commercial_stuff_facility_type_def:get_method("get_CommercialStuffID")

local facility_data_manager_type_def = sdk.find_type_definition(FACILITY_DATA_MANAGER_TYPE)
local get_commercial_stuff_facility_method = facility_data_manager_type_def:get_method("getCommercialStuffFacility")

local gui_lobby_hud_map_window_type_def = sdk.find_type_definition(GUI_LOBBY_HUD_MAP_WINDOW_TYPE)
local npc_balloon_visible_field = gui_lobby_hud_map_window_type_def:get_field("npcBalloonVisible")
local setup_talk_balloon_method = gui_lobby_hud_map_window_type_def:get_method("setupTalkBalloon")

local gui_manager_type_def = sdk.find_type_definition(GUI_MANAGER_TYPE)
local get_ref_gui_lobby_hud_map_window_method = gui_manager_type_def:get_method("get_refguiLobbyHudMapWindow")

-- Module
local npcs = {
  status = {
    commercial_stuff = false,
    speech_bubble_areas = {}
  }
}

local function update()
  local facility_data_manager = sdk.get_managed_singleton(FACILITY_DATA_MANAGER_TYPE)
  local gui_manager = sdk.get_managed_singleton(GUI_MANAGER_TYPE)

  if facility_data_manager then
    local commercial_stuff_facility = get_commercial_stuff_facility_method:call(facility_data_manager)
    npcs.status.commercial_stuff = get_can_obtain_item_method:call(commercial_stuff_facility) and get_commercial_stuff_id_method:call(commercial_stuff_facility) > 0
  end

  if gui_manager then
    local gui_lobby_hud_map_window = get_ref_gui_lobby_hud_map_window_method:call(gui_manager)
    setup_talk_balloon_method:call(gui_lobby_hud_map_window, false)
    local npc_balloon_visible = npc_balloon_visible_field:get_data(gui_lobby_hud_map_window):get_elements()

    for i, visible in ipairs(npc_balloon_visible) do
      npcs.status.speech_bubble_areas[i] = m_value_field:get_data(visible)
    end
  end
end

function npcs.init()
  re.on_script_reset(function()
    if game.get_status() == 1 --[[Base]] then
      json.dump_file(CACHE_FILE, npcs.status)
    end
  end)

  local cache = json.load_file(CACHE_FILE)

  if cache == nil then
    update()
  else
    npcs.status = cache
    json.dump_file(CACHE_FILE, nil)
  end
end

function npcs.on_reset_speech()
  update()
end

return npcs