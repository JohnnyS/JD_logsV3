local configRawFile = LoadResourceFile(GetCurrentResourceName(), "./configs/config.json")
Config = json.decode(configRawFile)
local channelRawFile = LoadResourceFile(GetCurrentResourceName(), "./configs/channels.json")
Channels = json.decode(channelRawFile)
if Config ~= nil then
	local langFile = LoadResourceFile(GetCurrentResourceName(), "./lang/" .. Config.language .. ".json")
	lang = json.decode(langFile)
end
local startup = false

CreateThread(function() --[[ Permissions check for buildin DiscordAcePerms ]]
	add_principal = true remove_principal = true addd_ace = true remove_ace = true
	if not IsPrincipalAceAllowed('resource.' .. GetCurrentResourceName(), 'command.add_principal') then
		print('^1Error:^0 JD_logs needs to have access to ^2add_principal^0 for the discord permissions to work.')
		add_principal = false
	end
	if not IsPrincipalAceAllowed('resource.' .. GetCurrentResourceName(), 'command.remove_principal') then
		print('^1Error:^0 JD_logs needs to have access to ^2remove_principal^0 for the discord permissions to work.')
		remove_principal = false
	end
	if not IsPrincipalAceAllowed('resource.' .. GetCurrentResourceName(), 'command.add_ace') then
		print('^1Error:^0 JD_logs needs to have access to ^2add_ace^0 for the discord permissions to work.')
		addd_ace = false
	end
	if not IsPrincipalAceAllowed('resource.' .. GetCurrentResourceName(), 'command.remove_ace') then
		print('^1Error:^0 JD_logs needs to have access to ^2remove_ace^0 for the discord permissions to work.')
		remove_ace = false
	end
	if not add_principal or not remove_principal or not addd_ace or not remove_ace then
		print('^1Error:^0 Make sure to add the following lines to your ^2server.cfg^0')
		print('^3add_ace resource.' .. GetCurrentResourceName() .. ' command.add_principal allow^0')
		print('^3add_ace resource.' .. GetCurrentResourceName() .. ' command.remove_principal allow^0')
		print('^3add_ace resource.' .. GetCurrentResourceName() .. ' command.add_ace allow^0')
		print('^3add_ace resource.' .. GetCurrentResourceName() .. ' command.remove_ace allow^0')
	end

	if Config ~= nil then
		if not Config.token then
			print('^1Error: Issue loading config file. Please follow the installation guild on the docs: https://docs.prefech.com^0')
		end
		if not Config.guildId then
			print('^1Error: Issue loading config file. Please follow the installation guild on the docs: https://docs.prefech.com^0')
		end
	else
		print('^1Error: Issue loading config file. Please follow the installation guild on the docs: https://docs.prefech.com^0')
	end

	Wait(15 * 1000)
	startup = true
end)

AddEventHandler("playerConnecting", function(name, setReason, deferrals)
	local src = source
	ServerFunc.CreateLog({ EmbedMessage = lang.join.msg:gsub("{name}", GetPlayerName(src)), player_id = src, channel = 'join'})
	deferrals.defer()
	Wait(50)
	deferrals.update(lang.join.update)
	if Config.CheckTimeout then
		ServerFunc.CheckTimeout({userId = ServerFunc.ExtractIdentifiers(src).discord:gsub("discord:", "")}, function(data)
			Wait(500)
			if not data.state then
				deferrals.done()
			else
				ServerFunc.CreateLog({ EmbedMessage = lang.join.deny:gsub("{name}", GetPlayerName(src)):gsub("{expire}", data.expire), channel = 'leave', color = '#F23A3A'})
				msg = lang.join.timeout:gsub("{expire}", data.expire)
				deferrals.done(msg)
			end
		end)
	else
		deferrals.done()
	end
end)

AddEventHandler('playerDropped', function(reason)
	local src = source
	ServerFunc.CreateLog({EmbedMessage = lang.leave.msg:gsub("{name}", GetPlayerName(src)):gsub("{reason}", reason), player_id = src, channel = 'leave'})
end)

AddEventHandler('chatMessage', function(source, name, msg)
	local src = source
	if msg:sub(1, 1) ~= '/' then
		ServerFunc.CreateLog({EmbedMessage = lang.chat.msg:gsub("{name}", GetPlayerName(src)):gsub("{msg}", msg), player_id = src, channel = 'chat'})
	end
end)

