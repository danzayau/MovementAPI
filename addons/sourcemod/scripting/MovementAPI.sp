#include <sourcemod>
#include <sdktools>
#include <movement>

#pragma newdecls required
#pragma semicolon 1

Plugin myinfo = 
{
	name = "Player Movement API", 
	author = "DanZay", 
	description = "API plugin for player movement.", 
	version = "0.1", 
	url = "https://github.com/danzayau/MovementAPI"
};


// Global Variables
float gF_Origin[MAXPLAYERS + 1][3];
float gF_GroundOrigin[MAXPLAYERS + 1][3];

float gF_DistanceToGround[MAXPLAYERS + 1];

float gF_Velocity[MAXPLAYERS + 1][3];
float gF_Speed[MAXPLAYERS + 1];

bool gB_OnGround[MAXPLAYERS + 1];
bool gB_OnLadder[MAXPLAYERS + 1];
bool gB_Noclipping[MAXPLAYERS + 1];

bool gB_Ducking[MAXPLAYERS + 1];

bool gB_JustDucked[MAXPLAYERS + 1];
bool gB_JustJumped[MAXPLAYERS + 1];
bool gB_JustLanded[MAXPLAYERS + 1];

float gF_TakeoffOrigin[MAXPLAYERS + 1][3];
float gF_TakeoffSpeed[MAXPLAYERS + 1];
int gI_TakeoffTick[MAXPLAYERS + 1];

float gF_LandingOrigin[MAXPLAYERS + 1][3];
float gF_LandingSpeed[MAXPLAYERS + 1];
int gI_LandingTick[MAXPLAYERS + 1];

float gF_JumpMaxHeight[MAXPLAYERS + 1];
float gF_JumpDistance[MAXPLAYERS + 1];
float gF_JumpOffset[MAXPLAYERS + 1];

float gF_VelocityModifier[MAXPLAYERS + 1];
float gF_DuckSpeed[MAXPLAYERS + 1];

float gF_Yaw[MAXPLAYERS + 1];
bool gB_Turning[MAXPLAYERS + 1];
bool gB_TurningLeft[MAXPLAYERS + 1];
bool gB_TurningRight[MAXPLAYERS + 1];


// Includes
#include "misc.sp"
#include "api.sp"


// Functions
public void OnPluginStart() {
	CreateGlobalForwards();
	HookEvent("player_jump", Event_Jump, EventHookMode_Pre);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNatives();
	return APLRes_Success;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	if (!IsPlayerAlive(client)) {
		return Plugin_Continue;
	}
	
	// Save previous variables
	float oldGroundOrigin[3];
	oldGroundOrigin = gF_GroundOrigin[client];
	float oldSpeed = gF_Speed[client];
	bool oldDucking = gB_Ducking[client];
	bool oldOnGround = gB_OnGround[client];
	float oldYaw = gF_Yaw[client];
	
	// Clear these variables by default
	gB_JustLanded[client] = false;
	
	// Origin
	GetClientAbsOrigin(client, gF_Origin[client]);
	
	// Ground origin
	GetGroundOrigin(client, gF_GroundOrigin[client]);
	
	// Distance to ground
	gF_DistanceToGround[client] = gF_Origin[client][2] - gF_GroundOrigin[client][2];
	
	// Velocity
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", gF_Velocity[client]);
	
	// Speed
	gF_Speed[client] = SquareRoot(Pow(gF_Velocity[client][0], 2.0) + Pow(gF_Velocity[client][1], 2.0));
	
	// Ducking
	gB_Ducking[client] = PlayerIsDucking(client);
	
	// Just ducked
	gB_JustDucked[client] = gB_Ducking[client] && !oldDucking;
	
	// On ground
	gB_OnGround[client] = PlayerIsOnGround(client);
	if (gB_OnGround[client]) {
		if (!oldOnGround) {  // Just touched on ground
			gF_LandingOrigin[client] = gF_GroundOrigin[client];
			gF_LandingSpeed[client] = oldSpeed;
			gI_LandingTick[client] = GetGameTickCount();
			gB_JustLanded[client] = true;
			gF_JumpDistance[client] = CalculateHorizontalDistance(gF_TakeoffOrigin[client], gF_GroundOrigin[client]);
			gF_JumpOffset[client] = CalculateVerticalDistance(gF_TakeoffOrigin[client], gF_GroundOrigin[client]);
			Call_OnPlayerTouchGround(client);
		}
		else {
			gB_JustLanded[client] = false;
		}
	}
	// In air
	else {
		if (oldOnGround) {  // Just left ground
			gF_TakeoffOrigin[client] = oldGroundOrigin;
			gF_TakeoffSpeed[client] = oldSpeed;
			gI_TakeoffTick[client] = GetGameTickCount();
			gF_JumpMaxHeight[client] = 0.0;
			gB_JustLanded[client] = false;
			Call_OnPlayerLeaveGround(client);
		}
		float currentJumpHeight = gF_Origin[client][2] - gF_TakeoffOrigin[client][2];
		if (currentJumpHeight > gF_JumpMaxHeight[client]) {
			gF_JumpMaxHeight[client] = currentJumpHeight;
		}
	}
	
	// On ladder
	gB_OnLadder[client] = PlayerIsOnLadder(client);
	
	// Noclipping
	gB_Noclipping[client] = PlayerIsNoclipping(client);
	
	// Velocity modifier
	gF_VelocityModifier[client] = GetEntPropFloat(client, Prop_Send, "m_flVelocityModifier");
	
	// Duck speed
	gF_DuckSpeed[client] = GetEntPropFloat(client, Prop_Send, "m_flDuckSpeed");
	
	// Turning
	gF_Yaw[client] = angles[1];
	if (angles[1] != oldYaw) {
		gB_Turning[client] = true;
		gB_TurningLeft[client] = PlayerIsTurningLeft(angles[1], oldYaw);
		gB_TurningRight[client] = !gB_TurningLeft[client];
	}
	else {
		gB_Turning[client] = false;
		gB_TurningLeft[client] = false;
		gB_TurningRight[client] = false;
	}
	
	return Plugin_Continue;
}

public void Event_Jump(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	gB_JustJumped[client] = true;
} 