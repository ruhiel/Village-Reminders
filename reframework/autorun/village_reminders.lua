-- Imports
local config = require("village_reminders.config")
local hooks = require("village_reminders.hooks")
local overlay = require("village_reminders.overlay")

-- Hooks
re.on_draw_ui(config.draw)
d2d.register(overlay.init, overlay.draw)
hooks.init()