AddEventHandler('onResourceStart', function (resourceName)
	Wait(100)
	if Config ~= nil then
		ServerFunc.CreateLog({EmbedMessage = lang.resource.start_msg:gsub("{resource}", ServerFunc.decode(resourceName)), channel = 'resource'})
	end
end)

AddEventHandler('onResourceStop', function (resourceName)
	ServerFunc.CreateLog({EmbedMessage = lang.resource.stop_msg:gsub("{resource}", ServerFunc.decode(resourceName)), channel = 'resource'})
end)

local explosionTypes = {'GRENADE', 'GRENADELAUNCHER', 'STICKYBOMB', 'MOLOTOV', 'ROCKET', 'TANKSHELL', 'HI_OCTANE', 'CAR', 'PLANE', 'PETROL_PUMP', 'BIKE', 'DIR_STEAM', 'DIR_FLAME', 'DIR_GAS_CANISTER', 'BOAT', 'SHIP_DESTROY', 'TRUCK', 'BULLET', 'SMOKEGRENADELAUNCHER', 'SMOKEGRENADE', 'BZGAS', 'FLARE', 'GAS_CANISTER', 'EXTINGUISHER', 'PROGRAMMABLEAR', 'TRAIN', 'BARREL', 'PROPANE', 'BLIMP', 'DIR_FLAME_EXPLODE', 'TANKER', 'PLANE_ROCKET', 'VEHICLE_BULLET', 'GAS_TANK', 'BIRD_CRAP', 'RAILGUN', 'BLIMP2', 'FIREWORK', 'SNOWBALL', 'PROXMINE', 'VALKYRIE_CANNON', 'AIR_DEFENCE', 'PIPEBOMB', 'VEHICLEMINE', 'EXPLOSIVEAMMO', 'APCSHELL', 'BOMB_CLUSTER', 'BOMB_GAS', 'BOMB_INCENDIARY', 'BOMB_STANDARD', 'TORPEDO', 'TORPEDO_UNDERWATER', 'BOMBUSHKA_CANNON', 'BOMB_CLUSTER_SECONDARY', 'HUNTER_BARRAGE', 'HUNTER_CANNON', 'ROGUE_CANNON', 'MINE_UNDERWATER', 'ORBITAL_CANNON', 'BOMB_STANDARD_WIDE', 'EXPLOSIVEAMMO_SHOTGUN', 'OPPRESSOR2_CANNON', 'MORTAR_KINETIC', 'VEHICLEMINE_KINETIC', 'VEHICLEMINE_EMP', 'VEHICLEMINE_SPIKE', 'VEHICLEMINE_SLICK', 'VEHICLEMINE_TAR', 'SCRIPT_DRONE', 'RAYGUN', 'BURIEDMINE', 'SCRIPT_MISSIL'}
AddEventHandler('explosionEvent', function(source, ev)
	local src = source
	print(explosionTypes[ev.explosionType + 1])
	ServerFunc.has_val(Config.ExplosionsNotLogged, explosionTypes[ev.explosionType + 1], function(resp)
		print(resp)
		if not resp then
			ServerFunc.CreateLog({EmbedMessage = lang.explosion.msg:gsub("{name}", GetPlayerName(src)):gsub("{type}", ServerExplotions.ExplosionNames[explosionTypes[ev.explosionType + 1]]), player_id = src, channel = 'explosion'})
		end
	end)
end)

