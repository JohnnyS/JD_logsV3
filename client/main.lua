Config = nil
lang = nil

CreateThread(function()
    while Config == nil do
        TriggerServerEvent("Prefech:JD_logsV3:GetConfigSettings") --[[ On client load this will make a request to the server to pull some config data. ]]
        Wait(0)
    end
    while lang == nil do
        if Config ~= nil then
            local langFile = LoadResourceFile(GetCurrentResourceName(), "lang/" .. Config.language .. ".json")
            lang = json.decode(langFile)
            print("Trying to load language file.")
            Wait(1000)
        end
    end
end)

RegisterNetEvent("Prefech:JD_logsV3:SendConfigSettings")
AddEventHandler("Prefech:JD_logsV3:SendConfigSettings", function(data)
    	Config = data --[[ Just the config data for weapon logs will be pulled. ]]
        if lang == nil then
            local langFile = LoadResourceFile(GetCurrentResourceName(), "lang/" .. Config.language .. ".json")
            lang = json.decode(langFile)
        end
end)

--[[ Screenshot request on client. ]]
RegisterNetEvent('Prefech:JD_logsV3:ClientCreateScreenshot')
AddEventHandler('Prefech:JD_logsV3:ClientCreateScreenshot', function(args)
    exports['screenshot-basic']:requestScreenshotUpload('https://discord.com/api/webhooks/'..args.url, 'files[]', function(data)
        local resp = json.decode(data)
		if resp.attachments then
            if args.screenshot then
                args.imageUrl = resp.attachments[1].url
                args.screenshot = false
            end
            if args.screenshot_2 and not args.screenshot then
                args.imageUrl_2 = resp.attachments[1].url
                args.screenshot_2 = false
            end
            TriggerServerEvent('Prefech:JD_logsV3:ScreenshotCB', args)
        end
    end)
end)

--[[ Exports ]]
exports('discord', function(msg, player_1, player_2, color, channel) --[[ This is to support the export from v1. ]]
	args ={
		['EmbedMessage'] = msg,
		['color'] = color,
		['channel'] = channel
	}
	if player_1 ~= 0 then
		args['player_id'] = player_1
	end
	if player_2 ~= 0 then
		args['player_2_id'] = player_2
	end
	TriggerServerEvent('Prefech:JD_logsV3:ClientDiscord', args)
end)

exports('createLog', function(args) --[[ and this is the new export with all new stuff. ]]
	TriggerServerEvent('Prefech:JD_logsV3:ClientDiscord', args)
end)

