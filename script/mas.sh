#!/usr/bin/env bash

# Automatically install purchased apps from the Mac App Store

mas signout

login_to_Mac_App_Store () {
#	Attempt at workaround for High Sierra error that prevents logging into Mac App Store
#		See Mike Ratcliffe, https://github.com/mas-cli/mas/issues/107#issuecomment-335514316

# Test if signed in. If not, launch MAS and sign in.

until (mas account > /dev/null); # If signed in, drop to outer "done"
do
#	If here, not logged in

	echo -e "You are not yet logged into the Mac App Store."
	echo -e "I will launch the Mac App Store now."
	echo -e "\nPlease log in to the Mac App Store..."
	open -a "/Applications/App Store.app"

#	until loop waits patiently until scriptrunner signs into Mac App Store
	until (mas account > /dev/null);
	do
		sleep 3
    	echo -e "… zzz …."
  	done	
done
echo -e "You are signed into the Mac App Store."
signed_in_user=$(mas account)
echo -e "MAS user name: $signed_in_user"
}

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