#!/bin/bash

i3-msg -t get_tree | jq -r '
    def truncate(s):
        if (s | length) > 20 then (s[0:17] + "...") else s end;

    [ 
        .. | select(.nodes? and .type == "workspace") as $ws
        | $ws.nodes[], $ws.floating_nodes[]
        | select(.window_properties? and .window)
        | { 
            workspace: $ws.num, 
            class: (.window_properties.class | ascii_downcase),
            name: .name
        }
    ]
    | map({
        workspace: .workspace,
        class: (
            if .class == "org.wezfurlong.wezterm" then "terminal \(truncate(.name))"
            elif .class == "telegramdesktop" then "telegram"
            elif .class == "kicad" then "kicad \(truncate(.name))"
            else truncate(.class) end
        )
    })
    | group_by(.workspace)
    | map({
        workspace: .[0].workspace,
        windows: (map(.class) | unique | join(","))
    })
    | sort_by(.workspace)
    | map("\(.workspace) \(.windows)")
    | join(" | ")
'