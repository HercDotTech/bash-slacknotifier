#!/usr/bin/env bash

TEXT_BOLD="\e[1m"
TEXT_RESET="\e[21m"

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_BLUE="\e[34m"
COLOR_END="\e[0m"

function printHelp {
    echo -e """${COLOR_GREEN}
 ____  _            _    _   _       _   _  __ _
/ ___|| | __ _  ___| | _| \ | | ___ | |_(_)/ _(_) ___ _ __
\___ \| |/ _  |/ __| |/ /  \| |/ _ \| __| | |_| |/ _ \ '__|
 ___) | | (_| | (__|   || |\  | (_) | |_| |  _| |  __/ |
|____/|_|\__,_|\___|_|\_\_| \_|\___/ \__|_|_| |_|\___|_|
---------------------------------------------------------------------------------
${TEXT_BOLD}CREATED BY: HercTech | LICENCE: GNU AGPLv3${TEXT_RESET}
https://github.com/herctech/bash-slacknotifier
---------------------------------------------------------------------------------

This is the examples script. It does require you to have a Slack APP oAuth BOT token ready before you can actually use
the calls to this script to test the main one.

For more details run 'slackNotifier help'

Usage: slackExamples <example> <channel_name> <token>

$COLOR_GREEN
---------------------------------------------------------------------------------
    ${TEXT_BOLD}AVAILABLE EXAMPLES${TEXT_RESET}
---------------------------------------------------------------------------------
$COLOR_END
send    o   Will send a message to the specified channel

reply   o   Will send a message to the specified channel and then a reply to it

edit    o   Will send a message to the specified channel and 10 seconds later it will edit it

remove  o   Will send a message to the specified channel and 10 seconds later it will remove it

custom  o   Will send a message to the specified channel using the custom functionality
""";
exit 0
}

function outputError {
    echo -e "${COLOR_RED}$1 Run 'slackNotifier help' for help page!${COLOR_END}"
}

function getToken {
    if [[ -z ${TOKEN} && ! -e ".token" ]]; then
        outputError "Missing token!"
        exit 1
    fi

    if [[ -z ${TOKEN} ]]; then
        TOKEN=$(cat ".token")

        if [[ -z ${TOKEN} ]]; then
            outputError "Token file is empty!"
            exit 1
        fi
    fi
}

# EXAMPLE #1
# This is how you would call the script to send a message
function sendMessage {
    local text="*Test* _message_!"
    local color="good"
    local channel="${CHANNEL}"
    local token="${TOKEN}"

    PAYLOAD=$(./slackNotifier.sh send channel="${channel}" token="${token}" text="${text}" color="${color}")
}

# EXAMPLE #2
# This is how you would call the script to reply to a message
# We are using the global PAYLOAD of the previous message and passing that to the reply call so that the script know which
# message to reply to
function replyToMessage {
    local text="Test reply!"
    local color="danger"
    local channel="${CHANNEL}"
    local token="${TOKEN}"

    local response=$(./slackNotifier.sh reply channel="${channel}" token="${token}" text="${text}" color="${color}" payload="${PAYLOAD}")
}

# EXAMPLE #2.a
# This is how you would call the script to reply to a message
# We are using the global PAYLOAD of the previous message and passing that to the reply call so that the script know which
# message to reply to
function replyToMessageAndChannel {
    local text="Test reply!"
    local color="danger"
    local channel="${CHANNEL}"
    local token="${TOKEN}"

    local response=$(./slackNotifier.sh reply channel="${channel}" token="${token}" text="${text}" color="${color}" broadcast="true" payload="${PAYLOAD}")
}

# EXAMPLE #3
# This is how you would call the script to edit a message
# We are using the global PAYLOAD of the previous message and passing that to the reply call so that the script know which
# message to edit
function editMessage {
    local text="Test ~message~!"
    local color="danger"
    local channel="${CHANNEL}"
    local token="${TOKEN}"

    local response=$(./slackNotifier.sh edit channel="${channel}" token="${token}" text="${text}" color="${color}" payload="${PAYLOAD}")
}

# EXAMPLE #4
# This is how you would call the script to edit a message
# We are using the global PAYLOAD of the previous message and passing that to the reply call so that the script know which
# message to remove
function removeMessage {
    local channel="${CHANNEL}"
    local token="${TOKEN}"

    local response=$(./slackNotifier.sh remove channel="${channel}" token="${token}" payload="${PAYLOAD}")
}

# EXAMPLE #5
# This is how you would call the script to send a custom payload
function sendCustomPayload {
    # Replacing <channel> in the custom payload with the value of the channel provided
    local payload=$(cat "./custom_payload.json")
    payload="${payload//<channel>/${CHANNEL}}"

    # Replacing <timestamp> in the custom payload with the value of the current timestamp
    local timestamp=$(date +"%s")
    payload="${payload//<timestamp>/${timestamp}}"

    echo "Payload: ${payload}"

    local response=$(./slackNotifier.sh custom channel="chat.postMessage" payload="${payload}")
    echo ${response}
}

EXAMPLE="$1"
CHANNEL="$2"
TOKEN="$3"

getToken

# Run the selected example
case "${EXAMPLE}" in
    send)
        sendMessage
    ;;
    reply)
        sendMessage
        replyToMessage
    ;;
    edit)
        sendMessage
        echo "Waiting for 10 seconds ..."
        sleep 10
        editMessage
    ;;
    remove)
        sendMessage
        echo "Waiting for 10 seconds ..."
        sleep 10
        removeMessage
    ;;
    custom)
        sendCustomPayload
    ;;
    *)
        printHelp
    ;;
esac