#!/bin/bash

# Get the current layout
current_layout=$(i3-msg -t get_workspaces | jq '.[] | select(.focused == true) | .layout' | tr -d '"')

# Toggle between 'splitv' and 'splith'
if [ "$current_layout" == "splitv" ]; then
    i3-msg split h
else
    i3-msg split v
fi

