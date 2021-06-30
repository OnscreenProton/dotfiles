pcall(require, "luarocks.loader")

-- Awesome libary
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- Theme name
local theme = "sleek"

if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors })
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err) })
		in_error = false
	end)
end

-- Variables
beautiful.init("~/.config/awesome/themes/" .. theme .. "/theme.lua")

terminal = "alacritty"
editor = "micro"
editor_cmd = terminal .. " -e " .. editor

-- Set modkey to Mod4
modkey = "Mod4"

-- Set layouts
awful.layout.layouts = {
	awful.layout.suit.tile.right,
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.spiral,
}

menubar.utils.terminal = terminal

textclock = wibox.widget.textclock()

local taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:mode_to_tag(t)
		end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end)
)

local function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.centered(wallpaper, s, "#000000", 0.75)
	end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)

	set_wallpaper(s)

	awful.tag({ "1", "2", "3", "4", "5", "6" ,"7", "8", "9"}, s, awful.layout.layouts[1])

	s.promptbox = awful.widget.prompt()
	s.layoutbox = awful.widget.layoutbox(s)
	s.layoutbox:buttons(gears.table.join(
			awful.button({ }, 1, function () awful.layout.inc(1) end),
			awful.button({ }, 3, function () awful.layout.inc(-1) end)))

		s.taglist = awful.widget.taglist {
			screen 	= s,
			filter 	= awful.widget.taglist.filter.all,
			buttons	= taglist_buttons
		}

		s.tasklist = awful.widget.tasklist {
			screen 	= s,
			filter 	= awful.widget.tasklist.filter.currenttags,
			buttons = tasklist_buttons
		}
		s.wibox = awful.wibar({ position = "bottom", screen = s })
		s.wibox:setup {
			layout = wibox.layout.align.horizontal,
			{
				layout = wibox.layout.fixed.horizontal,
				s.taglist,
			},
			s.tasklist,
			{
				layout = wibox.layout.fixed.horizontal,
				wibox.widget.systray(),
				-- Insert volume widget here
				-- Insert battery widget here
				textclock,
				s.layoutbox
				-- Insert logout menu widget here
			},
		}
end)

-- Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey, 			}, "d",			hotkeys_popup.show_help,
		{description = "show help", group = "awesome"}),
	awful.key({ modkey, 			}, "Left", 		awful.tag.viewprev,
		{description = "view previous", group = "tag"}),
	awful.key({ modkey, 			}, "Right",		awful.tag.viewnext,
		{description = "view next", group = "tag"}),
	awful.key({ modkey, 			}, "Escape",	awful.tag.history.restore,
		{description = "view previous", group = "tag"}),
	awful.key({ modkey, 			}, "j",
		function ()
			awful.client.focus.byidx( 1)
		end,
		{description = "focus next by index", group = "client"}),
	awful.key({ modkey, 			}, "k",
		function ()
			awful.client.focus.byidx(-1)
		end,
		{description = "focus previous by index", group = "client"}),
	awful.key({ modkey, "Shift" 	}, "j", function () awful.client.swap.byidx( 1)		end,
		{description = "swap with next client by index", group = "client"}),
	awful.key({ modkey, "Shift" 	}, "k", function () awful.client.swap.byidx(-1)		end,
		{description = "swap with previous client by index", group = "client"}),
	awful.key({ modkey, "Control" 	}, "j", function () awful.screen.focus_relative( 1)	end,
		{description = "focus the next screen", group = "screen"}),
	awful.key({ modkey, "Control" 	}, "k", function () awful.screen.focus_relative(-1)	end,
		{description = "focus the previous screen", group = "screen"}),
	awful.key({ modkey,				}, "u", awful.client.urgent.jumpto,
		{description = "jump to urgent client", group = "client"}),
	awful.key({ modkey, 			}, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = "go back", group = "client"}),
	awful.key({ modkey, 			}, "Return", function () awful.spawn(terminal) end,
		{description = "open a terminal", group = "launcher"}),
	awful.key({ modkey, "Shift" 	}, "r", awesome.restart,
		{description = "reload awesome", group = "awesome"}),
	awful.key({ modkey, "Shift"		}, "p", awesome.quit,
		{description = "quit awesome", group = "awesome"}),


	awful.key({ modkey,				}, "l",		function () awful.tag.incmwfact( 0.05)			end,
		{description = "increase master width factor", group = "layout"}),
	awful.key({ modkey, 			}, "h", 	function () awful.tag.incmwfact(-0.05)			end,
		{description = "decrease master width factor", group = "layout"}),
	awful.key({ modkey, "Shift"		}, "h", 	function () awful.tag.incnmaster( 1, nil, true)	end,
		{description = "increase the number of master clients", group = "layout"}),
	awful.key({ modkey, "Shift"		}, "l", 	function () awful.tag.incnmaster(-1, nil, true)	end,
		{description = "decrease the number of master clients", group = "layout"}),
	awful.key({ modkey, "Control"	}, "h", 	function () awful.tag.incncol( 1, nil, true)	end,
		{description = "increase the number of columns", group = "layout"}),
	awful.key({ modkey, "Control"	}, "l", 	function () awful.tag.incncol(-1, nil, true)	end,
		{description = "decrease the number of columns", group = "layout"}),
	awful.key({ modkey, 			}, "space", function () awful.layout.inc( 1)				end,
		{description = "select next", group = "layout"}),
	awful.key({ modkey, "Shift"		}, "space", function () awful.layout.inc(-1)				end,
		{description = "select previous", group = "layout"}),

	awful.key({ modkey, "Control"	}, "n",
		function ()
			local c = awful.client.restore()
			if c then
				c:emit_signal(
					"request::activate", "key.unminimize", {raise = true}
				)
			end
		end,
		{description = "restore minimized", group = "client"}),

	-- Run prompt
	awful.key({ modkey }, "r", function () awful.screen.focused().promptbox:run() end,
		{description = "run prompt", group = "launcher"}),

	awful.key({ modkey }, "p", function() menubar.show() end,
		{description = "show the menubar", group = "launcher"}),

	awful.key({ modkey }, "s", function() awful.util.spawn("flameshot gui", false) end)	
)
clientkeys = gears.table.join(
	awful.key({ modkey, 			}, "f",
		function (c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{description = "toggle fullscreen", group = "client"}),
	awful.key({ modkey, "Shift"		}, "q", 		function (c) c:kill() 							end,
		{description = "close", group = "client"}),
	awful.key({ modkey, "Control"	}, "space",		awful.client.floating.toggle_tag			  	   ,
		{description = "toggle floating", group = "client"}),
	awful.key({ modkey, "Control"	}, "Return", 	function (c) c:swap(awful.client.getmaster())	end,
		{description = "move to master", group = "client"}),
	awful.key({ modkey, 			}, "o", 		function (c) c:move_to_screen()					end,
		{description = "move to screen", group = "client"}),
	awful.key({ modkey, 			}, "t",			function (c) c.ontop = not c.ontop				end,
		{description = "toggle keep on top", group = "client"}),
	awful.key({ modkey,				}, "n", 		function (c) c.minimized = true					end,
		{description = "minimize", group = "client"}),
	awful.key({ modkey, 			}, "m",
		function (c)
			c.maximized = not c.maximized
			c:raise()
		end,
		{description = "(un)maximize", group = "client"}),
	awful.key({ modkey, "Control"	}, "m",
		function (c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end,
		{description = "(un)maximize vertically", group = "client"}),
	awful.key({ modkey, "Shift"		}, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end,
		{description = "(un)maximize horizontally", group = "client"})
)

for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
			function ()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			{description = "view tag #"..i, group = "tag"}),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9,
			function ()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			{description = "toggle tag #" .. i, group = "tag"}),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
			{description = "move focused client to tag #" .. i, group = "tag"}),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end,
			{description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

clientbuttons = gears.table.join(
	awful.button({ }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
	end),
	awful.button({ modkey }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.resize(c)
	end)
)

-- Set the keys
root.keys(globalkeys)

-- Create rules
awful.rules.rules = {
	-- All client rules
	{	rule = { },
	  	properties = {	border_width = beautiful.border_width,
	  					border_color = beautiful.border_normal,
	  					focus = awful.client.focus.filter,
	  					raise = true,
	  					keys = clientkeys,
	  					buttons = clientbuttons,
	  					screen = awful.screen.perferred,
	  					placement = awful.placement.no_overlap+awful.placement.no_offscreen
	  	}
	  },

	  -- Floating clients.
	  { rule_any = {
	  	instance = {
	  		"DTA",
	  		"copyq",
	  		"pinentry",
	  	},
	  	class = {
	  		"Arandr",
	  		"Blueman-manager",
	  		"Gpick",
	  		"Kruler",
	  		"MessageWin",
	  		"Sxiv",
	  		"Tor Browser",
	  		"Wpa_gui",
	  		"veromix",
	  		"xtightvncviewer"},
	  	name = {
	  		"Event Tester",
	  	},
	  	role = {
	  		"AlarmWindow",
	  		"ConfigManager",
	  		"pop-up",
	  	}
	  }, properties = { floating = true }},

	 { rule_any = {type = { "normal", "dialog" }
	 	}, properties = { titlebars_enabled = true}
	 },
}

client.connect_signal("manage", function (c)
	if awesome.startup
		and not c.size_hints.user_position
		and not c.size_hints.program_position then
			awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
