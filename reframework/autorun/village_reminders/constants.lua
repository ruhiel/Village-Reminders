local constants = {
  -- Anchors
  TOP_LEFT_ANCHOR = 1,
  TOP_RIGHT_ANCHOR = 2,
  BOTTOM_LEFT_ANCHOR = 3,
  BOTTOM_RIGHT_ANCHOR = 4,
  -- Enums
  VILLAGE_AREA_LABELS = {
    "Village (Outside)",
    "Your Room",
    "Buddy Plaza",
    "Gathering Hall",
    "Hub Prep Area",
    "Training Area"
  },
  -- Module Labels
  ARGOSY_LABEL = "Argosy",
  BUDDY_DOJO_LABEL = "Buddy Dojo",
  COHOOT_NEST_LABEL = "Cohoot Nest",
  MARKET_LABEL = "Market & Guild Store",
  MELDING_POT_LABEL = "Melding Pot",
  MEOWCENARIES_LABEL = "Meowcenaries",
  NPCS_LABEL = "NPCs",
  SUBQUESTS_LABEL = "Subquests"
}

constants.MODULE_LABELS = {
  constants.ARGOSY_LABEL,
  constants.BUDDY_DOJO_LABEL,
  constants.COHOOT_NEST_LABEL,
  constants.MARKET_LABEL,
  constants.MELDING_POT_LABEL,
  constants.MEOWCENARIES_LABEL,
  constants.NPCS_LABEL,
  constants.SUBQUESTS_LABEL
}

return constants