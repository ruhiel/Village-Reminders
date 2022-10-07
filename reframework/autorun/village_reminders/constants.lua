local constants = {
  -- Anchors
  TOP_LEFT_ANCHOR = 1,
  TOP_RIGHT_ANCHOR = 2,
  BOTTOM_LEFT_ANCHOR = 3,
  BOTTOM_RIGHT_ANCHOR = 4,
  -- Enums
  VILLAGE_AREA_LABELS = {
    "Steelworks (Kamura)",
    "Buddy Plaza (Kamura)",
    "Training Area (Kamura)",
    "Your Room (Kamura)",
    "Village Entrance (Kamura)",
    "Gathering Hub Entrance (Kamura)",
    "Hub Prep Area (Kamura)",
    "Gathering Hub (Kamura)",
    "Central Plaza (Elgado)",
    "Command Post (Elgado)",
    "Tea Shop (Elgado)",
    "Docks (Elgado)",
    "Your Room (Elgado)",
    "Market (Elgado)"
  },
  -- Module Labels
  ARGOSY_LABEL = "Argosy",
  BUDDY_DOJO_LABEL = "Buddy Dojo",
  COHOOT_NEST_LABEL = "Cohoot Nest",
  ITEMS_LABEL = "Items",
  MARKET_LABEL = "Market & Guild Store",
  MELDING_POT_LABEL = "Melding Pot",
  MEOWCENARIES_LABEL = "Meowcenaries",
  NPCS_LABEL = "NPCs",
  SUBQUESTS_LABEL = "Subquests",
  -- Rare Finds
  RARE_FINDS_ITEMS = {
    [68158516] = "Bhernastone",
    [68157913] = "Dash Juice",
    [68158517] = "Dundormarin",
    [68157603] = "Flash Bomb",
    [68158148] = "Gloamgrass Bud",
    [68158222] = "Great Whetfish",
    [68157803] = "Kelbi Horn",
    [68158518] = "Loc Lac Ore",
    [68158520] = "Minegardenite",
    [68157677] = "Pale Extract",
    [68157563] = "Pitfall Trap",
    [68157444] = "Shock Trap",
    [68157933] = "Sonic Bomb",
    [68157910] = "Sushifish",
    [68158519] = "Val Habar Quartz",
    [68157939] = "Whetfish"
  },
  RARE_FINDS_ORDER = {
    68158516,
    68157913,
    68158517,
    68157603,
    68158148,
    68158222,
    68157803,
    68158518,
    68158520,
    68157677,
    68157563,
    68157444,
    68157933,
    68157910,
    68158519,
    68157939
  },
  -- Reminder Modes
  ALWAYS_REMINDER_MODE = 1,
  THRESHOLD_REMINDER_MODE = 2,
  NEVER_REMINDER_MODE = 3
}

constants.MODULE_LABELS = {
  constants.ARGOSY_LABEL,
  constants.BUDDY_DOJO_LABEL,
  constants.COHOOT_NEST_LABEL,
  constants.ITEMS_LABEL,
  constants.MARKET_LABEL,
  constants.MELDING_POT_LABEL,
  constants.MEOWCENARIES_LABEL,
  constants.NPCS_LABEL,
  constants.SUBQUESTS_LABEL
}

return constants