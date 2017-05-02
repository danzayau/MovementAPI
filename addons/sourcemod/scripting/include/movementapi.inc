/* 	
	MovementAPI Plugin Include

	Website: https://github.com/danzayau/MovementAPI	
*/

#if defined _movementapi_included_
#endinput
#endif
#define _movementapi_included_

#include <movement>



/*===============================  Forwards  ===============================*/

/**
 * Called when an alive player presses a button.
 *
 * @param client		Client index.
 * @param button		Button pressed e.g. IN_FORWARD, IN_LEFT.
 * @noreturn
 */
forward void Movement_OnButtonPress(int client, int button);

/**
 * Called when an alive player releases a button.
 *
 * @param client		Client index.
 * @param button		Button released e.g. IN_FORWARD, IN_LEFT.
 * @noreturn
 */
forward void Movement_OnButtonRelease(int client, int button);

/**
 * Called when a player starts ducking.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void Movement_OnStartDucking(int client);

/**
 * Called when a player stops ducking.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void Movement_OnStopDucking(int client);

/**
 * Called when a player touches the ground.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void Movement_OnStartTouchGround(int client);

/**
 * Called when a player leaves the ground.
 *
 * @param client		Client index.
 * @param jumped		Whether player jumped to leave ground.
 * @noreturn
 */
forward void Movement_OnStopTouchGround(int client, bool jumped);

/**
 * Called when a player starts climbing a ladder.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void Movement_OnStartTouchLadder(int client);

/**
 * Called when a player stops climbing a ladder.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void Movement_OnStopTouchLadder(int client);

/**
 * Called when a player enters noclip.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void Movement_OnStartNoclipping(int client);

/**
 * Called when a player leaves noclip.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void Movement_OnStopNoclipping(int client);



/*===============================  Natives  ===============================*/

/**
 * Gets whether player's last takeoff was a perfect bunnyhop.
 *
 * @param client    	Client index.
 * @return        		Whether player's last takeoff was a perfect bunnyhop.
 */
native bool Movement_GetHitPerf(int client);

/**
 * Gets the player's origin at the time of their last takeoff.
 *
 * @param client		Client index.
 * @param result		Resultant vector.
 * @noreturn
 */
native void Movement_GetTakeoffOrigin(int client, float result[3]);

/**
 * Gets the player's velocity at the time of their last takeoff.
 *
 * @param client		Client index.
 * @param result		Resultant vector.
 * @noreturn
 */
native void Movement_GetTakeoffVelocity(int client, float result[3]);

/**
 * Gets the player's horizontal speed at the time of their last takeoff.
 *
 * @param client    	Client index.
 * @return        		Player's last takeoff speed.
 */
native float Movement_GetTakeoffSpeed(int client);

/**
 * Gets player's MovementAPI tick count at the time of their last takeoff.
 * Note: Not comparable to GetGameTickCount().
 *
 * @param client    	Client index.
 * @return        		Player's last takeoff MovementAPI tick count.
 */
native int Movement_GetTakeoffTick(int client);

/**
 * Gets the player's origin at the time of their last landing.
 *
 * @param client		Client index.
 * @param result		Resultant vector.
 * @noreturn
 */
native void Movement_GetLandingOrigin(int client, float result[3]);

/**
 * Gets the player's velocity at the time of their last landing.
 *
 * @param client		Client index.
 * @param result		Resultant vector.
 * @noreturn
 */
native void Movement_GetLandingVelocity(int client, float result[3]);

/**
 * Gets the player's horizontal speed at the time of their last landing.
 *
 * @param client    	Client index.
 * @return        		Last landing speed of the player (horizontal).
 */
native float Movement_GetLandingSpeed(int client);

/**
 * Gets player's MovementAPI tick count at the time of their last landing.
 * Note: Not comparable to GetGameTickCount().
 *
 * @param client    	Client index.
 * @return        		Player's last takeoff MovementAPI tick count.
 */
native int Movement_GetLandingTick(int client);

/**
 * Gets whether player is turning their aim horizontally.
 *
 * @param client    	Client index.
 * @return        		Whether player is turning their aim horizontally.
 */
native bool Movement_GetTurning(int client);

/**
 * Gets whether player is turning their aim left.
 *
 * @param client    	Client index.
 * @return        		Whether player is turning their aim left.
 */
native bool Movement_GetTurningLeft(int client);

/**
 * Gets whether player is turning their aim right.
 *
 * @param client    		Client index.
 * @return        			Whether player is turning their aim right.
 */
native bool Movement_GetTurningRight(int client);



/*===============================  Methodmap  ===============================*/

methodmap MovementAPIPlayer __nullable__ < MovementPlayer {
	
	public MovementAPIPlayer(int id) {
		return view_as<MovementAPIPlayer>(id);
	}
	
	property int id {
		public get() {
			return view_as<int>(this);
		}
	}
	
	property bool hitPerf {
		public get() {
			return Movement_GetHitPerf(this.id);
		}
	}
	
	public void GetTakeoffOrigin(float buffer[3]) {
		Movement_GetTakeoffOrigin(this.id, buffer);
	}
	
	public void GetTakeoffVelocity(float buffer[3]) {
		Movement_GetTakeoffVelocity(this.id, buffer);
	}
	
	property float takeoffSpeed {
		public get() {
			return Movement_GetTakeoffSpeed(this.id);
		}
	}
	
	property int takeoffTick {
		public get() {
			return Movement_GetTakeoffTick(this.id);
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