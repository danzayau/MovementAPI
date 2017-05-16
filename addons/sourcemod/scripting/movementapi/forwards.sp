/*	
	Forwards

	MovementAPI forwards implementation.
*/



static Handle H_OnButtonPress;
static Handle H_OnButtonRelease;
static Handle H_OnStartDucking;
static Handle H_OnStopDucking;
static Handle H_OnStartTouchGround;
static Handle H_OnStopTouchGround;
static Handle H_OnChangeMoveType;



void CreateGlobalForwards()
{
	H_OnButtonPress = CreateGlobalForward("Movement_OnButtonPress", ET_Ignore, Param_Cell, Param_Cell);
	H_OnButtonRelease = CreateGlobalForward("Movement_OnButtonRelease", ET_Ignore, Param_Cell, Param_Cell);
	H_OnStartDucking = CreateGlobalForward("Movement_OnStartDucking", ET_Ignore, Param_Cell);
	H_OnStopDucking = CreateGlobalForward("Movement_OnStopDucking", ET_Ignore, Param_Cell);
	H_OnStartTouchGround = CreateGlobalForward("Movement_OnStartTouchGround", ET_Ignore, Param_Cell);
	H_OnStopTouchGround = CreateGlobalForward("Movement_OnStopTouchGround", ET_Ignore, Param_Cell, Param_Cell);
	H_OnChangeMoveType = CreateGlobalForward("Movement_OnChangeMoveType", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
}

void Call_OnButtonPress(int client, int button)
{
	Call_StartForward(H_OnButtonPress);
	Call_PushCell(client);
	Call_PushCell(button);
	Call_Finish();
}

void Call_OnButtonRelease(int client, int button)
{
	Call_StartForward(H_OnButtonRelease);
	Call_PushCell(client);
	Call_PushCell(button);
	Call_Finish();
}

void Call_OnStartDucking(int client)
{
	Call_StartForward(H_OnStartDucking);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStopDucking(int client)
{
	Call_StartForward(H_OnStopDucking);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStartTouchGround(int client)
{
	Call_StartForward(H_OnStartTouchGround);
	Call_PushCell(client);
	Call_Finish();
}

void Call_OnStopTouchGround(int client, bool jumped)
{
	Call_StartForward(H_OnStopTouchGround);
	Call_PushCell(client);
	Call_PushCell(jumped);
	Call_Finish();
}

void Call_OnChangeMoveType(int client, MoveType oldMoveType, MoveType newMoveType)
{
	Call_StartForward(H_OnChangeMoveType);
	Call_PushCell(client);
	Call_PushCell(oldMoveType);
	Call_PushCell(newMoveType);
	Call_Finish();
} 