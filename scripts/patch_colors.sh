#!/bin/bash

# Make backgrounds darker in dark mode
sed -i 's/#36363a/#181818/g' build/patched/gnome-shell-sass/_colors.scss
sed -i 's/#222226/#111111/g' build/patched/gnome-shell-sass/_default-colors.scss
