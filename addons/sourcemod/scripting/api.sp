/*	api.sp

	Movement Tracking API (forwards and natives).
*/


// Forwards
Handle gH_Forward_OnLeaveGround;
Handle gH_Forward_OnTouchGround;

void CreateGlobalForwards() {
	gH_Forward_OnLeaveGround = CreateGlobalForward("OnPlayerLeaveGround", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_OnTouchGround = CreateGlobalForward("OnPlayerTouchGround", ET_Event, Param_Cell);
}

void Call_OnPlayerLeaveGround(int client) {
	Call_StartForward(gH_Forward_OnLeaveGround);
	Call_PushCell(client);
	Call_PushCell(gB_JustJumped[client]);
	Call_Finish();
	gB_JustJumped[client] = false; // Handled
}

void Call_OnPlayerTouchGround(int client) {
	Call_StartForward(gH_Forward_OnTouchGround);
	Call_PushCell(client);
	Call_Finish();
}


// Natives

void CreateNatives() {
	CreateNative("Movement_GetOrigin", Native_GetOrigin);
	CreateNative("Movement_GetGroundOrigin", Native_GetGroundOrigin);
	CreateNative("Movement_GetVelocity", Native_GetVelocity);
	CreateNative("Movement_SetVelocity", Native_SetVelocity);
	CreateNative("Movement_GetDistanceToGround", Native_GetDistanceToGround);
	CreateNative("Movement_GetSpeed", Native_GetSpeed);
	CreateNative("Movement_GetOnGround", Native_GetOnGround);
	CreateNative("Movement_GetOnLadder", Native_GetOnLadder);
	CreateNative("Movement_GetNoclipping", Native_GetNoclipping);
	CreateNative("Movement_GetDucking", Native_GetDucking);
	CreateNative("Movement_GetJustDucked", Native_GetJustDucked);
	CreateNative("Movement_GetJustJumped", Native_GetJustJumped);
	CreateNative("Movement_GetJustLanded", Native_GetJustLanded);
	CreateNative("Movement_GetTakeoffSpeed", Native_GetTakeoffSpeed);
	CreateNative("Movement_SetTakeoffSpeed", Native_SetTakeoffSpeed);	
	CreateNative("Movement_GetTakeoffOrigin", Native_GetTakeoffOrigin);
	CreateNative("Movement_GetTakeoffTick", Native_GetTakeoffTick);
	CreateNative("Movement_GetLandingSpeed", Native_GetLandingSpeed);
	CreateNative("Movement_GetLandingOrigin", Native_GetLandingOrigin);
	CreateNative("Movement_GetLandingTick", Native_GetLandingTick);
	CreateNative("Movement_GetJumpMaxHeight", Native_GetJumpMaxHeight);
	CreateNative("Movement_GetJumpDistance", Native_GetJumpDistance);
	CreateNative("Movement_GetJumpOffset", Native_GetJumpOffset);
	CreateNative("Movement_GetVelocityModifier", Native_GetVelocityModifier);
	CreateNative("Movement_SetVelocityModifier", Native_SetVelocityModifier);	
	CreateNative("Movement_GetDuckSpeed", Native_GetDuckSpeed);
	CreateNative("Movement_SetDuckSpeed", Native_SetDuckSpeed);
	CreateNative("Movement_GetTurning", Native_GetTurning);
	CreateNative("Movement_GetTurningLeft", Native_GetTurningLeft);
	CreateNative("Movement_GetTurningRight", Native_GetTurningRight);	
}

public int Native_GetOrigin(Handle plugin, int numParams) {
	SetNativeArray(2, gF_Origin[GetNativeCell(1)], 3);
}

public int Native_GetGroundOrigin(Handle plugin, int numParams) {
	SetNativeArray(2, gF_GroundOrigin[GetNativeCell(1)], 3);
}

public int Native_GetDistanceToGround(Handle plugin, int numParams) {
	return view_as<int>(gF_DistanceToGround[GetNativeCell(1)]);
}

public int Native_GetVelocity(Handle plugin, int numParams) {
	SetNativeArray(2, gF_Velocity[GetNativeCell(1)], 3);
}

public int Native_SetVelocity(Handle plugin, int numParams) {
	GetNativeArray(2, gF_Velocity[GetNativeCell(1)], 3);
	TeleportEntity(GetNativeCell(1), NULL_VECTOR, NULL_VECTOR, gF_Velocity[GetNativeCell(1)]);
}

public int Native_GetSpeed(Handle plugin, int numParams) {
	return view_as<int>(gF_Speed[GetNativeCell(1)]);
}

public int Native_GetOnGround(Handle plugin, int numParams) {
	return view_as<int>(gB_OnGround[GetNativeCell(1)]);
}

public int Native_GetOnLadder(Handle plugin, int numParams) {
	return view_as<int>(gB_OnLadder[GetNativeCell(1)]);
}

public int Native_GetNoclipping(Handle plugin, int numParams) {
	return view_as<int>(gB_Noclipping[GetNativeCell(1)]);
}

public int Native_GetDucking(Handle plugin, int numParams) {
	return view_as<int>(gB_Ducking[GetNativeCell(1)]);
}

public int Native_GetJustDucked(Handle plugin, int numParams) {
	return view_as<int>(gB_JustDucked[GetNativeCell(1)]);
}

public int Native_GetJustJumped(Handle plugin, int numParams) {
	return view_as<int>(gB_JustJumped[GetNativeCell(1)]);
}

public int Native_GetJustLanded(Handle plugin, int numParams) {
	return view_as<int>(gB_JustLanded[GetNativeCell(1)]);
}

public int Native_GetTakeoffSpeed(Handle plugin, int numParams) {
	return view_as<int>(gF_TakeoffSpeed[GetNativeCell(1)]);
}

public int Native_SetTakeoffSpeed(Handle plugin, int numParams) {
	gF_TakeoffSpeed[GetNativeCell(1)] = view_as<float>(GetNativeCell(2));
}

public int Native_GetTakeoffOrigin(Handle plugin, int numParams) {
	SetNativeArray(2, gF_TakeoffOrigin[GetNativeCell(1)], 3);
}

public int Native_GetTakeoffTick(Handle plugin, int numParams) {
	return view_as<int>(gI_TakeoffTick[GetNativeCell(1)]);
}

public int Native_GetLandingSpeed(Handle plugin, int numParams) {
	return view_as<int>(gF_LandingSpeed[GetNativeCell(1)]);
}

public int Native_GetLandingOrigin(Handle plugin, int numParams) {
	SetNativeArray(2, gF_LandingOrigin[GetNativeCell(1)], 3);
}

public int Native_GetLandingTick(Handle plugin, int numParams) {
	return view_as<int>(gI_LandingTick[GetNativeCell(1)]);
}

public int Native_GetJumpMaxHeight(Handle plugin, int numParams) {
	return view_as<int>(gF_JumpMaxHeight[GetNativeCell(1)]);
}

public int Native_GetJumpDistance(Handle plugin, int numParams) {
	return view_as<int>(gF_JumpDistance[GetNativeCell(1)]);
}

public int Native_GetJumpOffset(Handle plugin, int numParams) {
	return view_as<int>(gF_JumpOffset[GetNativeCell(1)]);
}

public int Native_GetVelocityModifier(Handle plugin, int numParams) {
	return view_as<int>(gF_VelocityModifier[GetNativeCell(1)]);
} 

public int Native_SetVelocityModifier(Handle plugin, int numParams) {
	gF_VelocityModifier[GetNativeCell(1)] = GetNativeCell(2);
	SetEntPropFloat(GetNativeCell(1), Prop_Send, "m_flVelocityModifier", GetNativeCell(2));
} 

public int Native_GetDuckSpeed(Handle plugin, int numParams) {
	return view_as<int>(gF_DuckSpeed[GetNativeCell(1)]);
} 

public int Native_SetDuckSpeed(Handle plugin, int numParams) {
	gF_VelocityModifier[GetNativeCell(1)] = GetNativeCell(2);
	SetEntPropFloat(GetNativeCell(1), Prop_Send, "m_flDuckSpeed", GetNativeCell(2));
}

public int Native_GetTurning(Handle plugin, int numParams) {
	return view_as<int>(gB_Turning[GetNativeCell(1)]);
} 

public int Native_GetTurningLeft(Handle plugin, int numParams) {
	return view_as<int>(gB_TurningLeft[GetNativeCell(1)]);
} 

public int Native_GetTurningRight(Handle plugin, int numParams) {
	return view_as<int>(gB_TurningRight[GetNativeCell(1)]);
} 