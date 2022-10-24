static DynamicDetour H_OnPlayerMove;
static DynamicDetour H_OnDuck;
static DynamicDetour H_OnLadderMove;
static DynamicDetour H_OnFullLadderMove;
static DynamicDetour H_OnJump;
static DynamicDetour H_OnAirAccelerate;
static DynamicDetour H_OnWalkMove;
static DynamicDetour H_OnCategorizePosition;

float gF_Origin[MAXPLAYERS + 1][3];
float gF_Velocity[MAXPLAYERS + 1][3];

bool gB_ProcessingLadderMove[MAXPLAYERS + 1];
float gF_PreLadderMoveVelocity[MAXPLAYERS + 1][3];
bool gB_TakeoffFromLadder[MAXPLAYERS + 1];
float gF_PostLadderMoveOrigin[MAXPLAYERS + 1][3];
float gF_PostLadderMoveVelocity[MAXPLAYERS + 1][3];

bool gB_ProcessingDuck[MAXPLAYERS + 1];
bool gB_Ducking[MAXPLAYERS + 1];
bool gB_PrevOnGround[MAXPLAYERS + 1];
bool gB_Duckbugged[MAXPLAYERS + 1];
float gF_PostDuckOrigin[MAXPLAYERS + 1][3];

bool gB_Jumpbugged[MAXPLAYERS + 1];

bool gB_WalkMoved[MAXPLAYERS + 1];
float gF_PostWalkMoveVelocity[MAXPLAYERS + 1][3];
float gF_PostAAOrigin[MAXPLAYERS + 1][3];
float gF_PostAAVelocity[MAXPLAYERS + 1][3];

bool gB_OldWalkMoved[MAXPLAYERS + 1];

void HookGameMovementFunctions()
{
	HookGameMovementFunction(H_OnDuck, "CCSGameMovement::Duck", DHooks_OnDuck_Pre, DHooks_OnDuck_Post);
	HookGameMovementFunction(H_OnLadderMove, "CGameMovement::LadderMove", DHooks_OnLadderMove_Pre, DHooks_OnLadderMove_Post);
	HookGameMovementFunction(H_OnFullLadderMove, "CGameMovement::FullLadderMove", DHooks_OnFullLadderMove_Pre, DHooks_OnFullLadderMove_Post);
	HookGameMovementFunction(H_OnAirAccelerate, "CGameMovement::AirAccelerate", DHooks_OnAirAccelerate_Pre, DHooks_OnAirAccelerate_Post);
	HookGameMovementFunction(H_OnWalkMove, "CGameMovement::WalkMove", DHooks_OnWalkMove_Pre, DHooks_OnWalkMove_Post);
	HookGameMovementFunction(H_OnJump, "CCSGameMovement::OnJump", DHooks_OnJump_Pre, DHooks_OnJump_Post);
	HookGameMovementFunction(H_OnPlayerMove, "CCSGameMovement::PlayerMove", DHooks_OnPlayerMove_Pre, DHooks_OnPlayerMove_Post);
	HookGameMovementFunction(H_OnCategorizePosition, "CGameMovement::CategorizePosition", DHooks_OnCategorizePosition_Pre, DHooks_OnCategorizePosition_Post);
}