AddEventHandler("playerJoining", function(newID, oldID) --[[ Name Change Logs / Discord Ace Perms. ]]
	local ids = ServerFunc.ExtractIdentifiers(newID)
	local oldName = GetResourceKvpString("JD_logs:nameChane:"..ids.license)
	if oldName == nil then
		SetResourceKvp("JD_logs:nameChane:"..ids.license, GetPlayerName(newID))
	else
		if oldName ~= GetPlayerName(newID) then
			ServerFunc.CreateLog({EmbedMessage = lang.nameChange.msg:gsub("{old_name}", oldName):gsub("{new_name}", GetPlayerName(newID)), player_id = newID, channel = 'nameChange'})
			SetResourceKvp("JD_logs:nameChane:"..ids.license, GetPlayerName(newID))
			for k,v in pairs(GetPlayers()) do
				if IsPlayerAceAllowed(v, Config.NameChangePerms) then
					TriggerClientEvent('chat:addMessage', i, {
						template = '<div style="background-color: rgba(90, 90, 90, 0.9); text-align: center; border-radius: 0.5vh; padding: 0.7vh; font-size: 1.7vh;"><b>Player ^1{0} ^0{1} ^1{2}</b></div>',
						args = { lang.nameChange.game_msg:gsub("{old_name}", oldName):gsub("{new_name}", GetPlayerName(newID)) }
					})
				end
			end
		end
	end
	if Config.UseDiscordAcePerms then
		local groups = ''
		local perms = ''
		ServerFunc.GetUser({ userId =  ids.discord:gsub("discord:", "")}, function(data)
			if data then
				for k, v in pairs(Config.DiscordAcePerms) do
					ServerFunc.has_val(data.roles, k, function(resp)
						if resp then
							if v.groups then
								for _, group in pairs(v.groups) do
									ExecuteCommand('add_principal identifier.' .. ids.license .. ' ' .. group)
									groups = groups .. '\n`👥` • '.. group:gsub("group.", "")
								end
							end
							if v.perms then
								for _, perm in pairs(v.perms) do
									ExecuteCommand('add_ace identifier.' .. ids.license .. ' ' .. perm .. ' allow')
									perms = perms .. '\n`🔒` • '.. perm
								end
							end
						end
					end)
				end
				if groups ~= '' or perms ~= '' then
					if groups == '' then groups = 'N/A' end
					if perms == '' then perms = 'N/A' end
					ServerFunc.CreateLog({EmbedMessage = lang.permission.msg:gsub("{name}", GetPlayerName(newID)), player_id = newID, channel = 'permission', fields = { { name = 'Groups:', value = groups, inline = true }, { name = 'Permissions:', value = perms, inline = true } } })
				end
			end
		end)
	end
end)

RegisterNetEvent("Prefech:JD_logsV3:GetConfigSettings")
AddEventHandler("Prefech:JD_logsV3:GetConfigSettings", function()
	if Config ~= nil then
		data = {
			weaponLog = Config.weaponLog,
			WeaponsNotLogged = Config.WeaponsNotLogged,
			language = Config.language,
			damageLog = Config.damageLog,
			deathLog = Config.deathLog
		}
		TriggerClientEvent("Prefech:JD_logsV3:SendConfigSettings", source, data)
	end
end)

RegisterServerEvent('Prefech:JD_logsV3:playerShotWeapon') --[[ Shooting logs. ]]
AddEventHandler('Prefech:JD_logsV3:playerShotWeapon', function(weapon, count)
	if not weapon then
		print('^1Error:^0 A weapon was fired, however this weapon is not in' .. GetCurrentResourceName() .. '/client/clientTables.lua. ^1' .. GetPlayerName(source) .. ' Fired this weapon^0')
	end
	if Config.weaponLog then
		ServerFunc.CreateLog({EmbedMessage = lang.shooting.msg:gsub("{name}", GetPlayerName(source)):gsub("{weapon}", weapon):gsub("{count}", count), player_id = source, channel = 'shooting'})
    end
end)

RegisterServerEvent('Prefech:JD_logsV3:playerDied')
AddEventHandler('Prefech:JD_logsV3:playerDied',function(args)
	if args.kil == 0 then
		ServerFunc.CreateLog({EmbedMessage = args.rsn, player_id = source, channel = 'death'})
	else
		ServerFunc.CreateLog({EmbedMessage = args.rsn, player_id = source, player_2_id = args.kil, channel = 'death'})
	end
end)

RegisterServerEvent('Prefech:JD_logsV3:PlayerDamage') --[[ Damaghe Logs. ]]
AddEventHandler('Prefech:JD_logsV3:PlayerDamage', function(args)
	if Config.damageLog then
		iPed = GetPlayerPed(source)
		cause = GetPedSourceOfDamage(iPed)
		dType = GetEntityType(cause)
		if dType == 0 then
			damageCause = lang.damage.type.self
		elseif dType == 1 then
			if IsPedAPlayer(cause) then
				if GetVehiclePedIsIn(cause, false) ~= 0 then
					damageCause = lang.damage.type.player_veh:gsub("{name}", GetPlayerName(getPlayerId(cause)))
				else
					damageCause = lang.damage.type.player:gsub("{name}", GetPlayerName(getPlayerId(cause)))
				end
			else
				if GetVehiclePedIsIn(cause, false) ~= 0 then
					damageCause = lang.damage.type.ai_veh
				else
					damageCause = lang.damage.type.ai
				end
			end
		elseif dType == 2 then
			driver = GetPedInVehicleSeat(cause, -1)
			if IsPedAPlayer(driver) then
				damageCause = lang.damage.type.player_veh:gsub("{name}", GetPlayerName(cause))
			else
				damageCause = lang.damage.type.veh
			end
		elseif dType == 3 then
			damageCause = lang.damage.type.obj
		end
		ServerFunc.CreateLog({EmbedMessage = lang.damage.msg:gsub("{name}", GetPlayerName(source)):gsub("{type}", damageCause):gsub("{health}", args), player_id = source, channel = 'damage'})
	end
end)

