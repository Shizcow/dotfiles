set $mod Mod4

# disable title bars
new_window pixel 0

# TODO: stop using i3

# >>> Wallpaper <<<
exec_always --no-startup-id "sleep 2; ~/.fehbg" # give desktop time to init before calling feh

# Default font
font pango:DejaVu Sans Mono 8

# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod

# start a normal terminal
bindsym $mod+Shift+Return exec urxvt
# start an emacs terminal
bindsym $mod+Return exec emacs -f "vterm"
# start an emacs scratch
bindsym $mod+Ctrl+Return exec emacs -f "switch-to-buffer \*scratch\*"

# kill focused window
bindsym $mod+Shift+q kill

# Change focus
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused window
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in horizontal orientation
bindsym $mod+h split h

# split in vertical orientation
bindsym $mod+v split v

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen toggle

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# NOTE: yes I actually use this many workspaces
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"
set $ws11 "11"
set $ws12 "12"
set $ws13 "13"
set $ws14 "14"
set $ws15 "15"
set $ws16 "16"
set $ws17 "17"
set $ws18 "18"
set $ws19 "19"
set $ws20 "20"

# switch to workspace
bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5
bindsym $mod+6 workspace $ws6
bindsym $mod+7 workspace $ws7
bindsym $mod+8 workspace $ws8
bindsym $mod+9 workspace $ws9
bindsym $mod+0 workspace $ws10
bindsym $mod+Ctrl+1 workspace $ws11
bindsym $mod+Ctrl+2 workspace $ws12
bindsym $mod+Ctrl+3 workspace $ws13
bindsym $mod+Ctrl+4 workspace $ws14
bindsym $mod+Ctrl+5 workspace $ws15
bindsym $mod+Ctrl+6 workspace $ws16
bindsym $mod+Ctrl+7 workspace $ws17
bindsym $mod+Ctrl+8 workspace $ws18
bindsym $mod+Ctrl+9 workspace $ws19
bindsym $mod+Ctrl+0 workspace $ws20

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4
bindsym $mod+Shift+5 move container to workspace $ws5
bindsym $mod+Shift+6 move container to workspace $ws6
bindsym $mod+Shift+7 move container to workspace $ws7
bindsym $mod+Shift+8 move container to workspace $ws8
bindsym $mod+Shift+9 move container to workspace $ws9
bindsym $mod+Shift+0 move container to workspace $ws10
bindsym $mod+Ctrl+Shift+1 move container to workspace $ws11
bindsym $mod+Ctrl+Shift+2 move container to workspace $ws12
bindsym $mod+Ctrl+Shift+3 move container to workspace $ws13
bindsym $mod+Ctrl+Shift+4 move container to workspace $ws14
bindsym $mod+Ctrl+Shift+5 move container to workspace $ws15
bindsym $mod+Ctrl+Shift+6 move container to workspace $ws16
bindsym $mod+Ctrl+Shift+7 move container to workspace $ws17
bindsym $mod+Ctrl+Shift+8 move container to workspace $ws18
bindsym $mod+Ctrl+Shift+9 move container to workspace $ws19
bindsym $mod+Ctrl+Shift+0 move container to workspace $ws20

# super+scroll to change workspaces
bindsym --whole-window $mod+button4 workspace prev_on_output
bindsym --whole-window $mod+button5 workspace next_on_output

# S-arrows to change workspaces
bindsym $mod+Ctrl+Left workspace prev_on_output
bindsym $mod+Ctrl+Right workspace next_on_output

# reload the configuration file
bindsym $mod+Shift+c reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+r restart

bar {
    font pango:DejaVu Sans Mono, FontAwesome 20
    status_command i3status-rs ~/.config/i3status-rs/config.toml
    tray_output primary
    colors {
        separator #666666
        background #222222
        statusline #dddddd
        focused_workspace #0088CC #0088CC #ffffff
        active_workspace #333333 #333333 #ffffff
        inactive_workspace #333333 #333333 #888888
        urgent_workspace #2f343a #900000 #ffffff
    }
}


# Pulse Audio controls
bindsym Ctrl+XF86AudioRaiseVolume exec pactl set-sink-mute 0 0 && amixer sset Master 25%+
bindsym XF86AudioRaiseVolume exec pactl set-sink-mute 0 0 && amixer sset Master 5%+
bindsym Shift+XF86AudioRaiseVolume exec pactl set-sink-mute 0 0 && amixer sset Master 1%+
bindsym Ctrl+XF86AudioLowerVolume exec pactl set-sink-mute 0 0 && amixer sset Master 25%-
bindsym XF86AudioLowerVolume exec pactl set-sink-mute 0 0 && amixer sset Master 5%-
bindsym Shift+XF86AudioLowerVolume exec pactl set-sink-mute 0 0 && amixer sset Master 1%-
bindsym XF86AudioMute exec pactl set-sink-mute 0 toggle # mute/unmute sound

# Sreen brightness controls
bindsym Ctrl+XF86MonBrightnessUp    exec light -A 25 
bindsym XF86MonBrightnessUp         exec light -A 10 
bindsym Shift+XF86MonBrightnessUp   exec light -A 1  
bindsym Ctrl+XF86MonBrightnessDown  exec light -U 25
bindsym XF86MonBrightnessDown       exec light -U 10
bindsym Shift+XF86MonBrightnessDown exec light -U 1

# screenshot
exec_always --no-startup-id flameshot
bindsym Print exec flameshot gui

# dmenu stuff - requires dmenu-rs (plugins: calc fuzzy lookup [spellcheck]) and j4-dmenu-desktop
bindsym $mod+d exec --no-startup-id j4-dmenu-desktop --dmenu="dmenu -i --fn 'Office Code Pro-14' --render_minheight 44"
bindsym $mod+equal exec --no-startup-id dmenu --calc --fn 'Office Code Pro-10' --render_minheight 44
bindsym $mod+s exec --no-startup-id dmenu --lookup --list-engines | dmenu --fn 'Office Code Pro-14' --render_minheight 44 | dmenu --lookup --fn 'Office Code Pro-10' --render_minheight 44
bindsym $mod+minus exec --no-startup-id dmenu --spellcheck --fn 'Office Code Pro-10' --render_minheight 44 # currently dead ree


# notification daemon
exec --no-startup-id dunst

exec --no-startup-id nm-applet

# TODO: this daemon sucks. Rewrite it in rust.
exec_always --no-startup-id echo 2147483647 > ~/.config/i3status-rs/.counter # trigger the statusbar daemon to check the database

# teams is not good software
for_window [title="Microsoft Teams Notification"] floating enable
# neither is zoom (these are just the notifications)
for_window [title="zoom"] floating enable