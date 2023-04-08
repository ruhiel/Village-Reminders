-- Imports
local config = require("village_reminders.config")
local hooks = require("village_reminders.hooks")
local overlay = require("village_reminders.overlay")

-- Hooks
re.on_draw_ui(config.draw)

if d2d then
  d2d.register(overlay.init, overlay.draw)
else
  re.on_frame(overlay.draw)
end

hooks.init()