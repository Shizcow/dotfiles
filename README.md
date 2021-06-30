## Installing
These dotfiles have been set up for [dotter](https://github.com/SuperCuber/dotter).

**Note**: My dotfiles require the use of [my own custom fork of dotter](https://github.com/Shizcow/dotfiles). This is because of some magic environment variables that are set in `pre_deploy.sh` -- they need to be dynamically set in order to get the correct output directories for some configuration files. The only thing that requires this is firefox `userChrome.css`, but it's staying regardless. These features will eventually be merged into upstream dotter.


Note note: Firefox 89 has brought a new theme engine that removes the need for my userChrome.css hacks. Everything will be able to work with vanilla dotter... One I get around to cleaning everything up.