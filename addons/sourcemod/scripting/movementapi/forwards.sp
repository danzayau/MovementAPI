static Handle H_OnStartDucking;
static Handle H_OnStopDucking;
static Handle H_OnStartTouchGround;
static Handle H_OnStopTouchGround;
static Handle H_OnChangeMovetype;
static Handle H_OnPlayerJump;

static Handle H_OnPlayerMovePre;
static Handle H_OnPlayerMovePost;
static Handle H_OnDuckPre;
static Handle H_OnDuckPost;
static Handle H_OnLadderMovePre;
static Handle H_OnLadderMovePost;
static Handle H_OnFullLadderMovePre;
static Handle H_OnFullLadderMovePost;
static Handle H_OnJumpPre;
static Handle H_OnJumpPost;
static Handle H_OnAirAcceleratePre;
static Handle H_OnAirAcceleratePost;
static Handle H_OnWalkMovePre;
static Handle H_OnWalkMovePost;
static Handle H_OnCategorizePositionPre;
static Handle H_OnCategorizePositionPost;

void CreateGlobalForwards()
{
	H_OnStartDucking = CreateGlobalForward("Movement_OnStartDucking", ET_Ignore, Param_Cell);
	H_OnStopDucking = CreateGlobalForward("Movement_OnStopDucking", ET_Ignore, Param_Cell);
	H_OnStartTouchGround = CreateGlobalForward("Movement_OnStartTouchGround", ET_Ignore, Param_Cell);
	H_OnStopTouchGround = CreateGlobalForward("Movement_OnStopTouchGround", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	H_OnChangeMovetype = CreateGlobalForward("Movement_OnChangeMovetype", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	H_OnPlayerJump = CreateGlobalForward("Movement_OnPlayerJump", ET_Ignore, Param_Cell, Param_Cell);

	H_OnPlayerMovePre = CreateGlobalForward("Movement_OnPlayerMovePre", ET_Event, Param_Cell, Param_Array, Param_Array);
	H_OnPlayerMovePost = CreateGlobalForward("Movement_OnPlayerMovePost", ET_Event, Param_Cell, Param_Array, Param_Array);

	H_OnDuckPre = CreateGlobalForward("Movement_OnDuckPre", ET_Event, Param_Cell, Param_Array, Param_Array);
	H_OnDuckPost = CreateGlobalForward("Movement_OnDuckPost", ET_Event, Param_Cell, Param_Array, Param_Array);
	
	H_OnLadderMovePre = CreateGlobalForward("Movement_OnLadderMovePre", ET_Event, Param_Cell, Param_Array, Param_Array);
	H_OnLadderMovePost = CreateGlobalForward("Movement_OnLadderMovePost", ET_Event, Param_Cell, Param_Array, Param_Array);

	H_OnFullLadderMovePre = CreateGlobalForward("Movement_OnFullLadderMovePre", ET_Event, Param_Cell, Param_Array, Param_Array);
	H_OnFullLadderMovePost = CreateGlobalForward("Movement_OnFullLadderMovePost", ET_Event, Param_Cell, Param_Array, Param_Array);
	
	H_OnJumpPre = CreateGlobalForward("Movement_OnJumpPre", ET_Event, Param_Cell, Param_Array, Param_Array);
	H_OnJumpPost = CreateGlobalForward("Movement_OnJumpPost", ET_Event, Param_Cell, Param_Array, Param_Array);

	H_OnAirAcceleratePre = CreateGlobalForward("Movement_OnAirAcceleratePre", ET_Event, Param_Cell, Param_Array, Param_Array);
	H_OnAirAcceleratePost = CreateGlobalForward("Movement_OnAirAcceleratePost", ET_Event, Param_Cell, Param_Array, Param_Array);

	H_OnWalkMovePre = CreateGlobalForward("Movement_OnWalkMovePre", ET_Event, Param_Cell, Param_Array, Param_Array);
	H_OnWalkMovePost = CreateGlobalForward("Movement_OnWalkMovePost", ET_Event, Param_Cell, Param_Array, Param_Array);

	H_OnCategorizePositionPre = CreateGlobalForward("Movement_OnCategorizePositionPre", ET_Event, Param_Cell, Param_Array, Param_Array);
	H_OnCategorizePositionPost = CreateGlobalForward("Movement_OnCategorizePositionPost", ET_Event, Param_Cell, Param_Array, Param_Array);
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

void Call_OnStopTouchGround(int client, bool jumped, bool ladderJump, bool jumpbug)
{
	Call_StartForward(H_OnStopTouchGround);
	Call_PushCell(client);
	Call_PushCell(jumped);
	Call_PushCell(ladderJump);
	Call_PushCell(jumpbug);
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

Action Call_OnPlayerMovePre(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnPlayerMovePre);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnPlayerMovePost(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnPlayerMovePost);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnDuckPre(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnDuckPre);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnDuckPost(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnDuckPost);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnLadderMovePre(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnLadderMovePre);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnLadderMovePost(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnLadderMovePost);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnFullLadderMovePre(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnFullLadderMovePre);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnFullLadderMovePost(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnFullLadderMovePost);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnJumpPre(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnJumpPre);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnJumpPost(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnJumpPost);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnAirAcceleratePre(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnAirAcceleratePre);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnAirAcceleratePost(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnAirAcceleratePost);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnWalkMovePre(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnWalkMovePre);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnWalkMovePost(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnWalkMovePost);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnCategorizePositionPre(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnCategorizePositionPre);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

Action Call_OnCategorizePositionPost(int client, float origin[3], float velocity[3], Action &result)
{
	Call_StartForward(H_OnCategorizePositionPost);
	Call_PushCell(client);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}