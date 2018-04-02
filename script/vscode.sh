#!/usr/bin/env bash

EXTENSIONS=(
    "AleksandarDev.vscode-sequence-diagrams" \
    "Dart-Code.dart-code" \
    "DavidAnson.vscode-markdownlint" \
    "EditorConfig.EditorConfig" \
    "HookyQR.beautify" \
    "PKief.material-icon-theme" \
    "PeterJausovec.vscode-docker" \
    "WakaTime.vscode-wakatime" \
    "christian-kohler.npm-intellisense" \
    "dbaeumer.jshint" \
    "dbaeumer.vscode-eslint" \
    "deerawan.vscode-dash" \
    "donjayamanne.githistory" \
    "eamodio.gitlens" \
    "ecmel.vscode-html-css" \
    "eg2.vscode-npm-script" \
    "ericadamski.carbon-now-sh" \
    "eriklynd.json-tools" \
    "fallenwood.vimL" \
    "felipecaputo.git-project-manager" \
    "flowtype.flow-for-vscode" \
    "formulahendry.auto-close-tag" \
    "mohsen1.prettify-json" \
    "monokai.theme-monokai-pro-vscode" \
    "msjsdiag.debugger-for-chrome" \
    "octref.vetur" \
    "sidneys1.gitconfig" \
    "vscodevim.vim" \
    "zhuangtongfa.Material-theme" \
    "hack.font" \
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