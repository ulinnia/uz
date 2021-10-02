#!/bin/bash

pacman -Sy --needed --noconfirm fish
curl -fLo /arch.fish https://github.com/rraayy246/uz/raw/master/jb/arch.fish
fish /arch.fish --live

