#!/bin/bash

i3-msg -t get_tree | jq -r '
    [ 
        .. | select(.nodes? and .type == "workspace") as $ws
        | $ws.nodes[], $ws.floating_nodes[]
        | select(.window_properties? and .window)
        | { workspace: $ws.num, class: (.window_properties.class | if . == "org.wezfurlong.wezterm" then "terminal" else . end | ascii_downcase) }
    ]
    | group_by(.class)
    | map({class: .[0].class, workspaces: map(.workspace) | unique | join(",")})
    | map("\(.workspaces) \(.class)")
    | join(" | ")
'
