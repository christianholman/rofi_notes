#!/bin/bash

NOTES_FOLDER="$HOME/.notes"
EDITOR="kitty nvim"
AUTHOR="Christian Holman>"

if [[ ! -a "${NOTES_FOLDER}" ]]; then
    mkdir NOTES_FOLDER
fi

get_notes() {
    ls ${NOTES_FOLDER}
}

edit_note() {
    note_location=$1
    $EDITOR "$note_location"
}

delete_note() {
    local note=$1
    local action=$(echo -e "Yes\nNo" | rofi -dmenu -p "Are you sure you want to delete $note?")

    case $action in
        "Yes")
            rm "$NOTES_FOLDER/$note"
            main
            ;;
        "No")
            main
    esac
}

note_context() {
    local note=$1
    local note_location="$NOTES_FOLDER/$note"
    local action=$(echo -e "Edit\nDelete" | rofi -dmenu -p "$note > ")
    case $action in
        "Edit")
            edit_note $note_location
            ;;
        "Delete")
            delete_note $note

    esac
}

new_note() {
    local title=$(echo -e "Cancel" | rofi -dmenu -p "Title: ")

    case "$title" in
        "Cancel")
            main
            ;;
        *)
            local file=$(echo "$title" | sed 's/ /_/g;s/\(.*\)/\L\1/g')
            local template=$(cat <<- END
---
title: $title
date: $(date --rfc-3339=seconds)
author: $AUTHOR
---

# $title
END
            )

            note_location="$NOTES_FOLDER/$file.md"
            if [ "$title" != "" ]; then
                echo "$template" > "$note_location" | edit_note $note_location
            fi
            ;;
    esac
}

main()
{
    local all_notes="$(get_notes)"

    local note=$(echo -e "New\n${all_notes}"  | rofi -dmenu -p "Note: ")

    case $note in 
        "New")
            new_note
            ;;
        "")
            ;;
        *)
            note_context $note
    esac
}


main
