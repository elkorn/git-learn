#!/bin/bash

revision_file="./.git-learn-current-revision"
log_file="./.git-learn-log"
git="git --no-pager"
echo "" > .logfile

function init {
    $git checkout master
    $git log --abbrev-commit --pretty=oneline > .git-learn-log
    echo 0 > $revision_file
}

function get_revision_hash {
    cat $log_file | tail "-$1" | head -1 | cut -d ' ' -f1
}

function get_current_revision {
    cat $revision_file
}

function get_next_revision {
    echo $(($(get_current_revision)+1))
}

function get_previous_revision {
    echo $(($(get_current_revision)-1))
}

function go_to_revision {
    set_current_revision "$1"
    echo $(get_revision_hash "$1")
}

function go_to_next_revision {
    echo $(go_to_revision $(get_next_revision))
}

function go_to_previous_revision {
    echo $(go_to_revision $(get_previous_revision))
}

function set_current_revision {
    echo "$1" > $revision_file
}

function checkout_next_revision {
    checkout_revision $(go_to_next_revision)
}

function checkout_previous_revision {
    checkout_revision $(go_to_previous_revision)
}

function checkout_revision {
    $git checkout $1
}

function whats_new {
    $git diff $(get_revision_hash $(get_previous_revision)) --word-diff
}

function revision_info {
    $git log -1 --pretty=format:"%B"
}

while [[ $# > 0 ]]
do
    arg="$1"

    case $arg in
        -i|--init)
            init
            checkout_next_revision
            echo "Start learning."
            shift
            ;;
        -n|--next)
            checkout_next_revision
            shift
            ;;
        -p|--prev|--previous)
            checkout_previous_revision
            shift
            ;;
        -c|--changes)
            whats_new
            shift
            ;;
        -s|--scope)
            revision_info
            shift
            ;;
    esac
done
