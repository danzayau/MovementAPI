#define NON_JUMP_VELOCITY     140.0

static DynamicDetour H_OnPlayerMove;
static DynamicDetour H_OnDuck;
static DynamicDetour H_OnLadderMove;
static DynamicDetour H_OnFullLadderMove;
static DynamicDetour H_OnJump;
static DynamicDetour H_OnAirAccelerate;
static DynamicDetour H_OnWalkMove;
static DynamicDetour H_OnCategorizePosition;
static DynamicDetour H_OnTryPlayerMove;
static DynamicHook H_OnTracePlayerBBox;
static bool gB_TraceHookAvailable;
static bool gB_TraceHookAttempted;
static bool gB_TraceHookFired;
static Address moveHelperAddr;
static bool gB_TryPlayerMoveThisTick[MAXPLAYERS + 1];

// trace_t offsets
#define TRACE_STARTPOS   0
#define TRACE_ENDPOS     12
#define TRACE_NORMAL     24
#define TRACE_FRACTION   44
#define TRACE_ALLSOLID   54

static bool gB_InTryPlayerMove[MAXPLAYERS + 1];
static bool gB_SeededFirstTrace[MAXPLAYERS + 1];
static float gF_SeedFirstDest[MAXPLAYERS + 1][3];

float gF_Origin[MAXPLAYERS + 1][3];
float gF_Velocity[MAXPLAYERS + 1][3];

bool gB_ProcessingLadderMove[MAXPLAYERS + 1];
float gF_PreLadderMoveVelocity[MAXPLAYERS + 1][3];
bool gB_TakeoffFromLadder[MAXPLAYERS + 1];
float gF_TakeoffLadderNormal[MAXPLAYERS + 1][3];
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

int gI_CollisionCount[MAXPLAYERS + 1];

