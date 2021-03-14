xrdb -merge .Xresources

# TODO: make this line machine-dependent with dotter
xrandr --dpi 238

# TODO: is there a better way to do this? udev rules?
setxkbmap -option ctrl:swapcaps

# I have some flatpakages on my system
export XDG_DATA_DIRS=/usr/share/:/usr/local/share/:/var/lib/flatpak/exports/share:/home/notroot/.local/share/flatpak/exports/share

# TODO: make this line machine-dependent
#       perhaps use some magic to digure out if there's a touchpad?
# disable touchpad when mouse is ON
while /bin/true; do
    if ls /sys/class/power_supply/hidpp_battery_*/status 2> /dev/null && [[ $(cat /sys/class/power_supply/hidpp_battery_*/status | head -n1) == "Discharging" ]]; then
	#echo "disable"
        xinput disable "ELAN1010:00 04F3:3012 Touchpad"
    else
	#echo "enable"
        xinput enable "ELAN1010:00 04F3:3012 Touchpad"
    fi
    sleep 0.25
done &

# I will eventually move away from plasma and either back to i3 or straight to penrose
#exec i3
exec startplasma-x11
