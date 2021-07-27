DynamicDetour gH_OnPlayerMove;
DynamicDetour gH_OnDuck;
DynamicDetour gH_OnLadderMove;
DynamicDetour gH_OnFullLadderMove;
DynamicDetour gH_OnJump;
DynamicDetour gH_OnAirAccelerate;
DynamicDetour gH_OnWalkMove;


bool gB_OldDuckbugged[MAXPLAYERS + 1];
float gF_OldPostAAOrigin[MAXPLAYERS + 1][3];
float gF_OldPostAAVelocity[MAXPLAYERS + 1][3];
bool gB_OldWalkMoved[MAXPLAYERS + 1];

float gF_PreLadderMoveOrigin[MAXPLAYERS + 1][3];
float gF_PreLadderMoveVelocity[MAXPLAYERS + 1][3];
bool gB_ProcessingFullLadderMove[MAXPLAYERS + 1];
float gF_PostLadderMoveOrigin[MAXPLAYERS + 1][3];

float gF_PreDuckOrigin[MAXPLAYERS + 1][3];
bool gB_OnDuck_OnGround[MAXPLAYERS + 1];
bool gB_Duckbugged[MAXPLAYERS + 1];
float gF_PostDuckOrigin[MAXPLAYERS + 1][3];

bool gB_Jumpbugged[MAXPLAYERS + 1];
float gF_PostJumpVelocity[MAXPLAYERS + 1][3];
float gF_PostLadderMoveVelocity[MAXPLAYERS + 1][3];

bool gB_WalkMoved[MAXPLAYERS + 1];
float gF_PostWalkMoveOrigin[MAXPLAYERS + 1][3];
float gF_PostWalkMoveVelocity[MAXPLAYERS + 1][3];

float gF_PreAAVelocity[MAXPLAYERS + 1][3];
float gF_PostAAOrigin[MAXPLAYERS + 1][3];
float gF_PostAAVelocity[MAXPLAYERS + 1][3];

float gF_PlayerMoveVelocity_Post[MAXPLAYERS + 1][3];


public MRESReturn DHooks_OnDuck_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}
	GameMove_GetOrigin(pThis, gF_PreDuckOrigin[client]);
	gB_OnDuck_OnGround[client] = Movement_GetOnGround(client);
	return MRES_Ignored;
}

public MRESReturn DHooks_OnDuck_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}
	
	// Only unducking from mid air can change your on ground state.
	// The only possible change is from air to ground.
	if (gB_OnDuck_OnGround[client] != Movement_GetOnGround(client))
	{
		gB_Duckbugged[client] = true;
		// Call on duckbug?
	}
	else
	{
		gB_Duckbugged[client] = false;
	}
	GameMove_GetOrigin(pThis, gF_PostDuckOrigin[client]);
	return MRES_Ignored;
}

public MRESReturn DHooks_OnLadderMove_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}
	
	GameMove_GetOrigin(pThis, gF_PreLadderMoveOrigin[client]);
	GameMove_GetVelocity(pThis, gF_PreLadderMoveVelocity[client]);
	return MRES_Ignored;
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
	return MRES_Ignored;
}

public MRESReturn DHooks_OnFullLadderMove_Pre(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	gB_ProcessingFullLadderMove[client] = true;
	return MRES_Ignored;
}

public MRESReturn DHooks_OnJump_Post(Address pThis, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	// We need to update LadderMove velocity again in case of jumping.
	if (gB_ProcessingFullLadderMove[client])
	{
		GameMove_GetVelocity(pThis, gF_PostLadderMoveVelocity[client]);
	}
	else
	{
		GameMove_GetVelocity(pThis, gF_PostJumpVelocity[client]);
	}
	// Must be set here for SlopeFix to work in PostThink
	if (gB_Duckbugged[client])
	{
		gB_Jumpbugged[client] = true;
	}
	return MRES_Ignored;
}

public MRESReturn DHooks_OnFullLadderMove_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client) || Movement_GetMovetype(client) == MOVETYPE_NOCLIP)
	{
		return MRES_Ignored;
	}
	gB_ProcessingFullLadderMove[client] = false;
	return MRES_Ignored;
}

public MRESReturn DHooks_OnAirAccelerate_Pre(Address pThis, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	GameMove_GetVelocity(pThis, gF_PreAAVelocity[client]);

	return MRES_Ignored;
}

public MRESReturn DHooks_OnAirAccelerate_Post(Address pThis, DHookParam hParams)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	gF_OldPostAAOrigin[client] = gF_PostAAOrigin[client];
	gF_OldPostAAVelocity[client] = gF_PostAAVelocity[client];
	GameMove_GetOrigin(pThis, gF_PostAAOrigin[client]);
	GameMove_GetVelocity(pThis, gF_PostAAVelocity[client]);
	return MRES_Ignored;
}

public MRESReturn DHooks_OnWalkMove_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	GameMove_GetOrigin(pThis, gF_PostWalkMoveOrigin[client]);
	GameMove_GetVelocity(pThis, gF_PostWalkMoveVelocity[client]);
	gB_WalkMoved[client] = true;
	return MRES_Ignored;
}

public MRESReturn DHooks_OnPlayerMove_Post(Address pThis)
{
	int client = GetClientFromGameMovementAddress(pThis);
	if (!IsPlayerAlive(client) || IsFakeClient(client))
	{
		return MRES_Ignored;
	}
	GameMove_GetVelocity(pThis, gF_PlayerMoveVelocity_Post[client]);
	return MRES_Ignored;
}