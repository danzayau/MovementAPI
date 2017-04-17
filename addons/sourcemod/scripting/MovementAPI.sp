#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <movement>

#pragma newdecls required
#pragma semicolon 1



public Plugin myinfo = 
{
	name = "Player Movement API", 
	author = "DanZay", 
	description = "API plugin for player movement.", 
	version = "0.6.0", 
	url = "https://github.com/danzayau/MovementAPI"
};



bool gB_LateLoad;

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
float gF_OldGroundOrigin[MAXPLAYERS + 1][3];
float gF_OldVelocity[MAXPLAYERS + 1][3];
float gF_OldSpeed[MAXPLAYERS + 1];
bool gB_OldDucking[MAXPLAYERS + 1];
bool gB_OldOnGround[MAXPLAYERS + 1];
bool gB_OldOnLadder[MAXPLAYERS + 1];
bool gB_OldNoclipping[MAXPLAYERS + 1];
float gF_OldEyeAngles[MAXPLAYERS + 1][3];
int gI_OldButtons[MAXPLAYERS + 1];



#include "MovementAPI/movementtracking.sp"
#include "MovementAPI/misc.sp"
#include "MovementAPI/forwards.sp"
#include "MovementAPI/natives.sp"



/*===============================  Plugin Forwards  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	RegPluginLibrary("MovementAPI");
	gB_LateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateGlobalForwards();
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_jump", OnPlayerJump, EventHookMode_Pre);
	if (gB_LateLoad)
	{
		OnLateLoad();
	}
}

void OnLateLoad()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			OnClientPutInServer(client);
		}
	}
}



/*===============================  Client Forwards  ===============================*/

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
}

public void OnClientPreThink(int client)
{
	if (IsPlayerAlive(client))
	{
		UpdateOldVariables(client);
		UpdateVariables(client);
		TryCallForwards(client);
		Call_OnClientPreThink(client);
	}
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