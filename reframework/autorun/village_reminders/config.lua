-- Imports
local constants = require("village_reminders.constants")

-- Constants
local ACTIVE_LABEL = "Remind When Active Below"
local ACTIVE_PROPERTY = "active"
local ANCHOR_LABEL = "Anchor"
local ANCHOR_PROPERTY = "anchor"
local ANCHORS = {
  [constants.TOP_LEFT_ANCHOR] = "Top Left",
  [constants.TOP_RIGHT_ANCHOR] = "Top Right",
  [constants.BOTTOM_LEFT_ANCHOR] = "Bottom Left",
  [constants.BOTTOM_RIGHT_ANCHOR] = "Bottom Right"
}
local ARGOSY_MODULE = "argosy"
local BACKGROUND_LABEL = "Background"
local BACKGROUND_PROPERTY = "background"
local BOOSTS_LABEL = "Remind When Boosts Below"
local BOOSTS_PROPERTY = "boosts"
local BUDDIES_LABEL = "Remind When Buddies Below"
local BUDDIES_PROPERTY = "buddies"
local BUDDY_DOJO_MODULE = "buddyDojo"
local COLOR_EDIT_FLAGS = 1 << 3 --[[No Options]] | 1 << 7 --[[No Label]] | 1 << 16 --[[Alpha Bar]]
local COMPLETED_LABEL = "Remind When Completed Above"
local COMPLETED_PROPERTY = "completed"
local COHOOT_NEST_MODULE = "cohootNest"
local ENABLED_LABEL = "Enabled"
local ENABLED_PROPERTY = "enabled"
local FILE = "village_reminders/config.json"
local FONT_SIZE_LABEL = "Font Size"
local FONT_SIZE_PROPERTY = "fontSize"
local FOREGROUND_LABEL = "Foreground"
local FOREGROUND_PROPERTY = "foreground"
local IDLE_LABEL = "Remind When Idle"
local IDLE_PROPERTY = "idle"
local INDENT_LABEL = "Indent"
local INDENT_PROPERTY = "indent"
local LINE_SPACING_LABEL = "Line Spacing"
local LINE_SPACING_PROPERTY = "lineSpacing"
local LOTTERY_LABEL = "Remind When Lottery Available"
local LOTTERY_PROPERTY = "lottery"
local MARKET_MODULE = "market"
local MAXED_BUDDIES_LABEL = "Remind When Max Level Buddies Above"
local MAXED_BUDDIES_PROPERTY = "maxedBuddies"
local MELDING_POT_MODULE = "meldingPot"
local MEOWCENARIES_MODULE = "meowcenaries"
local NPCS_MODULE = "npcs"
local ORDER_LABEL = "Order"
local ORDER_PROPERTY = "order"
local ORDERS_LABEL = "Remind When Orders Below"
local ORDERS_PROPERTY = "orders"
local OVERLAY_MODULE = "overlay"
local PADDING_LABEL = "Padding"
local PADDING_PROPERTY = "padding"
local ROUNDS_LABEL = "Remind When Rounds Below"
local ROUNDS_PROPERTY = "rounds"
local SALE_LABEL = "Remind When Sale"
local SALE_PROPERTY = "sale"
local SKILL_DURATION_LABEL = "Remind When Skill Duration Below"
local SKILL_DURATION_PROPERTY = "skillDuration"
local STEP_LABEL = "Remind When Step Above"
local STEP_PROPERTY = "step"
local SPEECH_BUBBLE_LABEL = "Remind When NPCs Have Speech Bubbles"
local SPEECH_BUBBLE_PROPERTY = "speechBubble"
local SUBQUESTS_MODULE = "subquests"
local TITLE = "Village Reminders"
local UNCOLLECTED_LABEL = "Remind When Uncollected Above"
local UNCOLLECTED_PROPERTY = "uncollected"
local WIDTH_LABEL = "Min Width"
local WIDTH_PROPERTY = "width"
local X_LABEL = "X"
local X_PROPERTY = "x"
local Y_LABEL = "Y"
local Y_PROPERTY = "y"

local DEFAULT_OVERLAY_ORDER = {}

for i, _ in ipairs(constants.MODULE_LABELS) do
  DEFAULT_OVERLAY_ORDER[i] = i
end

