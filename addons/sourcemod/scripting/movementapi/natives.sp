/*	
	Natives

	Movement API native implementation.
*/

void CreateNatives()
{
	CreateNative("Movement_GetTakeoffOrigin", Native_GetTakeoffOrigin);
	CreateNative("Movement_GetTakeoffVelocity", Native_GetTakeoffVelocity);
	CreateNative("Movement_GetTakeoffTick", Native_GetTakeoffTick);
	
	CreateNative("Movement_GetLandingOrigin", Native_GetLandingOrigin);
	CreateNative("Movement_GetLandingVelocity", Native_GetLandingVelocity);
	CreateNative("Movement_GetLandingTick", Native_GetLandingTick);
	
	CreateNative("Movement_GetTurning", Native_GetTurning);
	CreateNative("Movement_GetTurningLeft", Native_GetTurningLeft);
	CreateNative("Movement_GetTurningRight", Native_GetTurningRight);
}

public int Native_GetTakeoffOrigin(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_TakeoffOrigin[GetNativeCell(1)], 3);
}

public int Native_GetTakeoffVelocity(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_TakeoffVelocity[GetNativeCell(1)], 3);
}

public int Native_GetTakeoffTick(Handle plugin, int numParams)
{
	return gI_TakeoffTick[GetNativeCell(1)];
}

public int Native_GetLandingOrigin(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_LandingOrigin[GetNativeCell(1)], 3);
}

public int Native_GetLandingVelocity(Handle plugin, int numParams)
{
	SetNativeArray(2, gF_LandingVelocity[GetNativeCell(1)], 3);
}

public int Native_GetLandingTick(Handle plugin, int numParams)
{
	return gI_LandingTick[GetNativeCell(1)];
}

public int Native_GetTurning(Handle plugin, int numParams)
{
	return view_as<int>(PlayerIsTurning(GetNativeCell(1)));
}

public int Native_GetTurningLeft(Handle plugin, int numParams)
{
	return view_as<int>(PlayerIsTurningLeft(GetNativeCell(1)));
}

public int Native_GetTurningRight(Handle plugin, int numParams)
{
	return view_as<int>(PlayerIsTurning(GetNativeCell(1)) && !PlayerIsTurningLeft(GetNativeCell(1)));
} 