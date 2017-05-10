/*	
	Forwards

	MovementAPI forwards implementation.
*/

Handle gH_OnButtonPress;
Handle gH_OnButtonRelease;
Handle gH_OnStartDucking;
Handle gH_OnStopDucking;
Handle gH_OnStartTouchGround;
Handle gH_OnStopTouchGround;
Handle gH_OnChangeMoveType;

void CreateGlobalForwards()
{
	gH_OnButtonPress = CreateGlobalForward("Movement_OnButtonPress", ET_Ignore, Param_Cell, Param_Cell);
	gH_OnButtonRelease = CreateGlobalForward("Movement_OnButtonRelease", ET_Ignore, Param_Cell, Param_Cell);
	gH_OnStartDucking = CreateGlobalForward("Movement_OnStartDucking", ET_Ignore, Param_Cell);
	gH_OnStopDucking = CreateGlobalForward("Movement_OnStopDucking", ET_Ignore, Param_Cell);
	gH_OnStartTouchGround = CreateGlobalForward("Movement_OnStartTouchGround", ET_Ignore, Param_Cell);
	gH_OnStopTouchGround = CreateGlobalForward("Movement_OnStopTouchGround", ET_Ignore, Param_Cell, Param_Cell);
	gH_OnChangeMoveType = CreateGlobalForward("Movement_OnChangeMoveType", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
}

void Call_OnButtonPress(int client, int button)
{
	Call_StartForward(gH_OnButtonPress);
	Call_PushCell(client);
	Call_PushCell(button);
	Call_Finish();
}

void Call_OnButtonRelease(int client, int button)
{
	Call_StartForward(gH_OnButtonRelease);
	Call_PushCell(client);
	Call_PushCell(button);
	Call_Finish();
}

void Call_OnStartDucking(int client)
{
	Call_StartForward(gH_OnStartDucking);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStopDucking(int client)
{
	Call_StartForward(gH_OnStopDucking);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStartTouchGround(int client)
{
	Call_StartForward(gH_OnStartTouchGround);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStopTouchGround(int client, bool jumped)
{
	Call_StartForward(gH_OnStopTouchGround);
	Call_PushCell(client);
	Call_PushCell(jumped);
	Call_Finish();
}

void Call_OnChangeMoveType(int client, MoveType oldMoveType, MoveType newMoveType)
{
	Call_StartForward(gH_OnChangeMoveType);
	Call_PushCell(client);
	Call_PushCell(oldMoveType);
	Call_PushCell(newMoveType);
	Call_Finish();
} 