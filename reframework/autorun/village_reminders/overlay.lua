-- Imports
local argosy = require("village_reminders.argosy")
local buddy_dojo = require("village_reminders.buddy_dojo")
local cohoot_nest = require("village_reminders.cohoot_nest")
local config = require("village_reminders.config")
local constants = require("village_reminders.constants")
local game = require("village_reminders.game")
local items = require("village_reminders.items")
local market = require("village_reminders.market")
local melding_pot = require("village_reminders.melding_pot")
local meowcenaries = require("village_reminders.meowcenaries")
local npcs = require("village_reminders.npcs")
local subquests = require("village_reminders.subquests")

-- Constants
local DEBUG = false
local DEBUG_LABEL = "Debug"

-- Variables
local bold_font = nil
local font = nil
local font_offset_y = 0
local font_size = config.get_overlay_font_size()

-- Functions
local function insert_reminder(reminders, _module, module_reminders, max_width)
  reminders[_module] = module_reminders
  local header_width, _ = bold_font:measure(_module)
  max_width = math.max(header_width, max_width)

  for _, reminder in ipairs(module_reminders) do
    local width, _ = font:measure(reminder)
    max_width = math.max(width + config.get_overlay_indent(), max_width)
  end

  return max_width
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

local function draw_overlay(max_width, lines, reminders, overlay_anchor, overlay_x, overlay_y)
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
  local foreground_color = config.get_overlay_foreground()
  local background_color = config.get_overlay_background()

  if overlay_anchor == constants.TOP_RIGHT_ANCHOR or overlay_anchor == constants.BOTTOM_RIGHT_ANCHOR then
    left_x = left_x + surface_width - background_width - overlay_x
  else
    left_x = left_x + overlay_x
  end

  if overlay_anchor == constants.BOTTOM_LEFT_ANCHOR or overlay_anchor == constants.BOTTOM_RIGHT_ANCHOR then
    top_y = top_y + surface_height - background_height - overlay_y
  else
    top_y = top_y + overlay_y
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
    local _module_jp = DEBUG and i == 1 and DEBUG_LABEL or constants.MODULE_LABELS_JP[module_order[i]]
    local module_reminders = reminders[_module]

    if module_reminders ~= nil then
      d2d.text(bold_font, _module_jp, left_x + padding, top_y + (font_size + line_spacing) * (line - 1) + padding - font_offset_y, foreground_color)
      line = line + 1

      for _, reminder in ipairs(module_reminders) do
        d2d.text(font, reminder, left_x + padding + indent, top_y + (font_size + line_spacing) * (line - 1) + padding - font_offset_y, foreground_color)
        line = line + 1
      end
    end
  end
end

