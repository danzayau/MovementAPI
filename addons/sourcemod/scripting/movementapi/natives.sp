void CreateNatives()
{
	CreateNative("Movement_GetJumped", Native_GetJumped);
	CreateNative("Movement_GetHitPerf", Native_GetHitPerf);
	CreateNative("Movement_GetTakeoffOrigin", Native_GetTakeoffOrigin);
	CreateNative("Movement_GetTakeoffVelocity", Native_GetTakeoffVelocity);
	CreateNative("Movement_GetTakeoffSpeed", Native_GetTakeoffSpeed);
	CreateNative("Movement_GetTakeoffTick", Native_GetTakeoffTick);
	CreateNative("Movement_GetTakeoffCmdNum", Native_GetTakeoffCmdNum);
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
	SetNativeArray(2, gF_TakeoffOrigin[GetNativeCell(1)], 3);
}

public int Native_GetTakeoffVelocity(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_TakeoffVelocity[GetNativeCell(1)], 3);
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

public int Native_GetNobugLandingOrigin(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_NobugLandingOrigin[GetNativeCell(1)], 3);
}

public int Native_GetLandingOrigin(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_LandingOrigin[GetNativeCell(1)], 3);
}

public int Native_GetLandingVelocity(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_LandingVelocity[GetNativeCell(1)], 3);
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
	SetNativeArray(2, gF_Origin[GetNativeCell(1)], 3);
}

public int Native_GetProcessingVelocity(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_Velocity[GetNativeCell(1)], 3);
}

public int Native_SetTakeoffOrigin(Handle plugin, int numParams)
{
	float array[3];
	GetNativeArray(2, array, sizeof(array));
	for (int i = 0; i < 3; i++)
	{
		gF_TakeoffOrigin[GetNativeCell(1)][i] = array[i];
	}
}

public int Native_SetTakeoffVelocity(Handle plugin, int numParams)
{
	float array[3];
	GetNativeArray(2, array, sizeof(array));
	for (int i = 0; i < 3; i++)
	{
		gF_TakeoffVelocity[GetNativeCell(1)][i] = array[i];
	}
}

public int Native_SetLandingOrigin(Handle plugin, int numParams)
{
	float array[3];
	GetNativeArray(2, array, sizeof(array));
	for (int i = 0; i < 3; i++)
	{
		gF_LandingOrigin[GetNativeCell(1)][i] = array[i];
	}
}

public int Native_SetLandingVelocity(Handle plugin, int numParams)
{
	float array[3];
	GetNativeArray(2, array, sizeof(array));
	for (int i = 0; i < 3; i++)
	{
		gF_LandingVelocity[GetNativeCell(1)][i] = array[i];
	}
}