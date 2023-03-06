RegisterCommand('jdlogs', function(source, args, RawCommand)
	if source == 0 then
		if args[1]:lower() == "hide" then
            if not args[3] then return print("^1Error: Please use 'jdlogs hide [channel] [object]'^0") end
            if Channels[args[2]:lower()] then
                state = GetResourceKvpString("JD_logs:"..args[2]:lower()..":"..args[3]:lower())
                if state == 'false' or state == nil then _state = 'true' else _state = 'false' end
                SetResourceKvp("JD_logs:"..args[2]:lower()..":"..args[3]:lower(), _state)
                print('^5[JD_logs]^1: Updated the hide status for '..args[2]:lower()..' ('..args[3]:lower()..') to: '.._state..'^0')
            else
                print("^1Error: Channel "..args[2]:lower().." does not exist. (Make sure to add it to your channels.json before using this command.)^0")
            end
        end
	end
end)

RegisterCommand('screenshot', function(source, args, RawCommand)
	if source == 0 then
		if args[1] == nil then
			return console.log('^1JD_logs Error:^0 Please insert a target (1 argument expected got nil)')
		end
		TriggerEvent("JD_logsV3:ScreenshotCommand", args[1], 'Console')
	else
		if IsPlayerAceAllowed(source, Config.screenshotPerms) then
			if args[1] == nil then
				return TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {"JD_logsV3", "Please insert a target (use /screenshot id)"}})
			end
			if GetPlayerPing(args[1]) ~= 0 then
				TriggerEvent("JD_logsV3:ScreenshotCommand", args[1], GetPlayerName(source))
			else
				return TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {"JD_logsV3", "There is no player online with id "..args[1]}})
			end
		end
	end
end)

RegisterNetEvent("JD_logsV3:ScreenshotCommand")
AddEventHandler("JD_logsV3:ScreenshotCommand", function(tId, src)
	ServerFunc.CreateLog({
		EmbedMessage = "**Screenshot of:** `"..GetPlayerName(tId).."`\n**Requested by:** `"..src.."`",
		player_id = tId,
		channel = "screenshot",
		screenshot = true
	})
end)