Action UpdateMoveData(Address pThis, int client, Function func)
{
	GameMove_GetOrigin(pThis, gF_Origin[client]);
	GameMove_GetVelocity(pThis, gF_Velocity[client]);
	Action result;
	Call_StartFunction(INVALID_HANDLE, func);
	Call_PushCell(client);
	Call_PushArrayEx(gF_Origin[client], 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(gF_Velocity[client], 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	if (result != Plugin_Continue)
	{
		GameMove_SetOrigin(pThis, gF_Origin[client]);
		GameMove_SetVelocity(pThis, gF_Velocity[client]);
	}
	return result;
}

public MRESReturn DHooks_OnDuck_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnDuckPre);
	
	gB_Ducking[client] = Movement_GetDucking(client);
	gB_ProcessingDuck[client] = true;

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnDuck_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}
	
	if (gB_Ducking[client] && !gB_OldDucking[client])
	{
		Call_OnStartDucking(client);
	}
	else if (!gB_Ducking[client] && gB_OldDucking[client])
	{
		Call_OnStopDucking(client);
	}
	gB_ProcessingDuck[client] = false;
	GameMove_GetOrigin(pThis, gF_PostDuckOrigin[client]);

	Action result = UpdateMoveData(pThis, client, Call_OnDuckPost);
	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnLadderMove_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnLadderMovePre);

	gB_ProcessingLadderMove[client] = true;
	GameMove_GetVelocity(pThis, gF_PreLadderMoveVelocity[client]);

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnLadderMove_Post(Address pThis, DHookReturn hReturn)
{
	// While the movetype changed here, the vertical velocity is not yet updated.
	// gF_PostLadderMoveVelocity can be incorrect here.
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}
	
	GameMove_GetOrigin(pThis, gF_PostLadderMoveOrigin[client]);
	GameMove_GetVelocity(pThis, gF_PostLadderMoveVelocity[client]);
	gB_ProcessingLadderMove[client] = false;
	bool returnValue = DHookGetReturn(hReturn);
	// If this returns false, and the movetype was originally MOVETYPE_LADDER, that means the player will change movetype and takeoff (LAJ)
	// If this returns true, the movetype can still change in FullLadderMove by jumping (LAH)
	// The current movetype here is still ladder, but it will change right after this function call.
	if (!returnValue && Movement_GetMovetype(client) == MOVETYPE_LADDER)
	{
		gF_TakeoffVelocity[client] = gF_PostLadderMoveVelocity[client];
		gF_TakeoffOrigin[client] = gF_PostLadderMoveOrigin[client];
		gI_TakeoffTick[client] = gI_TickCount[client];
		gI_TakeoffCmdNum[client] = gI_Cmdnum[client];
		gB_Jumped[client] = false;
		gB_HitPerf[client] = false;
		Call_OnChangeMovetype(client, MOVETYPE_LADDER, MOVETYPE_WALK);
	}
	else if (returnValue && gMT_OldMovetype[client] != MOVETYPE_LADDER)
	{
		if (Movement_GetMovetype(client) == MOVETYPE_LADDER)
		{
			gF_LandingOrigin[client] = gF_PostLadderMoveOrigin[client];
			// We don't really care about nobug origin when player lands on ladder.
			gF_NobugLandingOrigin[client] = gF_LandingOrigin[client];
			gF_LandingVelocity[client] = gF_PreLadderMoveVelocity[client];
			gI_LandingCmdNum[client] = gI_Cmdnum[client];
			gI_LandingTick[client] = gI_TickCount[client];
			Call_OnChangeMovetype(client, MOVETYPE_WALK, MOVETYPE_LADDER);
		}
	}
	else if (returnValue && gMT_OldMovetype[client] == MOVETYPE_LADDER)
	{
		// Player is on the ladder and in the air, pressing jump pushes them away from the ladder.
		float curtime = GetGameTime();
		int buttons = GetClientButtons(client);
		float ignoreLadderJumpTime = GetEntPropFloat(client, Prop_Data, "m_ignoreLadderJumpTime");
		if (buttons & IN_JUMP && ignoreLadderJumpTime <= curtime)
		{
			gF_TakeoffVelocity[client] = gF_PostLadderMoveVelocity[client];
			gF_TakeoffOrigin[client] = gF_PostLadderMoveOrigin[client];
			gI_TakeoffTick[client] = gI_TickCount[client];
			gI_TakeoffCmdNum[client] = gI_Cmdnum[client];
			gB_Jumped[client] = false;
			gB_HitPerf[client] = false;
			gB_TakeoffFromLadder[client] = true;
			Call_OnChangeMovetype(client, MOVETYPE_LADDER, MOVETYPE_WALK);
		}
	}
	Action result = UpdateMoveData(pThis, client, Call_OnLadderMovePost);
	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnFullLadderMove_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnFullLadderMovePre);

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnJump_Pre(Address pThis, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}

	gB_Jumped[client] = true;
	if (gB_Duckbugged[client])
	{
		gB_Jumpbugged[client] = true;
	}

	// HitPerf must be modified here so plugins can know if player hits a perf or not.
	// Not a perf if last movetype was ladder, because jumping works differently on ladders.
	if (gMT_OldMovetype[client] != MOVETYPE_LADDER) 
	{
		// If you walked on the last tick then clearly it's not going to be a perf.
		// Can't perf if you don't jump.
		gB_HitPerf[client] = !gB_OldWalkMoved[client];
	}
	else
	{
		gB_HitPerf[client] = false;
	}

	Action result = UpdateMoveData(pThis, client, Call_OnJumpPre);

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnJump_Post(Address pThis, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	// We need to update LadderMove velocity again in case of jumping.
	GameMove_GetVelocity(pThis, gF_PostLadderMoveVelocity[client]);

	// Current origin because the player hasn't moved yet.
	gF_TakeoffOrigin[client] = gF_Origin[client];
	gF_TakeoffVelocity[client] = gF_Velocity[client];
	gI_TakeoffCmdNum[client] = gI_Cmdnum[client];
	gI_TakeoffTick[client] = gI_TickCount[client];

	// OnJump will only be called if the client previously touched some sort of ground, so Call_OnStopTouchGround should always be called.
	Call_OnStopTouchGround(client, true, gB_TakeoffFromLadder[client], gB_Jumpbugged[client]);

	Action result = UpdateMoveData(pThis, client, Call_OnJumpPost);
	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnFullLadderMove_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}

	Action result = UpdateMoveData(pThis, client, Call_OnFullLadderMovePost);
	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}
