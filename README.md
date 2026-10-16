# Object Deleter (FiveM)

This resource deletes specific objects (trees, chairs, props...) by model name or model hash.

Installation:
1. Place this resource folder in your server's `resources/` directory.
2. Add to your `server.cfg`:
   ensure fivem-object-deleter
3. Configure `config.lua` to include the model names or model hashes you want deleted.

Usage:
- /delobjs [radius]  — Delete all configured objects within radius (default from config)
- /delobj [radius]   — Delete the nearest configured object within radius
- To enable automatic scanning/deleting, set `Config.autoScan = true` in `config.lua` (client-side!). Be careful: this can remove many objects and may affect gameplay.

Notes & warnings:
- This script deletes objects client-side. If every player runs this resource, the objects will be removed for each player individually. Networked objects may behave differently depending on who owns them.
- Deleting world objects may break mission scripts, map aesthetics, or cause unexpected behavior. Use on test servers or backup map data as necessary.
- If you need server-wide guaranteed deletion (synchronized for all players), further server-side coordination / network ownership transfer is required. I can extend this script to attempt networked deletion and sync across clients if you want that.

License: MIT

Repository: https://github.com/ammaralnahari12-bot/fivem-object-deleter