-- Variables
local properties = json.load_file(FILE) or {
  [ARGOSY_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [IDLE_PROPERTY] = true,
    [SKILL_DURATION_PROPERTY] = 1,
    [UNCOLLECTED_PROPERTY] = 18
  },
  [BUDDY_DOJO_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [BOOSTS_PROPERTY] = 1,
    [BUDDIES_PROPERTY] = 6,
    [MAXED_BUDDIES_PROPERTY] = 0,
    [ROUNDS_PROPERTY] = 1
  },
  [COHOOT_NEST_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [UNCOLLECTED_PROPERTY] = 4
  },
  [MARKET_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [LOTTERY_PROPERTY] = true
  },
  [MELDING_POT_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [IDLE_PROPERTY] = true,
    [ORDERS_PROPERTY] = 0,
    [UNCOLLECTED_PROPERTY] = 0
  },
  [MEOWCENARIES_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [IDLE_PROPERTY] = true,
    [STEP_PROPERTY] = 4
  },
  [NPCS_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [SPEECH_BUBBLE_PROPERTY] = true
  },
  [OVERLAY_MODULE] = {
    [ANCHOR_PROPERTY] = constants.BOTTOM_LEFT_ANCHOR,
    [BACKGROUND_PROPERTY] = 0x66000000,
    [FONT_SIZE_PROPERTY] = 12,
    [FOREGROUND_PROPERTY] = 0xFFFFFFFF,
    [INDENT_PROPERTY] = 8,
    [LINE_SPACING_PROPERTY] = 4,
    [ORDER_PROPERTY] = DEFAULT_OVERLAY_ORDER,
    [PADDING_PROPERTY] = 6,
    [WIDTH_PROPERTY] = 0,
    [X_PROPERTY] = 24,
    [Y_PROPERTY] = 24
  },
  [SUBQUESTS_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [ACTIVE_PROPERTY] = 5,
    [COMPLETED_PROPERTY] = 0
  }
}
local is_open = false

-- Functions
local function draw_checkbox(_module, property, label)
  local changed, value = imgui.checkbox(label, properties[_module][property])

  if changed then
    properties[_module][property] = value
  end

  return changed
end

local function draw_color_picker(_module, property, label)
  local changed = false
  local value = properties[_module][property]

  if imgui.tree_node(label) then
    changed, value = imgui.color_picker_argb(label, value, COLOR_EDIT_FLAGS)

    if changed then
      properties[_module][property] = value
    end
  
    imgui.tree_pop()
  end

  return changed
end

local function draw_combo(_module, property, label, values)
  local changed, value = imgui.combo(label, properties[_module][property], values)

  if changed then
    properties[_module][property] = value
  end

  return changed
end

local function draw_drag_int(_module, property, label, min, max)
  local changed, value = imgui.drag_int(label, properties[_module][property], 1, min, max)

  if changed then
    properties[_module][property] = value
  end

  return changed
end

local function draw_reorder(_module, property, label, values)
  local changed = false
  local value = properties[_module][property]

  if imgui.tree_node(label) then
    for i = 1, #values do
      imgui.begin_group()

      if imgui.button("/\\##Up" .. i) and i > 1 then
        local above_index = i - 1
        local above_value = value[above_index]
        value[above_index] = value[i]
        value[i] = above_value
        changed = true
      end

      imgui.same_line()

      if imgui.button("\\/##Down" .. i) and i < #values then
        local below_index = i + 1
        local below_value = value[below_index]
        value[below_index] = value[i]
        value[i] = below_value
        changed = true
      end

      imgui.same_line()
      imgui.text(values[value[i]])
      imgui.end_group()
    end

    if changed then
      properties[_module][property] = value
    end
  
    imgui.tree_pop()
  end

  return changed
end

local function draw_slider_int(_module, property, label, min, max)
  local changed, value = imgui.slider_int(label, properties[_module][property], min, max)

  if changed then
    properties[_module][property] = value
  end

  return changed
end

-- Module
local config = {}

