if set -q SSH_CLIENT; or set -q SSH_TTY
    set IN_SSH true
end

# Ree
set -x DEBUGINFOD_URLS "https://debuginfod.archlinux.org"

set fish_greeting

# Ree
set -x DEBUGINFOD_URLS "https://debuginfod.archlinux.org"

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

    if test "$HOSTNAME" = "drone53"
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
    case dumb
        function fish_prompt
            echo '$ '
        end
end


############
# Git Nuke #
############
# ====== Core Implementation ======
function __git_nuke
    # Handle --help/-h
    if set --query argv[1]
        if contains -- "$argv[1]" --help -h
            echo "git nuke - Nuclear option for corrupted Git repositories"
            echo
            echo "Usage:"
            echo "  git nuke [--help]"
            echo
            echo "Description:"
            echo "  Completely removes the current repository and re-clones it while:"
            echo "  - Preserving your current branch"
            echo "  - Maintaining the origin URL"
            echo "  - Requiring confirmation for destructive actions"
            echo
            echo "Process flow:"
            echo "  1. Verify we're in a Git repository"
            echo "  2. Check for uncommitted changes"
            echo "  3. Confirm destruction of stashes"
            echo "  4. Delete repository and re-clone"
            echo "  5. Restore original branch"
            echo
            echo "Safety checks:"
            echo "  - Must be run from repository root"
            echo "  - Confirms destruction of uncommitted changes"
            echo "  - Warns about stashed changes"
            echo "  - Final confirmation before deletion"
            return 0
        end
    end

        # Fail immediately if any command fails
    set -l exit_code 0
    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "Error: Not in a Git repository"
        return 1
    end

    # Verify working directory matches repo root
    if test "$repo_root" != (pwd)
        echo "Error: Run from repository root: $repo_root"
        return 1
    end

    # Get repository information
    set -l origin_url (git config --get remote.origin.url)
    set -l current_branch (git symbolic-ref --short HEAD 2>/dev/null)

    if test -z "$origin_url"
        echo "Error: No remote 'origin' configured"
        return 1
    end

    if test -z "$current_branch"
        echo "Error: Detached HEAD state - checkout a branch first"
        return 1
    end

    # Check for unsaved changes
    if not git diff --quiet
        read -P "Uncommitted changes will be destroyed. Continue? (y/N) " -l confirm
        if not string match -qi 'y*' "$confirm"
            return 1
        end
    end

    # Check for existing stashes
    if test (git stash list | wc -l) -gt 0
        read -P "Stashed changes will be lost. Continue? (y/N) " -l confirm
        if not string match -qi 'y*' "$confirm"
            return 1
        end
    end

    # Final confirmation
    read -P "NUKE and re-clone '$repo_root'? (y/N) " -l confirm
    if not string match -qi 'y*' "$confirm"
        return 1
    end

    # Execute nuclear option
    set -l parent_dir (dirname "$repo_root")
    set -l repo_name (basename "$repo_root")

    cd "$parent_dir" || return 1
    rm -rf "$repo_name"
    git clone "$origin_url" "$repo_name" || return 1
    cd "$repo_name"

    # Restore branch
    if git checkout "$current_branch" 2>/dev/null
        echo "Restored branch '$current_branch'"
    else
        git checkout -b "$current_branch"
        echo "Created new branch '$current_branch'"
    end
end

# ====== Git Command Integration ======
if functions --query git
    functions --copy git __original_git
else
    function __original_git
        command git $argv
    end
end

function git
    if set --query argv[1]; and test "$argv[1]" = "nuke"
        __git_nuke $argv[2..]
    else
        __original_git $argv
    end
end
