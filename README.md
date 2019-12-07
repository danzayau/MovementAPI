# MovementAPI

[![Build Status](https://travis-ci.org/danzayau/MovementAPI.svg?branch=master)](https://travis-ci.org/danzayau/MovementAPI)

A SourceMod API focused on player movement in the form of a [function stock libary](addons/sourcemod/scripting/include/movement.inc) and an optional plugin with [forwards and natives](addons/sourcemod/scripting/include/movementapi.inc). MovementAPI officially supports CS:GO servers only.

### Requirements

 * SourceMod ^1.9
 
### Plugin Installation

 * Download and extract ```MovementAPI-vX.X.X.zip``` from the [latest GitHub release](https://github.com/danzayau/MovementAPI/releases/latest) to ```csgo/``` in your server directory.
 
### Terminology

 * **Takeoff** - Becoming airborne, including jumping, falling, getting off a ladder and leaving noclip.
 * **Landing** - Leaving the air, including landing on the ground, grabbing a ladder and entering noclip.
 * **Perfect Bunnyhop (Perf)** - When the player has jumped in the tick after landing and keeps their speed.
 * **Jumpbug** - When the player is never seen as 'on ground' when bunnyhopping. This is achievable by uncrouching and jumping at the same time. A jumpbug results in unusual behaviour such as maintaining horizontal speed and not receiving fall damage.
 * **Distbug** - A distbug can occur when a player lands close to the edge of a block. When calculating the landing position, the source engine will only consider either the horizontal or vertical speed on the very last tick, but not both. The GetNobugLandingOrigin calculates the correct landing position of the player based on his actual trajectory using all components of the velocity instead.