#!/bin/bash

# gnome shell theme
dconf write /org/gnome/shell/extensions/user-theme/name "'bdwaita'"

# gtk and libadwaita themes
if [ "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'prefer-dark'" ]; then
    dconf write /org/gnome/desktop/interface/gtk-theme "'bdwaita-dark'"
else
    dconf write /org/gnome/desktop/interface/gtk-theme "'bdwaita'"
fi

# auto switch between gtk/libadwaita themes based on system dark mode setting
dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/sunrise "'dconf write /org/gnome/desktop/interface/gtk-theme \"\'bdwaita\'\"'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/sunset "'dconf write /org/gnome/desktop/interface/gtk-theme \"\'bdwaita-dark\'\"'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/enabled true
