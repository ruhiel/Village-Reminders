-- Imports
local constants = require("village_reminders.constants")

-- Constants
local ACTIVE_BELOW_LABEL = "Remind When Active Below"
local ACTIVE_BELOW_PROPERTY = "activeBelow"
local ANCHOR_LABEL = "Anchor"
local ANCHORS = {
  [constants.TOP_LEFT_ANCHOR] = "Top Left",
  [constants.TOP_RIGHT_ANCHOR] = "Top Right",
  [constants.BOTTOM_LEFT_ANCHOR] = "Bottom Left",
  [constants.BOTTOM_RIGHT_ANCHOR] = "Bottom Right"
}
local ARGOSY_MODULE = "argosy"
local BACKGROUND_LABEL = "Background"
local BACKGROUND_PROPERTY = "background"
local BASE_ANCHOR_PROPERTY = "baseAnchor"
local BASE_MIN_WIDTH_PROPERTY = "baseMinWidth"
local BASE_X_PROPERTY = "baseX"
local BASE_Y_PROPERTY = "baseY"
local BOOSTS_BELOW_LABEL = "Remind When Boosts Below"
local BOOSTS_BELOW_PROPERTY = "boostsBelow"
local BUDDIES_BELOW_LABEL = "Remind When Buddies Below"
local BUDDIES_BELOW_PROPERTY = "buddiesBelow"
local BUDDY_DOJO_MODULE = "buddyDojo"
local COHOOT_NEST_MODULE = "cohootNest"
local COLOR_EDIT_FLAGS = 1 << 3 --[[No Options]] | 1 << 7 --[[No Label]] | 1 << 16 --[[Alpha Bar]]
local COMPLETED_ABOVE_LABEL = "Remind When Completed Above"
local COMPLETED_ABOVE_PROPERTY = "completedAbove"
local DIRTY_POUCH_LABEL = "Remind When Item Pouch Not Checked"
local DIRTY_POUCH_PROPERTY = "dirtyPouch"
local ENABLED_LABEL = "Enabled"
local ENABLED_PROPERTY = "enabled"
local FILE = "village_reminders/config.json"
local FONT_SIZE_LABEL = "Font Size"
local FONT_SIZE_PROPERTY = "fontSize"
local FOREGROUND_LABEL = "Foreground"
local FOREGROUND_PROPERTY = "foreground"
local GLOBAL_MODULE = "global"
local IDLE_LABEL = "Remind When Idle"
local IDLE_PROPERTY = "idle"
local INDENT_LABEL = "Indent"
local INDENT_PROPERTY = "indent"
local ITEMS_MODULE = "items"
local LINE_SPACING_LABEL = "Line Spacing"
local LINE_SPACING_PROPERTY = "lineSpacing"
local LOTTERY_LABEL = "Remind When Lottery Available"
local LOTTERY_PROPERTY = "lottery"
local MARKET_MODULE = "market"
local MAXED_BUDDIES_ABOVE_LABEL = "Remind When Max Level Buddies Above"
local MAXED_BUDDIES_ABOVE_PROPERTY = "maxedBuddiesAbove"
local MELDING_POT_MODULE = "meldingPot"
local MEOWCENARIES_MODULE = "meowcenaries"
local MIN_WIDTH_LABEL = "Min Width"
local NPCS_MODULE = "npcs"
local ORDER_LABEL = "Order"
local ORDER_PROPERTY = "order"
local ORDERS_BELOW_LABEL = "Remind When Orders Below"
local ORDERS_BELOW_PROPERTY = "ordersBelow"
local OVERLAY_MODULE = "overlay"
local PADDING_LABEL = "Padding"
local PADDING_PROPERTY = "padding"
local QUEST_ANCHOR_PROPERTY = "questAnchor"
local QUEST_MIN_WIDTH_PROPERTY = "questMinWidth"
local QUEST_PROGRESS_LABEL = "Show Progress During Quests"
local QUEST_PROGRESS_PROPERTY = "showProgressDuringQuests"
local QUEST_X_PROPERTY = "questX"
local QUEST_Y_PROPERTY = "questY"
local RARE_FINDS_LABEL = "Remind When Rare Finds Stocked"
local RARE_FINDS_PROPERTY = "rareFinds"
local ROUNDS_BELOW_LABEL = "Remind When Rounds Below"
local ROUNDS_BELOW_PROPERTY = "roundsBelow"
local SALE_LABEL = "Remind When Sale"
local SALE_PROPERTY = "sale"
local SKILL_DURATION_BELOW_LABEL = "Remind When Skill Duration Below"
local SKILL_DURATION_BELOW_PROPERTY = "skillDurationBelow"
local STEP_ABOVE_LABEL = "Remind When Step Above"
local STEP_ABOVE_PROPERTY = "stepAbove"
local SOUVENIR_LABEL = "Remind When Pingarh the Sailor Has Souvenir"
local SOUVENIR_PROPERTY = "souvenir"
local SPEECH_BUBBLE_LABEL = "Remind When NPCs Have Speech Bubbles"
local SPEECH_BUBBLE_PROPERTY = "speechBubble"
local SUBQUESTS_MODULE = "subquests"
local TITLE = "Village Reminders"
local UNCOLLECTED_ABOVE_LABEL = "Remind When Uncollected Above"
local UNCOLLECTED_ABOVE_PROPERTY = "uncollectedAbove"
local VERSION_PROPERTY = "version"
local X_LABEL = "X"
local Y_LABEL = "Y"

