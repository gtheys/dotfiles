# Geert has dotfiles too

## dotfiles

Over time you copy dotfiles and more and more you adapt them. Adding things you see in other dotfiles or even adding your own flavors.

Credit to [Holmans](https://github.com/holman/) and [Nick Nisi](https://github.com/nicknisi).

## install

Run this:

```sh
git clone https://github.com/gtheys/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap.sh
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

`update` is a simple script that installs some dependencies, sets sane OS X
defaults, and so on. Tweak this script, and occasionally run `update` from
time to time to keep your environment fresh and up-to-date. You can find
this script in `bin/`.

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## Brew and MAS

As I stopped using linux on my workstation since 2010. I run MacOSX and have a great Brew and MAS bootstrap. It runs also when `script/bootstrap.sh` is executed. You can run it seperate by `script/mas.sh` for mas and `update` for brew.

Before you run the `script/mash.sh` make sure to update the App store ID's.

## what's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you.
[Fork it](https://github.com/gtheys/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/\*.symlink**: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/link.sh`.
