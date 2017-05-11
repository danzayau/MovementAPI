# MovementAPI (CS:GO)

[![Build Status](https://travis-ci.org/danzayau/MovementAPI.svg?branch=master)](https://travis-ci.org/danzayau/MovementAPI)

An API for player movement in the form of a [function stock libary](addons/sourcemod/scripting/include/movement.inc) and an optional plugin with [forwards and natives](addons/sourcemod/scripting/include/movementapi.inc).

### Requirements

 * SourceMod 1.8+
 
### Plugin Installation

 * Download and extract ```MovementAPI-vX.X.X.zip``` from the latest GitHub release to ```csgo/``` in your server directory.
 
### Terminology

 * **Takeoff** - Becoming airborne, including jumping, falling, getting off a ladder and leaving noclip.
 * **Landing** - Leaving the air, including landing on the ground, grabbing a ladder and entering noclip.
 * **Perfect Bunnyhop (Perf)** - When the player has jumped in the tick after landing and keeps their speed.