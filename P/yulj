#!/usr/bin/env sh
# #############################################################################
# File: preview_cmd.sh
# Description: Minimal example to preview files and directories
#              No external dependencies
#              Can be easily extended
#              Automatically exits when the NNN_FIFO closes
#              Prints a `tree` if directory or `head` if it's a file
#
# Shell: POSIX compliant
# Author: Todd Yamakawa
#
# ToDo:
#   1. Add support for more types of files
#         e.g. binary files, we shouldn't try to `head` those
# #############################################################################

# Check FIFO
NNN_FIFO=${NNN_FIFO:-$1}
if [ ! -r "$NNN_FIFO" ]; then
    echo "Unable to open \$NNN_FIFO='$NNN_FIFO'" | less
    exit 2
fi

# Read selection from $NNN_FIFO
while read -r selection; do
    clear
    lines=$(($(tput lines)-1))
    cols=$(tput cols)

    # Print directory tree
    if [ -d "$selection" ]; then
        cd "$selection" || continue
        tree | head -n $lines | cut -c 1-"$cols"
        continue
    fi

    # Print file head
    if [ -f "$selection" ]; then
        head -n $lines "$selection" | cut -c 1-"$cols"
        continue
    fi

    # Something went wrong
    echo "Unknown type: '$selection'"
done < "$NNN_FIFO"

# =======  =======

nnn-preview ()
{
    # Block nesting of nnn in subshells
    if [ -n "$NNNLVL" ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, remove the "export" as in:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # NOTE: NNN_TMPFILE is fixed, should not be modified
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # This will create a fifo where all nnn selections will be written to
    NNN_FIFO="$(mktemp --suffix=-nnn -u)"
    export NNN_FIFO
    (umask 077; mkfifo "$NNN_FIFO")

    # Preview command
    preview_cmd="sh ~/.config/nnn/plugins/yulj"

    # Use `tmux` split as preview
    if [ -e "${TMUX%%,*}" ]; then
        tmux split-window -e "NNN_FIFO=$NNN_FIFO" -dh "$preview_cmd"

    # Use `xterm` as a preview window
    elif (which alacritty &> /dev/null); then
        alacritty -e "$preview_cmd" &

    # Unable to find a program to use as a preview window
    else
        echo "unable to open preview, please install tmux or xterm"
    fi

    nnn "$@"

    rm -f "$NNN_FIFO"
}
