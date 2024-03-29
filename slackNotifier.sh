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

Usage: slackNotifier <action> <action_parameters>
${COLOR_BLUE}
On Ubuntu or Debian:
    - install JQ by running 'sudo apt-get install jq'

On MacOS:
    - install brew (https://brew.sh/)
    - upgrade bash by running 'brew install bash'!
    - install JQ by running 'brew install jq'!
$COLOR_GREEN
---------------------------------------------------------------------------------
    ${TEXT_BOLD}AVAILABLE ACTIONS${TEXT_RESET}
---------------------------------------------------------------------------------
$COLOR_END
token   o   Writes the given token to a file so it can be reused without having to pass it every time
            Usage: slackNotifier token token=
            ${COLOR_RED}Notes:
                The token passed will be set system wide. Do not use this if you need to implement multiple tokens.
                If the token is set this way it does not have to be passed on every call.

send    o   Sends a message to the specified channel
            Usage: slackNotifier send channel= text= [color=] [attachments=]
            ${COLOR_RED}Notes:
                You cannot use 'text' and 'color' if you are using 'attachments'!${COLOR_END}

reply   o   Replies to a message in the specified channel
            Usage: slackNotifier reply channel= broadcast= text= [color=] [attachments=] [ts=|payload=]
            ${COLOR_RED}Notes:
                You cannot use 'text' and 'color' if you are using 'attachments'!
                Either 'ts' or 'payload' should be provided!${COLOR_END}

edit    o   Edits a message in the specified channel
            Usage: slackNotifier edit channel= text= [color=] [attachments=] [ts=|payload=]
            ${COLOR_RED}Notes:
                You cannot use 'text' and 'color' if you are using 'attachments'!
                Either 'ts' or 'payload' should be provided!${COLOR_END}

remove  o   Removes a message in the specified channel
            Usage: slackNotifier remove channel= [ts=|payload=]
            ${COLOR_RED}Notes:
                Either 'ts' or 'payload' should be provided!${COLOR_END}

custom  o   Sends a custom payload to a custom endpoint
            Usage: slackNotifier custom channel= payload=
            ${COLOR_RED}Notes:
                In this case the channel should be set to the API endpoint (Eg: chat.postMessage)!${COLOR_END}

parse   o   Parses the given payload to extract certain values
            Usage: slackNotifier parse payload= field=
            ${COLOR_RED}Notes:
                The field path must be given in the format below
                <top_level_element>[.<sub_element>].<element> (EG: .status.ok)
                See JQ (https://stedolan.github.io/jq/manual/) for more details
$COLOR_GREEN
---------------------------------------------------------------------------------
    ${TEXT_BOLD}AVAILABLE ACTION PARAMETERS${TEXT_RESET}
---------------------------------------------------------------------------------
$COLOR_END
token       - The oAuth token to be used to send messages. You can skip this if you've run 'slackNotifier token' and set
              it system wide

channel     - The channel to which the message will be sent
            - When used with 'custom' the channel should be set to the API endpoint (Eg: chat.postMessage)

text        - The text of the message to be sent ( Cannot be used together with 'attachments' )

color       - The color of the message to be sent ( Cannot be used together with 'attachments' )

attachments - The attachments to be sent with the message ( Overrides 'text' and 'color' )

ts          - The reference used to reply to, edit or remove a message

payload     - When used with 'custom' the payload will be sent as is to SlackAPI
            - When used with 'reply' action this has to be the payload of the first message in the thread
            - When used with 'edit' or 'remove' actions this needs to be the payload of the message to edit or remove
            - When used with 'parse' action this sets the payload to be parsed (JSON format, see JQ for more details)

field       - This sets the 'path' of the field to be extracted when used with 'parse' action, otherwise unavailable
            - See JQ for more details on patterns accepted by 'field'

broadcast   - When replying to messages setting this to 'true' will cause the message to also be posted in the main
              channel

""";
exit 0
}

# Slack token filepath (easily configurable by changing this one variable)
SLACK_TOKEN_FILE=".token"

# Slack API URL (easily configurable by changing this one variable)
SLACK_API_URL="https://slack.com/api/"

# Define parameters
CHANNEL=""
TS=""
TEXT=""
COLOR=""
ATTACHMENTS=""
BROADCAST=""
SLACK_TOKEN=""
JSON_PAYLOAD=""
JSON_FIELD=""

# Auxiliary globals
MESSAGE_PAYLOAD=""

function outputError {
    echo -e "${COLOR_RED}$1 Run 'slackNotifier help' for help page!${COLOR_END}"
}

function getSlackToken {
    if [[ -e ${SLACK_TOKEN_FILE} ]]; then
        SLACK_TOKEN="$(cat ${SLACK_TOKEN_FILE})"
    else
        outputError "Missing token file '${SLACK_TOKEN_FILE}' in '$(pwd)'!"
        exit 1
    fi
}

function checkTokenExists {
    if [[ -z ${SLACK_TOKEN} ]]; then
        outputError "Missing Slack oAuth token!"
        exit 1
    fi
}

function checkJQIsInstalled {
    local jqBin="$(which jq)"
    if [[ -z ${jqBin} ]]; then
        outputError "Missing JQ dependency!"
        exit 2
    fi
}

function listIncludesItem {
    local list="$1"
    local item="$2"

    if [[ ${list} =~ (^|[[:space:]])"$item"($|[[:space:]]) ]] ; then
        # list includes item
        echo "yes"
    else
        echo "no"
    fi
}

function getJSONValue {
    local path="$1"
    local json="$2"

    echo ${json} | jq --raw-output ${path}
}

function checkChannelValue {
    if [[ -z "$CHANNEL" ]]; then
        outputError "Channel value is empty!"
        exit 3
    fi
}

function makeRequest {
    local endpoint="$1"
    local payload="$2"

    echo $(curl -X POST -H "Authorization: Bearer $SLACK_TOKEN"  -H "Content-Type: application/json; charset=UTF8" --data "${payload}" --silent ${SLACK_API_URL}${endpoint})
}

function buildSendMessagePayload {
    if [[ -z "$ATTACHMENTS" ]] && [[ -z "$TEXT" ]]; then
        outputError "You cannot leave both 'text' and 'attachments' empty!"
        exit 3
    fi

    if [[ -n "$ATTACHMENTS" ]] && [[ -n "$TEXT" || -n "$COLOR" ]]; then
        outputError "You cannot use 'attachments' and 'text' or 'color'!"
        exit 3
    fi

    if [[ -z "$BROADCAST" ]]; then
        BROADCAST="false"
    fi

    # Just $TEXT passed in
    if [[ -n "$TEXT" && -z "$ATTACHMENTS" && -z "$COLOR" ]]; then
        MESSAGE_PAYLOAD=$(jq -n --arg t "$TEXT" --arg c "$CHANNEL" --arg s "$TS" --arg rb "$BROADCAST" '{"channel": $c, "text": $t, "thread_ts": $s, "reply_broadcast": $rb, "ts": $s, "mrkdwn": true}')
    fi

    # $TEXT and $COLOR passed in
    if [[ -n "$TEXT" && -z "$ATTACHMENTS" && -n "$COLOR" ]]; then
        MESSAGE_PAYLOAD=$(jq -n --arg t "$TEXT" --arg o "$COLOR"  --arg c "$CHANNEL" --arg s "$TS" --arg rb "$BROADCAST" '{"channel": $c, "thread_ts": $s, "reply_broadcast": $rb, "ts": $s, "attachments": [{"color": $o, "text": $t}], "mrkdwn": true}')
    fi

    # Just $ATTACHMENTS passed in
    if [[ -z "$TEXT" && -n "$ATTACHMENTS" && -z "$COLOR" ]]; then
        MESSAGE_PAYLOAD=$(jq -n --arg c "$CHANNEL"  --argjson a "$ATTACHMENTS" --arg s "$TS" --arg rb "$BROADCAST" '{"channel": $c, , "thread_ts": $s, "reply_broadcast": $rb, "ts": $s, "attachments": $a, "mrkdwn": true}')
    fi
}

function buildRemoveMessagePayload {
    # Check Channel and TS are set
    if [[ -n "$CHANNEL" && -n "$TS" ]]; then
        MESSAGE_PAYLOAD=$(jq -n --arg c "$CHANNEL"  --arg s "$TS" '{"channel": $c, "ts": $s}')
    else
        outputError "Missing TS and/or Channel!"
        exit 3
    fi
}

function getTSValue {
    if [[ -z "$TS" ]] && [[ -z "$JSON_PAYLOAD" ]]; then
        outputError "Either 'ts' or 'payload' required!"
        exit 3
    fi

    if [[ -z "$TS" ]]; then
        TS="$(getJSONValue ".ts" "${JSON_PAYLOAD}")"
        CHANNEL=$(getJSONValue ".channel" "${JSON_PAYLOAD}")
    else
        CHANNEL=convertChannelNameToID
    fi
}

function clearTSAndJSONPayload {
    TS=""
    JSON_PAYLOAD=""
}

function sendMessage {
    if [[ -n $1 ]]; then
        local payload=$(jq -n --arg t "$1" --arg c "$CHANNEL" '{"channel": $c, "text": $t}')
        echo $(makeRequest 'chat.postMessage' "${payload}")
    else
        echo $(makeRequest 'chat.postMessage' "${MESSAGE_PAYLOAD}")
    fi
}

function replyToMessage {
    echo $(makeRequest 'chat.postMessage' "${MESSAGE_PAYLOAD}")
}

function editMessage {
    echo $(makeRequest 'chat.update' "${MESSAGE_PAYLOAD}")
}

function removeMessage {
    if [[ -n $1 ]]; then
        echo $(makeRequest 'chat.delete' "$1")
    else
        echo $(makeRequest 'chat.delete' "${MESSAGE_PAYLOAD}")
    fi
}

function convertChannelNameToID {
    # Adding a deleting a message really is the only way :(
    local response="$(sendMessage 'channel id search')"
    local channelID="$(echo ${response} | jq .channel)"
    local ts="$(echo ${response} | jq .ts)"

    removeMessage '{"channel": '"$channelID"',"ts": '"$ts"'}'

    echo ${channelID}
}

function setToken {
    if [[ -e ".token" ]]; then
        rm ".token"
    fi

    touch ".token"
    echo ${SLACK_TOKEN} >> ".token"
}

# Check if only dependency is installed (JQ)
checkJQIsInstalled

# First argument should always be the action per the help, fetch it
SELECTED_ACTION="$1"

# If action wasn't passed in show help page
if [[ -z ${SELECTED_ACTION} || ${SELECTED_ACTION} = "help" ]]; then
    printHelp
fi

# Check action is allowed
if [[ "$(listIncludesItem 'help custom send reply edit remove parse token' ${SELECTED_ACTION})" = "no" ]]; then
    outputError "Action '${SELECTED_ACTION}' is unknown!"
    exit;
fi

# Parse all other arguments
for ARGUMENT in "$@"
do
    KEY=$(echo ${ARGUMENT} | cut -f1 -d=)
    VALUE=$(echo ${ARGUMENT} | cut -f2 -d=)

    case "$KEY" in
            channel)        CHANNEL=${VALUE} ;;
            ts)             TS=${VALUE} ;;
            text)           TEXT=${VALUE} ;;
            color)          COLOR=${VALUE} ;;
            attachments)    ATTACHMENTS=${VALUE} ;;
            broadcast)      BROADCAST=${VALUE} ;;
            token)          SLACK_TOKEN=${VALUE} ;;
            payload)        JSON_PAYLOAD=${VALUE} ;;
            field)          JSON_FIELD=${VALUE} ;;
            *)
                # Easy way to ignore actions from being parsed again
                if [[ "$(listIncludesItem 'help custom send reply edit remove parse token' ${KEY})" = "no" ]]; then
                    outputError "Unknown argument '$KEY'!"
                    exit;
                fi
            ;;
    esac
done

# If the selected action is parse run it and exit
if [[ ${SELECTED_ACTION} = "parse" ]]; then
    echo $(getJSONValue "${JSON_FIELD}" "${JSON_PAYLOAD}")
    exit 0
fi

# If token wasn't passed in means it should be in the file, try to fetch it
if [[ ${SELECTED_ACTION} = "token" ]]; then
    setToken
    exit 0
fi

# If token wasn't passed in means it should be in the file, try to fetch it
if [[ -z ${SLACK_TOKEN} ]]; then
    getSlackToken
fi

# Check the token isn't empty
checkTokenExists

# Check Channel is set
checkChannelValue

# Run the selected action
case "${SELECTED_ACTION}" in
    send)
        clearTSAndJSONPayload
        buildSendMessagePayload
        echo $(sendMessage)
    ;;
    reply)
        getTSValue
        buildSendMessagePayload
        echo $(replyToMessage)
    ;;
    edit)
        getTSValue
        buildSendMessagePayload
        echo $(editMessage)
    ;;
    remove)
        getTSValue
        buildRemoveMessagePayload
        echo $(removeMessage)
    ;;
    custom)
        echo $(makeRequest "${CHANNEL}" "${JSON_PAYLOAD}")
    ;;
    *)
        outputError "Something went wrong, unknown action ${SELECTED_ACTION}!"
    ;;
esac

exit 0