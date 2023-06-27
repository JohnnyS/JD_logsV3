module.exports = {
	name: 'messageCreate',
	once: false,
	async execute(message) {
		const {channel, content, guild, author} = message;
		if(content.toLowerCase().startsWith(`${client.config.prefix}hide`)){
			message.react("✅");
			const tUser = await message.guild.members.cache.get(author.id);
			if(!tUser.permissions.has("ADMINISTRATOR")) return message.reply({content: "⛔ | Missing Permissions to use this command.\nNeeded permission flag: `ADMINISTRATOR`"})
			const args = content.split(" ")
			if(!args[3]){ return message.reply(`Please use \`${client.config.prefix}hide CHANNEL INPUT\`\nFor eaxmple: \`${client.config.prefix}hide chat ip\``)}
			let status = await GetResourceKvpString(`JD_logs:${(args[2])}:${args[3]}`)
			if(status === "false" || status === null){
				status = 'true'
			} else {
				status = 'false'
			}
			await SetResourceKvp(`JD_logs:${args[2].toLowerCase()}:${args[3].toLowerCase()}`, status)
			message.reply(`:white_check_mark: **|** Updated the hide status for ${args[2]} (${args[3]}) to: \`${status}\``)
		}

		if(content.toLowerCase().startsWith(`${client.config.prefix}channelid`)){
			message.react("✅");
			const tUser = await message.guild.members.cache.get(author.id);
			if(!tUser.permissions.has("ADMINISTRATOR")) return message.reply({content: "⛔ | Missing Permissions to use this command.\nNeeded permission flag: `ADMINISTRATOR`"})
			message.reply(`:white_check_mark: **|** The channel id for **#${channel.name}** is: \`${channel.id}\``)
		}

		if(content.toLowerCase().startsWith(`${client.config.prefix}resethook`)){
            message.react("✅");
            const tUser = await message.guild.members.cache.get(author.id);
			if(!tUser.permissions.has("ADMINISTRATOR")) return message.reply({content: "⛔ | Missing Permissions to use this command.\nNeeded permission flag: `ADMINISTRATOR`"})
            const channels = JSON.parse(LoadResourceFile(GetCurrentResourceName(), '/configs/channels.json'));
            const args = content.split(" ")
            if(!channels['imageStore']){
                return channel.send(`Please use \`${client.config.prefix}setup\` first.`)
            }

            const c = await guild.channels.cache.get(channels['imageStore'].channelId)

            const hooks = await guild.fetchWebhooks();
            await hooks.forEach(async webhook => {
                if(webhook.channelId === c.id){
                    webhook.delete(`Requested per ${author.tag}`);
                }
            });

            await c.createWebhook('Image Store Webhook', {}).then(async hook => {
                channels['imageStore'].webhookID = hook.id;
                channels['imageStore'].webhookToken = hook.token;
            })

            const newChannels = JSON.stringify(channels, null, 2)
            SaveResourceFile(GetCurrentResourceName(), '/configs/channels.json', newChannels);
            channel.send(`Webhook for Image store has been reset!\n**If you set a webhook then the bot will delete the old one.**`)
		}

		if(content.toLowerCase().startsWith(`${client.config.prefix}uninstall`)){
			message.react("✅");
			const channels = JSON.parse(LoadResourceFile(GetCurrentResourceName(), '/configs/channels.json'));
			for (const [key, value] of Object.entries(channels)) {
				let channel = await client.channels.cache.get(value.channelId);
				try{
					await channel.delete()
				} catch {}
			};
		}

		if(content.toLowerCase().startsWith(`${client.config.prefix}help`)){
			message.react("✅");
			const tUser = await message.guild.members.cache.get(author.id);
			if(!tUser.permissions.has("ADMINISTRATOR")) return message.reply({content: "⛔ | Missing Permissions to use this command.\nNeeded permission flag: `ADMINISTRATOR`"})
			message.reply(`**Commands:**
\`${client.config.prefix}setup\` - Run the JD_logsV3 Setup.
\`${client.config.prefix}uninstall\` - Remove all channels used in JD_logsV3.
\`${client.config.prefix}create\` - Create a custom log channel.
\`${client.config.prefix}delete\` - Delete a custom log channel.
\`${client.config.prefix}embed\` - Enable or disable the embeds on a log channel.
\`${client.config.prefix}hide\` - Hide something from a specific log.
\`${client.config.prefix}resethook\` - Reset the screenshot webhook.
\`${client.config.prefix}screenshot\` - Request a screenshot from a player.
\`${client.config.prefix}ss\` - Request a screenshot from a player.
`)
		}

		if(content.toLowerCase().startsWith(`${client.config.prefix}delete`)){
            message.react("✅");
            const tUser = await message.guild.members.cache.get(author.id);
			if(!tUser.permissions.has("ADMINISTRATOR")) return message.reply({content: "⛔ | Missing Permissions to use this command.\nNeeded permission flag: `ADMINISTRATOR`"})
            const channels = JSON.parse(LoadResourceFile(GetCurrentResourceName(), '/configs/channels.json'));
            const args = content.split(" ")
            message.delete()

            if(!channels[args[2]]){
                return channel.send(`⛔ **|** No channel found with name: \`${args[2]}\``)
            }
            let dc = await guild.channels.cache.find(cc => cc.id === channels[args[2]].channelId) ?? null;
            try {
                await dc.delete();
                delete channels[args[2]];
            } catch {
                return channel.send(`⛔ **|** Could not delete channel <#${dc.id}}> for \`${args[2]}\``);
            }
            const newChannels = JSON.stringify(channels)
            SaveResourceFile(GetCurrentResourceName(), '/configs/channels.json', newChannels);
		}

		if(content.toLowerCase().startsWith(`${client.config.prefix}embed`)){
			message.react("✅");
			const tUser = await message.guild.members.cache.get(author.id);
			if(!tUser.permissions.has("ADMINISTRATOR")) return message.reply({content: "⛔ | Missing Permissions to use this command.\nNeeded permission flag: `ADMINISTRATOR`"})
			const channels = JSON.parse(LoadResourceFile(GetCurrentResourceName(), '/configs/channels.json'));
			const args = content.split(" ");
			if(args[2] == null || args[2] == undefined) return message.reply({content: "⛔ | You need to specify a channel.\nExample: `!embed chat`"})
			channels[args[2]].embed = !channels[args[2]].embed
			let state = 'Disabled'
			if(!channels[args[2]].noEmbed) state = 'Enabled'
			const newChannels = JSON.stringify(channels)
			SaveResourceFile(GetCurrentResourceName(), '/configs/channels.json', newChannels);
			channel.send({content:`✅ **|** Channel embeds have been \`${state}\`\n*Resource reload is required before changes can take effect.*`})
		}
	},
};