if set -q SSH_CLIENT; or set -q SSH_TTY
    set IN_SSH true
end

set fish_greeting

if status is-interactive && type -q thefuck
    thefuck --alias | source
end

function bedrock_count --description 'get the number of players on the running minecraft bedrock server'
    set IID (systemctl show -p InvocationID --value minecraft-bedrock-server.service)
    set joins (journalctl INVOCATION_ID=$IID + _SYSTEMD_INVOCATION_ID=$IID | grep 'Player connected: ' | wc -l)
    set leaves (journalctl INVOCATION_ID=$IID + _SYSTEMD_INVOCATION_ID=$IID | grep 'Player disconnected: ' | wc -l)
    math $joins-$leaves
end

function sysup --description 'pacaur wrapper that handles a few extra things'
    # Parse args

    set argarray $argv
    set ignorepkgs

    set noconfirm_flag ""
    set noconffound "no"

    while test (count $argarray) -gt 0
	if test "$argarray[1]" = "--noconfirm"
	    set noconfirm_flag "--noconfirm"
	    set noconffound "yes"
	    set argarray $argarray[2..]
	else if test "$argarray[1]" = "--ignore"
	    set -a ignorepkgs $argarray[2]
	    set argarray $argarray[3..]
	else
	    echo 'sysup: invalid arguement' 1>&2
	    echo 'Usage: sysup [--noconfirm] [--ignore X]...' 1>&2
	    return 1
	end
    end

    echo "Packages to ignore: $ignorepkgs"
    echo "Operating in noconfirm mode: $noconffound"
    
    # gather data on what to ignore and what orphans to remove
    # - $ignored_packages is persistent/global
    # - $ignorepkgs is from the command line input to sysup
    # Ugly if statement fix one day
    if test (count $ignorepkgs) -gt 0
	set ignore_flags (string split " " "$ignored_packages" | awk '{printf" --ignore %s", $1}') (string split " " "$ignorepkgs" | awk '{printf" --ignore %s", $1}')
    else
	set ignore_flags (string split " " "$ignored_packages" | awk '{printf" --ignore %s", $1}')
    end
    
    # finally, run pacman
    echo "Passing additional flags: $noconfirm_flag $ignore_flags"
    # sometimes full system upgrades take a long time
    # this may cause sudo to time out if ran as two separate commands, and prompt for password twice
    # therefore, this is all ran as a single sudo command
    # TODO: write my fish config in org-mode becuase this is dumb
    sudo -- sh -c " \
	sudo -u $USER -- sh -c '\
	EDITOR=$EDITOR pacaur $noconfirm_flag --noedit -Syu $ignore_flags; \
	fish -c \"fisher update\"'; \
	ORPHANS=\$(pacman -Qtdq); \
	if [ \"\$ORPHANS\" = \"\" ]; then \
	    echo \"System update complete; no orphans found.\"; \
        else \
	    pacman $noconfirm_flag -Rns \$ORPHANS \
	    && echo \"System update complete; Removed \$(wc -w <<< \"\$ORPHANS\") orphan(s)\" \
	    || echo \"System update complete, but did NOT remove \$(wc -w <<< \"\$ORPHANS\") orphan(s)\"; \
	fi"
end

export EDITOR=emacs

# Start X at login
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec startx -- -keeptty
    end
end

# TODO:
# - Make CSU ssh execute shell via pseudocommand instead of screw with bashprofile
#   - This would make it so I don't need to use self_redirect for shell integration... will think about it
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

# !! support
function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t $history[1]; commandline -f repaint
        case "*"
            commandline -i !
    end
end

function fish_user_key_bindings
    bind ! bind_bang
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

# Fish is special software that doesn't know what it's doing sometimes
function fish_command_not_found
    __fish_default_command_not_found_handler $argv
end

# TODO: use dotter for getting HOSTNAME and USERNAME, or something smarter?
function fish_prompt
    set prompt_string ""
    
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status
    set -l pipestatus_string (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) \
        (set_color --bold $fish_color_status) $last_pipestatus)
    
    set cwd (dirs | tr -d '\n')
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

    if test "$HOSTNAME" = "mothership"
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

# I only use this for really fancy emacs buffer names
function fish_title
    set USERNAME (whoami)
    set HOSTNAME (hostname)

    if test "$HOSTNAME" = "mothership"
	# on local machine
	if test "$USERNAME" != "notroot"
	    # worth printing
	    echo "$USERNAME:"
	end
    else
	# ssh
	echo "$USERNAME@$HOSTNAME:"
    end

    if [ (dirs | tr -d '\n') != "/" ]
	dirs | tr -d '\n'
    end
    echo "/"
end

#############
# emacs stuff
#############

switch $TERM
    case xterm-256color # only in vterm
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

	function vterm_prompt_end --description 'Used for directory tracking in vterm'
	    vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
	end

	function vterm_cmd --description 'Run an emacs command among the ones been defined in vterm-eval-cmds.'
	    set -l vterm_elisp ()
	    for arg in $argv
		set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
	    end
	    vterm_printf '51;E'(string join '' $vterm_elisp)
	end

	function vterm_before --on-event fish_preexec
	    if test -n "$IN_SSH"
		
	    else
		vterm_cmd vterm-set-active $self_redirect
	    end
	end

	functions -c fish_prompt vterm_old_fish_prompt
	function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
	    printf "%b" (string join "\n" (vterm_old_fish_prompt))
	    vterm_prompt_end
	    if test -n "$IN_SSH"
		
	    else
		vterm_cmd vterm-set-idle $self_redirect
	    end
	end
end
