Config = {}

Config.WebhookURL = "YOUR_DISCORD_WEBHOOK_URL"

Config.Logging = {
    weaponLog = true,
    damageLog = true,
    deathLog = true,
    playerId = true,
    postals = true,
    playerHealth = true,
    playerArmor = true,
    playerPing = true,
    ip = true,
    steamUrl = true,
    discordId = {
        enabled = true,
        spoiler = true
    },
    steamId = {
        enabled = true,
        spoiler = true
    },
    license = {
        enabled = true,
        spoiler = true
    }
}

Config.WeaponsNotLogged = {
    "WEAPON_SNOWBALL",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PETROLCAN"
}
