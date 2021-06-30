local themes_path = string.format("%s/.config/awesome/themes/%s", os.getenv("HOME"), "sleek")
local dpi = require("beautiful.xresources").apply_dpi

local theme = {}

theme.wallpaper     = "~/.config/awesome/themes/sleek/background.jpg"

theme.fg_normal     = "#ffffff"
theme.fg_focus      = "#000000"
theme.bg_normal     = "#000000"
theme.bg_focus      = "#ffffff"

theme.border_normal	= "#000000"
theme.border_focus	= "#000000"

theme.useless_gap 	= dpi(5)
theme.border_width	= dpi(0)

return theme
