-- WezTerm custom shortcut reference (Linux).
--
-- Workspaces
-- Ctrl+Shift+N          Create or switch workspace (prompt for name)
-- Ctrl+Shift+P          Open workspace picker
-- Ctrl+Alt+[            Previous workspace
-- Ctrl+Alt+]            Next workspace
-- Ctrl+Alt+LeftArrow    Previous workspace (alternate)
-- Ctrl+Alt+RightArrow   Next workspace (alternate)
-- Ctrl+Alt+M            Jump to "main" workspace
-- Ctrl+Alt+Shift+W      Delete current workspace (moves windows to "main")
--
-- Tabs
-- Ctrl+Shift+T          New tab
-- Ctrl+Shift+O          Tab navigator
-- Ctrl+Shift+W          Close current tab (with confirmation)
--
-- Panes
-- Ctrl+Shift+[          Previous pane
-- Ctrl+Shift+]          Next pane
-- Ctrl+Alt+h/j/k/l      Focus pane left/down/up/right
-- Ctrl+Alt+P            Pane selector
-- Ctrl+Alt+W            Close current pane (with confirmation)
--
-- Font size
-- Ctrl++                Increase font size
-- Ctrl+-                Decrease font size
-- Ctrl+0                Reset font size

local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

local DEFAULT_WORKSPACE = "main"
local HOME_DIR = os.getenv("HOME") or ""

local LIGHT_BG = "#f4f4f4"
local LIGHT_BG_SOFT = "#ececec"
local LIGHT_FG = "#3e3e3e"
local LIGHT_MUTED = "#6a737d"
local LIGHT_ACCENT = "#2f6feb"
local LIGHT_SELECTION = "#c9def5"

local STATUS_BG = LIGHT_BG
local STATUS_PILL_BG = LIGHT_BG_SOFT
local STATUS_PILL_FG = LIGHT_MUTED
local STATUS_PILL_ACTIVE_BG = LIGHT_ACCENT
local STATUS_PILL_ACTIVE_FG = "#ffffff"

