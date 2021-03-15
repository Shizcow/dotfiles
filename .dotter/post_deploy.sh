
# I use a few custom glyphs in i3status-rs
cd extra_font_characters
git clone https://github.com/Shizcow/modfont
sudo ./modfont/modFont --force /usr/share/fonts/awesome-terminal-fonts/fontawesome-regular.ttf -p f2ee Outlook.com_icon.svg -p f2ea ethernet-solid.svg -o /usr/share/fonts/awesome-terminal-fonts/fontawesome-regular.ttf
cd ..