float gF_TraceStartOrigin[MAXPLAYERS + 1][MAX_BUMPS][3];
float gF_TraceEndOrigin[MAXPLAYERS + 1][MAX_BUMPS][3];
float gF_TraceNormal[MAXPLAYERS + 1][MAX_BUMPS][3];

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
	HookGameMovementFunction(H_OnTryPlayerMove, "CGameMovement::TryPlayerMove", DHooks_OnTryPlayerMove_Pre, DHooks_OnTryPlayerMove_Post);
	
	moveHelperAddr = GameConfGetAddress(gH_GameData, "sm_pSingleton");
	if (!moveHelperAddr)
	{
		SetFailState("Failed to find IMoveHelper::sm_pSingleton.");	
	}

	H_OnTracePlayerBBox = DynamicHook.FromConf(gH_GameData, "CGameMovement::TracePlayerBBox");
	gB_TraceHookAvailable = H_OnTracePlayerBBox != null;
	if (!gB_TraceHookAvailable)
	{
		LogError("CGameMovement::TracePlayerBBox unavailable, using the MoveHelper touch list instead.");
	}
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
	if (!IsPlayerAlive(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
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
	if (!IsPlayerAlive(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
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
	if (!IsPlayerAlive(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
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
	if (!IsPlayerAlive(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
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
		GetEntPropVector(client, Prop_Send, "m_vecLadderNormal", gF_TakeoffLadderNormal[client]);
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
	else if (returnValue && gMT_OldMovetype[client] == MOVETYPE_LADDER
		&& Movement_GetMovetype(client) == MOVETYPE_WALK)
	{
		// Jumping away from the ladder.
		gF_TakeoffVelocity[client] = gF_PostLadderMoveVelocity[client];
		gF_TakeoffOrigin[client] = gF_PostLadderMoveOrigin[client];
		gI_TakeoffTick[client] = gI_TickCount[client];
		gI_TakeoffCmdNum[client] = gI_Cmdnum[client];
		gB_Jumped[client] = false;
		gB_HitPerf[client] = false;
		gB_TakeoffFromLadder[client] = true;
		GetEntPropVector(client, Prop_Send, "m_vecLadderNormal", gF_TakeoffLadderNormal[client]);
		Call_OnChangeMovetype(client, MOVETYPE_LADDER, MOVETYPE_WALK);
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
	if (!IsPlayerAlive(client))
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
	if (!IsPlayerAlive(client))
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
	if (!IsPlayerAlive(client))
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
	if (!gB_TakeoffFromLadder[client])
	{
		gF_TakeoffLadderNormal[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	}

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
	if (!IsPlayerAlive(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
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
	if (!IsPlayerAlive(client))
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
	if (!IsPlayerAlive(client))
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
	if (!IsPlayerAlive(client))
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
	if (!IsPlayerAlive(client))
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
	if (!IsPlayerAlive(client))
	{
		return MRES_Ignored;
	}
	
	gB_Duckbugged[client] = false;
	gB_WalkMoved[client] = false;
	gB_Jumpbugged[client] = false;
	gB_Jumped[client] = false;
	gB_TakeoffFromLadder[client] = false;
	gB_TryPlayerMoveThisTick[client] = false;
	gI_CollisionCount[client] = 0;

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
	if (!IsPlayerAlive(client))
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnPlayerMovePost);
	gB_TryPlayerMoveThisTick[client] = false;
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
	if (!IsPlayerAlive(client))
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
	if (!IsPlayerAlive(client))
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
			bool hadLadderMoveType = Movement_GetMovetype(client) == MOVETYPE_LADDER || gMT_OldMovetype[client] == MOVETYPE_LADDER;
			bool ladderJump = hadLadderMoveType && !gB_WalkMoved[client];
			if (ladderJump)
			{
				GetEntPropVector(client, Prop_Send, "m_vecLadderNormal", gF_TakeoffLadderNormal[client]);
			}
			else
			{
				gF_TakeoffLadderNormal[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
			}
			Call_OnStopTouchGround(client, false, ladderJump, false);
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

public MRESReturn DHooks_OnTryPlayerMove_Pre(Address pThis, DHookReturn hReturn, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	Action result = UpdateMoveData(pThis, client, Call_OnTryPlayerMovePre);
	
	for (int i = 0; i < MAX_BUMPS; i++)
	{
		gF_TraceStartOrigin[client][i] = NULL_VECTOR;
		gF_TraceEndOrigin[client][i] = NULL_VECTOR;
		gF_TraceNormal[client][i] = NULL_VECTOR;
	}
	gI_CollisionCount[client] = 0;
	gB_InTryPlayerMove[client] = true;
	gB_SeededFirstTrace[client] = false;

	// CGameMovement is a singleton, hook it once. HookRaw can throw, so never retry.
	if (gB_TraceHookAvailable && !gB_TraceHookAttempted)
	{
		gB_TraceHookAttempted = true;
		gB_TraceHookAvailable = false;
		if (H_OnTracePlayerBBox.HookRaw(Hook_Post, pThis, DHooks_OnTracePlayerBBox_Post) == INVALID_HOOK_ID)
		{
			LogError("Failed to hook CGameMovement::TracePlayerBBox, using the MoveHelper touch list instead.");
		}
		else
		{
			gB_TraceHookAvailable = true;
		}
	}

	// Bump 0 can reuse pFirstTrace without tracing.
	if (!DHookIsNullParam(hParams, 2))
	{
		float fraction = DHookGetParamObjectPtrVar(hParams, 2, TRACE_FRACTION, ObjectValueType_Float);
		bool allsolid = view_as<bool>(DHookGetParamObjectPtrVar(hParams, 2, TRACE_ALLSOLID, ObjectValueType_Bool));
		if (fraction < 1.0 && !allsolid)
		{
			DHookGetParamObjectPtrVarVector(hParams, 2, TRACE_STARTPOS, ObjectValueType_Vector, gF_TraceStartOrigin[client][0]);
			DHookGetParamObjectPtrVarVector(hParams, 2, TRACE_ENDPOS, ObjectValueType_Vector, gF_TraceEndOrigin[client][0]);
			DHookGetParamObjectPtrVarVector(hParams, 2, TRACE_NORMAL, ObjectValueType_Vector, gF_TraceNormal[client][0]);
			gI_CollisionCount[client] = 1;
			gB_SeededFirstTrace[client] = true;
			DHookGetParamVector(hParams, 1, gF_SeedFirstDest[client]);
		}
	}

	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

static bool VectorsNearEqual(const float a[3], const float b[3])
{
	return FloatAbs(a[0] - b[0]) < 0.001 && FloatAbs(a[1] - b[1]) < 0.001 && FloatAbs(a[2] - b[2]) < 0.001;
}

public MRESReturn DHooks_OnTracePlayerBBox_Post(Address pThis, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (client < 1 || !gB_InTryPlayerMove[client])
	{
		return MRES_Ignored;
	}
	gB_TraceHookFired = true;

	float start[3], end[3];
	DHookGetParamVector(hParams, 1, start);
	DHookGetParamVector(hParams, 2, end);
	// Skip stuck tests.
	if (VectorsNearEqual(start, end))
	{
		return MRES_Ignored;
	}

	float fraction = DHookGetParamObjectPtrVar(hParams, 5, TRACE_FRACTION, ObjectValueType_Float);
	bool allsolid = view_as<bool>(DHookGetParamObjectPtrVar(hParams, 5, TRACE_ALLSOLID, ObjectValueType_Bool));
	if (fraction >= 1.0 || allsolid)
	{
		return MRES_Ignored;
	}

	int idx = gI_CollisionCount[client];
	// Engine traced bump 0 anyway, replace the seed.
	if (gB_SeededFirstTrace[client] && idx == 1
		&& VectorsNearEqual(start, gF_TraceStartOrigin[client][0])
		&& FloatAbs(end[0] - gF_SeedFirstDest[client][0]) < 0.01
		&& FloatAbs(end[1] - gF_SeedFirstDest[client][1]) < 0.01)
	{
		idx = 0;
	}
	gB_SeededFirstTrace[client] = false;
	if (idx >= MAX_BUMPS)
	{
		return MRES_Ignored;
	}

	DHookGetParamObjectPtrVarVector(hParams, 5, TRACE_STARTPOS, ObjectValueType_Vector, gF_TraceStartOrigin[client][idx]);
	DHookGetParamObjectPtrVarVector(hParams, 5, TRACE_ENDPOS, ObjectValueType_Vector, gF_TraceEndOrigin[client][idx]);
	DHookGetParamObjectPtrVarVector(hParams, 5, TRACE_NORMAL, ObjectValueType_Vector, gF_TraceNormal[client][idx]);
	if (idx == gI_CollisionCount[client])
	{
		gI_CollisionCount[client] = idx + 1;
	}
	return MRES_Ignored;
}

static void ReadTouchListCollisions(int client)
{
	int touchCount = LoadFromAddress(moveHelperAddr + view_as<Address>(8) + view_as<Address>(12), NumberType_Int32);
	if (touchCount > MAX_BUMPS)
	{
		touchCount = MAX_BUMPS;
	}
	else if (touchCount < 0)
	{
		touchCount = 0;
	}

	Address elements = LoadFromAddress(moveHelperAddr + view_as<Address>(8) + view_as<Address>(16), NumberType_Int32);
	for (int i = 0; i < touchCount; i++)
	{
		Trace trace = Trace(elements + view_as<Address>(i * 96) + view_as<Address>(12));
		trace.startpos.ToArray(gF_TraceStartOrigin[client][i]);
		trace.endpos.ToArray(gF_TraceEndOrigin[client][i]);
		trace.plane.normal.ToArray(gF_TraceNormal[client][i]);
	}
	gI_CollisionCount[client] = touchCount;
}

public MRESReturn DHooks_OnTryPlayerMove_Post(Address pThis, DHookReturn hReturn, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (client >= 1)
	{
		gB_InTryPlayerMove[client] = false;
		gB_SeededFirstTrace[client] = false;
	}
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}

	gB_TryPlayerMoveThisTick[client] = true;

	// Use the touch list until the hook is seen working.
	if (!gB_TraceHookFired && gI_CollisionCount[client] == 0)
	{
		ReadTouchListCollisions(client);
	}

	bool hitStandableSurface = false;
	static ConVar sv_standable_normal;
	if (sv_standable_normal == INVALID_HANDLE)
	{
		sv_standable_normal = FindConVar("sv_standable_normal");
	}
	for (int i = 0; i < gI_CollisionCount[client]; i++)
	{
		if (gF_TraceNormal[client][i][2] >= sv_standable_normal.FloatValue)
		{
			hitStandableSurface = true;
		}
	}

	// Edgebug detection
	
	if (hitStandableSurface)
	{
		float currentOrigin[3], groundEndPoint[3];
		
		GameMove_GetOrigin(pThis, currentOrigin);
		groundEndPoint = currentOrigin;
		groundEndPoint[2] -= 2.0;
		float mins[3] = {-16.0, -16.0, 0.0};
		float maxs[3] = {16.0, 16.0, 0.0};
		TR_TraceHullFilter(currentOrigin, groundEndPoint, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
		
		float groundPos[3];
		TR_GetEndPosition(groundPos);
		
		// Note: Origin and velocity are not updated yet.
		if (!TR_DidHit())
		{
			Call_OnPlayerEdgebug(client, gF_Origin[client], gF_Velocity[client]);
		}
	}

	Action result = UpdateMoveData(pThis, client, Call_OnTryPlayerMovePost);
	if (result != Plugin_Continue)
	{
		return MRES_Handled;
	}
	else
	{
		return MRES_Ignored;
	}
}

static bool TraceGroundParity(int client, const float origin[3], float groundPos[3])
{
	static ConVar sv_standable_normal;
	if (sv_standable_normal == INVALID_HANDLE)
	{
		sv_standable_normal = FindConVar("sv_standable_normal");
	}
	float standableZ = sv_standable_normal.FloatValue;

	float hullMins[3], hullMaxs[3];
	GetClientMins(client, hullMins);
	GetClientMaxs(client, hullMaxs);

	float endPoint[3];
	endPoint = origin;
	endPoint[2] -= 2.0;

	TR_TraceHullFilter(origin, endPoint, hullMins, hullMaxs, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
	if (!TR_DidHit())
	{
		return false;
	}
	TR_GetEndPosition(groundPos);

	float normal[3];
	TR_GetPlaneNormal(null, normal);
	if (normal[2] >= standableZ)
	{
		return true;
	}

	// Same quadrant order as TracePlayerBBoxForGround.
	for (int q = 0; q < 4; q++)
	{
		float mins[3], maxs[3];
		mins = hullMins;
		maxs = hullMaxs;
		switch (q)
		{
			case 0: { maxs[0] = 0.0; maxs[1] = 0.0; }
			case 1: { mins[0] = 0.0; mins[1] = 0.0; }
			case 2: { mins[1] = 0.0; maxs[0] = 0.0; }
			case 3: { mins[0] = 0.0; maxs[1] = 0.0; }
		}

		TR_TraceHullFilter(origin, endPoint, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
		if (!TR_DidHit())
		{
			continue;
		}
		TR_GetPlaneNormal(null, normal);
		if (normal[2] >= standableZ)
		{
			return true;
		}
	}
	return false;
}

static void NobugLandingOrigin(int client, float landingOrigin[3])
{
	// NOTE: Get ground position and distance to ground.
	float groundEndPoint[3];
	groundEndPoint = gF_Origin[client];
	groundEndPoint[2] -= 2.0;

	float groundPos[3];
	// NOTE: This is almost guaranteed to hit because CategorizePosition does
	// the exact same trace to determine if the player is on the ground or not.
	if (!TraceGroundParity(client, gF_Origin[client], groundPos))
	{
		// Use groundEndPoint if trace fails, because this MIGHT
		// give less distance in this extremely rare case.
		groundPos = groundEndPoint;
	}
	
	gB_Duckbugged[client] = gB_ProcessingDuck[client];
	float distanceToGround = gF_Origin[client][2] - groundPos[2];
	float velocity[3], origin[3];
	// If there's any distance to the ground, then we'll trace it with this one.
	
	// It seems like sometimes the player can end up ever so slighly above this "ground" value,
	// likely due to floating point precision error. Treat it as a bugged jump as well.
	if (distanceToGround > 0.001 || gB_ProcessingDuck[client])
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

	// Jump is bugged, try to use the trace result of TryPlayerMove if possible.
	if (gB_TryPlayerMoveThisTick[client] && gI_CollisionCount[client] > 0)
	{
		landingOrigin = gF_TraceEndOrigin[client][0];
		return;
	}

	// Engine doesn't ground players moving up this fast.
	if (velocity[2] > NON_JUMP_VELOCITY)
	{
		landingOrigin = groundPos;
		return;
	}

	// Fallback when no collision happened during TryPlayerMove, or that function was not called.
	float firstTraceEndpoint[3], scaledVelocity[3];
	scaledVelocity = velocity;
	ScaleVector(scaledVelocity, GetTickInterval());
	AddVectors(origin, scaledVelocity, firstTraceEndpoint);

	float mins[3] = {-16.0, -16.0, 0.0};
	float maxs[3] = {16.0, 16.0, 0.0};
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
