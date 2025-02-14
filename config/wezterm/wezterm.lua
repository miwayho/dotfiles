local wezterm = require 'wezterm'

return {
  enable_tab_bar = false,
  adjust_window_size_when_changing_font_size = true,
  warn_about_missing_glyphs = false,
  
  font = wezterm.font("FiraCode Nerd Font"),
  font_size = 16.0,
  
  colors = {
    ansi = {
      "#100F0F", -- Black
      "#AF3029", -- Red
      "#66800B", -- Green
      "#AD8301", -- Yellow
      "#205EA6", -- Blue
      "#5E409D", -- Purple
      "#24837B", -- Cyan
      "#CECDC3", -- White
    },
    brights = {
      "#575653", -- Black
      "#D14D41", -- Red
      "#879A39", -- Green
      "#D0A215", -- Yellow
      "#4385BE", -- Blue
      "#8B7EC8", -- Purple
      "#3AA99F", -- Cyan
      "#FFFCF0", -- White
    },
    foreground = "#CECDC3",
    background = "#1C1B1A",
    cursor_bg = "#CECDC3",
    cursor_border = "#CECDC3",
    cursor_fg = "#100F0F",
    selection_bg = "#282726",
    selection_fg = "#CECDC3",
    indexed = {},
  },
}
