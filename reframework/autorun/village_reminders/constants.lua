local constants = {
  -- Anchors
  TOP_LEFT_ANCHOR = 1,
  TOP_RIGHT_ANCHOR = 2,
  BOTTOM_LEFT_ANCHOR = 3,
  BOTTOM_RIGHT_ANCHOR = 4,
  -- Enums
  VILLAGE_AREA_LABELS = {
    "カムラの里",
    "自宅",
    "オトモ広場",
    "集会所",
    "集会所 準備エリア",
    "修練場"
  },
  -- Module Labels
  ARGOSY_LABEL = "交易船",
  BUDDY_DOJO_LABEL = "オトモ道場",
  COHOOT_NEST_LABEL = "フクズクの巣",
  MARKET_LABEL = "雑貨屋とギルドストア",
  MELDING_POT_LABEL = "マカ錬金",
  MEOWCENARIES_LABEL = "オトモ隠密隊",
  NPCS_LABEL = "NPC",
  SUBQUESTS_LABEL = "フリーサイドクエスト"
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