// We hook AirAccelerate because TryPlayerMove in AirMove can change velocity
// AirAccelerate velocity is required for nobug landing origin.
public MRESReturn DHooks_OnAirAccelerate_Pre(Address pThis, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnAirAcceleratePre);

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnAirAccelerate_Post(Address pThis, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	
	GameMove_GetOrigin(pThis, gF_PostAAOrigin[client]);
	GameMove_GetVelocity(pThis, gF_PostAAVelocity[client]);

	Action result = UpdateMoveData(pThis, client, Call_OnAirAcceleratePost);
	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

// WalkMove is called too early to detect if the player is still on ground or not.
public MRESReturn DHooks_OnWalkMove_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnWalkMovePre);

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnWalkMove_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}

	GameMove_GetVelocity(pThis, gF_PostWalkMoveVelocity[client]);
	gB_WalkMoved[client] = true;

	Action result = UpdateMoveData(pThis, client, Call_OnWalkMovePost);	
	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnPlayerMove_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	
	gB_Duckbugged[client] = false;
	gB_WalkMoved[client] = false;
	gB_Jumpbugged[client] = false;
	gB_Jumped[client] = false;
	gB_TakeoffFromLadder[client] = false;
	
	Action result = UpdateMoveData(pThis, client, Call_OnPlayerMovePre);

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnPlayerMove_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnPlayerMovePost);

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnCategorizePosition_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnCategorizePositionPre);

	gB_PrevOnGround[client] = Movement_GetOnGround(client);

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHooks_OnCategorizePosition_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	bool ground = Movement_GetOnGround(client);
	// Ground state changed!
	if (gB_PrevOnGround[client] != ground)
	{
		if (ground) // Landing
		{
			NobugLandingOrigin(client, gF_NobugLandingOrigin[client]);
			
			gF_LandingOrigin[client] = gF_Origin[client];
			gI_LandingCmdNum[client] = gI_Cmdnum[client];
			gI_LandingTick[client] = gI_TickCount[client];
			Call_OnStartTouchGround(client);
		}
		else // Takeoff
		{
			gF_TakeoffOrigin[client] = gF_OldOrigin[client];
			// Note: Jumping isn't detected here.
			if (gB_WalkMoved[client])
			{
				gF_TakeoffVelocity[client] = gF_PostWalkMoveVelocity[client];
			}
			else
			{
				gF_TakeoffVelocity[client] = gF_PostLadderMoveVelocity[client];
			}
			gI_TakeoffTick[client] = gI_TickCount[client];
			gI_TakeoffCmdNum[client] = gI_Cmdnum[client];
			gB_Jumped[client] = false;
			gB_HitPerf[client] = false;
			Call_OnStopTouchGround(client, false, !gB_WalkMoved[client], false);
		}
	}

	Action result = UpdateMoveData(pThis, client, Call_OnCategorizePositionPost);
	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

static void NobugLandingOrigin(int client, float landingOrigin[3])
{
	// NOTE: Get ground position and distance to ground.
	float groundEndPoint[3];
	groundEndPoint = gF_Origin[client];
	groundEndPoint[2] -= 2.0;
	float mins[3] = {-16.0, -16.0, 0.0};
	float maxs[3] = {16.0, 16.0, 0.0};
	TR_TraceHullFilter(gF_Origin[client], groundEndPoint, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
	
	float groundPos[3];
	TR_GetEndPosition(groundPos);
	
	// NOTE: This is almost guaranteed to hit because CategorizePosition does
	// the exact same trace to determine if the player is on the ground or not.
	if (!TR_DidHit())
	{
		// Use groundEndPoint if trace fails, because this MIGHT
		// give less distance in this extremely rare case.
		groundPos = groundEndPoint;
	}
	
	gB_Duckbugged[client] = gB_ProcessingDuck[client];
	float distanceToGround = gF_Origin[client][2] - groundPos[2];
	float velocity[3], origin[3];
	// NOTE: this has to be 0.0. If there's any distance to the ground, then we'll trace it with this one.
	if (distanceToGround != 0.0 || gB_ProcessingDuck[client])
	{
		// Use the current origin and velocity if we're not touching the ground
		gF_LandingVelocity[client] = gF_Velocity[client];
		velocity = gF_Velocity[client];
		origin = gF_Origin[client];
	}
	else
	{
		// NOTE: Use gF_OldVelocity and gF_OldOrigin if jump is potentially bugged.
		gF_LandingVelocity[client] = gF_PostAAVelocity[client];
		velocity = gF_PostAAVelocity[client];
		origin = gF_PostAAOrigin[client];
	}
	
	float firstTraceEndpoint[3], scaledVelocity[3];
	scaledVelocity = velocity;
	ScaleVector(scaledVelocity, GetTickInterval());
	AddVectors(origin, scaledVelocity, firstTraceEndpoint);
	
	TR_TraceHullFilter(origin, firstTraceEndpoint, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
	if (!TR_DidHit())
	{
		// It is possible to not hit the trace, if your vertical velocity is low enough.
		// In an extreme case, you would need 10 more traces for this to hit.
		// It is also possible to miss the trace on a flat jump, by hitting the very edge of a block.
		
		// Use groundPos, because this will give no distance advantage to the player, but
		// it will let the player not have his jump invalidated.
		landingOrigin = groundPos;
	}
	else
	{
		TR_GetEndPosition(landingOrigin);
	}
}
