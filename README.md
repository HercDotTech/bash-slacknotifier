### Main Script

```
 ____  _            _    _   _       _   _  __ _
/ ___|| | __ _  ___| | _| \ | | ___ | |_(_)/ _(_) ___ _ __
\___ \| |/ _  |/ __| |/ /  \| |/ _ \| __| | |_| |/ _ \ '__|
 ___) | | (_| | (__|   || |\  | (_) | |_| |  _| |  __/ |
|____/|_|\__,_|\___|_|\_\_| \_|\___/ \__|_|_| |_|\___|_|
---------------------------------------------------------------------------------
CREATED BY: HercTech | LICENCE: GNU AGPLv3
https://github.com/herctech/bash-slacknotifier
---------------------------------------------------------------------------------

Usage: slackNotifier <action> <action_parameters>

On Ubuntu or Debian:
    - install JQ by running 'sudo apt-get install jq'

On MacOS:
    - install brew (https://brew.sh/)
    - upgrade bash by running 'brew install bash'!
    - install JQ by running 'brew install jq'!

---------------------------------------------------------------------------------
    AVAILABLE ACTIONS
---------------------------------------------------------------------------------

token   o   Writes the given token to a file so it can be reused without having to pass it every time
            Usage: slackNotifier token token=
            Notes:
                The token passed will be set system wide. Do not use this if you need to implement multiple tokens.
                If the token is set this way it does not have to be passed on every call.

send    o   Sends a message to the specified channel
            Usage: slackNotifier send channel= text= [color=] [attachments=]
            Notes:
                You cannot use 'text' and 'color' if you are using 'attachments'!

reply   o   Replies to a message in the specified channel
            Usage: slackNotifier reply channel= broadcast= text= [color=] [attachments=] [ts=|payload=]
            Notes:
                You cannot use 'text' and 'color' if you are using 'attachments'!
                Either 'ts' or 'payload' should be provided!

edit    o   Edits a message in the specified channel
            Usage: slackNotifier edit channel= text= [color=] [attachments=] [ts=|payload=]
            Notes:
                You cannot use 'text' and 'color' if you are using 'attachments'!
                Either 'ts' or 'payload' should be provided!

remove  o   Removes a message in the specified channel
            Usage: slackNotifier remove channel= [ts=|payload=]
            Notes:
                Either 'ts' or 'payload' should be provided!

custom  o   Sends a custom payload to a custom endpoint
            Usage: slackNotifier custom channel= payload=
            Notes:
                In this case the channel should be set to the API endpoint (Eg: chat.postMessage)!

parse   o   Parses the given payload to extract certain values
            Usage: slackNotifier parse payload= field=
            Notes:
                The field path must be given in the format below
                <top_level_element>[.<sub_element>].<element> (EG: .status.ok)
                See JQ (https://stedolan.github.io/jq/manual/) for more details

---------------------------------------------------------------------------------
    AVAILABLE ACTION PARAMETERS
---------------------------------------------------------------------------------

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
```
### Examples Script
```
 ____  _            _    _   _       _   _  __ _
/ ___|| | __ _  ___| | _| \ | | ___ | |_(_)/ _(_) ___ _ __
\___ \| |/ _  |/ __| |/ /  \| |/ _ \| __| | |_| |/ _ \ '__|
 ___) | | (_| | (__|   || |\  | (_) | |_| |  _| |  __/ |
|____/|_|\__,_|\___|_|\_\_| \_|\___/ \__|_|_| |_|\___|_|
---------------------------------------------------------------------------------
CREATED BY: HercTech | LICENCE: GNU AGPLv3
https://github.com/herctech/bash-slacknotifier
---------------------------------------------------------------------------------

This is the examples script. It does require you to have a Slack APP oAuth BOT token ready before you can actually use
the calls to this script to test the main one.

For more details run 'slackNotifier help'

Usage: slackExamples <example> <channel_name> <token>


---------------------------------------------------------------------------------
    AVAILABLE EXAMPLES
---------------------------------------------------------------------------------

send    o   Will send a message to the specified channel

reply   o   Will send a message to the specified channel and then a reply to it

edit    o   Will send a message to the specified channel and 10 seconds later it will edit it

remove  o   Will send a message to the specified channel and 10 seconds later it will remove it

custom  o   Will send a message to the specified channel using the custom functionality
```