local function draw_base_overlay()
  if not DEBUG and game.is_reserving_gui() then
    return
  end

  local max_width = config.get_overlay_base_min_width()
  local lines = 0
  local reminders = {}

  if DEBUG then
    local messages = {}
    table.insert(messages, "GUI Reserved: " .. tostring(game.is_reserving_gui()))
    table.insert(messages, "Event: " .. tostring(game.is_playing_event()))

    if #messages > 0 then
      max_width = insert_reminder(reminders, DEBUG_LABEL, messages, max_width)
      lines = lines + #messages + 1
    end
  end

  if config.get_argosy_enabled() then
    local status = argosy.status
    local module_reminders = {}

    for i, request in ipairs(status.trade.requests) do
      local prefix = "交易船 " .. i .. ": "

      if config.get_argosy_idle() and request.idle then
        table.insert(module_reminders, prefix .. "待機中")
      end

      if
        config.get_argosy_uncollected_mode() == constants.ALWAYS_REMINDER_MODE or
        (config.get_argosy_uncollected_mode() == constants.THRESHOLD_REMINDER_MODE and request.uncollected > config.get_argosy_uncollected_above())
      then
        table.insert(module_reminders, prefix .. request.uncollected .. "/" .. request.max_uncollected .. " 未受領")
      end

      if
        config.get_argosy_skill_duration_mode() == constants.ALWAYS_REMINDER_MODE or
        (config.get_argosy_skill_duration_mode() == constants.THRESHOLD_REMINDER_MODE and not request.idle and request.skill_duration < config.get_argosy_skill_duration_below())
      then
        table.insert(module_reminders, prefix .. request.skill_duration .. "/" .. request.max_skill_duration .. " 交渉術")
      end
    end

    local rare_finds = config.get_argosy_rare_finds()

    if rare_finds then
      for _, stocked_item in ipairs(status.exchange.rare_finds) do
        for _, reminder_item in ipairs(rare_finds) do
          if stocked_item == reminder_item then
            table.insert(module_reminders, constants.RARE_FINDS_ITEMS_JP[stocked_item] .. " 掘り出し物で交換可能")
            break
          end
        end
      end
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.ARGOSY_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_buddy_dojo_enabled() then
    local status = buddy_dojo.status
    local module_reminders = {}

    if
      config.get_buddy_dojo_rounds_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_buddy_dojo_rounds_mode() == constants.THRESHOLD_REMINDER_MODE and status.rounds < config.get_buddy_dojo_rounds_below())
    then
      table.insert(module_reminders, status.rounds .. "/" .. status.max_rounds .. " 回")
    end

    if
      config.get_buddy_dojo_boosts_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_buddy_dojo_boosts_mode() == constants.THRESHOLD_REMINDER_MODE and status.rounds > 0 and status.boosts < config.get_buddy_dojo_boosts_below())
    then
      table.insert(module_reminders, "ブースト " .. status.boosts .. "/" .. status.max_boosts .. " 回")
    end

    if
      config.get_buddy_dojo_buddies_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_buddy_dojo_buddies_mode() == constants.THRESHOLD_REMINDER_MODE and status.buddies < config.get_buddy_dojo_buddies_below())
    then
      table.insert(module_reminders, status.buddies .. "/" .. status.max_buddies .. " 匹")
    end

    if
      config.get_buddy_dojo_maxed_buddies_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_buddy_dojo_maxed_buddies_mode() == constants.THRESHOLD_REMINDER_MODE and status.maxed_buddies > config.get_buddy_dojo_maxed_buddies_above())
    then
      table.insert(module_reminders, status.maxed_buddies .. " 匹のオトモが最大レベルになりました" .. " (" .. status.max_level .. ")")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.BUDDY_DOJO_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_cohoot_nest_enabled() then
    local status = cohoot_nest.status
    local module_reminders = {}

    if
      config.get_cohoot_nest_uncollected_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_cohoot_nest_uncollected_mode() == constants.THRESHOLD_REMINDER_MODE and status.uncollected_kamura > config.get_cohoot_nest_uncollected_above())
    then
      table.insert(module_reminders, "カムラの里にて " .. status.uncollected_kamura .. "/" .. status.max_uncollected .. " 個未受領")
    end

    if
      status.uncollected_elgado >= 0 and (
        config.get_cohoot_nest_uncollected_mode() == constants.ALWAYS_REMINDER_MODE or
        (config.get_cohoot_nest_uncollected_mode() == constants.THRESHOLD_REMINDER_MODE and status.uncollected_elgado > config.get_cohoot_nest_uncollected_above())
      )
    then
      table.insert(module_reminders, "エルガドにて " .. status.uncollected_elgado .. "/" .. status.max_uncollected .. " 個未受領")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.COHOOT_NEST_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_items_enabled() then
    local status = items.status
    local module_reminders = {}

    if config.get_items_dirty_pouch() and status.dirty_pouch then
      table.insert(module_reminders, "補充されていないアイテムがあります")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.ITEMS_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_market_enabled() then
    local status = market.status
    local module_reminders = {}

    if config.get_market_sale() and status.sale then
      table.insert(module_reminders, "セール")
    end

    if config.get_market_lottery() and status.lottery then
      table.insert(module_reminders, "福引実施中")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.MARKET_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_melding_pot_enabled() then
    local status = melding_pot.status
    local module_reminders = {}

    if config.get_melding_pot_idle() and not status.active then
      table.insert(module_reminders, "待機")
    end

    if
      config.get_melding_pot_orders_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_melding_pot_orders_mode() == constants.THRESHOLD_REMINDER_MODE and status.orders < config.get_melding_pot_orders_below())
    then
      table.insert(module_reminders, status.orders .. "/" .. status.max_orders .. " 個依頼")
    end

    if
      config.get_melding_pot_uncollected_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_melding_pot_uncollected_mode() == constants.THRESHOLD_REMINDER_MODE and status.uncollected > config.get_melding_pot_uncollected_above())
    then
      table.insert(module_reminders, status.uncollected .. "/" .. status.max_uncollected .. " 未受領")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.MELDING_POT_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_meowcenaries_enabled() then
    local status = meowcenaries.status
    local module_reminders = {}

    if config.get_meowcenaries_idle() and not status.operating then
      table.insert(module_reminders, "待機")
    end

    if
      config.get_meowcenaries_step_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_meowcenaries_step_mode() == constants.THRESHOLD_REMINDER_MODE and status.step > config.get_meowcenaries_step_above())
    then
      table.insert(module_reminders, "調査ルート " .. status.step .. "/" .. status.steps)
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.MEOWCENARIES_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_npcs_enabled() then
    local status = npcs.status
    local module_reminders = {}

    if config.get_npcs_souvenir() and status.commercial_stuff then
      table.insert(module_reminders, "船乗りのピンガルから物資がもらえます")
    end

    if config.get_npcs_speech_bubble() then
      for i, speech_bubble in ipairs(status.speech_bubble_areas) do
        if speech_bubble then
          table.insert(module_reminders, (constants.VILLAGE_AREA_LABELS[i] or ("Unknown Area " .. i)) .. "に話をしたい人がいるようです")
        end
      end
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.NPCS_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  if config.get_subquests_enabled() then
    local status = subquests.base_status
    local module_reminders = {}

    if
      config.get_subquests_active_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_subquests_active_mode() == constants.THRESHOLD_REMINDER_MODE and status.active < config.get_subquests_active_below())
    then
      table.insert(module_reminders, status.active .. "/" .. status.selectable .. " 個受注中")
    end

    if
      config.get_subquests_completed_mode() == constants.ALWAYS_REMINDER_MODE or
      (config.get_subquests_completed_mode() == constants.THRESHOLD_REMINDER_MODE and status.completed > config.get_subquests_completed_above())
    then
      table.insert(module_reminders, status.completed .. " 個報告可能")
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.SUBQUESTS_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  draw_overlay(max_width, lines, reminders, config.get_overlay_base_anchor(), config.get_overlay_base_x(), config.get_overlay_base_y())
end

