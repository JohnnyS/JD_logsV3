module.exports = {
	name: 'messageCreate',
	once: false,
	async execute(message) {
		const {channel, content, guild, author} = message;
		if(content.toLowerCase().startsWith(`${client.config.prefix}create`)){
			const tUser = await message.guild.members.cache.get(author.id);
			if(!tUser.permissions.has("ADMINISTRATOR")) return message.reply({content: "⛔ | Missing Permissions to use this command.\nNeeded permission flag: `ADMINISTRATOR`"})
			const channels = JSON.parse(LoadResourceFile(GetCurrentResourceName(), '/configs/channels.json'));
			newChannel = {}
			message.delete()
			channels[newChannel.name] = {
				"channelId": 0,
				"icon": '',
				"color": '',
				"embed": true
			}
			await question(message, 'name','What do you want to call the export channel?')
			await question(message, 'icon','What icon do you want to use?')
			await question(message, 'color','What hex color do you want to use?')
			channels[newChannel.name] = {
				"channelId": 0,
				"icon": newChannel.icon,
				"color": newChannel.color,
				"embed": true
			}
			x = await guild.channels.cache.find(cc => cc.name === `Custom Logs` && cc.type === 'GUILD_CATEGORY')
			nc = false
			if(x){
				let cc = await guild.channels.cache.find(cc => cc.name === `・${newChannel.name}-logs`)
				if(!cc){
					await guild.channels.create(`${channels[newChannel.name].icon}・${newChannel.name}-logs`, "GUILD_TEXT").then(async c => {
						await c.setParent(x.id);
						channels[newChannel.name].channelId = c.id
						nc = true
					})
				} else {
					channels[newChannel.name].channelId = cc.id
					nc = false
				}
			} else {
				guild.channels.create('Custom Logs', {
					type: 'GUILD_CATEGORY',
				}).then(async x => {
					let cc = await guild.channels.cache.find(cc => cc.name === `・${newChannel.name}-logs`)
					if(!cc){
						await guild.channels.create(`${channels[newChannel.name].icon}・${newChannel.name}-logs`, "GUILD_TEXT").then(async c => {
							await c.setParent(x.id);
							channels[newChannel.name].channelId = c.id
						})
						nc = true
					} else {
						nc = false
						channels[newChannel.name].channelId = cc.id
					}
				})
			}
			channel.send(`Creating channel...`).then(m => {
				setTimeout(() => {
					m.delete()
				}, 5000)
			})
			setTimeout(() => {
				if(nc){
					const newChannels = JSON.stringify(channels)
					SaveResourceFile(GetCurrentResourceName(), '/configs/channels.json', newChannels);
					let embed = new MessageEmbed()
						.setTimestamp()
						.setDescription(`**Details:**\n\n**Export Channel:** \`${newChannel.name}\`\n**Discord Channel Name:** \`#・${newChannel.name}-logs\` - \`${channels[newChannel.name].channelId}\`\n**Message Icon:** ${newChannel.icon}\n**Embed Color:** \`${newChannel.color}\``)
						.setTitle("New Channel Created")
						.addField("Export for channel:", `\`\`\`lua
exports['${GetCurrentResourceName()}']:createLog({
	EmbedMessage = "EMBED MESSAGE",
	player_id = SERVER_ID_PLAYER_ONE,
	player_2_id = SERVER_ID_PLAYER_TWO,
	channel = "${newChannel.name}",
	screenshot = false
})
\`\`\`\n*More info about using the export can be found here: <https://docs.prefech.com/jd_logsv3/export>*`)
					channel.send({embeds: [embed]})
				} else {
					channel.send({content:`:no_entry: **|** Channel with the name \`#${`・${newChannel.name}-logs`}\` already exsists.\n<#${channels[newChannel.name].channelId}>`})
				}
			}, 5000);
		}
	},
};

async function question(message, x, q){
    const msg_filter = (m) => m.author.id === message.author.id;
	await message.channel.send(q).then(async (msg) => {
		await message.channel.awaitMessages({
			filter: msg_filter,
			max: 1,
			time: 30000,
			errors: ['time']
		}).then(async message => {
			message = message.first()
			if (message.content.toUpperCase() == 'CANCEL' || message.content.toUpperCase() == 'C') {
				message.channel.send(`⛔ **|** Channel creation canceled.`)
				msg.delete()
				message.delete()
				return
			} else if (message.content.toUpperCase() == 'SKIP' || message.content.toUpperCase() == 'S') {
				newChannel[x] = ''
				msg.delete()
				message.delete()
				return
			} else {
				newChannel[x] = message.content
				msg.delete()
				message.delete()
				return
			}
		})
		.catch(collected => {
			return message.channel.send('⛔ **|** Channel creation timed out.');
		});
	})
}