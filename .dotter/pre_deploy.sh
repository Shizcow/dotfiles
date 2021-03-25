# look for firefox user dir
# it changes from machine-to-machine but has a well defined format
# I won't reasonably not have firefox installed before getting to this point
export FF_CHROME_PATH=$(find ~/.mozilla/firefox/ -type d -name "*.default")

# Force a pull of the qmk submodule (this is pretty much qmk setup)
git submodule update --init --recursive
# and place symlinks to my keymap correctly
mkdir -p qmk/firmware/keyboards/kbdfans/kbd75/keymaps/shizcow
ln -fs $(pwd)/qmk/kbd75_keymap.c $(pwd)/qmk/firmware/keyboards/kbdfans/kbd75/keymaps/shizcow/keymap.c
