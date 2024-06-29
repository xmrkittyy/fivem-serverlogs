PerformHttpRequest = PerformHttpRequest or HttpRequest

Config = Config or {}
local WEBHOOK_URL = Config.WebhookURL

local playerConnectionTimes = {}

local function sendToDiscord(title, message, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color,
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S", os.time())
            }
        }
    }
    
    PerformHttpRequest(WEBHOOK_URL, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end

local function formatPlayerInfo(playerId)
    local info = {}
    if Config.Logging.playerId then
        table.insert(info, "**ID:** " .. playerId)
    end
    if Config.Logging.ip then
        table.insert(info, "**IP:** " .. GetPlayerEndpoint(playerId))
    end
    if Config.Logging.steamUrl then
        local steamId = GetPlayerIdentifier(playerId, "steam")
        if steamId then
            table.insert(info, "**Steam URL:** https://steamcommunity.com/profiles/" .. tonumber(steamId, 16))
        end
    end
    if Config.Logging.discordId.enabled then
        local discordId = GetPlayerIdentifier(playerId, "discord")
        if discordId then
            if Config.Logging.discordId.spoiler then
                table.insert(info, "||**Discord ID:** " .. discordId .. "||")
            else
                table.insert(info, "**Discord ID:** " .. discordId)
            end
        end
    end
    if Config.Logging.steamId.enabled then
        local steamId = GetPlayerIdentifier(playerId, "steam")
        if steamId then
            if Config.Logging.steamId.spoiler then
                table.insert(info, "||**Steam ID:** " .. steamId .. "||")
            else
                table.insert(info, "**Steam ID:** " .. steamId)
            end
        end
    end
    if Config.Logging.license.enabled then
        local license = GetPlayerIdentifier(playerId, "license")
        if license then
            if Config.Logging.license.spoiler then
                table.insert(info, "||**License:** " .. license .. "||")
            else
                table.insert(info, "**License:** " .. license)
            end
        end
    end
    if Config.Logging.playerHealth then
        local health = GetEntityHealth(GetPlayerPed(playerId))
        table.insert(info, "**Health:** " .. health)
    end
    if Config.Logging.playerArmor then
        local armor = GetPedArmour(GetPlayerPed(playerId))
        table.insert(info, "**Armor:** " .. armor)
    end
    if Config.Logging.playerPing then
        local ping = GetPlayerPing(playerId)
        table.insert(info, "**Ping:** " .. ping)
    end
    return table.concat(info, "\n")
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        sendToDiscord("Server Event", "Server started.", 3066993)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        sendToDiscord("Server Event", "Server stopped.", 15158332)
    end
end)

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local playerId = source
    local message = "**Player:** " .. playerName .. "\n" .. formatPlayerInfo(playerId)
    
    playerConnectionTimes[playerId] = os.time()
    
    sendToDiscord("Player Connecting", message, 3066993)
end)

AddEventHandler("playerDropped", function(reason)
    local playerId = source
    local playerName = GetPlayerName(playerId)
    local connectionTime = playerConnectionTimes[playerId]
    local disconnectTime = os.time()
    local sessionDuration = os.difftime(disconnectTime, connectionTime)
    local message = "**Player:** " .. playerName .. "\n" .. formatPlayerInfo(playerId) .. "\n**Reason:** " .. reason .. "\n**Session Duration:** " .. sessionDuration .. " seconds"
    
    playerConnectionTimes[playerId] = nil
    
    sendToDiscord("Player Disconnected", message, 15158332)
end)

RegisterServerEvent("chatMessage")
AddEventHandler("chatMessage", function(source, name, message)
    local logMessage = "**Player:** " .. name .. "\n" .. formatPlayerInfo(source) .. "\n**Message:** " .. message
    sendToDiscord("Chat Message", logMessage, 3447003)
end)

AddEventHandler("rconCommand", function(commandName, args)
    local playerId = source
    local message = "**Player ID:** " .. playerId .. " executed command: " .. commandName .. " with args: " .. table.concat(args, " ")
    sendToDiscord("Command Executed", message, 10181046)
end)

CreateThread(function()
    while true do
        local cpuUsage = GetConvar("sv_cpuUsage", "N/A")
        local memoryUsage = GetConvar("sv_memoryUsage", "N/A")
        local message = "CPU Usage: " .. cpuUsage .. "%, Memory Usage: " .. memoryUsage .. "MB"
        sendToDiscord("Server Performance", message, 15844367)
        Wait(60000)
    end
end)

AddEventHandler("baseevents:onPlayerKilled", function(killerId, data)
    if not Config.Logging.weaponLog then return end
    if Config.WeaponsNotLogged[data.weaponHash] then return end

    local victimId = source
    local message = "**Killer ID:** " .. killerId .. "\n" .. formatPlayerInfo(killerId) .. "\n**Victim ID:** " .. victimId .. "\n" .. formatPlayerInfo(victimId) .. "\n**Weapon Hash:** " .. data.weaponHash
    sendToDiscord("Player Killed", message, 15105570)
end)

