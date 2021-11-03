xrdb -merge .Xresources

# TODO: make this line machine-dependent with dotter
xrandr --dpi 238

# TODO: is there a better way to do this? udev rules?
setxkbmap -option ctrl:swapcaps
exec i3
