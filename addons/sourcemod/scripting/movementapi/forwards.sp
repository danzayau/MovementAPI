static Handle H_OnStartDucking;
static Handle H_OnStopDucking;
static Handle H_OnStartTouchGround;
static Handle H_OnStopTouchGround;
static Handle H_OnChangeMovetype;
static Handle H_OnPlayerJump;



void CreateGlobalForwards()
{
	H_OnStartDucking = CreateGlobalForward("Movement_OnStartDucking", ET_Ignore, Param_Cell);
	H_OnStopDucking = CreateGlobalForward("Movement_OnStopDucking", ET_Ignore, Param_Cell);
	H_OnStartTouchGround = CreateGlobalForward("Movement_OnStartTouchGround", ET_Ignore, Param_Cell);
	H_OnStopTouchGround = CreateGlobalForward("Movement_OnStopTouchGround", ET_Ignore, Param_Cell, Param_Cell);
	H_OnChangeMovetype = CreateGlobalForward("Movement_OnChangeMovetype", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
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

void Call_OnChangeMovetype(int client, MoveType oldMovetype, MoveType newMovetype)
{
	Call_StartForward(H_OnChangeMovetype);
	Call_PushCell(client);
	Call_PushCell(oldMovetype);
	Call_PushCell(newMovetype);
	Call_Finish();
}

void Call_OnPlayerJump(int client, bool jumpbug)
{
	Call_StartForward(H_OnPlayerJump);
	Call_PushCell(client);
	Call_PushCell(jumpbug);
	Call_Finish();
}