local DEFAULT_OVERLAY_ORDER = {}

for i, _ in ipairs(constants.MODULE_LABELS) do
  DEFAULT_OVERLAY_ORDER[i] = i
end

-- Variables
local properties = {
  [ARGOSY_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [IDLE_PROPERTY] = true,
    [RARE_FINDS_PROPERTY] = {},
    [SKILL_DURATION_BELOW_PROPERTY] = 1,
    [UNCOLLECTED_ABOVE_PROPERTY] = 15
  },
  [BUDDY_DOJO_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [BOOSTS_BELOW_PROPERTY] = 1,
    [BUDDIES_BELOW_PROPERTY] = 6,
    [MAXED_BUDDIES_ABOVE_PROPERTY] = 0,
    [ROUNDS_BELOW_PROPERTY] = 1
  },
  [COHOOT_NEST_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [UNCOLLECTED_ABOVE_PROPERTY] = 4
  },
  [ITEMS_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [DIRTY_POUCH_PROPERTY] = false
  },
  [MARKET_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [LOTTERY_PROPERTY] = true
  },
  [MELDING_POT_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [IDLE_PROPERTY] = true,
    [ORDERS_BELOW_PROPERTY] = 0,
    [UNCOLLECTED_ABOVE_PROPERTY] = 0
  },
  [MEOWCENARIES_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [IDLE_PROPERTY] = true,
    [STEP_ABOVE_PROPERTY] = 4
  },
  [NPCS_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [SPEECH_BUBBLE_PROPERTY] = true
  },
  [OVERLAY_MODULE] = {
    [BACKGROUND_PROPERTY] = 0x66000000,
    [BASE_ANCHOR_PROPERTY] = constants.BOTTOM_LEFT_ANCHOR,
    [BASE_MIN_WIDTH_PROPERTY] = 0,
    [BASE_X_PROPERTY] = 24,
    [BASE_Y_PROPERTY] = 24,
    [FONT_SIZE_PROPERTY] = 12,
    [FOREGROUND_PROPERTY] = 0xFFFFFFFF,
    [INDENT_PROPERTY] = 8,
    [LINE_SPACING_PROPERTY] = 4,
    [ORDER_PROPERTY] = DEFAULT_OVERLAY_ORDER,
    [PADDING_PROPERTY] = 6,
    [QUEST_ANCHOR_PROPERTY] = constants.TOP_RIGHT_ANCHOR,
    [QUEST_MIN_WIDTH_PROPERTY] = 0,
    [QUEST_X_PROPERTY] = 12,
    [QUEST_Y_PROPERTY] = 164
  },
  [SUBQUESTS_MODULE] = {
    [ENABLED_PROPERTY] = true,
    [ACTIVE_BELOW_PROPERTY] = 5,
    [COMPLETED_ABOVE_PROPERTY] = 0,
    [QUEST_PROGRESS_PROPERTY] = false
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

local function draw_multi_select(_module, property, label, values)
  local select_changed = false
  local selections = {}

  for _, item in ipairs(properties[_module][property]) do
    selections[item] = true
  end

  if imgui.tree_node(label) then
    for _, item in ipairs(values) do
      local item_changed, selected = imgui.checkbox(item .. "##" .. label, selections[item] or false)

      if item_changed then
        selections[item] = selected
        select_changed = select_changed or item_changed
      end
    end

    if select_changed then
      local raw_selections = {}

      for item, selected in pairs(selections) do
        if selected then
          table.insert(raw_selections, item)
        end
      end

      properties[_module][property] = raw_selections
    end

    imgui.tree_pop()
  end

  return select_changed
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
      local max_width, max_height = d2d.surface_size()
      changed = draw_slider_int(OVERLAY_MODULE, FONT_SIZE_PROPERTY, FONT_SIZE_LABEL, 4, 72) or changed
      imgui.text("Note: Changes to font size require the mod to be restarted.")
      changed = draw_slider_int(OVERLAY_MODULE, LINE_SPACING_PROPERTY, LINE_SPACING_LABEL, 0, 72) or changed
      changed = draw_slider_int(OVERLAY_MODULE, INDENT_PROPERTY, INDENT_LABEL, 0, 72) or changed
      changed = draw_slider_int(OVERLAY_MODULE, PADDING_PROPERTY, PADDING_LABEL, 0, 72) or changed

      if imgui.tree_node("Position and Size (Base)") then
        changed = draw_combo(OVERLAY_MODULE, BASE_ANCHOR_PROPERTY, ANCHOR_LABEL, ANCHORS) or changed
        changed = draw_drag_int(OVERLAY_MODULE, BASE_X_PROPERTY, X_LABEL, 0, max_width) or changed
        changed = draw_drag_int(OVERLAY_MODULE, BASE_Y_PROPERTY, Y_LABEL, 0, max_height) or changed
        changed = draw_drag_int(OVERLAY_MODULE, BASE_MIN_WIDTH_PROPERTY, MIN_WIDTH_LABEL, 0, max_width) or changed
        imgui.tree_pop()
      end

      if imgui.tree_node("Position and Size (Quest)") then
        changed = draw_combo(OVERLAY_MODULE, QUEST_ANCHOR_PROPERTY, ANCHOR_LABEL, ANCHORS) or changed
        changed = draw_drag_int(OVERLAY_MODULE, QUEST_X_PROPERTY, X_LABEL, 0, max_width) or changed
        changed = draw_drag_int(OVERLAY_MODULE, QUEST_Y_PROPERTY, Y_LABEL, 0, max_height) or changed
        changed = draw_drag_int(OVERLAY_MODULE, QUEST_MIN_WIDTH_PROPERTY, MIN_WIDTH_LABEL, 0, max_width) or changed
        imgui.tree_pop()
      end

      changed = draw_color_picker(OVERLAY_MODULE, FOREGROUND_PROPERTY, FOREGROUND_LABEL) or changed
      changed = draw_color_picker(OVERLAY_MODULE, BACKGROUND_PROPERTY, BACKGROUND_LABEL) or changed
      changed = draw_reorder(OVERLAY_MODULE, ORDER_PROPERTY, ORDER_LABEL, constants.MODULE_LABELS) or changed    
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.ARGOSY_LABEL) then
      changed = draw_checkbox(ARGOSY_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(ARGOSY_MODULE, IDLE_PROPERTY, IDLE_LABEL) or changed
      changed = draw_slider_int(ARGOSY_MODULE, UNCOLLECTED_ABOVE_PROPERTY, UNCOLLECTED_ABOVE_LABEL, 0, 20) or changed
      changed = draw_slider_int(ARGOSY_MODULE, SKILL_DURATION_BELOW_PROPERTY, SKILL_DURATION_BELOW_LABEL, 0, 9) or changed
      changed = draw_multi_select(ARGOSY_MODULE, RARE_FINDS_PROPERTY, RARE_FINDS_LABEL, constants.RARE_FINDS_ITEMS)
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.BUDDY_DOJO_LABEL) then
      changed = draw_checkbox(BUDDY_DOJO_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_slider_int(BUDDY_DOJO_MODULE, ROUNDS_BELOW_PROPERTY, ROUNDS_BELOW_LABEL, 0, 10) or changed
      changed = draw_slider_int(BUDDY_DOJO_MODULE, BOOSTS_BELOW_PROPERTY, BOOSTS_BELOW_LABEL, 0, 10) or changed
      changed = draw_slider_int(BUDDY_DOJO_MODULE, BUDDIES_BELOW_PROPERTY, BUDDIES_BELOW_LABEL, 0, 6) or changed
      changed = draw_slider_int(BUDDY_DOJO_MODULE, MAXED_BUDDIES_ABOVE_PROPERTY, MAXED_BUDDIES_ABOVE_LABEL, 0, 6) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.COHOOT_NEST_LABEL) then
      changed = draw_checkbox(COHOOT_NEST_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_slider_int(COHOOT_NEST_MODULE, UNCOLLECTED_ABOVE_PROPERTY, UNCOLLECTED_ABOVE_LABEL, 0, 5) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.ITEMS_LABEL) then
      changed = draw_checkbox(ITEMS_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(ITEMS_MODULE, DIRTY_POUCH_PROPERTY, DIRTY_POUCH_LABEL) or changed
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
      changed = draw_slider_int(MELDING_POT_MODULE, ORDERS_BELOW_PROPERTY, ORDERS_BELOW_LABEL, 0, 10) or changed
      changed = draw_slider_int(MELDING_POT_MODULE, UNCOLLECTED_ABOVE_PROPERTY, UNCOLLECTED_ABOVE_LABEL, 0, 70) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.MEOWCENARIES_LABEL) then
      changed = draw_checkbox(MEOWCENARIES_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(MEOWCENARIES_MODULE, IDLE_PROPERTY, IDLE_LABEL) or changed
      changed = draw_slider_int(MEOWCENARIES_MODULE, STEP_ABOVE_PROPERTY, STEP_ABOVE_LABEL, 0, 5) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.NPCS_LABEL) then
      changed = draw_checkbox(NPCS_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(NPCS_MODULE, SPEECH_BUBBLE_PROPERTY, SPEECH_BUBBLE_LABEL) or changed
      changed = draw_checkbox(NPCS_MODULE, SOUVENIR_PROPERTY, SOUVENIR_LABEL) or changed
      imgui.tree_pop()
    end

    if imgui.tree_node(constants.SUBQUESTS_LABEL) then
      changed = draw_checkbox(SUBQUESTS_MODULE, ENABLED_PROPERTY, ENABLED_LABEL) or changed
      changed = draw_checkbox(SUBQUESTS_MODULE, QUEST_PROGRESS_PROPERTY, QUEST_PROGRESS_LABEL) or changed
      changed = draw_slider_int(SUBQUESTS_MODULE, ACTIVE_BELOW_PROPERTY, ACTIVE_BELOW_LABEL, 0, 5) or changed
      changed = draw_slider_int(SUBQUESTS_MODULE, COMPLETED_ABOVE_PROPERTY, COMPLETED_ABOVE_LABEL, 0, 5) or changed
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

function config.get_argosy_rare_finds()
  return properties[ARGOSY_MODULE][RARE_FINDS_PROPERTY]
end

function config.get_argosy_skill_duration_below()
  return properties[ARGOSY_MODULE][SKILL_DURATION_BELOW_PROPERTY]
end

function config.get_argosy_uncollected_above()
  return properties[ARGOSY_MODULE][UNCOLLECTED_ABOVE_PROPERTY]
end

function config.get_buddy_dojo_boosts_below()
  return properties[BUDDY_DOJO_MODULE][BOOSTS_BELOW_PROPERTY]
end

function config.get_buddy_dojo_buddies_below()
  return properties[BUDDY_DOJO_MODULE][BUDDIES_BELOW_PROPERTY]
end

function config.get_buddy_dojo_enabled()
  return properties[BUDDY_DOJO_MODULE][ENABLED_PROPERTY]
end

function config.get_buddy_dojo_maxed_buddies_above()
  return properties[BUDDY_DOJO_MODULE][MAXED_BUDDIES_ABOVE_PROPERTY]
end

function config.get_buddy_dojo_rounds_below()
  return properties[BUDDY_DOJO_MODULE][ROUNDS_BELOW_PROPERTY]
end

function config.get_cohoot_nest_enabled()
  return properties[COHOOT_NEST_MODULE][ENABLED_PROPERTY]
end

function config.get_cohoot_nest_uncollected_above()
  return properties[COHOOT_NEST_MODULE][UNCOLLECTED_ABOVE_PROPERTY]
end

function config.get_items_enabled()
  return properties[ITEMS_MODULE][ENABLED_PROPERTY]
end

function config.get_items_dirty_pouch()
  return properties[ITEMS_MODULE][DIRTY_POUCH_PROPERTY]
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

function config.get_melding_pot_orders_below()
  return properties[MELDING_POT_MODULE][ORDERS_BELOW_PROPERTY]
end

function config.get_melding_pot_uncollected_above()
  return properties[MELDING_POT_MODULE][UNCOLLECTED_ABOVE_PROPERTY]
end

function config.get_meowcenaries_enabled()
  return properties[MEOWCENARIES_MODULE][ENABLED_PROPERTY]
end

function config.get_meowcenaries_idle()
  return properties[MEOWCENARIES_MODULE][IDLE_PROPERTY]
end

function config.get_meowcenaries_step_above()
  return properties[MEOWCENARIES_MODULE][STEP_ABOVE_PROPERTY]
end

function config.get_npcs_enabled()
  return properties[NPCS_MODULE][ENABLED_PROPERTY]
end

function config.get_npcs_souvenir()
  return properties[NPCS_MODULE][SOUVENIR_PROPERTY]
end

function config.get_npcs_speech_bubble()
  return properties[NPCS_MODULE][SPEECH_BUBBLE_PROPERTY]
end

function config.get_overlay_background()
  return properties[OVERLAY_MODULE][BACKGROUND_PROPERTY]
end

function config.get_overlay_base_anchor()
  return properties[OVERLAY_MODULE][BASE_ANCHOR_PROPERTY]
end

function config.get_overlay_base_min_width()
  return properties[OVERLAY_MODULE][BASE_MIN_WIDTH_PROPERTY]
end

function config.get_overlay_base_x()
  return properties[OVERLAY_MODULE][BASE_X_PROPERTY]
end

function config.get_overlay_base_y()
  return properties[OVERLAY_MODULE][BASE_Y_PROPERTY]
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

function config.get_overlay_quest_anchor()
  return properties[OVERLAY_MODULE][QUEST_ANCHOR_PROPERTY]
end

function config.get_overlay_quest_min_width()
  return properties[OVERLAY_MODULE][QUEST_MIN_WIDTH_PROPERTY]
end

function config.get_overlay_quest_x()
  return properties[OVERLAY_MODULE][QUEST_X_PROPERTY]
end

function config.get_overlay_quest_y()
  return properties[OVERLAY_MODULE][QUEST_Y_PROPERTY]
end

function config.get_subquests_enabled()
  return properties[SUBQUESTS_MODULE][ENABLED_PROPERTY]
end

function config.get_subquests_active_below()
  return properties[SUBQUESTS_MODULE][ACTIVE_BELOW_PROPERTY]
end

function config.get_subquests_completed_above()
  return properties[SUBQUESTS_MODULE][COMPLETED_ABOVE_PROPERTY]
end

function config.get_subquests_quest_progress()
  return properties[SUBQUESTS_MODULE][QUEST_PROGRESS_PROPERTY]
end

function config.load()
  local loaded = json.load_file(FILE)

  if not loaded then
    return
  end

  for _module, module_properties in pairs(loaded) do
    if not properties[_module] then
      properties[_module] = {}
    end

    for property, value in pairs(module_properties) do
      properties[_module][property] = value
    end
  end

  local global_module = loaded[GLOBAL_MODULE] or {}
  local version = global_module[VERSION_PROPERTY]
  local updated = false

  if not version then
    version = "1.1.0"
    properties[GLOBAL_MODULE] = {[VERSION_PROPERTY] = version}

    local argosy_module = properties[ARGOSY_MODULE]
    argosy_module[SKILL_DURATION_BELOW_PROPERTY] = argosy_module.skillDuration
    argosy_module.skillDuration = nil
    argosy_module[UNCOLLECTED_ABOVE_PROPERTY] = argosy_module.uncollected
    argosy_module.uncollected = nil

    local buddy_dojo_module = properties[BUDDY_DOJO_MODULE]
    buddy_dojo_module[BOOSTS_BELOW_PROPERTY] = buddy_dojo_module.boosts
    buddy_dojo_module.boosts = nil
    buddy_dojo_module[BUDDIES_BELOW_PROPERTY] = buddy_dojo_module.buddies
    buddy_dojo_module.buddies = nil
    buddy_dojo_module[MAXED_BUDDIES_ABOVE_PROPERTY] = buddy_dojo_module.maxedBuddies
    buddy_dojo_module.maxedBuddies = nil
    buddy_dojo_module[ROUNDS_BELOW_PROPERTY] = buddy_dojo_module.rounds
    buddy_dojo_module.rounds = nil

    local cohoot_nest_module = properties[COHOOT_NEST_MODULE]
    cohoot_nest_module[UNCOLLECTED_ABOVE_PROPERTY] = cohoot_nest_module.uncollected
    cohoot_nest_module.uncollected = nil

    local melding_pot_module = properties[MELDING_POT_MODULE]
    melding_pot_module[ORDERS_BELOW_PROPERTY] = melding_pot_module.orders
    melding_pot_module.orders = nil
    melding_pot_module[UNCOLLECTED_ABOVE_PROPERTY] = melding_pot_module.uncollected
    melding_pot_module.uncollected = nil

    local meowcenaries_module = properties[MEOWCENARIES_MODULE]
    meowcenaries_module[STEP_ABOVE_PROPERTY] = meowcenaries_module.step
    meowcenaries_module.step = nil

    local npcs_module = properties[NPCS_MODULE]
    npcs_module[SOUVENIR_PROPERTY] = true

    local overlay_module = properties[OVERLAY_MODULE]
    overlay_module.minWidth = overlay_module.width
    overlay_module.width = nil

    local subquests_module = properties[SUBQUESTS_MODULE]
    subquests_module[ACTIVE_BELOW_PROPERTY] = subquests_module.active
    subquests_module.active = nil
    subquests_module[COMPLETED_ABOVE_PROPERTY] = subquests_module.completed
    subquests_module.completed = nil

    updated = true
  end

  if version == "1.1.0" then
    version = "1.2.0"
    properties[GLOBAL_MODULE] = {[VERSION_PROPERTY] = version}

    local overlay_module = properties[OVERLAY_MODULE]
    overlay_module[BASE_ANCHOR_PROPERTY] = overlay_module.anchor
    overlay_module.anchor = nil
    overlay_module[BASE_MIN_WIDTH_PROPERTY] = overlay_module.minWidth
    overlay_module.minWidth = nil
    overlay_module[BASE_X_PROPERTY] = overlay_module.x
    overlay_module.x = nil
    overlay_module[BASE_Y_PROPERTY] = overlay_module.y
    overlay_module.y = nil

    updated = true
  end

  if version == "1.2.0" then
    version = "1.3.0"
    properties[GLOBAL_MODULE] = {[VERSION_PROPERTY] = version}

    local overlay_module = properties[OVERLAY_MODULE]
    local order = {}

    for _, _module in ipairs(overlay_module[ORDER_PROPERTY]) do
      table.insert(order, _module >= 4 and (_module + 1) or _module)
    end

    table.insert(order, 4)
    overlay_module[ORDER_PROPERTY] = order

    updated = true
  end

  if updated then
    json.dump_file(FILE, properties)
  end
end

config.load()

return config