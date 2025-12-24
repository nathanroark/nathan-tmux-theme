# Tmux Power

Yet another powerline theme for tmux.

### 📥 Installation

**Install manually**

Clone the repo somewhere and source it in `.tmux.conf`:

```tmux
run-shell "/path/to/tmux-power.tmux"
```

*NOTE: Options should be set before sourcing.*

**Install using [TPM](https://github.com/tmux-plugins/tpm)**

```tmux
set -g @plugin 'nathanroark/nathan-tmux-theme'
```
### ⚙  Customizing

You can define your favourite colors if you don't like any of above.

```tmux
# You can set it to a true color in '#RRGGBB' format
set -g @tmux_power_theme '#483D8B' # dark slate blue

# Or you can set it to 'colorX' which honors your terminal colorscheme
set -g @tmux_power_theme 'colour3'

# The following colors are used as gradient colors
set -g @tmux_power_g0 "#262626"
set -g @tmux_power_g1 "#303030"
set -g @tmux_power_g2 "#3a3a3a"
set -g @tmux_power_g3 "#444444"
set -g @tmux_power_g4 "#626262"
```

You can change the date and time formats using strftime:

```tmux
set -g @tmux_power_date_format '%F'
set -g @tmux_power_time_format '%T'
```

You can also customize the icons. As an example,
the following configurations can generate the theme shown in the first screenshot:
```bash
set -g @plugin 'nathanroark/nathan-tmux-theme'
set -g @tmux_power_theme 'everforest'
set -g @tmux_power_date_icon           ' '
set -g @tmux_power_time_icon           ' '
set -g @tmux_power_user_icon           ' '
set -g @tmux_power_session_icon        ' '
set -g @tmux_power_right_arrow_icon    ''
set -g @tmux_power_left_arrow_icon     ''
set -g @tmux_power_upload_speed_icon   '󰕒'
set -g @tmux_power_download_speed_icon '󰇚'
```

The following components can be toggled on or off:

```tmux
set -g @tmux_power_show_user    true
set -g @tmux_power_show_host    true
set -g @tmux_power_show_session true
```

*The default icons use glyphs from [nerd-fonts](https://github.com/ryanoasis/nerd-fonts).*
