/* 	Movement API Include File
	
	Author: DanZay
*/


/*	Double-include prevention	*/
#if defined _movement_included_
#endinput
#endif
#define _movement_included_


// Forwards

/**
 * Called when the player leaves the ground.
 *
 * @param client			Client entity index.
 * @param jumped			True if the player jumped to leave the ground.
 * @noreturn
 */
forward void OnPlayerLeaveGround(int client, bool jumped);

/**
 * Called when the player touches the ground.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void OnPlayerTouchGround(int client);


// Natives

/**
 * Gets the origin of the the player.
 *
 * @param client			Client entity index.
 * @param origin			Origin vector buffer.
 * @noreturn
 */
native void Movement_GetOrigin(int client, float origin[3]);

/**
 * Gets the origin of the ground beneath the player (more accurate than origin when on ground).
 *
 * @param client			Client entity index.
 * @param origin			Ground origin vector buffer.
 * @noreturn
 */
native void Movement_GetGroundOrigin(int client, float origin[3]);

/**
 * Gets the distance between the player's origin and the ground beneath.
 *
 * @param client			Client entity index.
 * @return					The distance from the player's origin to the ground.
 */
native float Movement_GetDistanceToGround(int client);

/**
 * Gets the velocity vector of the player.
 *
 * @param client			Client entity index.
 * @param velocity			Velocity vector buffer.
 * @noreturn
 */
native void Movement_GetVelocity(int client, float velocity[3]);

/**
 * Changes the velocity of the player.
 *
 * @param client			Client entity index.
 * @param velocity			Velocity vector to set the player's velocity to.
 * @noreturn
 */
native void Movement_SetVelocity(int client, float velocity[3]);

/**
 * Gets the player's horizontal speed.
 *
 * @param client    		Client entity index.
 * @return        			The horizontal speed of the player.
 */
native float Movement_GetSpeed(int client);

/**
 * Gets whether or not the player is on the ground.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is on the ground.
 */
native bool Movement_GetOnGround(int client);

/**
 * Gets whether or not the player is on a ladder.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is on a ladder.
 */
native bool Movement_GetOnLadder(int client);

/**
 * Gets whether or not the player is noclipping.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is noclipping.
 */
native bool Movement_GetNoclipping(int client);

/**
 * Gets whether or not the player is ducking/ducked.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is ducking/ducked.
 */
native bool Movement_GetDucking(int client);

/**
 * Gets whether or not the player just started ducking.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player just started ducking.
 */
native bool Movement_GetJustDucked(int client);

/**
 * Gets whether or not the player just jumped to leave the ground.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player just jumped to leave the ground.
 */
native bool Movement_GetJustJumped(int client);

/**
 * Gets whether or not the player just landed (touched the ground).
 *
 * @param client    		Client entity index.
 * @return 					Whether or not the player just landed (touched the ground).
 */
native bool Movement_GetJustLanded(int client);

/**
 * Gets the player's last takeoff speed (horizontal).
 *
 * @param client    		Client entity index.
 * @return        			The last takeoff speed of the player (horizontal).
 */
native float Movement_GetTakeoffSpeed(int client);

/**
 * Gets the player's last takeoff speed (horizontal).
 *
 * @param client    		Client entity index.
 * @param value				The value to set the player's takeoff speed to.
 * @noreturn
 */
native float Movement_SetTakeoffSpeed(int client, float value);

/**
 * Gets the origin of last takeoff position of the player.
 *
 * @param client			Client entity index.
 * @param origin			Takeoff origin vector buffer.
 * @noreturn
 */
native void Movement_GetTakeoffOrigin(int client, float origin[3]);

/**
 * Gets the time of the player's last takeoff.
 *
 * @param client    		Client entity index.
 * @return        			The time of the last takeoff of the player.
 */
native int Movement_GetTakeoffTick(int client);

/**
 * Gets the player's last landing speed (horizontal).
 *
 * @param client    		Client entity index.
 * @return        			The last landing speed of the player (horizontal).
 */
native float Movement_GetLandingSpeed(int client);

/**
 * Gets the origin of last landing position of the player.
 *
 * @param client			Client entity index.
 * @param origin			Landing origin vector buffer.
 * @noreturn
 */
native void Movement_GetLandingOrigin(int client, float origin[3]);

/**
 * Gets the time of the player's last landing.
 *
 * @param client    		Client entity index.
 * @return        			The time of the last landing of the player.
 */
native int Movement_GetLandingTick(int client);

/**
 * Gets the maximum height of the player's last jump.
 *
 * @param client    		Client entity index.
 * @return        			The maximum height of the player's last jump.
 */
native float Movement_GetJumpMaxHeight(int client);

/**
 * Gets the distnace of the player's last jump.
 *
 * @param client    		Client entity index.
 * @return        			The distance of the player's last jump.
 */