local function decode_uri_component(path)
  return (path:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

local function cwd_uri_to_path(cwd_uri)
  if not cwd_uri then
    return nil
  end

  if type(cwd_uri) == "table" and cwd_uri.file_path then
    return cwd_uri.file_path
  end

  local uri = tostring(cwd_uri)
  if uri == "" then
    return nil
  end

  local path = uri
    :gsub("^file://[^/]*", "")
    :gsub("^file://", "")
  return decode_uri_component(path)
end

local function format_home_relative(path)
  if not path or path == "" then
    return nil
  end

  if HOME_DIR ~= "" then
    if path == HOME_DIR then
      return "~"
    end

    local home_prefix = HOME_DIR .. "/"
    if path:sub(1, #home_prefix) == home_prefix then
      return "~/" .. path:sub(#home_prefix + 1)
    end
  end

  return path
end

local function sorted_workspaces()
  local names = mux.get_workspace_names()
  table.sort(names, function(a, b)
    if a == DEFAULT_WORKSPACE then return true end
    if b == DEFAULT_WORKSPACE then return false end
    return a:lower() < b:lower()
  end)
  return names
end

local function switch_workspace_relative(window, pane, delta)
  local target_pane = window:active_pane() or pane
  if not target_pane then return end
  window:perform_action(act.SwitchWorkspaceRelative(delta), target_pane)
end

local function delete_active_workspace(window, pane)
  local current = window:active_workspace()
  if current == DEFAULT_WORKSPACE then
    window:toast_notification("WezTerm", "Cannot delete '" .. DEFAULT_WORKSPACE .. "' workspace", nil, 3000)
    return
  end

  local moved = 0
  for _, mux_window in ipairs(mux.all_windows()) do
    if mux_window:get_workspace() == current then
      mux_window:set_workspace(DEFAULT_WORKSPACE)
      moved = moved + 1
    end
  end

  local target_pane = window:active_pane() or pane
  if target_pane then
    window:perform_action(act.SwitchToWorkspace { name = DEFAULT_WORKSPACE }, target_pane)
  end

  window:toast_notification(
    "WezTerm",
    "Workspace '" .. current .. "' deleted (" .. tostring(moved) .. " window(s) moved to '" .. DEFAULT_WORKSPACE .. "')",
    nil,
    4000
  )
end

local function push_format(out, item)
  out[#out + 1] = item
end

local function push_text(out, text)
  push_format(out, { Text = text })
end

local function push_pill(out, text, opts)
  local bg = opts and opts.bg or STATUS_PILL_BG
  local fg = opts and opts.fg or STATUS_PILL_FG
  local bold = opts and opts.bold

  push_format(out, { Background = { Color = bg } })
  push_format(out, { Foreground = { Color = fg } })
  if bold then
    push_format(out, { Attribute = { Intensity = "Bold" } })
  end
  push_text(out, " " .. text .. " ")
  if bold then
    push_format(out, { Attribute = { Intensity = "Normal" } })
  end

  push_format(out, { Background = { Color = STATUS_BG } })
  push_format(out, { Foreground = { Color = STATUS_PILL_FG } })
  push_text(out, " ")
end

local function workspace_display_list(names, active, max_items)
  max_items = max_items or 8

  local ordered = {}
  local seen = {}

  local function add(name)
    if not name or name == "" or seen[name] then
      return
    end
    seen[name] = true
    ordered[#ordered + 1] = name
  end

  for _, name in ipairs(names) do
    if name == DEFAULT_WORKSPACE then
      add(name)
      break
    end
  end
  add(active)

  for _, name in ipairs(names) do
    if #ordered >= max_items then
      break
    end
    add(name)
  end

  local truncated = #names > #ordered
  return ordered, truncated
end

wezterm.on("update-status", function(window, pane)
  local active_ws = window:active_workspace()
  local names = sorted_workspaces()
  local display, truncated = workspace_display_list(names, active_ws, 9)

  local left = {}
  push_format(left, { Background = { Color = STATUS_BG } })
  push_format(left, { Foreground = { Color = STATUS_PILL_FG } })
  push_text(left, " ")

  for _, name in ipairs(display) do
    if name == active_ws then
      push_pill(left, name, { bg = STATUS_PILL_ACTIVE_BG, fg = STATUS_PILL_ACTIVE_FG, bold = true })
    else
      push_pill(left, name, { bg = STATUS_PILL_BG, fg = STATUS_PILL_FG })
    end
  end

  if truncated then
    push_pill(left, "...", { bg = STATUS_BG, fg = STATUS_PILL_FG })
  end

  window:set_left_status(wezterm.format(left))

  local right = {}
  push_format(right, { Background = { Color = STATUS_BG } })
  push_format(right, { Foreground = { Color = STATUS_PILL_FG } })
  push_text(right, "Ctrl+Shift+P workspaces | Ctrl+Shift+O tabs | Ctrl+Shift+W close tab  ")
  window:set_right_status(wezterm.format(right))
end)

wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
  local target_pane = window:active_pane() or pane
  if not target_pane then
    return
  end

  if button == "Right" then
    window:perform_action(
      act.ShowLauncherArgs {
        flags = "FUZZY|WORKSPACES",
        title = "Workspaces",
      },
      target_pane
    )
    return false
  end

  if button == "Middle" then
    window:perform_action(act.ShowTabNavigator, target_pane)
    return false
  end

  window:perform_action(default_action, target_pane)
  return false
end)

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  local pane = tab.active_pane
  local cwd_path = pane and cwd_uri_to_path(pane.current_working_dir)
  local title = format_home_relative(cwd_path) or (pane and pane.title) or "shell"
  local padded = " " .. wezterm.truncate_right(title, math.max(max_width - 2, 1)) .. " "
  return padded
end)

return {
  default_workspace = DEFAULT_WORKSPACE,

  color_scheme = "Atelierheath (dark) (terminal.sexy)",
  font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
  font_size = 10.0,
  line_height = 1.15,
  window_background_opacity = 1.0,
  text_background_opacity = 1.0,

  window_padding = {
    left = 10,
    right = 10,
    top = 8,
    bottom = 8,
  },

  default_cursor_style = "BlinkingBar",
  command_palette_bg_color = LIGHT_BG,
  command_palette_fg_color = LIGHT_FG,
  pane_select_bg_color = LIGHT_BG,
  pane_select_fg_color = LIGHT_FG,
  char_select_bg_color = LIGHT_BG,
  char_select_fg_color = LIGHT_FG,

  colors = {
    foreground = LIGHT_FG,
    background = "#fdfdfd",
    cursor_bg = LIGHT_ACCENT,
    cursor_fg = "#ffffff",
    cursor_border = LIGHT_ACCENT,
    selection_bg = LIGHT_SELECTION,
    selection_fg = LIGHT_FG,
    tab_bar = {
      background = LIGHT_BG,
      active_tab = {
        bg_color = "#ffffff",
        fg_color = LIGHT_FG,
        intensity = "Bold",
      },
      inactive_tab = {
        bg_color = LIGHT_BG_SOFT,
        fg_color = LIGHT_MUTED,
      },
      inactive_tab_hover = {
        bg_color = "#dfe6ef",
        fg_color = LIGHT_FG,
      },
      new_tab = {
        bg_color = LIGHT_BG,
        fg_color = LIGHT_FG,
      },
      new_tab_hover = {
        bg_color = "#dfe6ef",
        fg_color = LIGHT_FG,
      },
    },
  },

  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = true,
  tab_max_width = 32,

  keys = {
    {
      key = "N",
      mods = "CTRL|SHIFT",
      action = act.PromptInputLine {
        description = "Workspace name (create/switch)",
        action = wezterm.action_callback(function(window, pane, line)
          if line and #line > 0 then
            local target_pane = window:active_pane() or pane
            if not target_pane then return end
            window:perform_action(act.SwitchToWorkspace { name = line }, target_pane)
          end
        end),
      },
    },
    {
      key = "P",
      mods = "CTRL|SHIFT",
      action = act.ShowLauncherArgs {
        flags = "FUZZY|WORKSPACES",
        title = "Workspaces",
      },
    },
    { key = "O", mods = "CTRL|SHIFT", action = act.ShowTabNavigator },
    {
      key = "[",
      mods = "CTRL|ALT",
      action = wezterm.action_callback(function(window, pane)
        switch_workspace_relative(window, pane, -1)
      end),
    },
    {
      key = "]",
      mods = "CTRL|ALT",
      action = wezterm.action_callback(function(window, pane)
        switch_workspace_relative(window, pane, 1)
      end),
    },
    {
      key = "LeftArrow",
      mods = "CTRL|ALT",
      action = wezterm.action_callback(function(window, pane)
        switch_workspace_relative(window, pane, -1)
      end),
    },
    {
      key = "RightArrow",
      mods = "CTRL|ALT",
      action = wezterm.action_callback(function(window, pane)
        switch_workspace_relative(window, pane, 1)
      end),
    },
    { key = "M", mods = "CTRL|ALT", action = act.SwitchToWorkspace { name = DEFAULT_WORKSPACE } },
    { key = "[", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Prev" },
    { key = "]", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Next" },
    { key = "h", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Left" },
    { key = "l", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Right" },
    { key = "k", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Up" },
    { key = "j", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Down" },
    { key = "p", mods = "CTRL|ALT", action = act.PaneSelect },
    { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab "CurrentPaneDomain" },
    { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab { confirm = true } },
    { key = "w", mods = "CTRL|ALT", action = act.CloseCurrentPane { confirm = true } },
    {
      key = "W",
      mods = "CTRL|ALT|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        delete_active_workspace(window, pane)
      end),
    },
    { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },
  },

  status_update_interval = 1000,
}
