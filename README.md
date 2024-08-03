# Dotfiles

## 🙋‍♂️Introduction

My current workflow is Windows or Linux in dual boot setting. I used WSL2 before in windows but stopped doing that and work native using Powershell.

I used [the the dotfiles of Nic Nisi](https://github.com/nicknisi/dotfiles/) for a long time. You can still find some remnants of it. But seeing lots of Windots repos I decided to go native with powershell. Better for my machine learning loads. 

I am using this [Windots](https://github.com/scottmckendry/Windots) as base reference but I copy and paste from loads of others.

Goal is to go more and more in my own direction befitting my own workflows.

> [!note]
> This repo is a work in progress. It is full off ugly hacks and probably here and there hardcoded items like colorshemes and fonts.

## 🚀 Installing

- Windows: ./Setup.ps1 all
- Linux: ./install.sh all

## 🕵🏻 Testing

### Windows

I have a docker container using a windows sandbox. Check the `testing\windows` folder.

> [!warning]
> You can load the instance and the folder is in the \\host.lan\Data but I haven't been able to make winget work yet. This is a sandbox and need to figure out why it is not fetchen from the winget source. The rest of the Setup.ps1 can be tested.

### Linux

There is also a docker container in `testing\linux`. For the moment you can just test the install script and the CLI. Not the gui aps like wezterm.

## 📋Applications

### Shells

#### On Windows powershell

Yes I run powershell and not WSL2 on windows. I prefer to be native as this give me the max performance needed for my machine learning code. WSL always an out of memory crashing my jupyter kernels. Thanks to the work of [Scott McKendry](https://github.com/scottmckendry/Windots) writing loads of powershell function to mimic, rm, grep, su, ... and loads more I feel like powershell is almost the same like my linux cli.

#### On Linux ZSH

Not much explaining needed here... Look into the config.

### Prompt: Starship

Why starship and not a ZSH implementation? Well it runs everyhere. Powershell, ZSH and loads of other shells. Now I only need to maintain 1 configuration. But it is portable between OS'es.

### Terminal: Wezterm

Yes love this terminal and same reason. It is portable between OS'es.

> [!note]
> Am in the process removing TMUX from my workflow. This configuration will change a lot in the future. This way I can use panes in wezterm instead of TMUX. Again less configuration to maintain and lets face it using almost a decade now and it still sucks 😄

## 💡Future

- [ ] Want to add my windows configurations. I use tiling manager in windows and linux and want to sync their shortcuts.
- [ ] Add more specfic tweaks to the respective OS'es.
- [ ] There are loads of development environments I use and want them to de dployed automatically and on both OS'es.
- [ ] Cleanup and tidy up code - Ongoing
- [ ] Make the windows test environment work better
- [ ] Setup Gui test environment for linux to test my tiling manager configurations
