set fish_greeting

if status is-interactive && type -q thefuck
    thefuck --alias | source
end

alias sysup='pacaur --noedit -Syu (cat ~/.config/i3status-rs/.pacaurignored ~/.config/i3status-rs/.repo_ignored | awk \'{printf"--ignore %s ", $1}\')'

export EDITOR=emacs

# Start X at login
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec startx -- -keeptty
    end
end

# TODO:
# - Make CSU ssh execute shell via pseudocommand instead of screw with bashprofile
#   - Or just wait until they get around to allowing us to use fish
function ssh --wraps=ssh --description 'if ssh target is "cs", it has fish installed. Forward the ID of this fish process so emacs can mark the vterm buffer correctly'
    if test "$argv[1]" = "cs"
	echo %self > ~/.fish_ssh_id
	scp ~/.fish_ssh_id cs:~/.fish_ssh_id
	/bin/ssh $argv
    else
	/bin/ssh $argv
    end
end

# weird ssh stuff
set self_redirect %self

# emacs stuff
function vterm_printf;
    if [ -n "$TMUX" ]
        # tell tmux to pass the escape sequences through
        # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
        printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
    else if string match -q -- "screen*" "$TERM"
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$argv"
    else
        printf "\e]%s\e\\" "$argv"
    end
end

# TODO: use dotter for getting HOSTNAME and USERNAME, or something smarter?
function fish_prompt
    set prompt_string ""

    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status
    set -l pipestatus_string (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) \
        (set_color --bold $fish_color_status) $last_pipestatus)
    
    set cwd (dirs | head -n1 | tr -d '\n')
    set USERNAME (whoami)
    set HOSTNAME (hostname)

    if not set -q __fish_git_prompt_color_branch
        set -g __fish_git_prompt_color_branch cyan --bold
    end

    set -l normal_color     (set_color normal)
    set -l directory_color  (set_color green)
    set -l repository_color (set_color yellow)
    set -l user_color       (set_color blue)
    set -l host_color       (set_color brown)

    if test "$HOSTNAME" = "shizcow"
	# on local machine
	if test "$USERNAME" != "notroot"
	    # worth printing
	    set prompt_string "$prompt_string$user_color$USERNAME $normal_color"
	end
    else
	# ssh
	set self_redirect (cat ~/.fish_ssh_id)
	set prompt_string "$prompt_string$user_color$USERNAME$normal_color@$host_color$HOSTNAME $normal_color"
    end
    set prompt_string "$prompt_string$directory_color$cwd$normal_color"

    set git_text (fish_git_prompt)
    set prompt_string "$prompt_string$git_text"
    
    set prompt_string "$prompt_string$pipestatus_string"

    # If the prompt is too long, put the command on a newline
    if test (string length "$prompt_string") -gt 80
	echo -ne "╮$prompt_string\n╰> "
    else
	echo -n "$prompt_string> "
    end
end

# more emacs stuff
functions -c fish_prompt old_fish_prompt
function fish_prompt
    old_fish_prompt
    switch $TERM
	case xterm-256color # only in vterm
	    vterm_cmd vterm-set-idle $self_redirect
    end
end

function vterm_prompt_end --description 'Used for directory tracking in vterm'
    vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
end

# I only use this for really fancy emacs buffer names
function fish_title
    set USERNAME (whoami)
    set HOSTNAME (hostname)

    if test "$HOSTNAME" = "shizcow"
	# on local machine
	if test "$USERNAME" != "notroot"
	    # worth printing
	    echo "$USERNAME:"
	end
    else
	# ssh
	echo "$USERNAME@$HOSTNAME:"
    end
    
    if test (dirs | head -n1) != "/"
	dirs | head -n1 | tr -d '\n'
    end
    echo "/"
end

function vterm_cmd --description 'Run an emacs command among the ones been defined in vterm-eval-cmds.'
    set -l vterm_elisp ()
    for arg in $argv
        set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
    end
    vterm_printf '51;E'(string join '' $vterm_elisp)
end

switch $TERM
    case xterm-256color # only in vterm
	function vterm_before --on-event fish_preexec
	    vterm_cmd vterm-set-active $self_redirect
	end
end

# !! support
function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t $history[1]; commandline -f repaint
        case "*"
            commandline -i !
    end
end

function subs_double_bang
    # regex is fucking broken
    commandline (commandline | sed 's/(?<=^[^\']*(\'[^\']*\'[^\']*)*)!!/'$history[1]'/g')
end

function fish_user_key_bindings
    bind ! bind_bang
    #bind \eq subs_double_bang
    switch $TERM
	# make fish somewhat competent at doing anything
        case rxvt-unicode-256color # urxvt
            bind \cH backward-kill-path-component
    	    bind [3^ kill-bigword
        case xterm-256color # vterm
            bind [127\;5u backward-kill-path-component
    	    bind [3\;5~ kill-bigword
    end
end

# more emacs stuff
functions -c fish_prompt vterm_old_fish_prompt
function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
    printf "%b" (string join "\n" (vterm_old_fish_prompt))
    vterm_prompt_end
end