AddEventHandler("baseevents:onPlayerDied", function(data)
    if not Config.Logging.deathLog then return end

    local playerId = source
    local message = "**Player ID:** " .. playerId .. "\n" .. formatPlayerInfo(playerId) .. "\n**Cause:** " .. data.cause
    sendToDiscord("Player Died", message, 15105570)
end)

RegisterServerEvent("economy:transaction")
AddEventHandler("economy:transaction", function(senderId, receiverId, amount, reason)
    local message = "**Sender ID:** " .. senderId .. "\n" .. formatPlayerInfo(senderId) .. "\n**Receiver ID:** " .. receiverId .. "\n" .. formatPlayerInfo(receiverId) .. "\n**Amount:** $" .. amount .. "\n**Reason:** " .. reason
    sendToDiscord("Transaction", message, 3066993)
end)

RegisterServerEvent("inventory:change")
AddEventHandler("inventory:change", function(playerId, item, changeType, amount)
    local message = "**Player ID:** " .. playerId .. "\n" .. formatPlayerInfo(playerId) .. "\n**Change Type:** " .. changeType .. "\n**Amount:** " .. amount .. "\n**Item:** " .. item
    sendToDiscord("Inventory Change", message, 3447003)
end)

RegisterServerEvent("admin:command")
AddEventHandler("admin:command", function(adminId, commandName, args)
    local message = "**Admin ID:** " .. adminId .. "\n" .. formatPlayerInfo(adminId) .. "\n**Command Name:** " .. commandName .. "\n**Args:** " .. table.concat(args, " ")
    sendToDiscord("Admin Command", message, 10181046)
end)

RegisterServerEvent("admin:ban")
AddEventHandler("admin:ban", function(adminId, playerId, reason)
    local message = "**Admin ID:** " .. adminId .. "\n" .. formatPlayerInfo(adminId) .. "\n**Banned Player ID:** " .. playerId .. "\n" .. formatPlayerInfo(playerId) .. "\n**Reason:** " .. reason
    sendToDiscord("Player Banned", message, 15158332)
end)

RegisterServerEvent("admin:kick")
AddEventHandler("admin:kick", function(adminId, playerId, reason)
    local message = "**Admin ID:** " .. adminId .. "\n" .. formatPlayerInfo(adminId) .. "\n**Kicked Player ID:** " .. playerId .. "\n" .. formatPlayerInfo(playerId) .. "\n**Reason:** " .. reason
    sendToDiscord("Player Kicked", message, 15158332)
end)

AddEventHandler("onResourceError", function(resourceName, error)
    local message = "Resource: " .. resourceName .. " encountered an error: " .. error
    sendToDiscord("Resource Error", message, 15158332)
end)

AddEventHandler("onResourceWarning", function(resourceName, warning)
    local message = "Resource: " .. resourceName .. " encountered a warning: " .. warning
    sendToDiscord("Resource Warning", message, 15844367)
end)

AddEventHandler("onResourceStart", function(resourceName)
    local message = "Resource: " .. resourceName .. " has started."
    sendToDiscord("Resource Start", message, 3066993)
end)

AddEventHandler("onResourceStop", function(resourceName)
    local message = "Resource: " .. resourceName .. " has stopped."
    sendToDiscord("Resource Stop", message, 15158332)
end)

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local playerId = source
    local ipAddress = GetPlayerEndpoint(playerId)
    local message = "**Player:** " .. playerName .. "\n" .. formatPlayerInfo(playerId) .. "\n**IP:** " .. ipAddress
    sendToDiscord("Connection Attempt", message, 3066993)
end)

RegisterServerEvent("admin:banIP")
AddEventHandler("admin:banIP", function(adminId, ip, reason)
    local message = "**Admin ID:** " .. adminId .. "\n**Banned IP:** " .. ip .. "\n**Reason:** " .. reason
    sendToDiscord("IP Ban", message, 15158332)
end)

RegisterServerEvent("custom:event")
AddEventHandler("custom:event", function(eventData)
    local message = "Custom event data: " .. json.encode(eventData)
    sendToDiscord("Custom Event", message, 10181046)
end)

CreateThread(function()
    while true do
        for _, playerId in ipairs(GetPlayers()) do
            local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(playerId)))
            local message = "**Player ID:** " .. playerId .. "\n" .. formatPlayerInfo(playerId) .. "\n**Position:** X=" .. x .. " Y=" .. y .. " Z=" .. z
            sendToDiscord("Player Position", message, 3447003)
        end
        Wait(300000)
    end
end)
