/* 	
	Movement Library

	Website: https://github.com/danzayau/MovementAPI	
*/

#if defined _movement_included_
#endinput
#endif
#define _movement_included_



/*===============================  Stocks  ===============================*/

/**
 * Calculates the absolute horizontal distance between two points.
 *
 * @param startPoint		First point.
 * @param endPoint			Second point.
 * @return					Absolute horizontal distance between the points.
 */
stock float CalcHorizontalDistance(const float startPoint[3], const float endPoint[3])
{
	float jumpDistanceX = FloatAbs(endPoint[0] - startPoint[0]);
	float jumpDistanceY = FloatAbs(endPoint[1] - startPoint[1]);
	return SquareRoot(Pow(jumpDistanceX, 2.0) + Pow(jumpDistanceY, 2.0)) + 32.0;
}

/**
 * Calculates the vertical distance from one point to another.
 *
 * @param startPoint		First point.
 * @param endPoint			Second point.
 * @return					Vertical distance from first point to second point.
 */
stock float CalcVerticalDistance(const float startPoint[3], const float endPoint[3])
{
	return endPoint[2] - startPoint[2];
}

/**
 * Calculates the absolute horizontal speed of a velocity vector.
 *
 * @param velocity			Velocity vector.
 * @return					Absolute horizontal speed of velocity vector.
 */
stock float CalcHorizontalSpeed(const float velocity[3])
{
	return SquareRoot(Pow(velocity[0], 2.0) + Pow(velocity[1], 2.0));
}

/**
 * Gets the origin of the the player.
 *
 * @param client			Client entity index.
 * @param buffer			Origin vector buffer.
 * @noreturn
 */
stock void Movement_GetOrigin(int client, float buffer[3])
{
	GetClientAbsOrigin(client, buffer);
}

/**
 * Changes the origin of the the player (by teleporting them).
 *
 * @param client			Client entity index.
 * @param origin			Origin vector to set the player's origin to.
 * @noreturn
 */
stock void Movement_SetOrigin(int client, const float origin[3])
{
	TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
}

/**
 * Gets the velocity vector of the player.
 *
 * @param client			Client entity index.
 * @param buffer			Velocity vector buffer.
 * @noreturn
 */
stock void Movement_GetVelocity(int client, float buffer[3])
{
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", buffer);
}

/**
 * Changes the velocity of the player (by teleporting them).
 * For convenience, this sets the takeoff velocity and takeoff speed
 * values if this is done immediately after the player takes off.
 *
 * @param client			Client entity index.
 * @param velocity			Vector to set the player's velocity to.
 * @noreturn
 */
stock void Movement_SetVelocity(int client, const float velocity[3])
{
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
}

/**
 * Gets the player's horizontal speed.
 *
 * @param client    		Client entity index.
 * @return        			Horizontal speed of the player.
 */
stock float Movement_GetSpeed(int client)
{
	float velocity[3];
	Movement_GetVelocity(client, velocity);
	return CalcHorizontalSpeed(velocity);
}

/**
 * Gets the vertical velocity of the player.
 *
 * @param client			Client entity index.
 * @return        			Vertical velocity of the player.
 */
stock float Movement_GetVerticalVelocity(int client)
{
	float velocity[3];
	Movement_GetVelocity(client, velocity);
	return velocity[2];
}

/**
 * Sets the vertical velocity of the player.
 *
 * @param client			Client entity index.
 * @param value				Desired vertical velocity.
 * @noreturn
 */
stock void Movement_SetVerticalVelocity(int client, float value)
{
	float velocity[3];
	Movement_GetVelocity(client, velocity);
	velocity[2] = value;
	Movement_SetVelocty(client, velocity);
}

/**
 * Gets the base velocity vector of the player.
 *
 * @param client			Client entity index.
 * @param buffer			Base velocity vector buffer.
 * @noreturn
 */
stock void Movement_GetBaseVelocity(int client, float buffer[3])
{
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", buffer);
}

/**
 * Sets the base velocity of the player.
 *
 * @param client			Client entity index.
 * @param baseVelocity		Vector to set the player's base velocity to.
 * @noreturn
 */
