/*	
	Forwards

	MovementAPI forwards implementation.
*/



static Handle H_OnStartDucking;
static Handle H_OnStopDucking;
static Handle H_OnStartTouchGround;
static Handle H_OnStopTouchGround;
static Handle H_OnChangeMoveType;
static Handle H_OnPlayerJump;



void CreateGlobalForwards()
{
	H_OnStartDucking = CreateGlobalForward("Movement_OnStartDucking", ET_Ignore, Param_Cell);
	H_OnStopDucking = CreateGlobalForward("Movement_OnStopDucking", ET_Ignore, Param_Cell);
	H_OnStartTouchGround = CreateGlobalForward("Movement_OnStartTouchGround", ET_Ignore, Param_Cell);
	H_OnStopTouchGround = CreateGlobalForward("Movement_OnStopTouchGround", ET_Ignore, Param_Cell, Param_Cell);
	H_OnChangeMoveType = CreateGlobalForward("Movement_OnChangeMoveType", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	H_OnPlayerJump = CreateGlobalForward("Movement_OnPlayerJump", ET_Ignore, Param_Cell, Param_Cell);
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

void Call_OnPlayerJump(int client, bool jumpbug)
{
	Call_StartForward(H_OnPlayerJump);
	Call_PushCell(client);
	Call_PushCell(jumpbug);
	Call_Finish();
} 