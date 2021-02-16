**WinURL** - assigns associations to internet shortcuts *.url and creates them

After installation, the .url files will be opened by the default browser. The .url icons will take the form of Internet Explorer; you can immediately see that the file "came" from Windows (C). Now, as in Windows, you can open and create compatible Internet shortcuts in Linux. The program checks the names of the created files the .url is checked for Linux <> Windows compatibility, automatically replaces incorrect characters and their combinations, controls the length of names, etc.

Clear custom icons of Internet shortcuts after deleting the winurl package (under the user):  
`find ~/.local/share/icons/hicolor -name 'application-x-mswinurl.png' -delete; xdg-icon-resource forceupdate`

Tested in LXDE, XFCE, LXQt (own icon), MATE, Enlightenment, Plasma (own icon), Cinnamon.

Important:
---
The icon theme "adwaita-icon-theme-3.38.0" has a critical bug that the developers are in no hurry to fix:  
https://gitlab.gnome.org/GNOME/adwaita-icon-theme/-/issues/108

For WinURL to work correctly, you need to install the 'adwaita-mime-patch-1-0.mrx8.noarch.rpm' from the 'adwaita-mime-patch' folder.

Made and tested in Mageia Linux-7/8.
