#include <sourcemod>

#include <sdkhooks>
#include <dhooks>

#include <movement>

#pragma newdecls required
#pragma semicolon 1



public Plugin myinfo = 
{
	name = "MovementAPI", 
	author = "DanZay", 
	description = "Provides API focused on player movement", 
	version = "2.3.0", 
	url = "https://github.com/danzayau/MovementAPI"
};

GameData gH_GameData;
Handle gH_GetMaxSpeed;
int gI_Cmdnum[MAXPLAYERS + 1];
int gI_TickCount[MAXPLAYERS + 1];

bool gB_Jumped[MAXPLAYERS + 1];
bool gB_HitPerf[MAXPLAYERS + 1];
float gF_NobugLandingOrigin[MAXPLAYERS + 1][3];
float gF_LandingOrigin[MAXPLAYERS + 1][3];
float gF_LandingVelocity[MAXPLAYERS + 1][3];
int gI_LandingTick[MAXPLAYERS + 1];
int gI_LandingCmdNum[MAXPLAYERS + 1];
float gF_TakeoffOrigin[MAXPLAYERS + 1][3];
float gF_TakeoffVelocity[MAXPLAYERS + 1][3];
int gI_TakeoffTick[MAXPLAYERS + 1];
int gI_TakeoffCmdNum[MAXPLAYERS + 1];
bool gB_Turning[MAXPLAYERS + 1];
bool gB_TurningLeft[MAXPLAYERS + 1];

float gF_OldOrigin[MAXPLAYERS + 1][3];
float gF_OldVelocity[MAXPLAYERS + 1][3];
float gF_OldEyeAngles[MAXPLAYERS + 1][3];
bool gB_OldOnGround[MAXPLAYERS + 1];
bool gB_OldDucking[MAXPLAYERS + 1];
MoveType gMT_OldMovetype[MAXPLAYERS + 1];

#include "movementapi/stocks.sp"
#include "movementapi/hooks.sp"
#include "movementapi/natives.sp"
#include "movementapi/forwards.sp"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	RegPluginLibrary("movementapi");
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvents();
	CreateGlobalForwards();
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_jump", OnPlayerJump, EventHookMode_Post);
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			OnClientPutInServer(client);
			if (IsPlayerAlive(client))
			{
				ResetClientData(client);
			}
		}
	}
}

void HookEvents()
{
	PrepSDKCalls();
	HookGameMovementFunctions();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PostThinkPost, OnPlayerPostThinkPost);
}

public void OnPlayerPostThinkPost(int client)
{
	if (!IsPlayerAlive(client))
	{
		return;
	}
	
	float eyeAngles[3];
	Movement_GetEyeAngles(client, eyeAngles);
	UpdateTurning(client, gF_OldEyeAngles[client], eyeAngles);
	gF_OldEyeAngles[client] = eyeAngles;

	Movement_GetOrigin(client, gF_OldOrigin[client]);
	Movement_GetVelocity(client, gF_OldVelocity[client]);
	gB_OldOnGround[client] = Movement_GetOnGround(client);
	gB_OldDucking[client] = gB_Ducking[client];
	gMT_OldMovetype[client] = Movement_GetMovetype(client);
	gB_OldWalkMoved[client] = gB_WalkMoved[client];
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetClientData(client);
}

public void OnPlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	bool jumpbug = !gB_OldOnGround[client];	
	Call_OnPlayerJump(client, jumpbug);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	CheckNoclip(client);
	gI_Cmdnum[client] = cmdnum;
	gI_TickCount[client] = tickcount;
	return Plugin_Continue;
}

float GetMaxSpeed(int client)
{
	return SDKCall(gH_GetMaxSpeed, client);
}

static void PrepSDKCalls()
{
	gH_GameData = LoadGameConfigFile("movementapi.games");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gH_GameData, SDKConf_Virtual, "GetPlayerMaxSpeed");
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_ByValue);
	gH_GetMaxSpeed = EndPrepSDKCall();
}

static void ResetClientData(int client)
{
	gB_Jumped[client] = false;
	gB_HitPerf[client] = false;
	gF_TakeoffOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_TakeoffVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gI_TakeoffTick[client] = 0;
	gF_LandingOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_LandingVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gI_LandingTick[client] = 0;
	gB_Turning[client] = false;
	gB_TurningLeft[client] = false;
	
	gF_OldOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_OldVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_OldEyeAngles[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gB_OldOnGround[client] = false;
	gB_OldDucking[client] = false;
	gMT_OldMovetype[client] = MOVETYPE_WALK;

	gB_ProcessingLadderMove[client] = false;
	gF_PreLadderMoveVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gB_TakeoffFromLadder[client] = false;
	gF_PostLadderMoveOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_PostLadderMoveVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gB_ProcessingDuck[client] = false;
	gF_PreLadderMoveVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gB_Ducking[client] = false;
	gB_PrevOnGround[client] = false;
	gB_Duckbugged[client] = false;
	gF_PostDuckOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );

	gB_Jumpbugged[client] = false;

	gB_WalkMoved[client] = false;
	gF_PostWalkMoveVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_PostAAOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_PostAAVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	
	gB_OldWalkMoved[client] = false;

}

static void UpdateTurning(int client, const float oldEyeAngles[3], const float eyeAngles[3])
{
	gB_Turning[client] = eyeAngles[1] != oldEyeAngles[1];
	gB_TurningLeft[client] = eyeAngles[1] < oldEyeAngles[1] - 180
	 || eyeAngles[1] > oldEyeAngles[1] && eyeAngles[1] < oldEyeAngles[1] + 180;
}

static void CheckNoclip(int client)
{
	// Leaving and entering noclip counts for leaving and touching ground is arbitrary.
	// Though this is required for some GOKZ functions to work properly.
	MoveType movetype = Movement_GetMovetype(client);
	if (gMT_OldMovetype[client] != movetype)
	{
		// Entering noclip
		if (movetype == MOVETYPE_NOCLIP)
		{
			gF_LandingOrigin[client] = gF_Origin[client];
			gF_LandingVelocity[client] = gF_Velocity[client];
			gI_LandingTick[client] = gI_TickCount[client];
			gI_LandingCmdNum[client] = gI_Cmdnum[client];
		}
		else // Leaving noclip
		{
			gF_TakeoffOrigin[client] = gF_Origin[client];
			gF_TakeoffVelocity[client] = gF_Velocity[client];
			gI_TakeoffTick[client] = gI_TickCount[client];
			gI_TakeoffCmdNum[client] = gI_Cmdnum[client];
			gB_HitPerf[client] = false;
			gB_Jumped[client] = false;
		}
		Call_OnChangeMovetype(client, gMT_OldMovetype[client], movetype);
	}
}

