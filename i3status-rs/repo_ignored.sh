while IFS= read -r package ; do
    package_name=$(echo $package | awk '{printf"%s", $1}')

    if [ -z "$(sed -n '/\['$(printf '%q' "$package_name")'\]/,/\[.*\]/p' /home/notroot/.config/i3status-rs/update.toml)" ]; then
	echo "$package"
	continue
    fi
    
    # TODO: Get better at sed so this is only one command
    patch_on=$(sed -n '/\['$(printf '%q' "$package_name")'\]/,/\[.*\]/p' /home/notroot/.config/i3status-rs/update.toml | grep -Po '(?<=^update_on)\s*\=\s*\".*\"' | awk 'NF>1{print substr($NF, 2, length($NF)-2)}')

    ignoring=1
    if [ -z "$patch_on" ]; then
	ignoring=0
    elif [ "$patch_on" = "never" ]; then
	ignoring=0 # don't need to update
    fi
    if [ "$ignoring" = "1" ]; then
	echo "$package" # normal packages are echo'd to stdout
    else
	echo "$package_name" 1>&2
    fi
done < /home/notroot/.config/i3status-rs/.pre_pending
