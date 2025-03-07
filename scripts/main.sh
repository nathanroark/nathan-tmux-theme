#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

main()
{
  # set configuration option variables
  show_kubernetes_context_label=$(get_tmux_option "@nathan-kubernetes-context-label" "")
  eks_hide_arn=$(get_tmux_option "@nathan-kubernetes-eks-hide-arn" false)
  eks_extract_account=$(get_tmux_option "@nathan-kubernetes-eks-extract-account" false)
  hide_kubernetes_user=$(get_tmux_option "@nathan-kubernetes-hide-user" false)
  terraform_label=$(get_tmux_option "@nathan-terraform-label" "")
  show_fahrenheit=$(get_tmux_option "@nathan-show-fahrenheit" true)
  show_location=$(get_tmux_option "@nathan-show-location" true)
  fixed_location=$(get_tmux_option "@nathan-fixed-location")
  show_powerline=$(get_tmux_option "@nathan-show-powerline" false)
  show_flags=$(get_tmux_option "@nathan-show-flags" false)
  show_left_icon=$(get_tmux_option "@nathan-show-left-icon" smiley)
  show_left_icon_padding=$(get_tmux_option "@nathan-left-icon-padding" 1)
  show_military=$(get_tmux_option "@nathan-military-time" false)
  timezone=$(get_tmux_option "@nathan-set-timezone" "")
  show_timezone=$(get_tmux_option "@nathan-show-timezone" true)
  show_left_sep=$(get_tmux_option "@nathan-show-left-sep" )
  show_right_sep=$(get_tmux_option "@nathan-show-right-sep" )
  show_border_contrast=$(get_tmux_option "@nathan-border-contrast" false)
  show_day_month=$(get_tmux_option "@nathan-day-month" false)
  show_refresh=$(get_tmux_option "@nathan-refresh-rate" 5)
  show_synchronize_panes_label=$(get_tmux_option "@nathan-synchronize-panes-label" "Sync")
  time_format=$(get_tmux_option "@nathan-time-format" "")
  show_ssh_session_port=$(get_tmux_option "@nathan-show-ssh-session-port" false)
  IFS=' ' read -r -a plugins <<< $(get_tmux_option "@nathan-plugins" "battery network weather")
  show_empty_plugins=$(get_tmux_option "@nathan-show-empty-plugins" true)

  # # nathan Color Pallette
  # white='#f8f8f2'
  # gray='#44475a'
  # dark_gray='#282a36'
  # light_purple='#bd93f9'
  # dark_purple='#6272a4'
  # cyan='#8be9fd'
  # green='#50fa7b'
  # orange='#ffb86c'
  # red='#ff5555'
  # pink='#ff79c6'
  # yellow='#f1fa8c'

  # Nathan's Color Pallette
  # white='#f8f8f2'
  # gray='#1b1e28'
  # gray='#121214'
  # dark_gray='#121214'
  # light_purple='#bd93f9'
  # dark_purple='#44475a' # old dark purple before darker
  # dark_purple='#282a36'
  # cyan='#8be9fd'
  # blue='#85c1dc' # old blue before darker
  # blue='#5e81ac'
  # green='#98ff98' # old green before darker
  # green='#9ae0c1'
  # mint='#9ccfd8'
  # orange='#ffb86c'
  # red='#ff5555'
  # pink='#ff79c6'
  # yellow='#f1fa8c'


  # # Rosé Pine Color Palette
  # white='#e0def4'        # Text
  # gray='#121214'         # Highlight Background
  # dark_gray='#121214'    # Background
  # # gray='#6e6a86'       # Muted
  # # dark_gray='#191724'  # Base
  # light_purple='#c4a7e7' # Iris
  # dark_purple='#2a283e'  # Highlight High
  # blue='#3e8fb0'         # Pine (moon)
  # cyan='#9ccfd8'         # Foam
  # green='#31748f'        # Pine
  # orange='#f6c177'       # Gold
  # red='#eb6f92'          # Love
  # pink='#ebbcba'         # Rose
  # yellow='#f6d177'       # Subtle

  # Rosé Pine Color Palette
  white='#e0def4'        # Text
  gray='#121214'         # Highlight Background
  dark_gray='#121214'    # Background
  # gray='#6e6a86'       # Muted
  # dark_gray='#191724'  # Base
  light_purple='#c4a7e7' # Iris
  dark_purple='#2a283e'  # Highlight High
  blue='#3e8fb0'         # Pine (moon)
  cyan='#9ccfd8'         # Foam
  green='#98ff98' # old green before darker
  orange='#f6c177'       # Gold
  red='#eb6f92'          # Love
  pink='#ebbcba'         # Rose
  yellow='#f6d177'       # Subtle



  # Horizon Bright Color Palette (light mode)
  # https://github.com/Gogh-Co/Gogh/blob/master/themes/Horizon%20Bright.yml
  # white='#1c1e26 '        # Foreground Text
  # dark_gray='#1c1e26 '        # Foreground Text
  # gray='#FDF0ED'     # Background
  # light_purple='#1EAEAE'                # Highlight Background
  # dark_purple='#1EAEAE'                # Highlight Background
  # # dark_purple='#1D8991'                # Highlight Background
  # # light_purple='#FADAD1'                # Highlight Background
  # # dark_purple='#FADAD1'                # Highlight Background
  # # green='#1EB980'         # Green
  # green='#07DA8C'         # Light Green
  # orange='#FFB454'        # Orange
  # red='#FF5370'           # Red
  # # light_magenta='#EE64AE'  # Red
  # # magenta='#F075B7'   # Red
  #


  # Handle left icon configuration
  case $show_left_icon in
    smiley)
      left_icon="☺" ;;
    session)
      left_icon="#S" ;;
    window)
      left_icon="#W" ;;
    hostname)
      left_icon="#H" ;;
    shortname)
      left_icon="#h" ;;
    *)
      left_icon=$show_left_icon ;;
  esac

  # Handle left icon padding
  padding=""
  if [ "$show_left_icon_padding" -gt "0" ]; then
    padding="$(printf '%*s' $show_left_icon_padding)"
  fi
  left_icon="$left_icon$padding"

  # Handle powerline option
  if $show_powerline; then
    right_sep="$show_right_sep"
    left_sep="$show_left_sep"
  fi

  # Set timezone unless hidden by configuration
  if [[ -z "$timezone" ]]; then
    case $show_timezone in
      false)
        timezone="" ;;
      true)
        timezone="#(date +%Z)" ;;
    esac
  fi

  case $show_flags in
    false)
      flags=""
      current_flags="" ;;
    true)
      flags="#{?window_flags,#[fg=${dark_purple}]#{window_flags},}"
      current_flags="#{?window_flags,#[fg=${light_purple}]#{window_flags},}"
  esac

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval $show_refresh

  # set the prefix + t time format
  if $show_military; then
    tmux set-option -g clock-mode-style 24
  else
    tmux set-option -g clock-mode-style 12
  fi

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # pane border styling
  if $show_border_contrast; then
    tmux set-option -g pane-active-border-style "fg=${light_purple}"
  else
    tmux set-option -g pane-active-border-style "fg=${dark_purple}"
  fi
  tmux set-option -g pane-border-style "fg=${gray}"

  # message styling
  tmux set-option -g message-style "bg=${gray},fg=${white}"

  # status bar
  tmux set-option -g status-style "bg=${gray},fg=${white}"

  # Status left
  if $show_powerline; then
    # tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon} #[fg=${green},bg=${gray}]#{?client_prefix,#[fg=${yellow}],}${left_sep}"
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${orange}],} ${left_icon} #[fg=${green},bg=${gray}]#{?client_prefix,#[fg=${orange}],}${left_sep}"
    powerbg=${gray}
  else
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${orange}],} ${left_icon}"
  fi

  # Status right
  tmux set-option -g status-right ""

  for plugin in "${plugins[@]}"; do

  if case $plugin in custom:*) true;; *) false;; esac; then
      script=${plugin#"custom:"}
      if [[ -x "${current_dir}/${script}" ]]; then
        IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-custom-plugin-colors" "cyan dark_gray")
        script="#($current_dir/${script})"
      else
        colors[0]="red"
        colors[1]="dark_gray"
        script="${script} not found!"
      fi

    elif [ $plugin = "cwd" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@nathan-cwd-colors" "dark_gray white")
      tmux set-option -g status-right-length 250
      script="#($current_dir/cwd.sh)"

    elif [ $plugin = "fossil" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@nathan-fossil-colors" "green dark_gray")
      tmux set-option -g status-right-length 250
      script="#($current_dir/fossil.sh)"

    elif [ $plugin = "git" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@nathan-git-colors" "green dark_gray")
      tmux set-option -g status-right-length 250
      script="#($current_dir/git.sh)"

    elif [ $plugin = "hg" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@nathan-hg-colors" "green dark_gray")
      tmux set-option -g status-right-length 250
      script="#($current_dir/hg.sh)"

    elif [ $plugin = "battery" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-battery-colors" "pink dark_gray")
      script="#($current_dir/battery.sh)"

    elif [ $plugin = "gpu-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-gpu-usage-colors" "pink dark_gray")
      script="#($current_dir/gpu_usage.sh)"

    elif [ $plugin = "gpu-ram-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-gpu-ram-usage-colors" "cyan dark_gray")
      script="#($current_dir/gpu_ram_info.sh)"

    elif [ $plugin = "gpu-power-draw" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-gpu-power-draw-colors" "green dark_gray")
      script="#($current_dir/gpu_power.sh)"

    elif [ $plugin = "cpu-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-cpu-usage-colors" "orange dark_gray")
      script="#($current_dir/cpu_info.sh)"

    elif [ $plugin = "ram-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-ram-usage-colors" "cyan dark_gray")
      script="#($current_dir/ram_info.sh)"

    elif [ $plugin = "tmux-ram-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-tmux-ram-usage-colors" "cyan dark_gray")
      script="#($current_dir/tmux_ram_info.sh)"

    elif [ $plugin = "network" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-network-colors" "cyan dark_gray")
      script="#($current_dir/network.sh)"

    elif [ $plugin = "network-bandwidth" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-network-bandwidth-colors" "cyan dark_gray")
      tmux set-option -g status-right-length 250
      script="#($current_dir/network_bandwidth.sh)"

    elif [ $plugin = "network-ping" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-network-ping-colors" "cyan dark_gray")
      script="#($current_dir/network_ping.sh)"

    elif [ $plugin = "network-vpn" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-network-vpn-colors" "cyan dark_gray")
      script="#($current_dir/network_vpn.sh)"

    elif [ $plugin = "attached-clients" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-attached-clients-colors" "cyan dark_gray")
      script="#($current_dir/attached_clients.sh)"

    elif [ $plugin = "mpc" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-mpc-colors" "green dark_gray")
      script="#($current_dir/mpc.sh)"

    elif [ $plugin = "spotify-tui" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-spotify-tui-colors" "green dark_gray")
      script="#($current_dir/spotify-tui.sh)"

    elif [ $plugin = "kubernetes-context" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-kubernetes-context-colors" "cyan dark_gray")
      script="#($current_dir/kubernetes_context.sh $eks_hide_arn $eks_extract_account $hide_kubernetes_user $show_kubernetes_context_label)"

    elif [ $plugin = "terraform" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-terraform-colors" "light_purple dark_gray")
      script="#($current_dir/terraform.sh $terraform_label)"

    elif [ $plugin = "continuum" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@nathan-continuum-colors" "cyan dark_gray")
      script="#($current_dir/continuum.sh)"

    elif [ $plugin = "weather" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-weather-colors" "orange dark_gray")
      script="#($current_dir/weather_wrapper.sh $show_fahrenheit $show_location $fixed_location)"

    elif [ $plugin = "time" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-time-colors" "dark_purple white")
      if [ -n "$time_format" ]; then
        script=${time_format}
      else
        if $show_day_month && $show_military ; then # military time and dd/mm
          script="%a %d/%m %R ${timezone} "
        elif $show_military; then # only military time
          script="%a %m/%d %R ${timezone} "
        elif $show_day_month; then # only dd/mm
          script="%a %d/%m %I:%M %p ${timezone} "
        else
          script="%a %m/%d %I:%M %p ${timezone} "
        fi
      fi
    elif [ $plugin = "synchronize-panes" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-synchronize-panes-colors" "cyan dark_gray")
      script="#($current_dir/synchronize_panes.sh $show_synchronize_panes_label)"

    elif [ $plugin = "ssh-session" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@nathan-ssh-session-colors" "green dark_gray")
      script="#($current_dir/ssh_session.sh $show_ssh_session_port)"

    else
      continue
    fi

    if $show_powerline; then
      if $show_empty_plugins; then
        tmux set-option -ga status-right "#[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
      else
        tmux set-option -ga status-right "#{?#{==:$script,},,#[fg=${!colors[0]},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script }"
      fi
      powerbg=${!colors[0]}
    else
      if $show_empty_plugins; then
        tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
      else
        tmux set-option -ga status-right "#{?#{==:$script,},,#[fg=${!colors[1]},bg=${!colors[0]}] $script }"
      fi
    fi
  done

  # Window option
  if $show_powerline; then
    tmux set-window-option -g window-status-current-format "#[fg=${gray},bg=${dark_purple}]${left_sep}#[fg=${white},bg=${dark_purple}] #I #W${current_flags} #[fg=${dark_purple},bg=${gray}]${left_sep}"
  else
    tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${dark_purple}] #I #W${current_flags} "
  fi

  tmux set-window-option -g window-status-format "#[fg=${white}]#[bg=${gray}] #I #W${flags}"
  tmux set-window-option -g window-status-activity-style "bold"
  tmux set-window-option -g window-status-bell-style "bold"
}

# run main function
main