--[[ Shooting logs. ]]
CreateThread(function()
    Wait(1000) --[[ Waiting for Config data to return from the server.]]
    local currWeapon = 0
    local fireWeapon = nil
    local timeout = 0
    local fireCount = 0
    while Config.weaponLog do --[[ Checking if shooting logs is enabled. ]]
        Wait(0)
        local playerped = GetPlayerPed(PlayerId())
        if IsPedShooting(playerped) then --[[ if the player is shooting we want to start counting the shots. ]]
            fireWeapon = GetSelectedPedWeapon(playerped)
            fireCount = fireCount + 1
            timeout = 1000 --[[ Set an active timout to make sure they don't stop for half a second with shooting to spam logs. ]]
        elseif not IsPedShooting(playerped) and fireCount ~= 0 and timeout ~= 0 then --[[ When they player is finished shooring or the timeout has expires we will make the log. ]]
            if timeout ~= 0 then
                timeout = timeout - 1 --[[ When the player is not shooting we will lower the timer. ]]
            end
            if fireWeapon ~= GetSelectedPedWeapon(playerped) then
                timeout = 0
            end
            if fireCount ~= 0 and timeout == 0 then --[[ When the timer is 0 and the weapon fire count is higher than 0 we will make a log. ]]
                if not ClientTables.WeaponNames[tostring(fireWeapon)] then --[[ Weapon info not found. creating log without weapon info. ]]
                    TriggerServerEvent('Prefech:JD_logsV3:playerShotWeapon', lang.shooting.undefined)
                    return
                end
                isLoggedWeapon = true
                for k,v in pairs(Config.WeaponsNotLogged) do --[[ Cheking if we need to make a log for the weapon that was shot. ]]
                    if fireWeapon == GetHashKey(v) then
                        isLoggedWeapon = false
                    end
                end
                if isLoggedWeapon then --[[ Sending the log with weapon info. ]]
                    TriggerServerEvent('Prefech:JD_logsV3:playerShotWeapon', ClientTables.WeaponNames[tostring(fireWeapon)], fireCount)
                end
                fireCount = 0
            end
        end
    end
end)

--[[ Damage logs. ]]
CreateThread(function()
    Wait(1000)
	local health = nil
	while Config.damageLog do --[[ Checking if damage logs is enabled. ]]
		Wait(0)
		if health == nil then health = GetEntityHealth(PlayerPedId()) end -- need to know the health if we gonna log the change of it ;)
		if health < GetEntityHealth(PlayerPedId()) then health = GetEntityHealth(PlayerPedId()) end -- Just to make sure we don't log when healt gets added
		if health > GetEntityHealth(PlayerPedId()) then
			newHealth = GetEntityHealth(PlayerPedId())
			TriggerServerEvent('Prefech:JD_logsV3:PlayerDamage', math.floor((health - newHealth) / 2))
			health = newHealth
			Wait(1000)
		else
			Wait(1000)
		end
	end
end)

--[[ Death Logs ]]
CreateThread(function()
    Wait(1000)
	local hasRun = false
	while Config.deathLog do
		Wait(0)
		local iPed = PlayerPedId()
		if IsEntityDead(iPed) then
			if not hasRun then
				hasRun = true
				local kPed = GetPedSourceOfDeath(iPed)
				local cause = GetPedCauseOfDeath(iPed)
				local DeathCause = ClientTables.deatCause[cause]
				local killer = 0
				local kPlayer = NetworkGetPlayerIndexFromPed(kPed)
				Wait(1000)
				if kPlayer == PlayerId() then
					if DeathCause ~= nil then
						if DeathCause[2] ~= nil then
							DeathReason = lang.death.suicide.weapon:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{weapon}", DeathCause[2])
						else
							DeathReason = lang.death.suicide.event:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1])
						end
					else
						DeathReason = lang.death.suicide.player:gsub("{name}", GetPlayerName(PlayerId()))
					end
				elseif kPlayer == nil or kPlayer == -1 then
					if kPed == 0 then
						if DeathCause ~= nil then
							if DeathCause[2] ~= nil then
								DeathReason = lang.death.suicide.weapon:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{weapon}", DeathCause[2])
							else
								DeathReason = lang.death.suicide.event:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1])
							end
						else
							DeathReason = lang.death.suicide.player:gsub("{name}", GetPlayerName(PlayerId()))
						end
					else
						if IsEntityAPed(kPed) then
							if DeathCause ~= nil then
								if DeathCause[2] ~= nil then
									DeathReason = lang.death.ai.weapon:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{weapon}", DeathCause[2])
								else
									DeathReason = lang.death.ai.event:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1])
								end
							else
								DeathReason = lang.death.ai.other:gsub("{name}", GetPlayerName(PlayerId()))
							end
						else
							if IsEntityAVehicle(kPed) then
								if IsEntityAPed(GetPedInVehicleSeat(kPed, -1)) then
									if IsPedAPlayer(GetPedInVehicleSeat(kPed, -1)) then
										killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(kPed, -1))
                                        if DeathCause ~= nil then
                                            if DeathCause[2] ~= nil then
                                                DeathReason = lang.death.player.weapon:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{weapon}", DeathCause[2]):gsub("{killer}", GetPlayerName(killer))
                                            else
                                                DeathReason = lang.death.player.event:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{killer}", GetPlayerName(killer))
                                            end
                                        else
                                            DeathReason = lang.death.player.other:gsub("{name}", GetPlayerName(PlayerId())):gsub("{killer}", GetPlayerName(killer))
                                        end
									else
										if DeathCause ~= nil then
                                            if DeathCause[2] ~= nil then
                                                DeathReason = lang.death.ai.weapon:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{weapon}", DeathCause[2])
                                            else
                                                DeathReason = lang.death.ai.event:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1])
                                            end
                                        else
                                            DeathReason = lang.death.ai.other:gsub("{name}", GetPlayerName(PlayerId()))
                                        end
									end
								else
									if DeathCause ~= nil then
                                        if DeathCause[2] ~= nil then
                                            DeathReason = lang.death.unknown.weapon:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{weapon}", DeathCause[2])
                                        else
                                            DeathReason = lang.death.unknown.event:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1])
                                        end
                                    else
                                        DeathReason = lang.death.unknown.other:gsub("{name}", GetPlayerName(PlayerId()))
                                    end
								end
							end
						end
					end
				else
					killer = NetworkGetPlayerIndexFromPed(kPed)
					if DeathCause ~= nil then
                        if DeathCause[2] ~= nil then
                            DeathReason = lang.death.player.weapon:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{weapon}", DeathCause[2]):gsub("{killer}", GetPlayerName(killer))
                        else
                            DeathReason = lang.death.player.event:gsub("{name}", GetPlayerName(PlayerId())):gsub("{type}", DeathCause[1]):gsub("{killer}", GetPlayerName(killer))
                        end
                    else
                        DeathReason = lang.death.player.other:gsub("{name}", GetPlayerName(PlayerId())):gsub("{killer}", GetPlayerName(killer))
                    end
				end
				TriggerServerEvent('Prefech:JD_logsV3:playerDied', { ['rsn'] = DeathReason, ['kil'] = GetPlayerServerId(killer) })
			end
		else
			Wait(500)
			hasRun = false
		end
	end
end)