/* 	
	MovementAPI Include

	Website: https://github.com/danzayau/MovementAPI	
*/

#if defined _movementapi_included_
#endinput
#endif
#define _movementapi_included_

#include <movement>



/*===============================  Forwards  ===============================*/

/**
 * Called when the player presses a button when alive.
 *
 * @param client			Client entity index.
 * @param button			Button pressed e.g. IN_FORWARD, IN_LEFT.
 * @noreturn
 */
forward void Movement_OnButtonPress(int client, int button);

/**
 * Called when the player releases a button when alive.
 *
 * @param client			Client entity index.
 * @param button			Button released e.g. IN_FORWARD, IN_LEFT.
 * @noreturn
 */
forward void Movement_OnButtonRelease(int client, int button);

/**
 * Called when the player starts ducking.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void Movement_OnStartDucking(int client);

/**
 * Called when the player stops ducking.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void Movement_OnStopDucking(int client);

/**
 * Called when the player touches the ground.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void Movement_OnStartTouchGround(int client);

/**
 * Called when the player leaves the ground.
 *
 * @param client			Client entity index.
 * @param jumped			Whether player jumped to leave the ground.
 * @noreturn
 */
forward void Movement_OnStopTouchGround(int client, bool jumped);

/**
 * Called when the player starts touching a ladders.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void Movement_OnStartTouchLadder(int client);

/**
 * Called when the player stops touching a ladder.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void Movement_OnStopTouchLadder(int client);

/**
 * Called when the player starts noclipping.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void Movement_OnStartNoclipping(int client);

/**
 * Called when the player stops noclipping.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void Movement_OnStopNoclipping(int client);



/*===============================  Natives  ===============================*/

/**
 * Gets whether player's last takeoff was a perfect bunnyhop.
 *
 * @param client    		Client entity index.
 * @return        			Whether player's last takeoff was a perfect bunnyhop.
 */
native bool Movement_GetHitPerf(int client);

/**
 * Gets the origin vector of the player at the time of their last takeoff.
 *
 * @param client			Client entity index.
 * @param origin			Last takeoff origin vector buffer.
 * @noreturn
 */
native void Movement_GetTakeoffOrigin(int client, float buffer[3]);

/**
 * Gets the velocity vector of the player at the time of their last takeoff.
 *
 * @param client			Client entity index.
 * @param origin			Last takeoff velocity vector buffer.
 * @noreturn
 */
native void Movement_GetTakeoffVelocity(int client, float buffer[3]);

/**
 * Gets the player's last takeoff speed (horizontal).
 *
 * @param client    		Client entity index.
 * @return        			Last takeoff speed of the player (horizontal).
 */
native float Movement_GetTakeoffSpeed(int client);

/**
 * Gets the MovementAPI tick count at the time of the player's last takeoff.
 * Note: Not comparable to GetGameTickCount().
 *
 * @param client    		Client entity index.
 * @return        			MovementAPI tick count at time of player's last takeoff.
 */
native int Movement_GetTakeoffTick(int client);

/**
 * Gets the origin vector of the player at the time of their last landing.
 *
 * @param client			Client entity index.
 * @param origin			Last landing origin vector buffer.
 * @noreturn
 */
native void Movement_GetLandingOrigin(int client, float buffer[3]);

/**
 * Gets the velocity vector of the player at the time of their last landing.
 *
 * @param client			Client entity index.
 * @param origin			Last landing velocity vector buffer.
 * @noreturn
 */
native void Movement_GetLandingVelocity(int client, float buffer[3]);

/**
 * Gets the player's last landing speed (horizontal).
 *
 * @param client    		Client entity index.
 * @return        			Last landing speed of the player (horizontal).
 */
native float Movement_GetLandingSpeed(int client);

/**
 * Gets the MovementAPI tick count at the time of the player's last landing.
 * Note: Not comparable to GetGameTickCount().
 *
 * @param client    		Client entity index.
 * @return        			MovementAPI tick count at time of player's last landing.
 */
native int Movement_GetLandingTick(int client);

/**
 * Gets whether player is turning their aim horizontally.
 *
 * @param client    		Client entity index.
 * @return        			Whether player is turning their aim horizontally.
 */
native bool Movement_GetTurning(int client);

/**
 * Gets whether player is turning their aim left.
 *
 * @param client    		Client entity index.
 * @return        			Whether player is turning their aim right.
 */
native bool Movement_GetTurningLeft(int client);

/**
 * Gets whether player is turning their aim right.
 *
 * @param client    		Client entity index.
 * @return        			Whether player is turning their aim left.
 */
native bool Movement_GetTurningRight(int client);



/*===============================  Methodmap  ===============================*/

methodmap MovementAPIPlayer __nullable__ < MovementPlayer
{
	public MovementAPIPlayer(int id)
	{
		return view_as<MovementAPIPlayer>(id);
	}
	
	property int id
	{
		public get()
		{
			return view_as<int>(this);
		}
	}
	
	property bool hitPerf {
		public get() {
			Movement_GetHitPerf(this.id);
		}
	}
	
	public void GetTakeoffOrigin(float buffer[3]) {
		Movement_GetTakeoffOrigin(this.id, buffer);
	}
	
	public void GetTakeoffVelocity(float buffer[3]) {
		Movement_GetTakeoffVelocity(this.id, buffer);
	}
	
	property int takeoffTick {
		public get() {
			return Movement_GetTakeoffTick(this.id);
		}
	}
	
	property float takeoffSpeed {
		public get() {
			return Movement_GetTakeoffSpeed(this.id);
		}
	}
	
	public void GetLandingOrigin(float buffer[3]) {
		Movement_GetLandingOrigin(this.id, buffer);
	}
	
	public void GetLandingVelocity(float buffer[3]) {
		Movement_GetLandingVelocity(this.id, buffer);
	}
	
	property float landingSpeed {
		public get() {
			return Movement_GetLandingSpeed(this.id);
		}
	}
	
	property int landingTick {
		public get() {
			return Movement_GetLandingTick(this.id);
		}
	}
	
	property bool turning {
		public get() {
			return Movement_GetTurning(this.id);
		}
	}
	
	property bool turningLeft {
		public get() {
			return Movement_GetTurningLeft(this.id);
		}
	}
	
	property bool turningRight {
		public get() {
			return Movement_GetTurningRight(this.id);
		}
	}
}



/*===============================  Dependency  ===============================*/

public SharedPlugin __pl_movementapi = 
{
	name = "movementapi", 
	file = "movementapi.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_movementapi_SetNTVOptional()
{
	MarkNativeAsOptional("MovementAPI_GetHitPerf");
	
	MarkNativeAsOptional("MovementAPI_GetTakeoffOrigin");
	MarkNativeAsOptional("MovementAPI_GetTakeoffVelocity");
	MarkNativeAsOptional("MovementAPI_GetTakeoffSpeed");
	MarkNativeAsOptional("MovementAPI_GetTakeoffTick");
	
	MarkNativeAsOptional("MovementAPI_GetLandingOrigin");
	MarkNativeAsOptional("MovementAPI_GetLandingVelocity");
	MarkNativeAsOptional("MovementAPI_GetLandingSpeed");
	MarkNativeAsOptional("MovementAPI_GetLandingTick");
	
	MarkNativeAsOptional("MovementAPI_GetTurning");
	MarkNativeAsOptional("MovementAPI_GetTurningLeft");
	MarkNativeAsOptional("MovementAPI_GetTurningRight");
}
#endif