stock void Movement_SetBaseVelocity(int client, const float baseVelocity[3])
{
	SetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", baseVelocity);
}

/**
 * Gets the eye angles of the player.
 *
 * @param client			Client entity index.
 * @param buffer			Eye angles vector buffer.
 * @noreturn
 */
stock void Movement_GetEyeAngles(int client, float buffer[3])
{
	GetClientEyeAngles(client, buffer);
}

/**
 * Changes the eye angles of the player (by teleporting them).
 *
 * @param client			Client entity index.
 * @param eyeAngles			Desired eye angles vector.
 * @noreturn
 */
stock void Movement_SetEyeAngles(int client, const float eyeAngles[3])
{
	TeleportEntity(client, NULL_VECTOR, eyeAngles, NULL_VECTOR);
}

/**
 * Gets whether or not the player is on the ground.
 *
 * @param client    		Client entity index.
 * @return        			Whether player is on the ground.
 */
stock bool Movement_GetOnGround(int client)
{
	return view_as<bool>(GetEntityFlags(client) & FL_ONGROUND);
}

/**
 * Gets the player's move type.
 *
 * @param client    		Client entity index.
 * @return        			Player's move type
 */
stock MoveType Movement_GetMoveType(int client)
{
	return GetEntityMoveType(client);
}

/**
 * Gets whether or not the player is on a ladder.
 *
 * @param client    		Client entity index.
 * @return        			Whether player is on a ladder.
 */
stock bool Movement_GetOnLadder(int client)
{
	return Movement_GetMoveType(client) == MOVETYPE_LADDER;
}

/**
 * Gets whether or not the player is noclipping.
 *
 * @param client    		Client entity index.
 * @return        			Whether player is noclipping.
 */
stock bool Movement_GetNoclipping(int client)
{
	return Movement_GetMoveType(client) == MOVETYPE_NOCLIP;
}

/**
 * Sets the player's move type.
 *
 * @param client    		Client entity index.
 * @param moveType			Desired move type.
 * @noreturn
 */
stock void Movement_SetMoveType(int client, MoveType moveType)
{
	SetEntityMoveType(client, moveType);
}

/**
 * Gets whether or not the player is ducking/ducked.
 *
 * @param client    		Client entity index.
 * @return        			Whether player is ducking/ducked.
 */
stock bool Movement_GetDucking(int client)
{
	return GetEntProp(client, Prop_Send, "m_bDucked") || GetEntProp(client, Prop_Send, "m_bDucking");
}

/**
 * Gets "m_flVelocityModifier" of the player.
 *
 * @param client    		Client entity index.
 * @return        			Value of "m_flVelocityModifier".
 */
stock float Movement_GetVelocityModifier(int client)
{
	return GetEntPropFloat(client, Prop_Send, "m_flVelocityModifier");
}

/**
 * Sets "m_flVelocityModifier" of the player.
 *
 * @param client    		Client entity index.
 * @param value				Desired velocity modifier.
 * @noreturn
 */
stock void Movement_SetVelocityModifier(int client, float value)
{
	SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", value);
}

/**
 * Gets "m_flDuckSpeed" of the player.
 *
 * @param client    		Client entity index.
 * @return        			Value of "m_flDuckSpeed".
 */
stock float Movement_GetDuckSpeed(int client)
{
	return GetEntPropFloat(client, Prop_Send, "m_flDuckSpeed");
}

/**
 * Sets "m_flDuckSpeed" of the player.
 *
 * @param client    		Client entity index.
 * @param value				Desired duck speed.
 * @noreturn
 */
stock void Movement_SetDuckSpeed(int client, float value)
{
	SetEntPropFloat(client, Prop_Send, "m_flDuckSpeed", value);
}



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
	
	public void GetEyeAngles(float buffer[3]) {
		Movement_GetEyeAngles(this.id, buffer);
	}
	
	public void SetEyeAngles(float eyeAngles[3]) {
		Movement_SetEyeAngles(this.id, eyeAngles);
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