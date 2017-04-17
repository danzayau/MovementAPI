/*	
	Forwards

	Movement API global forward implementation.
*/

Handle gH_Forward_OnClientPreThink;
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
	gH_Forward_OnClientPreThink = CreateGlobalForward("Movement_OnClientPreThink", ET_Ignore, Param_Cell);
	gH_Forward_OnStartTouchGround = CreateGlobalForward("Movement_OnStartTouchGround", ET_Ignore, Param_Cell);
	gH_Forward_OnStopTouchGround = CreateGlobalForward("Movement_OnStopTouchGround", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
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
	TryCallTouchGroundForwards(client);
	TryCallDuckingForwards(client);
	TryCallTouchLadderForwards(client);
	TryCallNoclipForwards(client);
}

void TryCallTouchGroundForwards(int client)
{
	if (!gB_OldOnGround[client] && gB_OnGround[client])
	{
		Call_OnStartTouchGround(client);
	}
	else if (gB_OldOnGround[client] && !gB_OnGround[client])
	{
		Call_OnStopTouchGround(client);
	}
}

void TryCallDuckingForwards(int client)
{
	if (!gB_OldDucking[client] && gB_Ducking[client])
	{
		Call_OnStartDucking(client);
	}
	else if (gB_OldDucking[client] && !gB_Ducking[client])
	{
		Call_OnStopDucking(client);
	}
}

void TryCallTouchLadderForwards(int client)
{
	if (!gB_OldOnLadder[client] && gB_OnLadder[client])
	{
		Call_OnStartTouchLadder(client);
	}
	else if (gB_OldOnLadder[client] && !gB_OnLadder[client])
	{
		Call_OnStopTouchLadder(client);
	}
	
}

void TryCallNoclipForwards(int client)
{
	if (!gB_OldNoclipping[client] && gB_Noclipping[client])
	{
		Call_OnStartNoclipping(client);
	}
	else if (gB_OldNoclipping[client] && !gB_Noclipping[client])
	{
		Call_OnStopNoclipping(client);
	}
}



/*===============================  Callers  ===============================*/

void Call_OnClientPreThink(int client)
{
	Call_StartForward(gH_Forward_OnClientPreThink);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStopTouchGround(int client)
{
	Call_StartForward(gH_Forward_OnStopTouchGround);
	Call_PushCell(client);
	Call_PushCell(gB_JustJumped[client]);
	Call_PushCell(gB_JustDucked[client]);
	Call_PushCell(gB_HitPerf[client]);
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