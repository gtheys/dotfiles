#!/usr/bin/env bash

# Automatically install purchased apps from the Mac App Store

mas signout

read -r -t 60 -p "What is yout Apple ID?: " appleid
login_to_Mac_App_Store
#mas signin --dialog "$appleid"

# Mac App Store apps to install
apps=(
    "iThoughtsX:720669838"
    "Kaleidoscope:587512244"
    "TaskPaper:1090940630"
    "BetterSnapTool:417375580"
    "Magnet:441258766"
    "Dropzone 3:695406827"
    "Pixelmator:407963104"
    "Tweetbot:557168941"
    "DaisyDisk:411643860"
    "Deckset:847496013"
    "SQLPro for SQLite (Lite):635299994"
    "iMovie:635299994"
    "Alternote:974971992"
    "Day One:1055511498"
    "NotePlan:1137020764"
)

for app in "${apps[@]}"; do
    name=${app%%:*}
    id=${app#*:}

    echo -e "Attempting to install $name"
    mas install "$id"
done