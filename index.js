const { Console } = require('console');
const { Client, Collection, MessageEmbed } = require('discord.js');
const { glob } = require("glob");
const { promisify } = require("util");
const globPromise = promisify(glob);

try {
    config = require("./configs/config.json");
    channels = require("./configs/channels.json");
} catch {}

const permissionCheck = ["MANAGE_CHANNELS", "SEND_MESSAGES", "VIEW_CHANNEL", "MANAGE_WEBHOOKS"]

client = new Client({
    intents: 32767,
    partials: ["CHANNEL"],
});

const eventFiles = fs.readdirSync(`${GetResourcePath(GetCurrentResourceName())}/events/`).filter(file => file.endsWith('.js'));
for (const file of eventFiles) {
	const event = require(`./events/${file}`);
	if (event.once) {
		client.once(event.name, (...args) => event.execute(...args));
	} else {
		client.on(event.name, (...args) => event.execute(...args));
	}
}

const commandFiles = fs.readdirSync(`${GetResourcePath(GetCurrentResourceName())}/commands/`).filter(file => file.endsWith('.js'));
for (const file of commandFiles) {
	const event = require(`./commands/${file}`);
	if (event.once) {
		client.once(event.name, (...args) => event.execute(...args));
	} else {
		client.on(event.name, (...args) => event.execute(...args));
	}
}


client.on('messageCreate', async (message) => {
    const {channel, content, guild, author} = message;
    if(content.toLowerCase().startsWith(`${client.config.prefix}players`)){
        const tUser = await message.guild.members.cache.get(author.id);
        if(!tUser.permissions.has("MANAGE_MESSAGES")) return message.reply({content: "⛔ | Missing Permissions to use this command.\nNeeded permission flag: `MANAGE_MESSAGES`"})
        const players = await exports[GetCurrentResourceName()].GetPlayers()
        let playerlist = 'No Players Online.'
        for (const [k, v] of Object.entries(players)) {
            console.log(k,v)
            if(playerlist === 'No Players Online.'){
                playerlist = `**${Number(k) + 1}.** ${GetPlayerName(v)} - Server ID: \`${v}\``
            } else {
                playerlist = `\n${playerlist} **${k + 1}.** ${GetPlayerName(v)} - Server ID: \`${v}\``
            };
        };
        message.reply({embeds: [new MessageEmbed().setColor("RANDOM").setDescription(playerlist)]})
    }
})

process.on('unhandledRejection', error => {
	console.log(error);
});

process.setMaxListeners(config.maxListeners);

try {
    client.config = config;
    client.login(config.token);
} catch {}