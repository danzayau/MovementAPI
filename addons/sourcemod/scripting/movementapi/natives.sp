void CreateNatives()
{
	CreateNative("Movement_GetJumped", Native_GetJumped);
	CreateNative("Movement_GetHitPerf", Native_GetHitPerf);
	CreateNative("Movement_GetTakeoffOrigin", Native_GetTakeoffOrigin);
	CreateNative("Movement_GetTakeoffVelocity", Native_GetTakeoffVelocity);
	CreateNative("Movement_GetTakeoffSpeed", Native_GetTakeoffSpeed);
	CreateNative("Movement_GetTakeoffTick", Native_GetTakeoffTick);
	CreateNative("Movement_GetTakeoffCmdNum", Native_GetTakeoffCmdNum);
	CreateNative("Movement_GetTakeoffLadderNormal", Native_GetTakeoffLadderNormal);
	CreateNative("Movement_GetNobugLandingOrigin", Native_GetNobugLandingOrigin);
	CreateNative("Movement_GetLandingOrigin", Native_GetLandingOrigin);
	CreateNative("Movement_GetLandingVelocity", Native_GetLandingVelocity);
	CreateNative("Movement_GetLandingSpeed", Native_GetLandingSpeed);
	CreateNative("Movement_GetLandingTick", Native_GetLandingTick);
	CreateNative("Movement_GetLandingCmdNum", Native_GetLandingCmdNum);
	CreateNative("Movement_GetTurning", Native_GetTurning);
	CreateNative("Movement_GetTurningLeft", Native_GetTurningLeft);
	CreateNative("Movement_GetTurningRight", Native_GetTurningRight);
	CreateNative("Movement_GetMaxSpeed", Native_GetMaxSpeed);
	CreateNative("Movement_GetDuckbugged", Native_GetDuckbugged);
	CreateNative("Movement_GetJumpbugged", Native_GetJumpbugged);
	CreateNative("Movement_GetProcessingOrigin", Native_GetProcessingOrigin);
	CreateNative("Movement_GetProcessingVelocity", Native_GetProcessingVelocity);
	CreateNative("Movement_SetTakeoffOrigin", Native_SetTakeoffOrigin);
	CreateNative("Movement_SetTakeoffVelocity", Native_SetTakeoffVelocity);
	CreateNative("Movement_SetLandingOrigin", Native_SetLandingOrigin);
	CreateNative("Movement_SetLandingVelocity", Native_SetLandingVelocity);
	CreateNative("Movement_GetState", Native_GetState);
	CreateNative("Movement_SetState", Native_SetState);

	CreateNative("Movement_GetCollisionCount", Native_GetCollisionCount);
	CreateNative("Movement_GetCollisionStartOrigin", Native_GetCollisionStartOrigin);
	CreateNative("Movement_GetCollisionEndOrigin", Native_GetCollisionEndOrigin);
	CreateNative("Movement_GetCollisionNormal", Native_GetCollisionNormal);
}

public int Native_GetJumped(Handle plugin, int numParams)
{
	return gB_Jumped[GetNativeCell(1)];
}

public int Native_GetHitPerf(Handle plugin, int numParams)
{
	return gB_HitPerf[GetNativeCell(1)];
}

public int Native_GetTakeoffOrigin(Handle plugin, int numParams)
{
	return SetNativeArray(2, gF_TakeoffOrigin[GetNativeCell(1)], 3);
}

public int Native_GetTakeoffVelocity(Handle plugin, int numParams)
{
	return SetNativeArray(2, gF_TakeoffVelocity[GetNativeCell(1)], 3);
}

public int Native_GetTakeoffSpeed(Handle plugin, int numParams)
{
	return view_as<int>(GetVectorHorizontalLength(gF_TakeoffVelocity[GetNativeCell(1)]));
}

public int Native_GetTakeoffTick(Handle plugin, int numParams)
{
	return gI_TakeoffTick[GetNativeCell(1)];
}

public int Native_GetTakeoffCmdNum(Handle plugin, int numParams)
{
	return gI_TakeoffCmdNum[GetNativeCell(1)];
}

public int Native_GetTakeoffLadderNormal(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	SetNativeArray(2, gF_TakeoffLadderNormal[client], 3);
	return gF_TakeoffLadderNormal[client][0] != 0.0
		|| gF_TakeoffLadderNormal[client][1] != 0.0
		|| gF_TakeoffLadderNormal[client][2] != 0.0;
}

public int Native_GetNobugLandingOrigin(Handle plugin, int numParams)
{
	return SetNativeArray(2, gF_NobugLandingOrigin[GetNativeCell(1)], 3);
}