native float Movement_GetJumpDistance(int client);

/**
 * Gets the height offset of the player's last jump.
 *
 * @param client    		Client entity index.
 * @return        			The height of the player's last jump.
 */
native float Movement_GetJumpOffset(int client);

/**
 * Gets "m_flVelocityModifier" of the player.
 *
 * @param client    		Client entity index.
 * @return        			The value of the "m_flVelocityModifier".
 */
native float Movement_GetVelocityModifier(int client);

/**
 * Sets "m_flVelocityModifier" of the player.
 *
 * @param client    		Client entity index.
 * @param value				Value to set the player's velocity modifier to.
 * @noreturn
 */
native void Movement_SetVelocityModifier(int client, float value);

/**
 * Gets "m_flVelocityModifier" of the player.
 *
 * @param client    		Client entity index.
 * @return        			The value of the "m_flDuckSpeed".
 */
native float Movement_GetDuckSpeed(int client);

/**
 * Sets "m_flVelocityModifier" of the player.
 *
 * @param client    		Client entity index.
 * @param value				Value to set the player's duck speed to.
 * @noreturn
 */
native void Movement_SetDuckSpeed(int client, float value);

/**
 * Gets whether or not the player is turning their aim horizontally.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is turning their aim horizontally..
 */
native bool Movement_GetTurning(int client);

/**
 * Gets whether or not the player is turning their aim left.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is turning their aim right.
 */
native bool Movement_GetTurningLeft(int client);

/**
 * Gets whether or not the player is turning their aim right.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is turning their aim left.
 */
native bool Movement_GetTurningRight(int client);


// Method Map

methodmap MovementPlayer __nullable__ {
	public MovementPlayer(int id) {
		return view_as<MovementPlayer>(id);
	}
	
	property int id {
		public get() {
			return view_as<int>(this);
		}
	}
	
	public void GetOrigin(float origin[3]) {
		Movement_GetOrigin(this.id, origin);
	}
	
	public void GetGroundOrigin(float origin[3]) {
		Movement_GetGroundOrigin(this.id, origin);
	}
	
	property float distanceToGround {
		public get() {
			return Movement_GetDistanceToGround(this.id);
		}
	}
	
	public void GetVelocity(float velocity[3]) {
		Movement_GetVelocity(this.id, velocity);
	}
	
	public void SetVelocity(float velocity[3]) {
		Movement_SetVelocity(this.id, velocity);
	}
	
	property float speed {
		public get() {
			return Movement_GetSpeed(this.id);
		}
	}
	
	property bool onGround {
		public get() {
			return Movement_GetOnGround(this.id);
		}
	}
	
	property bool ladder {
		public get() {
			return Movement_GetOnLadder(this.id);
		}
	}
	
	property bool noclipping {
		public get() {
			return Movement_GetNoclipping(this.id);
		}
	}
	
	property bool ducking {
		public get() {
			return Movement_GetDucking(this.id);
		}
	}
	
	property bool justDucked {
		public get() {
			return Movement_GetJustDucked(this.id);
		}
	}
	
	property bool justJumped {
		public get() {
			return Movement_GetJustJumped(this.id);
		}
	}
	
	property bool justLanded {
		public get() {
			return Movement_GetJustLanded(this.id);
		}
	}
	
	property float takeoffSpeed {
		public get() {
			return Movement_GetTakeoffSpeed(this.id);
		}
		public set(float value) {
			Movement_SetTakeoffSpeed(this.id, value);
		}
	}
	
	public void GetTakeoffOrigin(float origin[3]) {
		Movement_GetTakeoffOrigin(this.id, origin);
	}
	
	property int takeoffTick {
		public get() {
			return Movement_GetTakeoffTick(this.id);
		}
	}
	
	property float landingSpeed {
		public get() {
			return Movement_GetLandingSpeed(this.id);
		}
	}
	
	public void GetLandingOrigin(float origin[3]) {
		Movement_GetLandingOrigin(this.id, origin);
	}
	
	property int landingTick {
		public get() {
			return Movement_GetLandingTick(this.id);
		}
	}
	
	property float jumpMaxHeight {
		public get() {
			return Movement_GetJumpMaxHeight(this.id);
		}
	}
	
	property float jumpDistance {
		public get() {
			return Movement_GetJumpDistance(this.id);
		}
	}
	
	property float jumpOffset {
		public get() {
			return Movement_GetJumpOffset(this.id);
		}
	}
	
	property float velocityModifier {
		public get() {
			return Movement_GetVelocityModifier(this.id);
		}
		public set(float value) {
			Movement_SetVelocityModifier(this.id, value);
		}
	}
	
	property float duckSpeed {
		public get() {
			return Movement_GetDuckSpeed(this.id);
		}
		public set(float value) {
			Movement_SetDuckSpeed(this.id, value);
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