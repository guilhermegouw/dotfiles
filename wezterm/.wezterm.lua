local wezterm = require 'wezterm'
local act = wezterm.action

local my_leader = { key = "Space", mods = "CTRL" }
local leader_active = false

-- STATUS BAR
wezterm.on('update-status', function(window)
  local SOLID_LEFT_ROUND = utf8.char(0xe0b6)
  local date = wezterm.strftime("%Y-%m-%d");
  local time = wezterm.strftime("%H:%M:%S")

  local color_scheme = window:effective_config().resolved_palette
  local bg = color_scheme.background
  local fg = color_scheme.foreground
  local calendar_bg = "#f5c2e7"
  local clock_bg = "#a6e3a1"
  local icon_fg = "#000000"
  local text_fg = "#ffffff"
  local default_bg = "#1e1e2e"

  window:set_right_status(wezterm.format({
     -- 📅 Calendar Section (Rounded Left)
    { Background = { Color = default_bg } }, 
    { Foreground = { Color = calendar_bg } }, { Text = SOLID_LEFT_ROUND }, -- Rounded edge
    { Background = { Color = calendar_bg } }, { Foreground = { Color = icon_fg } }, { Text = "" .. utf8.char(0xf073) .. " " }, -- Calendar icon
    { Background = { Color = default_bg } }, { Foreground = { Color = text_fg } }, { Text = " " .. date .. "  " }, -- Date text

    -- ⏰ Clock Section (Rounded Left)
    { Background = { Color = default_bg } }, 
    { Foreground = { Color = clock_bg } }, { Text = SOLID_LEFT_ROUND }, -- Rounded edge
    { Background = { Color = clock_bg } }, { Foreground = { Color = icon_fg } }, { Text = "" .. utf8.char(0xf017) .. " " }, -- Clock icon
    { Background = { Color = default_bg } }, { Foreground = { Color = text_fg } }, { Text = " " .. time .. "  " }, -- Time text
  }))
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local bg_color = tab.is_active and "#1e1e2e" or "#1e1e2e"  -- Keep standard background
  local fg_color = tab.is_active and "#ffffff" or "#cdd6f4"  -- White for active, dimmed for inactive

  local number_bg = tab.is_active and "#fab387" or "#89b4fa"  -- Orange for active, Blue for inactive
  local number_fg = "#000000"  -- Black text for tab number

  return {
    { Background = { Color = number_bg } }, { Foreground = { Color = number_fg } }, { Text = " " .. (tab.tab_index + 1) .. " " },
    { Background = { Color = bg_color } }, { Foreground = { Color = fg_color } }, { Text = " " .. tab.active_pane.title .. " " },
  }
end)

return {
  leader = my_leader,

    keys = {
    {
      key = my_leader.key,
      mods = my_leader.mods,
      action = wezterm.action_callback(function(window, pane)
        leader_active = true
        window:perform_action(act.ClearScrollback("ScrollbackAndViewport"), pane)
        wezterm.sleep_ms(1000) -- Leader key active for 1 second
        leader_active = false
      end),
    },

    -- PANES NAVIGATION
    { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") }, -- Like `Ctrl + Space, c` in tmux
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") }, -- Move left
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") }, -- Move right
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") }, -- Move down
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") }, -- Move up
    { key = "|", mods = "LEADER", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } }, -- Like `Ctrl + Space, %`
    { key = '-', mods = "LEADER", action = act.SplitVertical { domain = "CurrentPaneDomain" } }, -- Like `Ctrl + Space, "`
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = true } }, -- Close pane
    -- TABS NAVIGATION
    { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
    { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
    { key = "9", mods = "LEADER", action = act.ActivateTab(8) },
    { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "r", mods = "LEADER", action = act.PromptInputLine {
        description = "Rename Tab",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }
    },
    -- CLIPBOARD CONFIG
    { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
    { key = "]", mods = "LEADER", action = act.PasteFrom("Clipboard") },
    { key = "y", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  },
  mouse_bindings = {
    {
      event = { Down = { streak = 3, button = "Left" } },
      action = act.SelectTextAtMouseCursor("Word"),
      mods = "NONE",
    },
    {
      event = { Up = { streak = 1, button = "Left" } },
      action = act.CompleteSelection("Clipboard"),
      mods = "NONE",
    },
  },

  colors = {
    tab_bar = {
      background = "#1e1e2e",
      active_tab = {
        bg_color = "#1e1e2e",
        fg_color = "#ffffff",
      },
      inactive_tab = {
        bg_color = "#1e1e2e",
        fg_color = "#cdd6f4",
      },
    },
  },

  font = wezterm.font("ComicShannsMono Nerd Font Mono"),
  font_size = 14.0,
  color_scheme = "Catppuccin Mocha",
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  use_fancy_tab_bar = false,
}

