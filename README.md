# MovementAPI

[![Build Status](https://travis-ci.org/danzayau/MovementAPI.svg?branch=master)](https://travis-ci.org/danzayau/MovementAPI)

A SourceMod API focused on player movement in the form of a [function stock libary](addons/sourcemod/scripting/include/movement.inc) and an optional plugin with [forwards and natives](addons/sourcemod/scripting/include/movementapi.inc). MovementAPI officially supports CS:GO servers only.

### Requirements

 * SourceMod ^1.10
 * [DHooks 2 with detour support](https://github.com/peace-maker/DHooks2)
 
### Plugin Installation

 * Download and extract ```MovementAPI-vX.X.X.zip``` from the [latest GitHub release](https://github.com/danzayau/MovementAPI/releases/latest) to ```csgo/``` in your server directory.
 
### Terminology

 * **Takeoff** - Becoming airborne, including jumping, falling, getting off a ladder and leaving noclip.
 * **Landing** - Leaving the air, including landing on the ground, grabbing a ladder, leaving noclip while on ground and entering noclip.
 * **Perfect Bunnyhop (Perf)** - When the player has jumped in the tick after landing and keeps their speed.
 * **Duckbug/Crouchbug** - When the player sucessfully lands due to uncrouching from mid air and not by falling down. This causes no stamina loss or fall damage upon landing.
 * **Jumpbug** - This is achieved by duckbugging and jumping at the same time. The player is never seen as 'on ground' when bunnyhopping from a tick by tick perspective. A jumpbug inherits the same behavior as a duckbug/crouchbug, along with its effects such as maintaining speed due to no stamina loss.
 * **Distbug** - Landing behavior varies depending on whether the player lands close to the edge of a block or not:

    1. If the player lands close to the edge of a block, this causes the jump duration to be one tick longer and the player can "slide" on the ground during the landing tick, using the position post-tick as landing position becomes inaccurate.
    2. On the other hand, if the player does not land close to the edge, the player will be considered on the ground one tick earlier, using this position as landing position is not accurate as the player has yet to be fully on the ground.
 
    - In scenario 1, GetNobugLandingOrigin calculates the correct landing position of the player before the sliding effect takes effect.

    - In scenario 2, GetNobugLandingOrigin attempts extrapolate the player's fully on ground position to make landing positions consistent across scenarios.