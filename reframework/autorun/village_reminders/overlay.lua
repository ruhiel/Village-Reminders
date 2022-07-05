-- Imports
local argosy = require("village_reminders.argosy")
local buddy_dojo = require("village_reminders.buddy_dojo")
local cohoot_nest = require("village_reminders.cohoot_nest")
local config = require("village_reminders.config")
local constants = require("village_reminders.constants")
local market = require("village_reminders.market")
local melding_pot = require("village_reminders.melding_pot")
local meowcenaries = require("village_reminders.meowcenaries")
local npcs = require("village_reminders.npcs")
local subquests = require("village_reminders.subquests")

-- Constants
local DEBUG = false
local DEBUG_LABEL = "Debug"
local EVENT_MANAGER_TYPE = "snow.eventcut.EventManager"
local GUI_MANAGER = "snow.gui.GuiManager"
local NOW_LOADING_TYPE = "snow.NowLoading"
local SNOW_GAME_MANAGER_TYPE = "snow.SnowGameManager"
local VILLAGE_AREA_MANAGER_TYPE = "snow.VillageAreaManager"

-- Memo
local event_manager_type_def = sdk.find_type_definition(EVENT_MANAGER_TYPE)
local get_playing_method = event_manager_type_def:get_method("get_Playing")

local gui_manager_type_def = sdk.find_type_definition(GUI_MANAGER)
local is_calling_owl_method = gui_manager_type_def:get_method("isCallingOwl")
local is_invisible_all_gui_method = gui_manager_type_def:get_method("isInvisibleAllGUI")
local is_open_gui_quest_board_method = gui_manager_type_def:get_method("isOpenGuiQuestBoard")
local is_open_owl_menu_method = gui_manager_type_def:get_method("isOpenOwlMenu")
local is_sensor_access_method = gui_manager_type_def:get_method("isSensorAccess")
local is_start_menu_and_submenu_open_method = gui_manager_type_def:get_method("IsStartMenuAndSubmenuOpen")

local now_loading_type_def = sdk.find_type_definition(NOW_LOADING_TYPE)
local get_visible_method = now_loading_type_def:get_method("getVisible")

local snow_game_manager_type_def = sdk.find_type_definition(SNOW_GAME_MANAGER_TYPE)
local get_status_method = snow_game_manager_type_def:get_method("getStatus")

local village_area_manager_type_def = sdk.find_type_definition(VILLAGE_AREA_MANAGER_TYPE)
local get_current_area_no_method = village_area_manager_type_def:get_method("getCurrentAreaNo")

-- Variables
local bold_font = nil
local font = nil
local font_offset_y = 0
local font_size = config.get_overlay_font_size()

-- Functions
local function insert_reminder(reminders, _module, module_reminders, max_width)
  reminders[_module] = module_reminders
  local header_width, header_height = bold_font:measure(_module)
  max_width = math.max(header_width, max_width)

  for _, reminder in ipairs(module_reminders) do
    local width, height = font:measure(reminder)
    max_width = math.max(width + config.get_overlay_indent(), max_width)
  end

  return max_width
end

local function is_event_playing()
  if DEBUG then
    return false
  end

  local event_manager = sdk.get_managed_singleton(EVENT_MANAGER_TYPE)
  return event_manager and get_playing_method:call(event_manager)
end

local function is_gui_reserved()
  if DEBUG then
    return false
  end

  local gui_manager = sdk.get_managed_singleton(GUI_MANAGER)
  return gui_manager and (
    is_invisible_all_gui_method:call(gui_manager) or -- Not actually sure when this is active, but just in case.
    is_start_menu_and_submenu_open_method:call(gui_manager) or
    is_open_gui_quest_board_method:call(gui_manager) or
    is_sensor_access_method:call(gui_manager) or -- Talking, Sitting, Facilities
    is_calling_owl_method:call(gui_manager) or
    is_open_owl_menu_method:call(gui_manager)
  )
end

local function is_in_village()
  local snow_game_manager = sdk.get_managed_singleton(SNOW_GAME_MANAGER_TYPE)

  if not snow_game_manager or get_status_method:call(snow_game_manager) ~= 1 --[[Village]] then
    return false
  end

  local village_area_manager = sdk.get_managed_singleton(VILLAGE_AREA_MANAGER_TYPE)
  return get_current_area_no_method:call(village_area_manager) ~= 5 --[[Training]]
