```
 ____  _            _    _   _       _   _  __ _
/ ___|| | __ _  ___| | _| \ | | ___ | |_(_)/ _(_) ___ _ __
\___ \| |/ _` |/ __| |/ /  \| |/ _ \| __| | |_| |/ _ \ '__|
 ___) | | (_| | (__|   <| |\  | (_) | |_| |  _| |  __/ |
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

parse   o   Parses the given payload to extract certain values
            Usage: slackNotifier parse payload= field=
            Notes:
                The field path must be given in the format below
                <top_level_element>[.<sub_element>].<element> (EG: status.ok)
                See JQ (https://stedolan.github.io/jq/manual/) for more details


---------------------------------------------------------------------------------
    AVAILABLE ACTION PARAMETERS
---------------------------------------------------------------------------------

channel     - Sets the channel to which the message will be sent

ts          - Reference used for replying to message and/or editing/removing messages

text        - Text of the message ( Cannot be used together with 'attachments' )

color       - Sets the color of the message ( Cannot be used together with 'attachments' )

attachments - Sets the attachments to be sent with the message ( Overrides 'text' and 'color' )

broadcast   - When replying to messages setting this to 'true' will cause the message to also be posted in the main channel

token       - You can pass the oAuth token to be used in this parameter or alternatively set the token in the '.token' file

payload     - If used with 'parse' action this sets the payload to be parsed (JSON format, see JQ for more details)
              If used with 'reply' action this has to be the payload of the first message in the thread.
              If used with 'edit' or 'remove' actions this needs to be the payload of the message to edit or remove respectively.

field       - This sets the 'path' of the field to be extracted when used with 'parse' action, otherwise unavailable
              See JQ for more details on patterns accepted by 'field'
```
