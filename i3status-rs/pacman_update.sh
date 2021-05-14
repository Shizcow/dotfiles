# Checks both pacman databases and pacaur on a regular basis
# Queries upstream servers once in every SYNC_ITERATE*LOCAL_ITERATE times this command is ran
# References local caches every LOCAL_ITERATE times for a list of installed packages/versions
# Every (1) time this script is ran, iff packages need updating, print from pending
#
# Note: this file has a lot of "screen -dm bash -c". This is because i3status-rs will fully
#       wait for this command to complete before moving. If this hangs, everything hangs
#       statusbar. screen fixes that

# assuming interval = 2
SYNC_ITERATE=20 # 2 minutes, sync with upstream
LOCAL_ITERATE=3 # 6 seconds, sync with downstream

# check for existance of files
mkdir -p /home/notroot/.config/i3status-rs/.dbcache
touch /home/notroot/.config/i3status-rs/.pacaurcache
touch /home/notroot/.config/i3status-rs/.pacaurignored
if ! test -f /home/notroot/.config/i3status-rs/.counter; then
    echo 2147483647 > /home/notroot/.config/i3status-rs/.counter # instant update if no file
fi
if ! test -f /home/notroot/.config/i3status-rs/.counter-pretty; then
    echo 0 > /home/notroot/.config/i3status-rs/.counter-pretty
fi

# update counter
if (( $(cat /home/notroot/.config/i3status-rs/.counter) >= $SYNC_ITERATE*$LOCAL_ITERATE )); then
    echo '1' > /home/notroot/.config/i3status-rs/.counter
else
    echo $(( $(cat /home/notroot/.config/i3status-rs/.counter)+1 )) > /home/notroot/.config/i3status-rs/.counter
fi

# update databases if required, print appropriate tag
# if kernal needs updating, do that too
if (( $(cat /home/notroot/.config/i3status-rs/.counter) == 1 )); then
    rm -f /home/notroot/.config/i3status-rs/.dbcache/db.lck
    screen -dm bash -c 'fakeroot -- pacman -Syb /home/notroot/.config/i3status-rs/.dbcache --logfile /dev/null &> /dev/null';  # repo
    screen -dm bash -c "bash /home/notroot/.config/i3status-rs/aurgetcache.sh > /home/notroot/.config/i3status-rs/.pacaurcache 2> /home/notroot/.config/i3status-rs/.pacaurignored" # aur
    echo -n ' '
else
    KERNEL_FILENAME=/boot/vmlinuz-linux
    read -d "" version < <(tail -c +$(($(od -d -j $((0x20e)) -N 2 -An "$KERNEL_FILENAME") + 0x201)) "$KERNEL_FILENAME")
    read -d "" v_r < <(echo $version | awk '{print $1;}')
    read -d "" u_r < <(uname -r)
    read -d "" u_v < <(uname -v)
    if [[ "$v_r" == "$u_r" ]] && [[ "$version" == *"$u_v"* ]]; then
	echo -n ' '
    else
	echo -n ' '
    fi
fi

# Check local every $LOCAL_ITERATE times the script is called
# This is pretty fast so we can do it in real time
if (( $(cat /home/notroot/.config/i3status-rs/.counter) % $LOCAL_ITERATE == 0 )); then
    rm /home/notroot/.config/i3status-rs/.dbcache/local -r
    ln -sfn /var/lib/pacman/local /home/notroot/.config/i3status-rs/.dbcache/local
    (pacman -Qub /home/notroot/.config/i3status-rs/.dbcache --logfile /dev/null; pacman -Qm --logfile /dev/null | join -j 999999 -o 1.1,1.2,2.1,1.2 /home/notroot/.config/i3status-rs/.pacaurcache - | awk '{if($1==$3){printf "%s %s -> %s\n", $1, $2, $4}}') | awk 'NF' | sort > /home/notroot/.config/i3status-rs/.pre_pending
    bash /home/notroot/.config/i3status-rs/repo_ignored.sh > /home/notroot/.config/i3status-rs/.pending 2> /home/notroot/.config/i3status-rs/.repo_ignored
fi

if (( $(cat /home/notroot/.config/i3status-rs/.pending | wc -l) > 0)); then
    # update counter
    if (( $(cat /home/notroot/.config/i3status-rs/.counter-pretty) >=  $(cat /home/notroot/.config/i3status-rs/.pending | wc -l))); then
	echo '0' > /home/notroot/.config/i3status-rs/.counter-pretty
    else
	echo $(( $(cat /home/notroot/.config/i3status-rs/.counter-pretty)+1 )) > /home/notroot/.config/i3status-rs/.counter-pretty
    fi
    cat /home/notroot/.config/i3status-rs/.pending | wc -l | tr -d '\n' # print number of packages that need updating
    echo -n ' |' # print a seperator
    # the next few lines are needed for dynamic sizing of package rotation
    LONGEST_LINE=$(( $(cat /home/notroot/.config/i3status-rs/.pending | awk '{printf"%s\n",$1}'| awk ' { if ( length > x ) { x = length; y = $0 } }END{ print y }' | wc -c)-1 ))
    if ((LONGEST_LINE > 25)); then
	LONGEST_LINE=25 # make sure things don't get out of hand
    fi
    NTH_LINE=$(cat /home/notroot/.config/i3status-rs/.counter-pretty)
    if (( $(cat /home/notroot/.config/i3status-rs/.pending | wc -l) == 1)); then
	cat /home/notroot/.config/i3status-rs/.pending | awk '{printf"%s",$1}'
    elif ((NTH_LINE == 0)); then
	awk 'BEGIN {s=sprintf("%'$LONGEST_LINE's","");gsub(/ /," ",s);print s}' | tr -d '\n' # apparently this is "really fast"
    else
	sed $NTH_LINE"q;d" /home/notroot/.config/i3status-rs/.pending | awk '{if(length($1)<='$LONGEST_LINE'){printf "%'$LONGEST_LINE's", $1}else{printf "%'$(($LONGEST_LINE-3))'s...", substr($1, 0, '$LONGEST_LINE'-3)}}' # Finally, print the package name, smart-truncate if need be
    fi
    echo -n '|' # print a seperator
else
    echo -n 'System up to date'
fi