function config.draw()
  if imgui.button(TITLE) then
    is_open = true
  end

  if imgui.begin_window(TITLE, is_open) then
    local changed = false

    if imgui.tree_node("Overlay") then
      changed = draw_combo(OVERLAY_MODULE, ANCHOR_PROPERTY, ANCHOR_LABEL, ANCHORS) or changed
      local max_width, max_height = d2d.surface_size()
      changed = draw_drag_int(OVERLAY_MODULE, X_PROPERTY, X_LABEL, 0, max_width) or changed
      changed = draw_drag_int(OVERLAY_MODULE, Y_PROPERTY, Y_LABEL, 0, max_height) or changed
      changed = draw_slider_int(OVERLAY_MODULE, FONT_SIZE_PROPERTY, FONT_SIZE_LABEL, 4, 72) or changed
      imgui.text("Note: Changes to font size require the mod to be restarted.")
      changed = draw_slider_int(OVERLAY_MODULE, LINE_SPACING_PROPERTY, LINE_SPACING_LABEL, 0, 72) or changed
      changed = draw_slider_int(OVERLAY_MODULE, INDENT_PROPERTY, INDENT_LABEL, 0, 72) or changed
      changed = draw_slider_int(OVERLAY_MODULE, PADDING_PROPERTY, PADDING_LABEL, 0, 72) or changed
      changed = draw_drag_int(OVERLAY_MODULE, WIDTH_PROPERTY, WIDTH_LABEL, 0, max_width) or changed
      changed = draw_color_picker(OVERLAY_MODULE, FOREGROUND_PROPERTY, FOREGROUND_LABEL) or changed
      changed = draw_color_picker(OVERLAY_MODULE, BACKGROUND_PROPERTY, BACKGROUND_LABEL) or changed
      changed = draw_reorder(OVERLAY_MODULE, ORDER_PROPERTY, ORDER_LABEL, constants.MODULE_LABELS) or changed    
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.ARGOSY_LABEL) then
      changed = draw_checkbox(ARGOSY_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(ARGOSY_MODULE, IDLE_PROPERTY, IDLE_LABEL) or changed
      changed = draw_slider_int(ARGOSY_MODULE, UNCOLLECTED_PROPERTY, UNCOLLECTED_LABEL, 0, 20) or changed
      changed = draw_slider_int(ARGOSY_MODULE, SKILL_DURATION_PROPERTY, SKILL_DURATION_LABEL, 0, 9) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.BUDDY_DOJO_LABEL) then
      changed = draw_checkbox(BUDDY_DOJO_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_slider_int(BUDDY_DOJO_MODULE, ROUNDS_PROPERTY, ROUNDS_LABEL, 0, 10) or changed
      changed = draw_slider_int(BUDDY_DOJO_MODULE, BOOSTS_PROPERTY, BOOSTS_LABEL, 0, 10) or changed
      changed = draw_slider_int(BUDDY_DOJO_MODULE, BUDDIES_PROPERTY, BUDDIES_LABEL, 0, 6) or changed
      changed = draw_slider_int(BUDDY_DOJO_MODULE, MAXED_BUDDIES_PROPERTY, MAXED_BUDDIES_LABEL, 0, 6) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.COHOOT_NEST_LABEL) then
      changed = draw_checkbox(COHOOT_NEST_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_slider_int(COHOOT_NEST_MODULE, UNCOLLECTED_PROPERTY, UNCOLLECTED_LABEL, 0, 5) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.MARKET_LABEL) then
      changed = draw_checkbox(MARKET_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(MARKET_MODULE, SALE_PROPERTY, SALE_LABEL) or changed
      changed = draw_checkbox(MARKET_MODULE, LOTTERY_PROPERTY, LOTTERY_LABEL) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.MELDING_POT_LABEL) then
      changed = draw_checkbox(MELDING_POT_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(MELDING_POT_MODULE, IDLE_PROPERTY, IDLE_LABEL) or changed
      changed = draw_slider_int(MELDING_POT_MODULE, ORDERS_PROPERTY, ORDERS_LABEL, 0, 10) or changed
      changed = draw_slider_int(MELDING_POT_MODULE, UNCOLLECTED_PROPERTY, UNCOLLECTED_LABEL, 0, 70) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.MEOWCENARIES_LABEL) then
      changed = draw_checkbox(MEOWCENARIES_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(MEOWCENARIES_MODULE, IDLE_PROPERTY, IDLE_LABEL) or changed
      changed = draw_slider_int(MEOWCENARIES_MODULE, STEP_PROPERTY, STEP_LABEL, 0, 5) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.NPCS_LABEL) then
      changed = draw_checkbox(NPCS_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(NPCS_MODULE, SPEECH_BUBBLE_PROPERTY, SPEECH_BUBBLE_LABEL) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.SUBQUESTS_LABEL) then
      changed = draw_checkbox(SUBQUESTS_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_slider_int(SUBQUESTS_MODULE, ACTIVE_PROPERTY, ACTIVE_LABEL, 0, 5) or changed
      changed = draw_slider_int(SUBQUESTS_MODULE, COMPLETED_PROPERTY, COMPLETED_LABEL, 0, 5) or changed
      imgui.tree_pop()
    end

    if changed then
      json.dump_file(FILE, properties)
    end

    imgui.end_window()
  else
    is_open = false
  end
end

function config.get_argosy_enabled()
  return properties[ARGOSY_MODULE][ENABLED_PROPERTY]
end

function config.get_argosy_idle()
  return properties[ARGOSY_MODULE][IDLE_PROPERTY]
end

function config.get_argosy_skill_duration()
  return properties[ARGOSY_MODULE][SKILL_DURATION_PROPERTY]
end

function config.get_argosy_uncollected()
  return properties[ARGOSY_MODULE][UNCOLLECTED_PROPERTY]
end

function config.get_buddy_dojo_boosts()
  return properties[BUDDY_DOJO_MODULE][BOOSTS_PROPERTY]
end

function config.get_buddy_dojo_buddies()
  return properties[BUDDY_DOJO_MODULE][BUDDIES_PROPERTY]
end

function config.get_buddy_dojo_enabled()
  return properties[BUDDY_DOJO_MODULE][ENABLED_PROPERTY]
end

function config.get_buddy_dojo_maxed_buddies()
  return properties[BUDDY_DOJO_MODULE][MAXED_BUDDIES_PROPERTY]
end

function config.get_buddy_dojo_rounds()
  return properties[BUDDY_DOJO_MODULE][ROUNDS_PROPERTY]
end

function config.get_cohoot_nest_enabled()
  return properties[COHOOT_NEST_MODULE][ENABLED_PROPERTY]
end

function config.get_cohoot_nest_uncollected()
  return properties[COHOOT_NEST_MODULE][UNCOLLECTED_PROPERTY]
end

function config.get_market_enabled()
  return properties[MARKET_MODULE][ENABLED_PROPERTY]
end

function config.get_market_lottery()
  return properties[MARKET_MODULE][LOTTERY_PROPERTY]
end

function config.get_market_sale()
  return properties[MARKET_MODULE][SALE_PROPERTY]
end

function config.get_melding_pot_enabled()
  return properties[MELDING_POT_MODULE][ENABLED_PROPERTY]
end

function config.get_melding_pot_idle()
  return properties[MELDING_POT_MODULE][IDLE_PROPERTY]
end

function config.get_melding_pot_orders()
  return properties[MELDING_POT_MODULE][ORDERS_PROPERTY]
end

function config.get_melding_pot_uncollected()
  return properties[MELDING_POT_MODULE][UNCOLLECTED_PROPERTY]
end

function config.get_meowcenaries_enabled()
  return properties[MEOWCENARIES_MODULE][ENABLED_PROPERTY]
end

function config.get_meowcenaries_idle()
  return properties[MEOWCENARIES_MODULE][IDLE_PROPERTY]
end

function config.get_meowcenaries_step()
  return properties[MEOWCENARIES_MODULE][STEP_PROPERTY]
end

function config.get_npcs_enabled()
  return properties[NPCS_MODULE][ENABLED_PROPERTY]
end

function config.get_npcs_speech_bubble()
  return properties[NPCS_MODULE][SPEECH_BUBBLE_PROPERTY]
end

function config.get_overlay_anchor()
  return properties[OVERLAY_MODULE][ANCHOR_PROPERTY]
end

function config.get_overlay_background()
  return properties[OVERLAY_MODULE][BACKGROUND_PROPERTY]
end

function config.get_overlay_font_size()
  return properties[OVERLAY_MODULE][FONT_SIZE_PROPERTY]
end

function config.get_overlay_foreground()
  return properties[OVERLAY_MODULE][FOREGROUND_PROPERTY]
end

function config.get_overlay_indent()
  return properties[OVERLAY_MODULE][INDENT_PROPERTY]
end

function config.get_overlay_line_spacing()
  return properties[OVERLAY_MODULE][LINE_SPACING_PROPERTY]
end

function config.get_overlay_order()
  return properties[OVERLAY_MODULE][ORDER_PROPERTY]
end

function config.get_overlay_padding()
  return properties[OVERLAY_MODULE][PADDING_PROPERTY]
end

function config.get_overlay_width()
  return properties[OVERLAY_MODULE][WIDTH_PROPERTY]
end

function config.get_overlay_x()
  return properties[OVERLAY_MODULE][X_PROPERTY]
end

function config.get_overlay_y()
  return properties[OVERLAY_MODULE][Y_PROPERTY]
end

function config.get_subquests_enabled()
  return properties[SUBQUESTS_MODULE][ENABLED_PROPERTY]
end

function config.get_subquests_active()
  return properties[SUBQUESTS_MODULE][ACTIVE_PROPERTY]
end

function config.get_subquests_completed()
  return properties[SUBQUESTS_MODULE][COMPLETED_PROPERTY]
end

return config