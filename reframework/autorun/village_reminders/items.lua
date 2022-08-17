
-- Constants
local GUI_ITEM_POUCH_WINDOW_TYPE = "snow.gui.GuiItemPouchWindow"

-- Memo
local gui_item_pouch_window_type_def = sdk.find_type_definition(GUI_ITEM_POUCH_WINDOW_TYPE)
local do_open_method = gui_item_pouch_window_type_def:get_method("doOpen")

-- Module
local items = {
  status = {
    dirty_pouch = true
  }
}

function items.hook()
  sdk.hook(do_open_method, nil, function()
    items.status.dirty_pouch = false
  end)
end

function items.init()
  items.status.dirty_pouch = true
end

return items