#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

# configuration
# @nathan-clients-minimum 1
# @nathan-clients-singular client
# @nathan-clients-plural clients

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $current_dir/utils.sh

count_clients() {
  pane=$(tmux list-panes -F "#{session_name}" | head -n 1)
  tmux list-clients -t $pane | wc -l | tr -d ' '
}

main() {
  # storing the refresh rate in the variable RATE, default is 5
  RATE=$(get_tmux_option "@nathan-refresh-rate" 5)
  clients_count=$(count_clients)
  clients_minimum=$(get_tmux_option "@nathan-clients-minimum" 1)
  if (( $clients_count >= $clients_minimum )); then
    if (( $clients_count > 1 )); then
      clients_label=$(get_tmux_option "@nathan-clients-plural" "clients")
    else
      clients_label=$(get_tmux_option "@nathan-clients-singular" "client")
    fi
    echo "$clients_count $clients_label"
  fi
  sleep $RATE
}

# run main driver
main
