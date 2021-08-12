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
	version = "2.1.0", 
	url = "https://github.com/danzayau/MovementAPI"
};

GameData gH_GameData;
Handle gH_GetMaxSpeed;
int gI_Cmdnum[MAXPLAYERS + 1];
int gI_TickCount[MAXPLAYERS + 1];
bool gB_JustJumped[MAXPLAYERS + 1];

ConVar gCV_sv_gravity;
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
	gCV_sv_gravity = FindConVar("sv_gravity");
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

	gH_OnDuck = DynamicDetour.FromConf(gH_GameData, "CCSGameMovement::Duck");
	if (!gH_OnDuck)
	{
		SetFailState("Failed to find CCSGameMovement::Duck config");
	}
	if (!gH_OnDuck.Enable(Hook_Pre, DHooks_OnDuck_Pre))
	{
		SetFailState("Failed to enable detour on CCSGameMovement::Duck");
	}
	if (!gH_OnDuck.Enable(Hook_Post, DHooks_OnDuck_Post))
	{
		SetFailState("Failed to enable detour on CCSGameMovement::Duck");
	}

	gH_OnLadderMove = DynamicDetour.FromConf(gH_GameData, "CGameMovement::LadderMove");
	if (!gH_OnLadderMove)
	{
		SetFailState("Failed to find CGameMovement::LadderMove config");
	}
	if (!gH_OnLadderMove.Enable(Hook_Pre, DHooks_OnLadderMove_Pre))
	{
		SetFailState("Failed to enable detour on CGameMovement::LadderMove");
	}
	if (!gH_OnLadderMove.Enable(Hook_Post, DHooks_OnLadderMove_Post))
	{
		SetFailState("Failed to enable detour on CGameMovement::LadderMove");
	}

	gH_OnFullLadderMove = DynamicDetour.FromConf(gH_GameData, "CGameMovement::FullLadderMove");
	if (!gH_OnFullLadderMove)
	{
		SetFailState("Failed to find CGameMovement::FullLadderMove config");
	}
	if (!gH_OnFullLadderMove.Enable(Hook_Pre, DHooks_OnFullLadderMove_Pre))
	{
		SetFailState("Failed to enable detour on CGameMovement::FullLadderMove");
	}
	if (!gH_OnFullLadderMove.Enable(Hook_Post, DHooks_OnFullLadderMove_Post))
	{
		SetFailState("Failed to enable detour on CGameMovement::FullLadderMove");
	}

	gH_OnAirAccelerate = DynamicDetour.FromConf(gH_GameData, "CGameMovement::AirAccelerate");
	if (!gH_OnAirAccelerate)
	{
		SetFailState("Failed to enable detour on CGameMovement::TryPlayerMove");
	}
	if (!gH_OnAirAccelerate.Enable(Hook_Pre, DHooks_OnAirAccelerate_Pre))
	{
		SetFailState("Failed to enable detour on CGameMovement::AirAccelerate");
	}
	if (!gH_OnAirAccelerate.Enable(Hook_Post, DHooks_OnAirAccelerate_Post))
	{
		SetFailState("Failed to enable detour on CGameMovement::AirAccelerate");
	}

	gH_OnWalkMove = DynamicDetour.FromConf(gH_GameData, "CGameMovement::WalkMove");
	if (!gH_OnWalkMove)
	{
		SetFailState("Failed to find CGameMovement::WalkMove config");
	}
	if (!gH_OnWalkMove.Enable(Hook_Post, DHooks_OnWalkMove_Post))
	{
		SetFailState("Failed to enable detour on CGameMovement::WalkMove");
	}

	gH_OnJump = DynamicDetour.FromConf(gH_GameData, "CCSGameMovement::OnJump");
	if (!gH_OnJump)
	{
		SetFailState("Failed to find CCSGameMovement::OnJump config");
	}
	if (!gH_OnJump.Enable(Hook_Post, DHooks_OnJump_Post))
	{
		SetFailState("Failed to enable detour on CCSGameMovement::OnJump");
	}
	
	gH_OnPlayerMove = DynamicDetour.FromConf(gH_GameData, "CCSGameMovement::PlayerMove");
	if (!gH_OnPlayerMove)
	{
		SetFailState("Failed to find CCSGameMovement::PlayerMove config");
	}
	if (!gH_OnPlayerMove.Enable(Hook_Post, DHooks_OnPlayerMove_Post))
	{
		SetFailState("Failed to enable detour on CCSGameMovement::PlayerMove");
	}
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
	bool ducking = Movement_GetDucking(client);	
	UpdateTurning(client, gF_OldEyeAngles[client], eyeAngles);
	UpdateDucking(client, gB_OldDucking[client], ducking);
	UpdateOnGround(client, gI_Cmdnum[client], gI_TickCount[client]);
	if (Movement_GetMovetype(client) != gMT_OldMovetype[client])
	{
		UpdateMovetype(client, gI_Cmdnum[client], gI_TickCount[client]);
	}
	gB_JustJumped[client] = false;
	Movement_GetOrigin(client, gF_OldOrigin[client]);
	Movement_GetVelocity(client, gF_OldVelocity[client]);
	gF_OldEyeAngles[client] = eyeAngles;
	gB_OldOnGround[client] = Movement_GetOnGround(client);
	gB_OldDucking[client] = ducking;
	gMT_OldMovetype[client] = Movement_GetMovetype(client);
	gB_OldDuckbugged[client] = gB_Duckbugged[client];
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
	gB_JustJumped[client] = true;
	bool jumpbug = !gB_OldOnGround[client];	
	Call_OnPlayerJump(client, jumpbug);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	gI_Cmdnum[client] = cmdnum;
	gI_TickCount[client] = tickcount;
	gB_Duckbugged[client] = false;
	gB_WalkMoved[client] = false;
	gB_Jumpbugged[client] = false;
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

	gB_OldDuckbugged[client] = false;
	gF_OldPostAAOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_OldPostAAVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gB_OldWalkMoved[client] = false;

	gF_PreLadderMoveOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_PreLadderMoveVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gB_ProcessingFullLadderMove[client] = false;
	gF_PostLadderMoveOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );

	gF_PreDuckOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gB_OnDuck_OnGround[client] = false;
	gB_Duckbugged[client] = false;
	gF_PostDuckOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );

	gB_Jumpbugged[client] = false;
	gF_PostJumpVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_PostLadderMoveVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );

	gB_WalkMoved[client] = false;
	gF_PostWalkMoveOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_PostWalkMoveVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );

	gF_PreAAVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_PostAAOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_PostAAVelocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );

	gF_PlayerMoveVelocity_Post[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
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

static void UpdateOnGround(int client, int cmdnum, int tickcount)
{
	// GetOriginEx returns an incorrect origin that the player was never on.
	// Use NoBugLandingOrigin for distbug origin, and GetOrigin for real origin.
	// GetOriginEx causes ladderhop jumpstats to gain extra airtime.
	float origin[3];
	Movement_GetOrigin(client, origin);

	// Need to take into account SlopeFix() being called during PostThink...
	float velocity[3];
	float slopeFixAccel[3];
	Movement_GetVelocity(client, velocity);
	SubtractVectors(velocity, gF_PlayerMoveVelocity_Post[client], slopeFixAccel);

	// The game can still categorize you as "on ground" while noclipping.
	// Since no real ground collision happens, we just consider the player as not on ground.
	bool onGround = Movement_GetOnGround(client) && Movement_GetMovetype(client) != MOVETYPE_NOCLIP;

	// Duckbug is a special case where you can land then jump on the same tick.
	if (gB_Duckbugged[client])
	{
		// On this tick WalkMove can be called instead of AirMove.
		// Therefore gF_PostAAOrigin can't be used here.
		// Movement_GetOrigin will results in different landing origins,
		// depending on whether you jumped or not in this tick.
		gF_LandingOrigin[client] = gF_PostDuckOrigin[client];
		AddVectors(gF_PreAAVelocity[client], slopeFixAccel, gF_LandingVelocity[client]);
		gI_LandingTick[client] = tickcount;
		gI_LandingCmdNum[client] = cmdnum;

		if (!onGround) // AirMove is called.
		{
			// In that case, nobug origin needs to be calculated from last tick's velocity after air accel,
			// as landing on this tick is caused by Duck() and not AirMove().
			NobugLandingOrigin(client, gF_PostDuckOrigin[client], gF_OldPostAAVelocity[client], gF_NobugLandingOrigin[client]);
			gF_TakeoffOrigin[client] = gF_PostDuckOrigin[client];
			AddVectors(gF_PreAAVelocity[client], slopeFixAccel, gF_TakeoffVelocity[client]);
			gB_HitPerf[client] = gB_JustJumped[client];
			gI_TakeoffTick[client] = tickcount;
			gI_TakeoffCmdNum[client] = cmdnum;
			gB_Jumped[client] = gB_JustJumped[client];
			// The player never touches the ground so they can't "leave" it, do not call OnStopTouchGround.
			Call_OnJumpbug(client);
		}
		else // WalkMove is called.
		{
			// Did not jumpbug, player fully touched the ground.
			NobugLandingOrigin(client, gF_PostDuckOrigin[client], gF_PostAAVelocity[client], gF_NobugLandingOrigin[client]);
			Call_OnStartTouchGround(client);
		}
	}
	else if (onGround && !gB_OldOnGround[client])
	{
		// We use PostAAVelocity for nobug origin because AirMove() results in landing.
		NobugLandingOrigin(client, gF_PostAAOrigin[client], gF_PostAAVelocity[client], gF_NobugLandingOrigin[client]);
		gF_LandingOrigin[client] = origin;
		AddVectors(gF_PreAAVelocity[client], slopeFixAccel, gF_LandingVelocity[client]);
		gI_LandingTick[client] = tickcount;
		gI_LandingCmdNum[client] = cmdnum;
		Call_OnStartTouchGround(client);
	}
	else if (!onGround && gB_OldOnGround[client])
	{
		gI_TakeoffTick[client] = tickcount;
		gI_TakeoffCmdNum[client] = cmdnum;
		gB_Jumped[client] = gB_JustJumped[client];
		gF_TakeoffOrigin[client] = gF_OldOrigin[client];
		if (gMT_OldMovetype[client] == MOVETYPE_LADDER) // Ladderjump/Ladderhop/Climbing ladder
		{
			AddVectors(gF_PreAAVelocity[client], slopeFixAccel, gF_TakeoffVelocity[client]);
			// Can't perf off ladders.
			gB_HitPerf[client] = false;
		}
		else if (gMT_OldMovetype[client] == MOVETYPE_WALK) 
		{
			gF_TakeoffOrigin[client] = gF_OldOrigin[client];
			if (gB_JustJumped[client]) // Jumping
			{
				AddVectors(gF_PreAAVelocity[client], slopeFixAccel, gF_TakeoffVelocity[client]);
			}
			else // Falling
			{
				// OldVelocity is one tick too early if you walk off a block.
				AddVectors(gF_PostWalkMoveVelocity[client], slopeFixAccel, gF_TakeoffVelocity[client]);
			}

			// If you walked on the last tick then clearly it's not going to be a perf.
			// Can't perf if you don't jump.
			gB_HitPerf[client] = gB_JustJumped[client] && !gB_OldWalkMoved[client];
		}
		else // Noclip and fallback scenarios
		{
			gF_TakeoffVelocity[client] = gF_OldVelocity[client];
			gB_HitPerf[client] = false;
		}
		Call_OnStopTouchGround(client, gB_JustJumped[client]);
	}
}

static void UpdateMovetype(int client, int cmdnum, int tickcount)
{
	switch (Movement_GetMovetype(client))
	{
		case MOVETYPE_WALK:
		{
			// The only change that should matter is between MOVETYPE_LADDER and MOVETYPE_WALK.
			if (gMT_OldMovetype[client] == MOVETYPE_LADDER) // Ladder jump or ladder hop
			{
				gF_TakeoffVelocity[client] = gF_PostLadderMoveVelocity[client];
			}
			else
			{
				Movement_GetVelocity(client, gF_TakeoffVelocity[client]);
			}
			// PostLadderMoveOrigin should do the same thing as OldOrigin.
			// The only time it differs is when the player walks off the ground
			// trying to snap to a ladder behind them, which isn't the case here.
			gF_TakeoffOrigin[client] = gF_OldOrigin[client];
			gI_TakeoffTick[client] = tickcount;
			gI_TakeoffCmdNum[client] = cmdnum;
			gB_Jumped[client] = gB_JustJumped[client];
			gB_HitPerf[client] = false;			
		}
		case MOVETYPE_LADDER:
		{
			Movement_GetOrigin(client, gF_LandingOrigin[client]);
			gF_LandingVelocity[client] = gF_PreLadderMoveVelocity[client];
			gI_LandingTick[client] = tickcount;
			gI_LandingCmdNum[client] = cmdnum;
		}
		case MOVETYPE_NOCLIP:
		{
			Movement_GetOrigin(client, gF_LandingOrigin[client]);
			Movement_GetVelocity(client, gF_LandingVelocity[client]);
			gI_LandingTick[client] = tickcount;
			gI_LandingCmdNum[client] = cmdnum;
		}
	}
	Call_OnChangeMovetype(client, gMT_OldMovetype[client], Movement_GetMovetype(client));
}

static void UpdateTurning(int client, const float oldEyeAngles[3], const float eyeAngles[3])
{
	gB_Turning[client] = eyeAngles[1] != oldEyeAngles[1];
	gB_TurningLeft[client] = eyeAngles[1] < oldEyeAngles[1] - 180
	 || eyeAngles[1] > oldEyeAngles[1] && eyeAngles[1] < oldEyeAngles[1] + 180;
}

static void NobugLandingOrigin(int client, const float oldOrigin[3], const float oldVelocity[3], float landingOrigin[3])
{
	float firstTraceEndpoint[3], velocity[3];
	float hullMin[3] =  { -16.0, -16.0, 0.0 };
	float hullMax[3] =  { 16.0, 16.0, 0.0 };
	
	velocity[0] = oldVelocity[0] * GetTickInterval();
	velocity[1] = oldVelocity[1] * GetTickInterval();
	velocity[2] = oldVelocity[2] * GetTickInterval();
	AddVectors(oldOrigin, velocity, firstTraceEndpoint);
	
	Handle trace = TR_TraceHullFilterEx(oldOrigin, firstTraceEndpoint, hullMin, hullMax, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
	if (!TR_DidHit(trace))
	{
		// Nobug jump, extrapolating landing position
		delete trace;
		
		float secondTraceEndpoint[3];
		// Movement_GetGravity is not sv_gravity. Normally this is 1 or 0, sometimes 40 on antibhop triggers.		
		// We will (boldly) assume that player's gravity wasn't changed between OnPlayerRunCmd and PostThink.

		velocity[2] -= GetTickInterval() * GetTickInterval() * gCV_sv_gravity.FloatValue;	
		AddVectors(firstTraceEndpoint, velocity, secondTraceEndpoint);
		trace = TR_TraceHullFilterEx(firstTraceEndpoint, secondTraceEndpoint, hullMin, hullMax, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
		
		// It is possible to not hit the trace, if your vertical velocity is low enough.
		// In an extreme case, you would need 10 more traces for this to hit.
		// It is also possible to miss the trace on a flat jump, by hitting the very edge of a block.
		if (!TR_DidHit(trace))
		{
			// Invalidate the landing origin	
			landingOrigin[0] = 0.0 / 0.0;
			landingOrigin[1] = 0.0 / 0.0;
			landingOrigin[2] = 0.0 / 0.0;
			delete trace;
			return;
		}
	}
	
	TR_GetEndPosition(landingOrigin, trace);
	// The trace is correct, the player will be at least 0.03125 unit above the ground.
	// So do not subtract the z origin by 0.03125.
	
	delete trace;
}