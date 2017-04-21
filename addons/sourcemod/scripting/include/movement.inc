/* 	
	Movement API Include File

	Website: https://github.com/danzayau/MovementAPI	
*/

#if defined _movement_included_
#endinput
#endif
#define _movement_included_



/*===============================  Forwards  ===============================*/

/**
 * Called after MovementAPI has refreshed (done during OnPlayerRunCmd).
 * This is called after all other MovementAPI forwards.
 * Only called if the client is alive.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void Movement_OnClientUpdate(int client);

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
 * @param jumped			True if the player jumped to leave the ground.
 * @param ducked			True if the player ducked at the same time.
 * @param landed			True if the player just landed (e.g. perfect bunnyhop).
 * @noreturn
 */
forward void Movement_OnStopTouchGround(int client, bool jumped, bool ducked, bool landed);

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
 * Gets the origin of the the player.
 *
 * @param client			Client entity index.
 * @param origin			Origin vector buffer.
 * @noreturn
 */
native void Movement_GetOrigin(int client, float buffer[3]);

/**
 * Changes the origin of the the player (by teleporting them).
 *
 * @param client			Client entity index.
 * @param origin			Origin vector to set the player's origin to.
 * @noreturn
 */
native void Movement_SetOrigin(int client, float buffer[3]);

/**
 * Gets the origin of the ground beneath the player (more accurate than origin when on ground).
 * Ground origin is NULL_VECTOR ({0.0, 0.0, 0.0}) if ground is more than 16 units below player origin.
 *
 * @param client			Client entity index.
 * @param origin			Ground origin vector buffer.
 * @noreturn
 */
native void Movement_GetGroundOrigin(int client, float buffer[3]);

/**
 * Gets the velocity vector of the player.
 *
 * @param client			Client entity index.
 * @param velocity			Velocity vector buffer.
 * @noreturn
 */
native void Movement_GetVelocity(int client, float buffer[3]);

/**
 * Changes the velocity of the player (by teleporting them).
 * For convenience, this sets the takeoff velocity and takeoff speed
 * values if this is done immediately after the player takes off.
 *
 * @param client			Client entity index.
 * @param velocity			Vector to set the player's velocity to.
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
 * Gets the vertical velocity of the player.
 *
 * @param client			Client entity index.
 * @return        			The vertical velocity of the player.
 */
native float Movement_GetVerticalVelocity(int client);

/**
 * Gets the base velocity vector of the player.
 *
 * @param client			Client entity index.
 * @param velocity			Base velocity vector buffer.
 * @noreturn
 */
native void Movement_GetBaseVelocity(int client, float buffer[3]);

/**
 * Sets the base velocity of the player.
 *
 * @param client			Client entity index.
 * @param velocity			Vector to set the player's base velocity to.
 * @noreturn
 */
native void Movement_SetBaseVelocity(int client, float velocity[3]);

/**
 * Gets whether or not the player is on the ground.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is on the ground.
 */
native bool Movement_GetOnGround(int client);

/**
 * Gets the player's move type.
 *
 * @param client    		Client entity index.
 * @return        			The player's move type
 */
native MoveType Movement_GetMoveType(int client);

/**
 * Sets the player's move type.
 *
 * @param client    		Client entity index.
 * @param moveType			What to set the player's move type to.
 * @noreturn
 */
native void Movement_SetMoveType(int client, MoveType moveType);

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
 * @return        			The last takeoff speed of the player (horizontal).
 */
native float Movement_GetTakeoffSpeed(int client);

/**
 * Sets the player's last takeoff speed (horizontal).
 *
 * @param client    		Client entity index.
 * @param value				The value to set the player's takeoff speed (horizontal) to.
 * @noreturn
 */
native float Movement_SetTakeoffSpeed(int client, float value);

/**
 * Gets the tick of the player's last takeoff (leaving the ground).
 *
 * @param client    		Client entity index.
 * @return        			The tick of the last takeoff of the player.
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
 * @return        			The last landing speed of the player (horizontal).
 */
native float Movement_GetLandingSpeed(int client);

/**
 * Gets the tick of the player's last landing.
 *
 * @param client    		Client entity index.
 * @return        			The tick of the last landing of the player.
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
 * @return        			The horizontal distance of the player's last jump.
 */
native float Movement_GetJumpDistance(int client);

/**
 * Gets the height offset of the player's last jump.
 *
 * @param client    		Client entity index.
 * @return        			The vertical distance of the player's last jump.
 */
native float Movement_GetJumpOffset(int client);

/**
 * Gets whether or not the player's last jump was a perfect bunnyhop.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player's last jump wasThe vertical distance of the player's last jump.
 */
native bool Movement_GetHitPerf(int client);

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
 * Gets the eye angles of the player.
 *
 * @param client			Client entity index.
 * @param buffer			Eye angles vector buffer.
 * @noreturn
 */
native void Movement_GetEyeAngles(int client, float buffer[3]);

/**
 * Changes the eye angles of the player (by teleporting them).
 *
 * @param client			Client entity index.
 * @param eyeAngles			Eye angles vector to set the player's eye angles to.
 * @noreturn
 */
native void Movement_SetEyeAngles(int client, float eyeAngles[3]);

/**
 * Gets whether or not the player is turning their aim horizontally.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player is turning their aim horizontally.
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



/*===============================  Methodmap  ===============================*/

methodmap MovementPlayer __nullable__ {
	public MovementPlayer(int id) {
		return view_as<MovementPlayer>(id);
	}
	
	property int id {
		public get() {
			return view_as<int>(this);
		}
	}
	
	public void GetOrigin(float buffer[3]) {
		Movement_GetOrigin(this.id, buffer);
	}
	
	public void SetOrigin(float origin[3]) {
		Movement_SetOrigin(this.id, origin);
	}
	
	public void GetGroundOrigin(float buffer[3]) {
		Movement_GetGroundOrigin(this.id, buffer);
	}
	
	public void GetVelocity(float buffer[3]) {
		Movement_GetVelocity(this.id, buffer);
	}
	
	public void SetVelocity(float velocity[3]) {
		Movement_SetVelocity(this.id, velocity);
	}
	
	property float speed {
		public get() {
			return Movement_GetSpeed(this.id);
		}
	}
	
	property float verticalVelocity {
		public get() {
			return Movement_GetVerticalVelocity(this.id);
		}
	}
	
	public void GetBaseVelocity(float buffer[3]) {
		Movement_GetBaseVelocity(this.id, buffer);
	}
	
	public void SetBaseVelocity(float baseVelocity[3]) {
		Movement_SetBaseVelocity(this.id, baseVelocity);
	}
	
	property bool onGround {
		public get() {
			return Movement_GetOnGround(this.id);
		}
	}
	
	property MoveType moveType {
		public get() {
			return Movement_GetMoveType(this.id);
		}
		public set(MoveType moveType) {
			Movement_SetMoveType(this.id, moveType);
		}
	}
	
	property bool onLadder {
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
	
	property bool hitPerf {
		public get() {
			return Movement_GetHitPerf(this.id);
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
	
	public void GetEyeAngles(float buffer[3]) {
		Movement_GetEyeAngles(this.id, buffer);
	}
	
	public void SetEyeAngles(float eyeAngles[3]) {
		Movement_SetEyeAngles(this.id, eyeAngles);
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
	
	property int buttons {
		public get() {
			return GetClientButtons(this.id);
		}
	}
	
	property float gravity {
		public get() {
			GetEntityGravity(this.id);
		}
		public set(float value) {
			SetEntityGravity(this.id, value);
		}
	}
} 