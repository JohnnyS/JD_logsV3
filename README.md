

# From the Docs website in case it goes down as well

I am/was (not even sure) a admin on the Prefech Discord. I am not sure what is going on with Prefech/JokeDevil but I wanted to upload these for those that need it. If you have a updated version OR the source code please let me know so I can update this but this should be working. Hopefully it works like this.

## Requirements
-   A Discord Server
-   FXServer with at LEAST **5562**
- [screenshot-basic](https://github.com/citizenfx/screenshot-basic)

## Main Features
-  Basic logs:
    -   Chat Logs (Messages typed in chat.)
    -   Join Logs (When i player is connecting to the sever.)
    -   Leave Logs (When a player disconnects from the server.)
    -   Death Logs (When a player dies/get killed.)
    -   Shooting Logs (When a player fires a weapon.)
    -   Resource Logs (When a resouce get started/stopped.)
    -   Explotion Logs (When a player creates an explotion.)
    -   Namechange Logs (When someone changes their steam name.)
-   Screenshot Logs (You can add screenshot of the players game to your logs.)
-   Optional custom logs
    -   Easy to add with the export.
# Commands
In Game
 - screenshot 
	 - /screenshot 12 
		 - Will make a screenshot of the target player and send them to discord.
Discord Commands:
- setup
	- !jdlogs setup
		- Will run the setup for creating channels and adding them to the channels.json.
- create
	- !jdlogs create
		- Will run the setup to create a export channel.
- delete
	- !jdlogs delete carrot
		- Will delete the channel carrot from the channels.json and the linked channel on discord.
- hide
	- !jdlogs hide screenshot ip
		- Will hide the ip from the screenshot logs.
- resethook
	- !jdlogs resethook
		- Will create a new webhook for imageStore. (Everytime JD_logsV3 starts the resource will create a new webhook anyways.)
- players
	- !jdlogs players
		- Will return a list of online players and their server id.
- screenshot
	- !jdlogs screenshot 1
		- Will create a screenshot of the player with server id 1.
- ss
	- !jdlogs ss 1
		- Screenshot command as well just shorter
- uninstall
	- !jdlogs uninstall
		- Will remove all channels created by JD_logsV3 from the discord.
# Installation
1. Download the latest version from here. *Note: If you have a more up to date version PLEASE SHARE!!*
	 *Since this is already built I assume it should work, I dont have source code.*
2. Put the JD_logsV3 folder in the server resource directory
    -   Make sure to rename the folder to  **JD_logsV3**.
Rename the  **example.config.json**  to  **config.json**  (The file is in the config folder)
Do the same for the  **example.channels.json**.
3. Get yourself the bot token and add them in the  `config.json`
    -   Not sure how to get a bot token?  [How to get a bot token.](https://forum.prefech.com/d/12-how-to-get-a-discord-bot-token)
    -   The bots need to have the following intents enabled:
        -   Presence Intent
        -   Server Members Intent
        -   Message Content Intent
4. Add this to your server.cfg
```
ensure JD_logsV3
```
5.  Start the resource once and let it build. *Prob dont need to since I built it already?*
6.  Go to your discord where you invited the bot (_The one where you want your new main logs to be._) and use the command  `!jdlogs setup`.
7.  Restart your server and you will see the logs on your discord.
  
 # Configuration

After you have installed JD_logs you can open the config file and change the settings to your needs. You will find the config file in the config folder.

When you just installed JD_logs your config should look like this:

```json
{
    "prefix":"!jdlogs ",
    "token": "",
    "guildId": "",
    "TimezoneOffset": "+00:00",
    "language": "en",

    "NameChangePerms": "jd.staff",
    "screenshotPerms": "jd.staff",

    "allLogs": true,

    "weaponLog": true,
    "damageLog": true,
    "deathLog": true,

    "playerId": true,
    "postals": true,
    "playerHealth": true,
    "playerArmor": true,
    "playerPing": true,

    "ip": true,
    "steamUrl": true,
    "discordId": {
        "enabled": true,
        "spoiler": true
    },
    "steamId": {
        "enabled": true,
        "spoiler": true
    },
    "license": {
        "enabled": true,
        "spoiler": true
    },

    "WebhookResetMessage": false,

    "WeaponsNotLogged": [
        "WEAPON_SNOWBALL",
        "WEAPON_FIREEXTINGUISHER",
        "WEAPON_PETROLCAN"
    ],

    "DiscordAcePerms": {
        "DISCORD_ROLE_ID": {
            "groups": ["group.admin", "group.mod"],
            "perms": ["jd.staff"]
        }
    }
}


```

#### Config settings:

![Basic Settings](https://imgur.com/JCAQiXz.png)

![Ace perms](https://imgur.com/Ao1Bz62.png)
	
![Additional Settings](https://imgur.com/UcxHX0X.png)


![Player Details](https://imgur.com/uC0jIT7.png)
  
  ![Rest of the settings](https://imgur.com/yDzWgWH.png)


# How to log
To make custom logs you will need to have some coding knowledge! We only provide the export we can not help you make use of it.

If you run into issues you can always open a ticket but there won’t be guarantee that we can help.

To create custom logs you will need to add the export to the event/function or command you want to log. This is in the resource you want to log You can use the command  `!jdlogs create`  on your discord server to setup a custom logs channel.

```lua
exports.JD_logsV3:createLog({
  EmbedMessage = "Embed Message",
  player_id = SERVER_ID_PLAYER_ONE,
  player_2_id = SERVER_ID_PLAYER_TWO,
  channel = "Channel name from channels.json | Discord Channel ID | Discord Webhook URL",
  screenshot = true,
	screenshot_2 = true,
	title = 'Custom Title',
	color = '#A1A1A1',
	icon = '✅'
})

```
*If you change the name of the resource make sure you update that on the logs export as well*
  


-   **EmbedMessage:**  This can be anything you want it to say.
    -   You can even use variables in it as long as they contain a value.
-   **player_id:**  This will be the server id of the first player.
    -   If you don’t have a first player you can remove this.
-   **player_2_id:**  This will be the server id of the second player.
    -   If you don’t have a second player you can remove this.
-   **channel:**  Will be pre filled out if you use the  `!jdlogs create`  command.
    -   This links to the channel in the  `channels.json`  This can also be the channel id or a webhook url.
-   **screenshot:**  this can be either true or false it will add a screenshot of the first player to embeds
-   **screenshot2:**  this can be either true or false it will add a screenshot of the second player to embeds
    -   You need to have embeds enabled on the channel to see screenshots!
-   **title:**  Set a custom title for this export only.
-   **color:**  Set a custom color for this export only. -**icon:**  Set a custom icon for this export only.


Since making custom logs are depending on what you want to logs i can not give any examples other than some standalone commands.

##### Using the export with no player details!
```lua
RegisterCommand("tweet", function(source, args, rawCommand)
    TriggerClientEvent('chatMessage', -1, "Tweet | " .. GetPlayerName(source)..": "..rawCommand:gsub("tweet ", ""), { 201, 201, 201 })
    exports.JD_logsV3:createLog({
        EmbedMessage = "Tweet | " .. GetPlayerName(source)..": "..rawCommand:gsub("tweet ", ""),
        channel = "tweet",
        screenshot = false
    })
end)
```
-   **EmbedMessage:**  This will be the /tweet message in this case
-   **player_id:**  Since there is no players we have removed it
-   **player_2_id:**  Since there is no players we have removed it
-   **color:**  This can be any color you want
-   **channel:**  This will be linked to the channel in the config.
#### Using the export for one player!

-   **player_id:**  is the variable that is used for getting the player info.
-   **player_2_id:**  isn’t used and therefore we can remove it from the export.

for server-side resources  `player_id`  will be  `source`  on client-side this will be  `GetPlayerServerId(PlayerId())`  
_Keep in mind these might also change depending on the framework_
```lua
RegisterCommand("me", function(source, args, rawCommand)
    TriggerClientEvent('chatMessage', -1, "ME | " .. GetPlayerName(source)..": "..rawCommand:gsub("me", ""), { 201, 201, 201 })
    exports.JD_logsV3:createLog({
        EmbedMessage = "ME | " .. GetPlayerName(source)..": "..rawCommand:gsub("me", ""),
        player_id = source,
        channel = "me",
        screenshot = false
    })
end)
```
-   **EmbedMessage:**  This will be the /me message in this case
-   **player_id:**  In this use it will be source
-   **player_2_id:**  Since there is one player we have removed it
-   **channel:**  This will be linked to the channel in the config.
-   **screenshot:**  This can be true if you want the embed to include a screenshot.

#### Using the export for two players!
-   **player_id:**  is the variable that is used for getting the player info.
-   **player_2_id:**  this will be the server id of the second player to get their info.

**player_2_id**  will be a server variable that is the server id of the second player  
_Keep in mind these might also change depending on the framework_

```lua
RegisterCommand("mention", function(source, args, rawCommand)
    TriggerClientEvent('chatMessage', -1, "Mention | " .. GetPlayerName(args[1]), { 201, 201, 201 })
    exports.JD_logsV3:createLog({
        EmbedMessage = "Mention | " .. GetPlayerName(args[1]),
        player_id = source,
        player_2_id = args[1],
        channel = "mention",
        screenshot = false
    })
end)
```
-   **EmbedMessage:**  This will be the /mention message in this case
-   **player_id:**  In this use it will be source
-   **player_2_id:**  Since there is one player we have removed it
-   **channel:**  This will be linked to the channel in the config.
-   **screenshot:**  This can be true if you want the embed to include a screenshot.
- 