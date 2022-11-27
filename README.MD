# Raf's MapVote
<p align="center">
    <img src="materials/logo.png" alt="Logo" width="200"/>
</p>

## What is it?

Raf's MapVote is a server addon for Garry's Mod that allows players to vote for the next map to be played. This addon is specifically tailored for the Trouble in Terrorist Town (TTT) gamemode, but includes admin commands to be manually started with any gamemode.


## Why?

The inspiration to create my own mapvote addon came from the flaws of other mapvote addons available in the Steam Community Workshop. Mainly:

- The sheer amount of candidate maps. This leads to candidates receiving a maximum of 3-4 votes (depending on the server player count) and most of the candidates not receiving any votes at all, making voting not very competitive.
- The candidates are often chosen randomly.
- The UI isn't very pleasing to look at.

## Features

- Keeps track of how many times each map has been played.
- Ability to choose specific maps to be in the mapvote rotation or use all the maps located on the server, with the ability to filter them by prefix (e.g. _ttt\__, _cs\__").
- A static number of candidate maps (6). Candidates maps consist of 3 "_popular_" maps and 3 _random maps_. "_Popular_" maps have the highest play count on the current server. There's also a "_random_" button for the indecisive.
- And "_extend_" button to vote for extending the current map.
- Cooldown system. After a map has been played, it won't show up as a candidate for a number of maps (**configurable**).
- Ability to use map thumbnails from other addons (e.g. [ttt_map_icons](https://steamcommunity.com/sharedfiles/filedetails/?id=2218062124)) or insert a custom image for each map (this option would require to force the clients to download the image as well).
- Rock the vote implementation, to skip a map, if the majority (**configurable**) votes to do so.
- A map pool screen, that any player can open by typing "_!rmvpool_". This shows the maps currently included in the map pool, as well as tagging maps on cooldown.
- Darkmode/lightmode color schemes that are saved as a convar "_rmv\_lightmode 1/0_".
- Admin console command "_rmv\_start_" to manually start the mapvote. 
- ULX integration - ability for admins to manually start the mapvote with the "_ulx rmvstart_" command or through the  graphical menu. 


## Config

The config file is automatically generated after running the server once with the addond installed in "garrysmod/data/rafsmapvote/config_rafs_mapvote.json".

- **MAPS : ["cs\_office", "ttt\_67thway\_v3"]** - Custom map pool. If left empty, will use every map on the server, taking into account the given map prefixes. If setting a custom map pool, you should always have at least 6 + **MAP\_COOLDOWN** amount of maps in the map pool, to avoid potential issues.
- **MAP\_PREFIX : ["ttt\_", "cs\_"]** - Filters the map pool with the given prefixes.
- **MAP\_COOLDOWN : 5**  - Map changes before a recently played map can be as mapvote candidate. 
- **TIMER : 45** - Vote time in seconds.
- **NO\_VOTE\_TO\_RANDOM : true** - If a player doesn't vote, does it vote go to a random candidate.
- **RTV\_MIN : 3** - Minimal player count on the server, for RTV to be enabled.
- **RTV\_TIME : 300** - Time in seconds after which RTV is enabled.
- **RTV\_PERCENT: 0.6** - Percentage of players needed to RTV.
- **DATA_DIR : "rafsmapvote/"** - Data directory. You shouldn't change this.
- **THUMBNAIL\_DIR : "rafsmapvote/thumbnails"** - Directory to place your custom thumbnails, they should with the filename _ttt_mapname.jpg/.png_. If placing images here, you are responsible for sending them to the client.
- **FORCE\_VOTE\_USER\_GROUPS: ["superadmin"], ["admin"]** - Roles that can force the mapvote by using the "_rmv\_start_" console command.If using ULX, you should prefer to use the appropriate ULX command and setup permissions there.

Thumbnail icons are prioritized as follows:
1. Custom _.png_ or _.jpg_ files under **THUMBNAIL\_DIR** (_e.g. data/rafsmapvote/thumbnails/ttt_MAPNAME.jpg_)
2. Map thumbnails in _maps/thumb/_ (this also usually includes addons like [ttt_map_icons](https://steamcommunity.com/sharedfiles/filedetails/?id=2218062124))
3. Defaults to "no map preview" image

## Installation

It is preferred to install the addon using the [Steam Workshop]().

If hosting a local server, you and your friends should have the addon installed through the [Steam Workshop]().
If hosting a dedicated server you have to:

- Add the addon to your [servers workshop collection](https://wiki.facepunch.com/gmod/Workshop_for_Dedicated_Servers)
- Add the addon workshop ID manually in _/garrysmod/lua/autorun/server/workshop.lua_ with **resource.AddWorkshop([ID])**

This will make all clients download the addon automatically. It is also possible to copy this code and place it in your server's _addons/_ directory but you are then responsible for sending the addon to the client (probably FastDL).

It is also recommended to install a Map Icon pack like the one made by [Kirays](https://steamcommunity.com/sharedfiles/filedetails/?id=2218062124). However, keep in mind that Raf's MapVote uses landscape images, and most of the Map Icon packs are small square images, causing them to look a bit low-res. This should inspire you to create your own Map Icon pack with landscape images and share them with everyone :) 

If installed correctly, there should be a console splash screen when starting the server. Afterwards, you should probably change the config to your liking.

## Chat commands

- **!rmvlist, !mappool, !rmvpool** - Opens a map list window where the player can view the current server map pool.
- **!rtv** - Vote to rock the vote.
- **!rmv [duration] [noVotesToRandomVotes]** - Force starts the mapvote through ULX (ULX custom permissions apply).

## Console commands
- **rmv_lightmode 0/1** - Toggles the "light mode" color scheme.
- **rmv_start** - Force starts the mapVote, if player is under a **FORCE\_VOTE\_USER\_GROUPS** (config) player group.
- **ulx rmvstart [duration] [noVotesToRandomVotes]** - Force starts the mapvote through ULX (ULX custom permissions apply).


## Links
[Steam Workshop]()
[Adding a server workshop collection](https://wiki.facepunch.com/gmod/Workshop_for_Dedicated_Servers)
[TTT map icon pack by Kirays](https://steamcommunity.com/sharedfiles/filedetails/?id=2218062124)
[Icons used](https://icons8.com/)

## Notes
This addon does not work in single player (and makes no sense to do so).

## Licence

Feel free to use and modify the code to your own liking, following the guidelines of the MIT licence.

