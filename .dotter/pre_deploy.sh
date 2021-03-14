# look for firefox user dir
# it changes from machine-to-machine but has a well defined format
# I won't reasonably not have firefox installed before getting to this point
export FF_CHROME_PATH=$(find ~/.mozilla/firefox/ -type d -name "*.default")
