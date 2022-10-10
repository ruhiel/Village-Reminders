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
  ARGOSY_LABEL = "交易船",
  BUDDY_DOJO_LABEL = "オトモ道場",
  COHOOT_NEST_LABEL = "フクズクの巣",
  ITEMS_LABEL = "アイテム",
  MARKET_LABEL = "雑貨屋",
  MELDING_POT_LABEL = "マカ錬金",
  MEOWCENARIES_LABEL = "オトモ隠密隊",
  NPCS_LABEL = "NPC",
  SUBQUESTS_LABEL = "フリーサイドクエスト",
  -- Rare Finds
  RARE_FINDS_ITEMS = {
    [68158516] = "ベルナストーン",
    [68157913] = "強走薬",
    [68158517] = "ドンドルマリン",
    [68157603] = "閃光玉",
    [68158148] = "落陽草の花",
    [68158222] = "ドスキレアジ",
    [68157803] = "ケルビの角",
    [68158518] = "ロックラック鉱",
    [68158520] = "ミナガルデナイト",
    [68157677] = "アルビノエキス",
    [68157563] = "落とし穴",
    [68157444] = "シビレ罠",
    [68157933] = "音爆弾",
    [68157910] = "サシミウオ",
    [68158519] = "バルバレクォーツ",
    [68157939] = "キレアジ"
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