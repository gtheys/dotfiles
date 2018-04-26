#!/usr/bin/env bash

EXTENSIONS=(
 "AleksandarDev.vscode-sequence-diagrams" \
 "CoenraadS.bracket-pair-colorizer" \
 "Dart-Code.dart-code" \
 "DavidAnson.vscode-markdownlint" \
 "EditorConfig.EditorConfig" \
 "HookyQR.beautify" \
 "PKief.material-icon-theme" \
 "PatrykPeszko.vscode-proselint" \
 "PeterJausovec.vscode-docker" \
 "WakaTime.vscode-wakatime" \
 "ban.spellright" \
 "christian-kohler.npm-intellisense" \
 "dariofuzinato.vue-peek" \
 "dbaeumer.jshint" \
 "dbaeumer.vscode-eslint" \
 "deerawan.vscode-dash" \
 "donjayamanne.githistory" \
 "eamodio.gitlens" \
 "ecmel.vscode-html-css" \
 "eg2.vscode-npm-script" \
 "ericadamski.carbon-now-sh" \
 "eriklynd.json-tools" \
 "esbenp.prettier-vscode" \
 "fallenwood.vimL" \
 "felipecaputo.git-project-manager" \
 "flowtype.flow-for-vscode" \
 "formulahendry.auto-close-tag" \
 "formulahendry.auto-rename-tag" \
 "mohsen1.prettify-json" \
 "monokai.theme-monokai-pro-vscode" \
 "mrmlnc.vscode-attrs-sorter" \
 "ms-vscode.wordcount" \
 "msjsdiag.debugger-for-chrome" \
 "mushan.vscode-paste-image" \
 "octref.vetur" \
 "shekhardtu.vuejspack" \
 "sidneys1.gitconfig" \
 "travisthetechie.write-good-linter" \
 "vscodevim.vim" \
 "wix.vscode-import-cost" \
 "yzhang.dictionary-completion" \
 "yzhang.markdown-all-in-one" \
 "zhuangtongfa.Material-theme" \
)

for VARIANT in "code"

do
  if hash $VARIANT 2>/dev/null; then
    echo "Installing extensions for $VARIANT"
    for EXTENSION in ${EXTENSIONS[@]}
    do
      $VARIANT --install-extension $EXTENSION
    done
  fi
done

# Make symbolic link even if file exists
function lnif(){
  if [ -e "$1" ]; then
    info "Linking $1 to $2"
    if ( ! is_dir_exists `dirname "$2"` ); then
      mkdir -p `dirname "$2"`
    fi;
    rm -rf "$2"
    ln -s "$1" "$2"
  fi;
}

function is_dir_exists(){
  [[ -d "$1" ]] && return 0 || return 1
}

vscode_path="$HOME/Library/Application Support/Code"

echo "Installing vscode configs ..."

mkdir -p "$vscode_path/User"

lnif "$DOTFILES_ROOT/vscode/settings.json" \
      "$vscode_path/User/settings.json"

lnif "$DOTFILES_ROOT/vscode/keybindings.json" \
      "$vscode_path/User/keybindings.json"

echo "Successfully installed vscode configs."