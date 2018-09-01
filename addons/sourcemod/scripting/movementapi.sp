#include <sourcemod>
#include <sdktools>
#include <movement>

#pragma newdecls required
#pragma semicolon 1



public Plugin myinfo = 
{
	name = "MovementAPI", 
	author = "DanZay", 
	description = "MovementAPI Plugin", 
	version = "1.0.0", 
	url = "https://github.com/danzayau/MovementAPI"
};

Handle gH_GameData;
Handle gH_GetMaxSpeed;

bool gB_JustJumped[MAXPLAYERS + 1];

bool gB_Jumped[MAXPLAYERS + 1];
bool gB_HitPerf[MAXPLAYERS + 1];
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
MoveType gMT_OldMoveType[MAXPLAYERS + 1];

#include "movementapi/forwards.sp"
#include "movementapi/natives.sp"



public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	RegPluginLibrary("movementapi");
	return APLRes_Success;
}

public void OnPluginStart()
{
	PrepSDKCalls();
	CreateGlobalForwards();
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_jump", OnPlayerJump, EventHookMode_Post);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
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
	gMT_OldMoveType[client] = MOVETYPE_WALK;
}

public void OnPlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	gB_JustJumped[client] = true;
	bool jumpbug = !gB_OldOnGround[client];
	Call_OnPlayerJump(client, jumpbug);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	
	float origin[3];
	Movement_GetOriginEx(client, origin);
	float velocity[3];
	Movement_GetVelocity(client, velocity);
	float eyeAngles[3];
	Movement_GetEyeAngles(client, eyeAngles);
	bool onGround = Movement_GetOnGround(client);
	bool ducking = Movement_GetDucking(client);
	MoveType moveType = Movement_GetMoveType(client);
	
	UpdateDucking(client, gB_OldDucking[client], ducking);
	UpdateOnGround(client, cmdnum, tickcount, gB_OldOnGround[client], onGround, gF_OldOrigin[client], origin, gF_OldVelocity[client], velocity);
	UpdateMoveType(client, cmdnum, tickcount, gMT_OldMoveType[client], moveType, gF_OldOrigin[client], origin, gF_OldVelocity[client], velocity);
	UpdateTurning(client, gF_OldEyeAngles[client], eyeAngles);
	
	gB_JustJumped[client] = false;
	gF_OldOrigin[client] = origin;
	gF_OldVelocity[client] = velocity;
	gF_OldEyeAngles[client] = eyeAngles;
	gB_OldOnGround[client] = onGround;
	gB_OldDucking[client] = ducking;
	gMT_OldMoveType[client] = moveType;
	
	return Plugin_Continue;
}

float GetMaxSpeed(int client)
{
	return SDKCall(gH_GetMaxSpeed, client);
}



// =========================  PRIVATE  ========================= //

static void PrepSDKCalls()
{
	gH_GameData = LoadGameConfigFile("movementapi.games");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gH_GameData, SDKConf_Signature, "GetPlayerMaxSpeed");
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_ByValue);
	gH_GetMaxSpeed = EndPrepSDKCall();
}

static void UpdateDucking(int client, bool oldDucking, bool ducking)
{
	if (ducking && !oldDucking)
	{
		Call_OnStartDucking(client);
	}
	else if (!ducking && oldDucking)
	{
		Call_OnStopDucking(client);
	}
}

static void UpdateOnGround(
	int client, 
	int cmdnum, 
	int tickcount, 
	bool oldOnGround, 
	bool onGround, 
	const float oldOrigin[3], 
	const float origin[3], 
	const float oldVelocity[3], 
	const float velocity[3])
{
	if (onGround && !oldOnGround)
	{
		gF_LandingOrigin[client] = origin;
		gF_LandingVelocity[client] = velocity;
		gI_LandingTick[client] = tickcount;
		gI_LandingCmdNum[client] = cmdnum;
		Call_OnStartTouchGround(client);
	}
	else if (!onGround && oldOnGround)
	{
		gF_TakeoffOrigin[client] = oldOrigin;
		gF_TakeoffVelocity[client] = oldVelocity;
		gI_TakeoffTick[client] = tickcount;
		gI_TakeoffCmdNum[client] = cmdnum;
		gB_HitPerf[client] = (gI_TakeoffTick[client] - gI_LandingTick[client]) == 1;
		gB_Jumped[client] = gB_JustJumped[client];
		Call_OnStopTouchGround(client, gB_JustJumped[client]);
	}
}

static void UpdateMoveType(
	int client, 
	int cmdnum, 
	int tickcount, 
	MoveType oldMoveType, 
	MoveType moveType, 
	const float oldOrigin[3], 
	const float origin[3], 
	const float oldVelocity[3], 
	const float velocity[3])
{
	if (moveType != oldMoveType)
	{
		switch (moveType)
		{
			case MOVETYPE_WALK:
			{
				gF_TakeoffOrigin[client] = oldOrigin;
				// New velocity because game will adjust the velocity
				// of the player in some cases (jumping off ladder).
				gF_TakeoffVelocity[client] = velocity;
				gI_TakeoffTick[client] = tickcount;
				gI_TakeoffCmdNum[client] = cmdnum;
				gB_HitPerf[client] = false;
				gB_Jumped[client] = false;
			}
			case MOVETYPE_LADDER:
			{
				gF_LandingOrigin[client] = origin;
				// Old velocity because player loses speed before
				// their move type has changed to MOVETYPE_LADDER.
				gF_LandingVelocity[client] = oldVelocity;
				gI_LandingTick[client] = tickcount;
				gI_LandingCmdNum[client] = cmdnum;
			}
			case MOVETYPE_NOCLIP:
			{
				gF_LandingOrigin[client] = origin;
				gF_LandingVelocity[client] = velocity;
				gI_LandingTick[client] = tickcount;
				gI_LandingCmdNum[client] = cmdnum;
			}
		}
		Call_OnChangeMoveType(client, gMT_OldMoveType[client], moveType);
	}
}

static void UpdateTurning(int client, const float oldEyeAngles[3], const float eyeAngles[3])
{
	gB_Turning[client] = eyeAngles[1] != oldEyeAngles[1];
	gB_TurningLeft[client] = eyeAngles[1] < oldEyeAngles[1] - 180
	 || eyeAngles[1] > oldEyeAngles[1] && eyeAngles[1] < oldEyeAngles[1] + 180;
} 