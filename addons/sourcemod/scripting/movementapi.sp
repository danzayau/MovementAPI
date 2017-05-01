#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <movement>

#include <movementapi>

#pragma newdecls required
#pragma semicolon 1

#define MAX_BUTTONS 25



public Plugin myinfo = 
{
	name = "MovementAPI", 
	author = "DanZay", 
	description = "MovementAPI Plugin", 
	version = "0.8.0", 
	url = "https://github.com/danzayau/MovementAPI"
};



int gI_TickCount[MAXPLAYERS + 1];

float gF_LandingOrigin[MAXPLAYERS + 1][3];
float gF_LandingVelocity[MAXPLAYERS + 1][3];
int gI_LandingTick[MAXPLAYERS + 1];

float gF_TakeoffOrigin[MAXPLAYERS + 1][3];
float gF_TakeoffVelocity[MAXPLAYERS + 1][3];
int gI_TakeoffTick[MAXPLAYERS + 1];

bool gB_JustJumped[MAXPLAYERS + 1];

float gF_OldOrigin[MAXPLAYERS + 1][3];
float gF_OldGroundOrigin[MAXPLAYERS + 1][3];
float gF_OldVelocity[MAXPLAYERS + 1][3];
bool gB_OldDucking[MAXPLAYERS + 1];
bool gB_OldOnGround[MAXPLAYERS + 1];
MoveType gMT_OldMoveType[MAXPLAYERS + 1];
float gF_OldEyeAngles[MAXPLAYERS + 1][3];
int gI_OldButtons[MAXPLAYERS + 1];



#include "movementapi/forwards.sp"
#include "movementapi/natives.sp"



/*===============================  Forwards  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	RegPluginLibrary("movementapi");
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateGlobalForwards();
	HookEvent("player_jump", OnPlayerJump, EventHookMode_Pre);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	
	gI_TickCount[client]++;
	
	UpdateButtons(client, buttons);
	UpdateTakeoff(client);
	UpdateLanding(client);
	TryCallForwards(client);
	
	UpdateOldVariables(client);
	
	return Plugin_Continue;
}

public void OnPlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	gB_JustJumped[client] = true;
}



/*===============================  Functions  ===============================*/

void UpdateButtons(int client, int buttons)
{
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		int button = (1 << i);
		if (buttons & button)
		{
			if (!(gI_OldButtons[client] & button))
			{
				Call_OnButtonPress(client, button);
			}
		}
		else if (gI_OldButtons[client] & button)
		{
			Call_OnButtonRelease(client, button);
		}
	}
	gI_OldButtons[client] = buttons;
}

void UpdateTakeoff(int client)
{
	// If just took off the ground.
	if (!Movement_GetOnGround(client) && gB_OldOnGround[client])
	{
		gF_TakeoffOrigin[client] = gF_OldGroundOrigin[client];
		gF_TakeoffVelocity[client] = gF_OldVelocity[client];
		gI_TakeoffTick[client] = gI_TickCount[client] - 1;
	}
	// Ekse if just took off a ladder or left noclip.
	else if (!Movement_GetOnLadder(client) && gMT_OldMoveType[client] == MOVETYPE_LADDER
		 || !Movement_GetNoclipping(client) && gMT_OldMoveType[client] == MOVETYPE_NOCLIP)
	{
		gF_TakeoffOrigin[client] = gF_OldOrigin[client];
		gF_TakeoffVelocity[client] = gF_OldVelocity[client];
		gI_TakeoffTick[client] = gI_TickCount[client] - 1;
	}
}

void UpdateLanding(int client)
{
	if (Movement_GetOnGround(client) && !gB_OldOnGround[client])
	{
		GetGroundOrigin(client, gF_LandingOrigin[client]);
		gF_LandingVelocity[client] = gF_OldVelocity[client];
		gI_LandingTick[client] = gI_TickCount[client] - 1;
	}
	else if (Movement_GetOnLadder(client) && gMT_OldMoveType[client] != MOVETYPE_LADDER
		 || Movement_GetNoclipping(client) && gMT_OldMoveType[client] != MOVETYPE_NOCLIP)
	{
		Movement_GetOrigin(client, gF_LandingOrigin[client]);
		gF_LandingVelocity[client] = gF_OldVelocity[client];
		gI_LandingTick[client] = gI_TickCount[client] - 1;
	}
}

void UpdateOldVariables(int client)
{
	Movement_GetOrigin(client, gF_OldOrigin[client]);
	GetGroundOrigin(client, gF_OldGroundOrigin[client]);
	Movement_GetVelocity(client, gF_OldVelocity[client]);
	Movement_GetEyeAngles(client, gF_OldEyeAngles[client]);
	
	gB_OldDucking[client] = Movement_GetDucking(client);
	gB_OldOnGround[client] = Movement_GetOnGround(client);
	gMT_OldMoveType[client] = Movement_GetMoveType(client);
}

// Gets the origin of the ground beneath the player (more accurate than origin when on ground).
// Ground origin is NULL_VECTOR ({0.0, 0.0, 0.0}) if ground is more than 8 units below player origin
void GetGroundOrigin(int client, float groundOrigin[3])
{
	float startPosition[3], endPosition[3];
	GetClientAbsOrigin(client, startPosition);
	endPosition = startPosition;
	endPosition[2] = startPosition[2] - 8.0;
	Handle trace = TR_TraceHullFilterEx(
		startPosition, 
		endPosition, 
		view_as<float>( { -16.0, -16.0, 0.0 } ),  // Players are 32x32
		view_as<float>( { 16.0, 16.0, 1.0 } ), 
		MASK_PLAYERSOLID, 
		TraceEntityFilterPlayers, 
		client);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(groundOrigin, trace);
		groundOrigin[2] = groundOrigin[2] - 0.03125; // Offset the error (unknown why it is inaccurate)
	}
	else
	{
		groundOrigin = NULL_VECTOR;
	}
	CloseHandle(trace);
}

public bool TraceEntityFilterPlayers(int entity, int contentsMask, any data)
{
	return (entity != data && entity >= 1 && entity <= MaxClients);
}

bool PlayerIsTurning(int client)
{
	float eyeAngles[3];
	Movement_GetEyeAngles(client, eyeAngles);
	return eyeAngles[1] != gF_OldEyeAngles[client][1];
}

bool PlayerIsTurningLeft(int client)
{
	float eyeAngles[3];
	Movement_GetEyeAngles(client, eyeAngles);
	return (eyeAngles[1] > gF_OldEyeAngles[client][1] && eyeAngles[1] < gF_OldEyeAngles[client][1] + 180
		 || eyeAngles[1] < gF_OldEyeAngles[client][1] - 180);
} 