public int Native_GetLandingOrigin(Handle plugin, int numParams)
{
	return SetNativeArray(2, gF_LandingOrigin[GetNativeCell(1)], 3);
}

public int Native_GetLandingVelocity(Handle plugin, int numParams)
{
	return SetNativeArray(2, gF_LandingVelocity[GetNativeCell(1)], 3);
}

public int Native_GetLandingSpeed(Handle plugin, int numParams)
{
	return view_as<int>(GetVectorHorizontalLength(gF_LandingVelocity[GetNativeCell(1)]));
}

public int Native_GetLandingTick(Handle plugin, int numParams)
{
	return gI_LandingTick[GetNativeCell(1)];
}

public int Native_GetLandingCmdNum(Handle plugin, int numParams)
{
	return gI_LandingCmdNum[GetNativeCell(1)];
}

public int Native_GetTurning(Handle plugin, int numParams)
{
	return view_as<int>(gB_Turning[GetNativeCell(1)]);
}

public int Native_GetTurningLeft(Handle plugin, int numParams)
{
	return view_as<int>(gB_TurningLeft[GetNativeCell(1)]);
}

public int Native_GetTurningRight(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return view_as<int>(gB_Turning[client] && !gB_TurningLeft[client]);
}

public int Native_GetMaxSpeed(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return view_as<int>(GetMaxSpeed(client));
}

public int Native_GetDuckbugged(Handle plugin, int numParams)
{
	return view_as<int>(gB_Duckbugged[GetNativeCell(1)]);
}

public int Native_GetJumpbugged(Handle plugin, int numParams)
{
	return view_as<int>(gB_Jumpbugged[GetNativeCell(1)]);
}

public int Native_GetProcessingOrigin(Handle plugin, int numParams)
{
	return SetNativeArray(2, gF_Origin[GetNativeCell(1)], 3);
}

public int Native_GetProcessingVelocity(Handle plugin, int numParams)
{
	return SetNativeArray(2, gF_Velocity[GetNativeCell(1)], 3);
}

public int Native_SetTakeoffOrigin(Handle plugin, int numParams)
{
	float array[3];
	GetNativeArray(2, array, sizeof(array));
	for (int i = 0; i < 3; i++)
	{
		gF_TakeoffOrigin[GetNativeCell(1)][i] = array[i];
	}

	return 0;
}

public int Native_SetTakeoffVelocity(Handle plugin, int numParams)
{
	float array[3];
	GetNativeArray(2, array, sizeof(array));
	for (int i = 0; i < 3; i++)
	{
		gF_TakeoffVelocity[GetNativeCell(1)][i] = array[i];
	}

	return 0;
}

public int Native_SetLandingOrigin(Handle plugin, int numParams)
{
	float array[3];
	GetNativeArray(2, array, sizeof(array));
	for (int i = 0; i < 3; i++)
	{
		gF_LandingOrigin[GetNativeCell(1)][i] = array[i];
	}

	return 0;
}

public int Native_SetLandingVelocity(Handle plugin, int numParams)
{
	float array[3];
	GetNativeArray(2, array, sizeof(array));
	for (int i = 0; i < 3; i++)
	{
		gF_LandingVelocity[GetNativeCell(1)][i] = array[i];
	}

	return 0;
}

public int Native_GetState(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (!ValidStateSize(GetNativeCell(3)))
	{
		return 0;
	}
	any state[STATE_SIZE];
	SaveState(client, state);
	SetNativeArray(2, state, sizeof(state));
	return 0;
}

public int Native_SetState(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (!ValidStateSize(GetNativeCell(3)))
	{
		return 0;
	}
	any state[STATE_SIZE];
	GetNativeArray(2, state, sizeof(state));
	if (state[0] != STATE_VERSION)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "State version %d isn't MovementAPI's %d.", state[0], STATE_VERSION);
		return 0;
	}
	LoadState(client, state);
	return 0;
}

static bool ValidStateSize(int size)
{
	if (size != STATE_SIZE)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "State size %d doesn't match MovementAPI's %d.", size, STATE_SIZE);
		return false;
	}
	return true;
}

