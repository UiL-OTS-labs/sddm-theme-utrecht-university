# SDDM theme Utrecht University

This is a quickly put together sddm theme set in the Utrecht University style. It is originally build for the Utrecht Institute for Linguistics.

## Test instruction:
Testing can easily be done by running sddm-greeter --theme _theme-directory_. From the top level directory this is:

`sddm-greeter --theme sddm-theme-utrecht-university-1.0-1/usr/share/sddm/themes/utrecht-university/`

## Build instruction:
* Open a terminal and navigate one level above the sddm-theme-utrecht-university-* folder
* Run `dpkg-deb --build sddm-theme-utrecht-university*`
* You should now have an debian package that you can install by running `sudo dpkg -i sddm-theme-utrecht-university*.deb`.
