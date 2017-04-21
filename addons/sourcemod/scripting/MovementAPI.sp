#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <movement>

#pragma newdecls required
#pragma semicolon 1

#define MAX_BUTTONS 25



public Plugin myinfo = 
{
	name = "Player Movement API", 
	author = "DanZay", 
	description = "API plugin for player movement.", 
	version = "0.7.1", 
	url = "https://github.com/danzayau/MovementAPI"
};



float gF_Origin[MAXPLAYERS + 1][3];
float gF_GroundOrigin[MAXPLAYERS + 1][3];

float gF_Velocity[MAXPLAYERS + 1][3];
float gF_Speed[MAXPLAYERS + 1];
float gF_BaseVelocity[MAXPLAYERS + 1][3];

bool gB_OnGround[MAXPLAYERS + 1];

MoveType gMT_MoveType[MAXPLAYERS + 1];
bool gB_OnLadder[MAXPLAYERS + 1];
bool gB_Noclipping[MAXPLAYERS + 1];

bool gB_Ducking[MAXPLAYERS + 1];

float gF_TakeoffOrigin[MAXPLAYERS + 1][3];
float gF_TakeoffVelocity[MAXPLAYERS + 1][3];
float gF_TakeoffSpeed[MAXPLAYERS + 1];
int gI_TakeoffTick[MAXPLAYERS + 1];

float gF_LandingOrigin[MAXPLAYERS + 1][3];
float gF_LandingVelocity[MAXPLAYERS + 1][3];
float gF_LandingSpeed[MAXPLAYERS + 1];
int gI_LandingTick[MAXPLAYERS + 1];

float gF_JumpMaxHeight[MAXPLAYERS + 1];
float gF_JumpDistance[MAXPLAYERS + 1];
float gF_JumpOffset[MAXPLAYERS + 1];

bool gB_HitPerf[MAXPLAYERS + 1];

float gF_VelocityModifier[MAXPLAYERS + 1];
float gF_DuckSpeed[MAXPLAYERS + 1];

float gF_EyeAngles[MAXPLAYERS + 1][3];

bool gB_JustJumped[MAXPLAYERS + 1];
bool gB_JustDucked[MAXPLAYERS + 1];

bool gB_JustTookOff[MAXPLAYERS + 1];
float gF_OldOrigin[MAXPLAYERS + 1][3];
float gF_OldGroundOrigin[MAXPLAYERS + 1][3];
float gF_OldVelocity[MAXPLAYERS + 1][3];
float gF_OldSpeed[MAXPLAYERS + 1];
bool gB_OldDucking[MAXPLAYERS + 1];
bool gB_OldOnGround[MAXPLAYERS + 1];
bool gB_OldOnLadder[MAXPLAYERS + 1];
bool gB_OldNoclipping[MAXPLAYERS + 1];
float gF_OldEyeAngles[MAXPLAYERS + 1][3];
int gI_OldButtons[MAXPLAYERS + 1];



#include "MovementAPI/misc.sp"
#include "MovementAPI/forwards.sp"
#include "MovementAPI/natives.sp"
#include "MovementAPI/tracking.sp"



/*===============================  Plugin Forwards  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	RegPluginLibrary("MovementAPI");
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateGlobalForwards();
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_jump", OnPlayerJump, EventHookMode_Pre);
}



/*===============================  Client Forwards  ===============================*/

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	
	UpdateButtons(client, buttons);
	UpdateOldVariables(client);
	UpdateVariables(client);
	TryCallForwards(client);
	Call_OnClientUpdate(client);
	
	return Plugin_Continue;
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetVariables(client);
}

public void OnPlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	gB_JustJumped[client] = true;
	gB_HitPerf[client] = GetGameTickCount() <= (gI_LandingTick[client] + 1);
} 