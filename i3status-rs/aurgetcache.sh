PACKAGES=$(pacaur -k | awk "{printf \"%s %s\n\", \$3, \$6}")

while IFS= read -r package ; do
    package_name=$(echo $package | awk '{printf"%s", $1}')
    # TODO: Get better at sed so this is only one command
    patch_on=$(sed -n '/\['$(printf '%q' "$package_name")'\]/,/\[.*\]/p' /home/notroot/.config/i3status-rs/update.toml | grep -Po '(?<=^update_on)\s*\=\s*\".*\"' | awk 'NF>1{print substr($NF, 2, length($NF)-2)}')
    if [ -z "$patch_on" ]; then
	ignoring=0
    elif [ "$patch_on" = "never" ]; then
	ignoring=1 # don't need to update
    elif [ "$patch_on" != "always" ]; then
	package_version_local=$(pacaur -Q $package_name | awk '{printf"%s", $2}')
	package_version_upstream=$(pacaur -Si $package_name | grep -Po '^Version\s*\:\s*.*?(?=\s)' | awk 'NF>1{print $NF}')
	if [ "$patch_on" = "major" ]; then
	    ver_lines=1
	elif [ "$patch_on" = "minor" ]; then
	    ver_lines=2
	elif [ "$patch_on" = "patch" ]; then
	    ver_lines=3
	else
	    echo 'Allowed values are "never", "major", "minor", "patch", and "always" (default)'
	    exit 1
	fi
	version_short_local=$(echo "$package_version_local" | sed 's/\./\n/g' | head -n $ver_lines | tr '\n' '.')
	version_short_upstream=$(echo "$package_version_upstream" | sed 's/\./\n/g' | head -n $ver_lines | tr '\n' '.')
	if [ "$version_short_local" = "$version_short_upstream" ]; then
	    ignoring=1
	fi
    fi
    if [ "$ignoring" = "0" ]; then
	echo "$package" # normal packages are echo'd to stdout
    else
	echo "$package_name" 1>&2; # ignored are to stderr
    fi
done <<< "$PACKAGES"
