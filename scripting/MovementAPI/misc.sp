/*	misc.sp

	Miscellaneous, non-specific functions.
*/


void GetGroundOrigin(int client, float groundOrigin[3]) {
	float startPosition[3], endPosition[3];
	GetClientAbsOrigin(client, startPosition);
	endPosition = startPosition;
	endPosition[2] = startPosition[2] - 1024.0;
	Handle trace = TR_TraceHullFilterEx(
		startPosition, 
		endPosition, 
		view_as<float>( { -16.0, -16.0, 0.0 } ),  // Players are 32x32
		view_as<float>( { 16.0, 16.0, 1.0 } ), 
		MASK_PLAYERSOLID, 
		TraceEntityFilterPlayers, 
		client);
	if (TR_DidHit(trace)) {
		TR_GetEndPosition(groundOrigin, trace);
	}
	CloseHandle(trace);
}

public bool TraceEntityFilterPlayers(int entity, int contentsMask, any data) {
	return (entity != data && entity >= 1 && entity <= MaxClients);
}

bool PlayerIsOnGround(int client) {
	if (GetEntityFlags(client) & FL_ONGROUND) {
		return true;
	}
	return false;
}

bool PlayerIsTurningLeft(int client) {
	return (gF_EyeAngles[client][1] > gF_OldEyeAngles[client][1] && gF_EyeAngles[client][1] < gF_OldEyeAngles[client][1] + 180
		 || gF_EyeAngles[client][1] < gF_OldEyeAngles[client][1] - 180);
}

float CalculateHorizontalDistance(float pointA[3], float pointB[3]) {
	float jumpDistanceX = FloatAbs(pointA[0] - pointB[0]);
	float jumpDistanceY = FloatAbs(pointA[1] - pointB[1]);
	return SquareRoot(Pow(jumpDistanceX, 2.0) + Pow(jumpDistanceY, 2.0)) + 32.0;
}

float CalculateVerticalDistance(float startPoint[3], float endPoint[3]) {
	return endPoint[2] - startPoint[2];
} 