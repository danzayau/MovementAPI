#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <movement>

#pragma newdecls required
#pragma semicolon 1

#define MAX_BUTTONS 25



public Plugin myinfo = 
{
	name = "MovementAPI", 
	author = "DanZay", 
	description = "MovementAPI Plugin", 
	version = "0.9.0", 
	url = "https://github.com/danzayau/MovementAPI"
};



bool gB_JustJumped[MAXPLAYERS + 1];

bool gB_Jumped[MAXPLAYERS + 1];
bool gB_HitPerf[MAXPLAYERS + 1];
float gF_LandingOrigin[MAXPLAYERS + 1][3];
float gF_LandingVelocity[MAXPLAYERS + 1][3];
int gI_LandingTick[MAXPLAYERS + 1];
float gF_TakeoffOrigin[MAXPLAYERS + 1][3];
float gF_TakeoffVelocity[MAXPLAYERS + 1][3];
int gI_TakeoffTick[MAXPLAYERS + 1];
bool gB_Turning[MAXPLAYERS + 1];
bool gB_TurningLeft[MAXPLAYERS + 1];

int gI_OldButtons[MAXPLAYERS + 1];
float gF_OldOrigin[MAXPLAYERS + 1][3];
float gF_OldVelocity[MAXPLAYERS + 1][3];
float gF_OldEyeAngles[MAXPLAYERS + 1][3];
bool gB_OldOnGround[MAXPLAYERS + 1];
bool gB_OldDucking[MAXPLAYERS + 1];
MoveType gMT_OldMoveType[MAXPLAYERS + 1];



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
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_jump", OnPlayerJump, EventHookMode_Pre);
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
	
	gI_OldButtons[client] = 0;
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
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	
	float origin[3];
	Movement_GetOrigin(client, origin);
	float velocity[3];
	Movement_GetVelocity(client, velocity);
	float eyeAngles[3];
	Movement_GetEyeAngles(client, eyeAngles);
	bool onGround = Movement_GetOnGround(client);
	bool ducking = Movement_GetDucking(client);
	MoveType moveType = Movement_GetMoveType(client);
	
	UpdateButtons(client, buttons);
	UpdateDucking(client, ducking);
	UpdateOnGround(client, tickcount, onGround, origin, velocity);
	UpdateMoveType(client, tickcount, moveType, origin, velocity);
	UpdateEyeAngles(client, eyeAngles);
	
	gI_OldButtons[client] = buttons;
	gF_OldOrigin[client] = origin;
	gF_OldVelocity[client] = velocity;
	gF_OldEyeAngles[client] = eyeAngles;
	gB_OldOnGround[client] = onGround;
	gB_OldDucking[client] = ducking;
	gMT_OldMoveType[client] = moveType;
	
	return Plugin_Continue;
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
}

void UpdateDucking(int client, bool ducking)
{
	if (ducking && !gB_OldDucking[client])
	{
		Call_OnStartDucking(client);
	}
	else if (!ducking && gB_OldDucking[client])
	{
		Call_OnStopDucking(client);
	}
}

void UpdateOnGround(int client, int tickcount, bool onGround, const float origin[3], const float velocity[3])
{
	if (onGround && !gB_OldOnGround[client])
	{
		gF_LandingOrigin[client] = origin;
		gF_LandingVelocity[client] = velocity;
		gI_LandingTick[client] = tickcount - 1;
		Call_OnStartTouchGround(client);
	}
	else if (!onGround && gB_OldOnGround[client])
	{
		gF_TakeoffOrigin[client] = gF_OldOrigin[client];
		gF_TakeoffVelocity[client] = gF_OldVelocity[client];
		gI_TakeoffTick[client] = tickcount - 1;
		gB_HitPerf[client] = gI_TakeoffTick[client] - gI_LandingTick[client] == 1;
		Call_OnStopTouchGround(client, gB_JustJumped[client]);
		gB_JustJumped[client] = false; // Handled event_jump
	}
}

void UpdateMoveType(int client, int tickcount, MoveType moveType, const float origin[3], const float velocity[3])
{
	if (moveType != gMT_OldMoveType[client])
	{
		switch (moveType)
		{
			case MOVETYPE_WALK:
			{
				gF_TakeoffOrigin[client] = gF_OldOrigin[client];
				gF_TakeoffVelocity[client] = gF_OldVelocity[client];
				gI_TakeoffTick[client] = tickcount - 1;
				gB_HitPerf[client] = false;
			}
			case MOVETYPE_LADDER:
			{
				gF_LandingOrigin[client] = origin;
				gF_LandingVelocity[client] = gF_OldVelocity[client];
				gI_LandingTick[client] = tickcount - 1;
			}
			case MOVETYPE_NOCLIP:
			{
				gF_LandingOrigin[client] = origin;
				gF_LandingVelocity[client] = velocity;
				gI_LandingTick[client] = tickcount - 1;
			}
		}
		Call_OnChangeMoveType(client, gMT_OldMoveType[client], moveType);
	}
}

void UpdateEyeAngles(int client, const float eyeAngles[3])
{
	gB_Turning[client] = eyeAngles[1] != gF_OldEyeAngles[client][1];
	gB_TurningLeft[client] = eyeAngles[1] > gF_OldEyeAngles[client][1] && eyeAngles[1] < gF_OldEyeAngles[client][1] + 180
	 || eyeAngles[1] < gF_OldEyeAngles[client][1] - 180;
} 