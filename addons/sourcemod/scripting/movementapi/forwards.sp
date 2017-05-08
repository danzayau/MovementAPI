/*	
	Forwards

	MovementAPI forwards implementation.
*/

Handle gH_Forward_OnButtonPress;
Handle gH_Forward_OnButtonRelease;
Handle gH_Forward_OnStartTouchGround;
Handle gH_Forward_OnStopTouchGround;
Handle gH_Forward_OnStartDucking;
Handle gH_Forward_OnStopDucking;
Handle gH_Forward_OnStartTouchLadder;
Handle gH_Forward_OnStopTouchLadder;
Handle gH_Forward_OnStartNoclipping;
Handle gH_Forward_OnStopNoclipping;

void CreateGlobalForwards()
{
	gH_Forward_OnButtonPress = CreateGlobalForward("Movement_OnButtonPress", ET_Ignore, Param_Cell, Param_Cell);
	gH_Forward_OnButtonRelease = CreateGlobalForward("Movement_OnButtonRelease", ET_Ignore, Param_Cell, Param_Cell);
	gH_Forward_OnStartTouchGround = CreateGlobalForward("Movement_OnStartTouchGround", ET_Ignore, Param_Cell);
	gH_Forward_OnStopTouchGround = CreateGlobalForward("Movement_OnStopTouchGround", ET_Ignore, Param_Cell, Param_Cell);
	gH_Forward_OnStartDucking = CreateGlobalForward("Movement_OnStartDucking", ET_Ignore, Param_Cell);
	gH_Forward_OnStopDucking = CreateGlobalForward("Movement_OnStopDucking", ET_Ignore, Param_Cell);
	gH_Forward_OnStartTouchLadder = CreateGlobalForward("Movement_OnStartTouchLadder", ET_Ignore, Param_Cell);
	gH_Forward_OnStopTouchLadder = CreateGlobalForward("Movement_OnStopTouchLadder", ET_Ignore, Param_Cell);
	gH_Forward_OnStartNoclipping = CreateGlobalForward("Movement_OnStartNoclipping", ET_Ignore, Param_Cell);
	gH_Forward_OnStopNoclipping = CreateGlobalForward("Movement_OnStopNoclipping", ET_Ignore, Param_Cell);
}



/*===============================  Call Checkers  ===============================*/

void TryCallForwards(int client)
{
	TryCallDuckingForwards(client);
	TryCallTouchGroundForwards(client);
	TryCallTouchLadderForwards(client);
	TryCallNoclipForwards(client);
}

void TryCallDuckingForwards(int client)
{
	if (Movement_GetDucking(client) && !gB_OldDucking[client])
	{
		Call_OnStartDucking(client);
	}
	else if (!Movement_GetDucking(client) && gB_OldDucking[client])
	{
		Call_OnStopDucking(client);
	}
}

void TryCallTouchGroundForwards(int client)
{
	if (Movement_GetOnGround(client) && !gB_OldOnGround[client])
	{
		Call_OnStartTouchGround(client);
	}
	else if (!Movement_GetOnGround(client) && gB_OldOnGround[client])
	{
		Call_OnStopTouchGround(client);
	}
}

void TryCallTouchLadderForwards(int client)
{
	if (Movement_GetOnLadder(client) && !(gMT_OldMoveType[client] == MOVETYPE_LADDER))
	{
		Call_OnStartTouchLadder(client);
	}
	else if (!Movement_GetOnLadder(client) && gMT_OldMoveType[client] == MOVETYPE_LADDER)
	{
		Call_OnStopTouchLadder(client);
	}
	
}

void TryCallNoclipForwards(int client)
{
	if (Movement_GetNoclipping(client) && !(gMT_OldMoveType[client] == MOVETYPE_NOCLIP))
	{
		Call_OnStartNoclipping(client);
	}
	else if (!Movement_GetNoclipping(client) && gMT_OldMoveType[client] == MOVETYPE_NOCLIP)
	{
		Call_OnStopNoclipping(client);
	}
}



/*===============================  Callers  ===============================*/

void Call_OnButtonPress(int client, int button)
{
	Call_StartForward(gH_Forward_OnButtonPress);
	Call_PushCell(client);
	Call_PushCell(button);
	Call_Finish();
}

void Call_OnButtonRelease(int client, int button)
{
	Call_StartForward(gH_Forward_OnButtonRelease);
	Call_PushCell(client);
	Call_PushCell(button);
	Call_Finish();
}

void Call_OnStopTouchGround(int client)
{
	gB_Jumped[client] = gB_JustJumped[client];
	Call_StartForward(gH_Forward_OnStopTouchGround);
	Call_PushCell(client);
	Call_PushCell(gB_JustJumped[client]);
	Call_Finish();
	gB_JustJumped[client] = false; // Handled event_jump
}

void Call_OnStartTouchGround(int client)
{
	Call_StartForward(gH_Forward_OnStartTouchGround);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStopDucking(int client)
{
	Call_StartForward(gH_Forward_OnStopDucking);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStartDucking(int client)
{
	Call_StartForward(gH_Forward_OnStartDucking);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStopTouchLadder(int client)
{
	Call_StartForward(gH_Forward_OnStopTouchLadder);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStartTouchLadder(int client)
{
	Call_StartForward(gH_Forward_OnStartTouchLadder);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStopNoclipping(int client)
{
	Call_StartForward(gH_Forward_OnStopNoclipping);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStartNoclipping(int client)
{
	Call_StartForward(gH_Forward_OnStartNoclipping);
	Call_PushCell(client);
	Call_Finish();
} 