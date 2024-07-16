# How to get a symlink's target's absolute path
# https://unix.stackexchange.com/a/17500
DIR="$(dirname "$(readlink -f "$0")")"

# Loading variables
. "$DIR/.variables"

# Loading aliases
. "$DIR/.aliases"

# Copy Vim configuration
yes | cp "$DIR/.vimrc" ~/.vimrc > /dev/null 2>&1

# Load macOS specific configurations
# . ./macos

# Loading .bash_profile
 . "$DIR/.bash_profile"
