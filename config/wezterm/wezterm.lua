local wezterm = require 'wezterm'

return {
    enable_tab_bar = false, 
    font_size = 18, font = wezterm.font("Iosevka Nerd Font Mono"), warn_about_missing_glyphs = false, 
    colors = {
        ansi        = {"#100F0F", "#AF3029", "#66800B", "#AD8301", "#205EA6", "#5E409D", "#24837B", "#FFFCF0"},
        brights     = {"#575653", "#D14D41", "#879A39", "#D0A215", "#4385BE", "#8B7EC8", "#3AA99F", "#FFFCF0"},
        foreground  = "#FFFCF0", background = "#100F0F",
        cursor_bg   = "#FFFCF0", cursor_fg = "#100F0F", cursor_border = "#FFFCF0",
        selection_bg = "#282726", selection_fg = "#FFFCF0"
    }
}