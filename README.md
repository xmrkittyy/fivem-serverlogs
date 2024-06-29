# FiveM Server Discord Logging Script

## Description
This script enhances your FiveM server with comprehensive logging capabilities integrated directly into Discord. It provides real-time notifications and logs for various server events, player activities, and administrative actions, improving server administration and monitoring.

## Features
- **Server Events:** Logs server start, stop, resource loading/unloading.
- **Player Activities:** Tracks player connections, disconnections, chat messages.
- **Player State:** Monitors player health, armor, ping, and position.
- **Economy & Inventory:** Logs transactions and inventory changes.
- **Administrative Actions:** Records bans, kicks, and admin commands.
- **Performance Monitoring:** Monitors server CPU and memory usage.
- **Custom Events:** Supports customizable event logging.

## Installation
1. Ensure you have a functioning FiveM server.
2. Clone this repository into your FiveM `resources` directory.
   ```
   git clone https://github.com/xmrkittyy/fivem-serverlogs.git
   ```
3. Configure `config.lua` with your Discord webhook URL and customize logging preferences.
4. Add `start fivem-serverlogs` to your FiveM server's `server.cfg` file.
5. Restart your FiveM server or use `ensure fivem-serverlogs` in the console.

## Configuration
Edit `config.lua` to enable/disable specific logs and configure which player data to include in the logs. Replace `YOUR_DISCORD_WEBHOOK_URL` with your actual Discord webhook URL.

## Usage
Once configured and started, logs will automatically be sent to your designated Discord channel via webhooks. Monitor your server activities and take necessary actions promptly.

## Dependencies
- FiveM Server
- Discord Webhook URL

## Version
1.0.0