// Cell 0 is the layout's version: a new field bumps STATE_VERSION, and LoadState must still read older states.
static void SaveState(int client, any state[STATE_SIZE])
{
	int i = 0;
	state[i++] = STATE_VERSION;
	state[i++] = gB_Jumped[client];
	state[i++] = gB_HitPerf[client];
	SaveVector(state, i, gF_NobugLandingOrigin[client]);
	SaveVector(state, i, gF_LandingOrigin[client]);
	SaveVector(state, i, gF_LandingVelocity[client]);
	state[i++] = gI_LandingTick[client] - gI_TickCount[client];
	state[i++] = gI_LandingCmdNum[client] - gI_Cmdnum[client];
	SaveVector(state, i, gF_TakeoffOrigin[client]);
	SaveVector(state, i, gF_TakeoffVelocity[client]);
	state[i++] = gI_TakeoffTick[client] - gI_TickCount[client];
	state[i++] = gI_TakeoffCmdNum[client] - gI_Cmdnum[client];
	SaveVector(state, i, gF_TakeoffLadderNormal[client]);
	state[i++] = gB_Turning[client];
	state[i++] = gB_TurningLeft[client];
	SaveVector(state, i, gF_OldOrigin[client]);
	SaveVector(state, i, gF_OldVelocity[client]);
	SaveVector(state, i, gF_OldEyeAngles[client]);
	state[i++] = gB_OldOnGround[client];
	state[i++] = gB_OldDucking[client];
	state[i++] = gMT_OldMovetype[client];
	state[i++] = gB_OldWalkMoved[client];
	state[i++] = gB_Ducking[client];
	state[i++] = gB_Duckbugged[client];
	state[i++] = gB_Jumpbugged[client];
	// A ladder takeoff can read it before this tick's LadderMove sets it.
	SaveVector(state, i, gF_PostLadderMoveVelocity[client]);
}

static void LoadState(int client, const any state[STATE_SIZE])
{
	int i = 1;
	gB_Jumped[client] = state[i++];
	gB_HitPerf[client] = state[i++];
	LoadVector(state, i, gF_NobugLandingOrigin[client]);
	LoadVector(state, i, gF_LandingOrigin[client]);
	LoadVector(state, i, gF_LandingVelocity[client]);
	gI_LandingTick[client] = gI_TickCount[client] + state[i++];
	gI_LandingCmdNum[client] = gI_Cmdnum[client] + state[i++];
	LoadVector(state, i, gF_TakeoffOrigin[client]);
	LoadVector(state, i, gF_TakeoffVelocity[client]);
	gI_TakeoffTick[client] = gI_TickCount[client] + state[i++];
	gI_TakeoffCmdNum[client] = gI_Cmdnum[client] + state[i++];
	LoadVector(state, i, gF_TakeoffLadderNormal[client]);
	gB_Turning[client] = state[i++];
	gB_TurningLeft[client] = state[i++];
	LoadVector(state, i, gF_OldOrigin[client]);
	LoadVector(state, i, gF_OldVelocity[client]);
	LoadVector(state, i, gF_OldEyeAngles[client]);
	gB_OldOnGround[client] = state[i++];
	gB_OldDucking[client] = state[i++];
	gMT_OldMovetype[client] = state[i++];
	gB_OldWalkMoved[client] = state[i++];
	gB_Ducking[client] = state[i++];
	gB_Duckbugged[client] = state[i++];
	gB_Jumpbugged[client] = state[i++];
	LoadVector(state, i, gF_PostLadderMoveVelocity[client]);
}

static void SaveVector(any state[STATE_SIZE], int &i, const float vector[3])
{
	for (int j = 0; j < 3; j++)
	{
		state[i++] = vector[j];
	}
}

static void LoadVector(const any state[STATE_SIZE], int &i, float vector[3])
{
	for (int j = 0; j < 3; j++)
	{
		vector[j] = state[i++];
	}
}

public int Native_GetCollisionCount(Handle plugin, int numParams)
{
	return gI_CollisionCount[GetNativeCell(1)];
}

static bool ValidCollisionIndex(int client, int num)
{
	if (num < 0 || num >= MAX_BUMPS)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Collision index %d out of range, must be 0 to %d.", num, MAX_BUMPS - 1);
		return false;
	}
	if (num >= gI_CollisionCount[client])
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Collision index %d exceeds this tick's collision count of %d.", num, gI_CollisionCount[client]);
		return false;
	}
	return true;
}

public int Native_GetCollisionStartOrigin(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int num = GetNativeCell(2);
	if (!ValidCollisionIndex(client, num))
	{
		return 0;
	}
	SetNativeArray(3, gF_TraceStartOrigin[client][num], sizeof(gF_TraceStartOrigin[][]));
	return 0;
}

public int Native_GetCollisionEndOrigin(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int num = GetNativeCell(2);
	if (!ValidCollisionIndex(client, num))
	{
		return 0;
	}
	SetNativeArray(3, gF_TraceEndOrigin[client][num], sizeof(gF_TraceEndOrigin[][]));
	return 0;
}

public int Native_GetCollisionNormal(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int num = GetNativeCell(2);
	if (!ValidCollisionIndex(client, num))
	{
		return 0;
	}
	SetNativeArray(3, gF_TraceNormal[client][num], sizeof(gF_TraceNormal[][]));
	return 0;
}