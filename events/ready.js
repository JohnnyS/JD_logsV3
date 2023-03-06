const { MessageEmbed } = require("discord.js");

module.exports = {
	name: 'ready',
	once: true,
	async execute() {
        console.log(`Client ${client.user.tag} ready!`)
    }
};