## Installing
These dotfiles have been set up for [dotter](https://github.com/SuperCuber/dotter).

**Note**: My dotfiles require the use of [my own custom fork of dotter](https://github.com/Shizcow/dotfiles). This is because of some magic environment variables that are set in `pre_deploy.sh` -- they need to be dynamically set in order to get the correct output directories for some configuration files. The only thing that requires this is firefox `userChrome.css`, but it's staying regardless. These features will eventually be merged into upstream dotter.
