ServerFunc = {}

ServerFunc.CreateLog = function(data)

    if Config ~= nil then
		if not Config.token or Config.token == "" then
			return print('^1Error:^0 Issue loading config file. Please follow the installation guild on the docs: https://docs.prefech.com')
		end
		if not Config.guildId or Config.guildId == "" then
			return print('^1Error:^0 Issue loading config file. Please follow the installation guild on the docs: https://docs.prefech.com')
		end
	else
		return print('^1Error:^0 Issue loading config file. Please follow the installation guild on the docs: https://docs.prefech.com')
	end

    if data.screenshot then --[[ this log requires a screenshot to be made so we will transfer to client to grab a screenshot. ]]
        local channelsLoadFile = LoadResourceFile(GetCurrentResourceName(), "./configs/channels.json")
        local theFile = json.decode(channelsLoadFile)
        data.url = theFile.imageStore.webhookID.."/"..theFile.imageStore.webhookToken
        return TriggerClientEvent('Prefech:JD_logsV3:ClientCreateScreenshot', data.player_id, data)
    end
    if data.screenshot_2 then --[[ this log requires a second screenshot to be made so we will transfer to client to grab a screenshot. ]]
        local channelsLoadFile = LoadResourceFile(GetCurrentResourceName(), "./configs/channels.json")
        local theFile = json.decode(channelsLoadFile)
        data.url = theFile.imageStore.webhookID.."/"..theFile.imageStore.webhookToken
        return TriggerClientEvent('Prefech:JD_logsV3:ClientCreateScreenshot', data.player_2_id, data)
    end
    newTitle = data.channel:gsub("^%l", string.upper) --[[ Format the title to the first word on upper case. ]]
    if not Channels[data.channel] or data.title then --[[ Check if the channel is in the channels.json and we make sure the user has not set a custom title. ]]
        if data.title then
            if data.icon then --[[ Making sure they have also added a icon. ]]
                newTitle = data.icon .. " " .. data.title --[[ since it's not in the channels.json the user can add a data.title and data.icon ]]
            else
                newTitle = "❓ " .. data.title --[[ No data.icon found so we will add the default question mark. ]]
            end
        else
            newTitle = '❓ Unknown Channel Name' --[[ No data.title found so we will maken in a unknown channel. ]]
        end
    else
        newTitle = Channels[data.channel].icon .. " " .. data.channel:gsub("^%l", string.upper)
    end

    color = '#A1A1A1' --[[ Setting a base color and then checking if one was provided or if we can grab one from the channels.json ]]
    if Channels[data.channel] and not data.color then --[[ check if the channel is in the channels.json or if a custom color was provided. ]]
        if Channels[data.channel].color then
            color = Channels[data.channel].color
        end
    elseif data.color then
        color = data.color --[[ Custom color found and there was no channel in the channels.json ]]
    end

    if data.noEmbed or Channels[data.channel].noEmbed then
        msg = {
            content = data.EmbedMessage,
        }
    else
        msg = {
            content = null,
            embeds = {
                {
                    title = newTitle,
                    description = data.EmbedMessage,
                    color = ConvertColor(color),
                    footer = {
                        text = "JD_logs V" .. GetResourceMetadata(GetCurrentResourceName(), 'version') .. "  •  Made by Prefech",
                        icon_url = "https://prefech.com/assets/favicon/apple-touch-icon.png"
                    },
                    timestamp = os.date("%Y-%m-%d") .. "T" ..os.date("%H:%M:%S") .. ".0000".. Config.TimezoneOffset
                }
            }
        }
    end

    if not data.noEmbed and not Channels[data.channel].noEmbed then
        if data.player_id then
            msg.embeds[1].fields = {
                {
                    name = "Player: ".. GetPlayerName(data.player_id),
                    value = GetPlayerDetails(data.player_id, data.channel)
                }
            }
            if data.imageUrl then --[[ There is a image we got provided provide to the embed. ]]
                table.insert(msg.embeds, {
                    title = "Screenshot: (" .. data.player_id .. ") - " .. GetPlayerName(data.player_id),
                    color = ConvertColor(color),
                    image = {
                        url = data.imageUrl
                    }
                })
            end
        end

        if data.player_2_id then
            table.insert(msg.embeds[1].fields, {
                name = "Player: ".. GetPlayerName(data.player_2_id),
                value = GetPlayerDetails(data.player_2_id, data.channel)
            })
            if data.imageUrl_2 then --[[ There is a second image we got provided provide to the embed. ]]
                table.insert(msg.embeds, {
                    title = "Screenshot: (" .. data.player_2_id .. ") - " .. GetPlayerName(data.player_2_id),
                    color = ConvertColor(color),
                    image = {
                        url = data.imageUrl_2
                    }
                })
            end
        end

        if data.fields then
            if not msg.embeds[1].fields then msg.embeds[1].fields = {} end
            for k,v in pairs(data.fields) do
                table.insert(msg.embeds[1].fields, {
                    name = v.name,
                    value = v.value,
                    inline = v.inline
                })
            end
        end
    end

    url = '' --[[ Get the url for the api used. ]]
    if tonumber(data.channel) == nil then --[[ Check ig the channel name is a number or a word. If its a number then we will assume its a channel id. ]]
        if string.find(data.channel, 'https://') then --[[ Check if the provided channel is a webhook. ]]
            url = data.channel
        elseif Channels[data.channel] then --[[ If it's not a webhook we will check in the channels.json ]]
            if string.find(Channels[data.channel].channelId, 'https://') then --[[ Check if the channels.json channelId is a webhook or a channel id. ]]
                url = Channels[data.channel].channelId --[[ Using the webhook url here. ]]
            else
                url = 'https://discord.com/api/v9/channels/' .. Channels[data.channel].channelId .. '/messages' --[[ Using the channel id here. ]]
            end
        end
    else
        url = 'https://discord.com/api/v9/channels/' .. data.channel .. '/messages' --[[ If the provided channel is not a webhook or a channel name from the channels.json we will assume its a channel id ]]
    end

    PerformHttpRequest(url, function() end, 'POST', json.encode(msg), { --[[ Sending the message to the channel. ]]
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. Config.token
    })

    if Config.allLogs then --[[ Check if all logs is enabled. ]]
        PerformHttpRequest('https://discord.com/api/v9/channels/' .. Channels['all'].channelId .. '/messages', function() --[[ Sending the message to the all logs channel. ]]
        end, 'POST', json.encode(msg), {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = 'Bot ' .. Config.token
        })
    end
end

ServerFunc.CheckTimeout = function(data, cb) --[[ Function for optional check on member's timeout on discord. ]]
    if Config.CheckTimeout then
        PerformHttpRequest('https://discord.com/api/v9/guilds/' .. Config.guildId .. '0/members/' .. data.userId, function(err, text, headers)
            if err == 200 then
                local timestamp = json.decode(text).communication_disabled_until --[[ If the member has a timeout this value will hold the expire timestamp. ]]
                if timestamp ~= nil then --[[ So when it is not nil the member has a timeout. ]]
                    local date = mysplit(mysplit(timestamp, 'T')[1], '-')
                    local time = mysplit(mysplit(mysplit(timestamp, 'T')[2], '.')[1], ':')
                    local expire = os.time({ year = date[1], month = date[2], day = date[3], hour = time[1], min = time[2], sec = time[3] })
                    local curTime = os.time(os.date("!*t"))
                    if expire > curTime then --[[ Checking if the expire time for the timeout was in the past since sometimes this value won't be removed when the timeout expires. ]]
                        cb({state = true, expire = SecondsToClock(expire - curTime)}) --[[ User has a timeout confirmd that has not expired and we will send the info back to the event. ]]
                    else
                        cb({state = false}) --[[ Timeout has expired and we will send that info back to the event. ]]
                    end
                else
                    cb({state = false}) --[[ Member does not have a timeout and we can send that info back to the event. ]]
                end
            else
                cb({state = false}) --[[ Unable to check timeout to letting them in the server. ]]
            end
        end, 'GET', '', {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = 'Bot ' .. Config.token
        })
    else
        cb({state = false})
    end
end

ServerFunc.GetUser = function(data, cb)
    PerformHttpRequest('https://discord.com/api/v9/guilds/' .. Config.guildId .. '/members/' .. data.userId, function(err, text, headers)
        if err == 200 then
            cb(json.decode(text))
        else
            cb(false)
        end
    end, 'GET', '', {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. Config.token
    })
end

ServerFunc.has_val= function(tab, val, cb)
    for k,v in pairs(tab) do
        if v == val then
            return cb(true)
        end
    end
    return cb(false)
end

ServerFunc.ExtractIdentifiers = function(src) --[[ Just  a simple function to grab all identifiers for a user. ]]
    local identifiers = {
        steam = "N/A",
        ip = "N/A",
        discord = "N/A",
        license = "N/A",
        license2 = "N/A",
        xbl = "N/A",
        live = "N/A",
        fivem = "N/A"
    }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam:") then
            identifiers['steam'] = id
        elseif string.find(id, "ip:") then
            identifiers['ip'] = id
        elseif string.find(id, "discord:") then
            identifiers['discord'] = id
        elseif string.find(id, "license:") then
            identifiers['license'] = id
        elseif string.find(id, "license2:") then
            identifiers['license2'] = id
        elseif string.find(id, "xbl:") then
            identifiers['xbl'] = id
        elseif string.find(id, "live:") then
            identifiers['live'] = id
        elseif string.find(id, "fivem:") then
            identifiers['fivem'] = id
        end
    end
    return identifiers
end

function mysplit(inputstr, sep) --[[ Function to split a string into an array. ]]
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function SecondsToClock(seconds) --[[ Format seconds to a display showing days, hours, minutes and seconds. ]]
	local days = math.floor(seconds / 86400)
	seconds = seconds - days * 86400
	local hours = math.floor(seconds / 3600 )
	seconds = seconds - hours * 3600
	local minutes = math.floor(seconds / 60)
	seconds = seconds - minutes * 60

	if days == 0 and hours == 0 and minutes == 0 then
		return string.format("%d seconds.", seconds)
	elseif days == 0 and hours == 0 then
		return string.format("%d minutes and %d seconds.", minutes, seconds)
	elseif days == 0 then
		return string.format("%d hours, %d minutes and %d seconds.", hours, minutes, seconds)
	else
		return string.format("%d days, %d hours, %d minutes and %d seconds.", days, hours, minutes, seconds)
	end
	return string.format("%d days, %d hours, %d minutes and %d seconds.", days, hours, minutes, seconds)
end

function ConvertColor(col) --[[ Function to convert hex colors to decimal colors. ]]
    if col ~= nil then
        if string.find(col,"#") then
            return tonumber(col:gsub("#",""),16)
        else
            return col
        end
    else
        return 000000
    end
end

function GetPlayerDetails(src, channel) --[[ Function to grab player details. ]]
    local ids = ServerFunc.ExtractIdentifiers(src)
    value = ""
    if Config.playerId and GetResourceKvpString("JD_logs:"..channel:lower()..":playerid") ~= 'true' then
        sid = src
        if channel == "join" then
            sid = "N/A"
        end
        value = value .. "\n`🔢` **Server ID:** `" .. sid .. "`"
    end
    if Config.postals and GetResourceKvpString("JD_logs:"..channel:lower()..":postals") ~= 'true' then
        value = value .. "\n`🗺️` **Nearest Postal:** `" .. GetPlayerPostal(src) .. "`"
    end
    if Config.playerHealth and GetResourceKvpString("JD_logs:"..channel:lower()..":health") ~= 'true' then
        value = value .. "\n`❤️` **Health:** `" .. math.floor(GetEntityHealth(GetPlayerPed(src)) / 2) .. "/100`"
    end
    if Config.playerArmor and GetResourceKvpString("JD_logs:"..channel:lower()..":armor") ~= 'true' then
        value = value .. "\n`🛡️` **Armour:** `" .. math.floor(GetPedArmour(GetPlayerPed(src))) .. "/100`"
    end
    if Config.discordId.enabled and GetResourceKvpString("JD_logs:"..channel:lower()..":discordid") ~= 'true' then
        if Config.discordId.spoiler then
            value = value .. "\n`💬` **Discord:** <@" .. ids.discord:gsub("discord:", "") .."> (||" .. ids.discord:gsub("discord:", "") .. "||)"
        else
            value = value .. "\n`💬` **Discord:** <@" .. ids.discord:gsub("discord:", "") .."> (`" .. ids.discord:gsub("discord:", "") .. "`)"
        end
    end
    if Config.ip and GetResourceKvpString("JD_logs:"..channel:lower()..":ip") ~= 'true' then
        value = value .. "\n`🔗` **IP:** ||" .. ids.ip:gsub("ip:", "") .. "||"
    end
    if Config.playerPing and GetResourceKvpString("JD_logs:"..channel:lower()..":ping") ~= 'true' then
        value = value .. "\n`📶` **Ping:** `" .. GetPlayerPing(src) .. "ms`"
    end
    if Config.steamId.enabled and GetResourceKvpString("JD_logs:"..channel:lower()..":steamid") ~= 'true' then
        if Config.steamId.spoiler then
            value = value .. "\n`🎮` **Steam Hex:** ||" .. ids.steam .. "||"
        else
            value = value .. "\n`🎮` **Steam Hex:** `" .. ids.steam .. "`"
        end
    end
    if Config.steamUrl and GetResourceKvpString("JD_logs:"..channel:lower()..":steamurl") ~= 'true' then
        if ids.steam and ids.steam ~= "N/A" then
            value = value .. " [`🔗` Steam Profile](https://steamcommunity.com/profiles/" ..tonumber(ids.steam:gsub("steam:", ""), 16)..")"
        end
    end

    if Config.license.enabled and GetResourceKvpString("JD_logs:"..channel:lower()..":license") ~= 'true' then
        if Config.license.spoiler then
            value = value .. "\n`💿` **License:** ||" .. ids.license .. "||"
            value = value .. "\n`📀` **License 2:** ||" .. ids.license2 .. "||"
        else
            value = value .. "\n`💿` **License:** `" .. ids.license .. "`"
            value = value .. "\n`📀` **License 2:** `" .. ids.license2 .. "`"
        end
    end

    if value ~= "" then
        return value
    else
        return "No info Avalible."
    end
end

function GetPlayerPostal(src) --[[ Get the neatest postal of the player. ]]
    local raw = LoadResourceFile(GetCurrentResourceName(), "./json/postals.json")

    local postals = json.decode(raw)
    local nearest = nil

    local player = src
    local ped = GetPlayerPed(player)
    local playerCoords = GetEntityCoords(ped)

    local x, y = table.unpack(playerCoords)

	local ndm = -1
	local ni = -1
	for i, p in ipairs(postals) do
		local dm = (x - p.x) ^ 2 + (y - p.y) ^ 2
		if ndm == -1 or dm < ndm then
			ni = i
			ndm = dm
		end
	end

	if ni ~= -1 then
		local nd = math.sqrt(ndm)
		nearest = {i = ni, d = nd}
	end
	_nearest = postals[nearest.i].code
	return _nearest
end

ServerFunc.decode = function(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)",
        function(h) return string.char(tonumber(h,16)) end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end