function getPlayerId(ped)
	for k,v in pairs(GetPlayers()) do
	   	if GetPlayerPed(v) == ped then
			return v
	   	end
	end
end

--[[ Export from client side. ]]
RegisterServerEvent('Prefech:JD_logsV3:ClientDiscord')
AddEventHandler('Prefech:JD_logsV3:ClientDiscord', function(args)
	ServerFunc.CreateLog(args)
end)

--[[ Exports from server side ]]
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
	ServerFunc.CreateLog(args)
end)

exports('createLog', function(args) --[[ and this is the new export with all new stuff. ]]
	ServerFunc.CreateLog(args)
end)

exports('getRoles', function(src)
	local ids = ServerFunc.ExtractIdentifiers(src)
	ServerFunc.GetUser({ userId =  ids.discord:gsub("discord:", "")}, function(data)
		return data.roles
	end)
end)

exports('hasRole', function(src, roleid)
	local ids = ServerFunc.ExtractIdentifiers(src)
	ServerFunc.GetUser({ userId =  ids.discord:gsub("discord:", "")}, function(data)
		for k,v in pairs(data.roles) do
			if v == roleid then
				return true
			end
		end
		return false
	end)
end)

exports('GetPlayers', function(args)
	return GetPlayers()
end)

RegisterNetEvent("Prefech:JD_logsV3:ScreenshotCB") --[[ Returning screenshot value. ]]
AddEventHandler("Prefech:JD_logsV3:ScreenshotCB", function(args)
	ServerFunc.CreateLog(args)
end)

CreateThread( function() --[[ Version Checker ]]
	local version = GetResourceMetadata(GetCurrentResourceName(), 'version')
	PerformHttpRequest('https://raw.githubusercontent.com/JohnnyS/JD_logsV3/master/json/version.json', function(code, res, headers)
		if code == 200 then
			local rv = json.decode(res)
			if tonumber(table.concat(mysplit(rv.version, "."))) > tonumber(table.concat(mysplit(version, "."))) then
					print(([[^1-------------------------------------------------------
					JD_logsV3
UPDATE: %s AVAILABLE
CHANGELOG: %s
-------------------------------------------------------^0]]):format(rv.version, rv.changelog))
				ServerFunc.CreateLog({ EmbedMessage = "**JD_logsV3 Update V"..rv.version.."**\nDownload the latest update of JD_logsV3 here:\nhttps://github.com/JohnnyS/JD_logsV3/\n\n**Changelog:**\n"..rv.changelog..'\n\n**How to update?**\n1. Download the latest version.\n2. Replace all files with your old once **EXCEPT THE CONFIG** folder.\n3. run the `!jdlogs setup` command again and you\'re done.', channel = 'system'})
			end
		end
	end, 'GET')
end)

--[[

All options for the export.

exports.JD_logsV3:createLog({
    EmbedMessage = "Embed Message", -- The Embed Message you want to show in the export.
    player_id = SERVER_ID_PLAYER_ONE, -- Server id for the first player (Optional)
    player_2_id = SERVER_ID_PLAYER_TWO, -- Server if for the second player (Optional)
    channel = "Channel name from channels.json | Discord Channel ID | Discord Webhook URL", -- You have 3 options here.
    screenshot = true, -- Make a screenshot of the first player (Optional)
	screenshot_2 = true, -- Make a screenshot of the second player (Optional)
	title = 'Custom Title', -- Set a custom title for this export (Optional)
	color = '#A1A1A1', -- Set a custom color for this export (Optional)
	icon = '✅' -- Set a custom icon for this export (Requires Custom Title) (Optional)
	noEmbed = false -- Enable or disable the embed (Player details and more fileds will be removed!!)
})

]]