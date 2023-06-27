const { MessageEmbed } = require("discord.js");

module.exports = {
	name: 'ready',
	once: true,
	async execute() {
        try {
            const channels = JSON.parse(LoadResourceFile(GetCurrentResourceName(), '/configs/channels.json'));
            if(channels['imageStore'].channelId == ''){ return }
            const c = await client.channels.cache.get(channels['imageStore'].channelId);
            const guild = c.guild;
            if(!guild.me.permissions.has("MANAGE_WEBHOOKS")){ return }
            if(c === undefined){ return }
            const hooks = await guild.fetchWebhooks();
            await hooks.forEach(async webhook => {
                if(webhook.channelId === c.id){
                    webhook.delete(`Requested per JD_logs`);
                }
            });
            await c.createWebhook('Image Store Webhook', {}).then(async hook => {
                channels['imageStore'].webhookID = hook.id;
                channels['imageStore'].webhookToken = hook.token;
                console.log(`^2New Screenshot Webhook Generated. (Old one got deleted)^0`)
            })

            const newChannels = JSON.stringify(channels, null, 2)
            SaveResourceFile(GetCurrentResourceName(), '/configs/channels.json', newChannels);
            if(client.config.WebhookResetMessage){
                await c.send({embeds: [new MessageEmbed().setTitle(`🧹・Webhook for Image store has been Reset!`)]})
            }
        } catch {
            console.log(`^1JD_logs Error: ^0Could not generate a new webhook.`)
        }
    }
};