local function draw_quest_overlay()
  if not DEBUG and not game.is_showing_hud() then
    return
  end

  local max_width = config.get_overlay_quest_min_width()
  local lines = 0
  local reminders = {}

  if DEBUG then
    local messages = {}
    table.insert(messages, "GUI Reserved: " .. tostring(game.is_reserving_gui()))
    table.insert(messages, "Event: " .. tostring(game.is_playing_event()))
    table.insert(messages, "HUD: " .. tostring(game.is_showing_hud()))

    if #messages > 0 then
      max_width = insert_reminder(reminders, DEBUG_LABEL, messages, max_width)
      lines = lines + #messages + 1
    end
  end

  if config.get_subquests_enabled() then
    local status = subquests.quest_status
    local module_reminders = {}

    if config.get_subquests_quest_progress() then
      for _, subquest in ipairs(status.progress) do
        if not subquest.completed then
          table.insert(module_reminders, subquest.current .. "/" .. subquest.target .. " " .. subquest.mission)
        end
      end
    end

    if #module_reminders > 0 then
      max_width = insert_reminder(reminders, constants.SUBQUESTS_LABEL, module_reminders, max_width)
      lines = lines + #module_reminders + 1
    end
  end

  draw_overlay(max_width, lines, reminders, config.get_overlay_quest_anchor(), config.get_overlay_quest_x(), config.get_overlay_quest_y())
end

function overlay.draw()
  if not DEBUG and (game.is_loading() or game.is_playing_event()) then
    return
  end

  local status = game.get_status()

  if status == 1 --[[Base]] and not game.is_in_training() then
    draw_base_overlay()
  elseif status == 2 --[[Quest]] then
    draw_quest_overlay()
  end
end

return overlay