end

local function is_loading()
  local now_loading = sdk.get_managed_singleton(NOW_LOADING_TYPE)
  return now_loading and get_visible_method:call(now_loading)
end

local function is_table_empty(table)
  return next(table) == nil
end

-- Module
local overlay = {}

function overlay.init()
  bold_font = d2d.Font.new("Tahoma", font_size, true)
  font = d2d.Font.new("Tahoma", font_size)
  -- Rendered font seems to be higher than given font size. This is a hack to offset it back towards the center.
  local _, bold_height = bold_font:measure("")
  local _, normal_height = font:measure("")
  local average_height = (bold_height + normal_height) / 2
  font_offset_y = math.max(0, average_height - font_size) / 2
end

function overlay.draw()
  if is_loading() or not is_in_village() or is_gui_reserved() or is_event_playing() then
    return
  end

  local max_width = config.get_overlay_width()
  local lines = 0
  local reminders = {}

  if DEBUG then
    local messages = {}

    local gui_manager = sdk.get_managed_singleton(GUI_MANAGER)
    local event_manager = sdk.get_managed_singleton(EVENT_MANAGER_TYPE)

    if gui_manager then
      table.insert(messages, "Invisible All GUI: " .. tostring(is_invisible_all_gui_method:call(gui_manager)))
      table.insert(messages, "Start Menu and Submenu: " .. tostring(is_start_menu_and_submenu_open_method:call(gui_manager)))
      table.insert(messages, "Sensor Access: " .. tostring(is_sensor_access_method:call(gui_manager)))
    end

    if event_manager then
      table.insert(messages, "Event Playing: " .. tostring(get_playing_method:call(event_manager)))
    end

    if #messages > 0 then
      max_width = insert_reminder(reminders, DEBUG_LABEL, messages, max_width)
      lines = lines + #messages + 1
    end
  end

  if config.get_argosy_enabled() then
    local subs, requests = argosy.get_status()

    if subs > 0 then
      local module_reminders = {}

      for i = 1, subs do
        local request = requests[i]
        local prefix = "Sub " .. i .. ": "

        if config.get_argosy_idle() and request.idle then
          table.insert(module_reminders, prefix .. "Idle")
        end

        if request.uncollected > config.get_argosy_uncollected() then
          table.insert(module_reminders, prefix .. request.uncollected .. "/" .. request.max_uncollected .. " Uncollected")
        end

        if not request.idle and request.skill_duration < config.get_argosy_skill_duration() then
          table.insert(module_reminders, prefix .. request.skill_duration .. "/" .. request.max_skill_duration .. " Skill Duration")
        end
      end

      if #module_reminders > 0 then
        max_width = insert_reminder(reminders, constants.ARGOSY_LABEL, module_reminders, max_width)
        lines = lines + #module_reminders + 1
      end
    end
  end

  if config.get_buddy_dojo_enabled() then
    local status = buddy_dojo.get_status()
    local module_reminders = {}

    if status.rounds < config.get_buddy_dojo_rounds() then
      table.insert(module_reminders, status.rounds .. "/" .. status.max_rounds .. " Rounds")
    end

    if status.rounds > 0 and status.boosts < config.get_buddy_dojo_boosts() then
      table.insert(module_reminders, status.boosts .. "/" .. status.max_boosts .. " Boosts")
    end

    if status.buddies < config.get_buddy_dojo_buddies() then
      table.insert(module_reminders, status.buddies .. "/" .. status.max_buddies .. " Buddies")
    end

    if status.maxed_buddies > config.get_buddy_dojo_maxed_buddies() then
      table.insert(module_reminders, status.maxed_buddies .. " Max Level Budd" .. (status.maxed_buddies == 1 and "y" or "ies") .. " (" .. status.max_level .. ")")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.BUDDY_DOJO_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_cohoot_nest_enabled() then
    local uncollected_kamura, uncollected_elgado, max_uncollected = cohoot_nest.get_status()
    local module_reminders = {}

    if uncollected_kamura > config.get_cohoot_nest_uncollected() then
      table.insert(module_reminders, uncollected_kamura .. "/" .. max_uncollected .. " Uncollected in Kamura")
    end

    if uncollected_elgado > config.get_cohoot_nest_uncollected() then
      table.insert(module_reminders, uncollected_elgado .. "/" .. max_uncollected .. " Uncollected in Elgado")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.COHOOT_NEST_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_market_enabled() then
    local sale, lottery_done = market.get_status()
    local module_reminders = {}

    if sale then
      if config.get_market_sale() then
        table.insert(module_reminders, "Sale")
      end

      if config.get_market_lottery() and not lottery_done then
        table.insert(module_reminders, "Lottery Available")
      end
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.MARKET_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_melding_pot_enabled() then
    local active, orders, max_orders, uncollected, max_uncollected = melding_pot.get_status()
    local module_reminders = {}

    if config.get_melding_pot_idle() and not active then
      table.insert(module_reminders, "Idle")
    end

    if orders < config.get_melding_pot_orders() then
      table.insert(module_reminders, orders .. "/" .. max_orders .. " Orders")
    end

    if uncollected > config.get_melding_pot_uncollected() then
      table.insert(module_reminders, uncollected .. "/" .. max_uncollected .. " Uncollected")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.MELDING_POT_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_meowcenaries_enabled() then
    local operating, step, steps = meowcenaries.get_status()
    local module_reminders = {}

    if config.get_meowcenaries_idle() and not operating then
      table.insert(module_reminders, "Idle")
    end

    if step > config.get_meowcenaries_step() then
      table.insert(module_reminders, "Step " .. step .. "/" .. steps)
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.MEOWCENARIES_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_npcs_enabled() then
    local status = npcs.get_status()
    local module_reminders = {}

    if config.get_npcs_speech_bubble() then
      for i, speech_bubble in ipairs(status.speech_bubble_areas) do
        if speech_bubble then
          table.insert(module_reminders, "Speech Bubble in " .. (i <= #constants.VILLAGE_AREA_LABELS and constants.VILLAGE_AREA_LABELS[i] or "Unknown Area " .. i))
        end
      end
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.NPCS_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_subquests_enabled() then
    local active, selectable, completed = subquests.get_status()
    local module_reminders = {}

    if active < config.get_subquests_active() then
      table.insert(module_reminders, active .. "/" .. selectable .. " Active")
    end

    if completed > config.get_subquests_completed() then
      table.insert(module_reminders, completed .. " Completed")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.SUBQUESTS_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if is_table_empty(reminders) then
    return
  end

  local line_spacing = config.get_overlay_line_spacing()
  local indent = config.get_overlay_indent()
  local padding = config.get_overlay_padding()
  local left_x = 0
  local top_y = 0
  local background_width = max_width + 2 * padding
  local background_height = font_size * lines + line_spacing * (lines - 1) + padding * 2
  local surface_width, surface_height = d2d.surface_size()
  local overlay_anchor = config.get_overlay_anchor()
  local foreground_color = config.get_overlay_foreground()
  local background_color = config.get_overlay_background()

  if overlay_anchor == constants.TOP_RIGHT_ANCHOR or overlay_anchor == constants.BOTTOM_RIGHT_ANCHOR then
    left_x = left_x + surface_width - background_width - config.get_overlay_x()
  else
    left_x = left_x + config.get_overlay_x()
  end

  if overlay_anchor == constants.BOTTOM_LEFT_ANCHOR or overlay_anchor == constants.BOTTOM_RIGHT_ANCHOR then
    top_y = top_y + surface_height - background_height - config.get_overlay_y()
  else
    top_y = top_y + config.get_overlay_y()
  end

  d2d.fill_rect(left_x, top_y, background_width, background_height, background_color)
  local line = 1
  local module_order = config.get_overlay_order()
  local total_modules = #module_order

  if DEBUG then
    total_modules = total_modules + 1
  end

  for i = 1, total_modules do
    local _module = DEBUG and i == 1 and DEBUG_LABEL or constants.MODULE_LABELS[module_order[i]]
    local module_reminders = reminders[_module]

    if module_reminders ~= nil then
      d2d.text(bold_font, _module, left_x + padding, top_y + (font_size + line_spacing) * (line - 1) + padding - font_offset_y, foreground_color)
      line = line + 1

      for _, reminder in ipairs(module_reminders) do
        d2d.text(font, reminder, left_x + padding + indent, top_y + (font_size + line_spacing) * (line - 1) + padding - font_offset_y, foreground_color)
        line = line + 1
      end
    end
  end
end

return overlay