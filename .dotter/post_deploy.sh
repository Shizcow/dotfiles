# I use a few custom glyphs in i3status-rs
if type git > /dev/null; then
    cd extra_font_characters
    git clone https://github.com/Shizcow/modfont
    sudo ./modfont/modFont --force /usr/share/fonts/awesome-terminal-fonts/fontawesome-regular.ttf -p f2ee Outlook.com_icon.svg -p f2ea ethernet-solid.svg -o /usr/share/fonts/awesome-terminal-fonts/fontawesome-regular.ttf
    cd ..
else
    echo -e "\e[0;91mErr: qit not installed; skipping modfont\e[0;97m"
fi

# Fix the qmk homedir to point inside this repo (I store my firmware here)
if type qmk > /dev/null; then
    qmk config user.qmk_home=$(pwd)/qmk/firmware
else
    echo -e "\e[0;91mErr: qmk not installed; skipping configuration\e[0;97m"
fi
