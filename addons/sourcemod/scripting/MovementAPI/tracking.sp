/*	
	Movement Tracking

	Movement tracking using variables.
*/

void UpdateButtons(int client, int buttons)
{
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		int button = (1 << i);
		
		if (buttons & button)
		{
			if (!(gI_OldButtons[client] & button))
			{
				Call_OnButtonPress(client, button);
			}
		}
		else if (gI_OldButtons[client] & button)
		{
			Call_OnButtonRelease(client, button);
		}
	}
	gI_OldButtons[client] = buttons;
}

void UpdateOldVariables(int client)
{
	gB_JustTookOff[client] = false;
	gF_OldOrigin[client] = gF_Origin[client];
	gF_OldGroundOrigin[client] = gF_GroundOrigin[client];
	gF_OldVelocity[client] = gF_Velocity[client];
	gF_OldSpeed[client] = gF_Speed[client];
	gB_OldDucking[client] = gB_Ducking[client];
	gB_OldOnGround[client] = gB_OnGround[client];
	gB_OldOnLadder[client] = gB_OnLadder[client];
	gB_OldNoclipping[client] = gB_Noclipping[client];
	gF_OldEyeAngles[client] = gF_EyeAngles[client];
}

void UpdateVariables(int client)
{
	/*==========  Update Independent Variables  ==========*/
	
	GetClientAbsOrigin(client, gF_Origin[client]);
	GetGroundOrigin(client, gF_GroundOrigin[client]);
	
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", gF_Velocity[client]);
	gF_Speed[client] = SquareRoot(Pow(gF_Velocity[client][0], 2.0) + Pow(gF_Velocity[client][1], 2.0));
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", gF_BaseVelocity[client]);
	
	gMT_MoveType[client] = GetEntityMoveType(client);
	gB_OnGround[client] = PlayerIsOnGround(client);
	
	gB_Ducking[client] = (GetEntProp(client, Prop_Send, "m_bDucked") || GetEntProp(client, Prop_Send, "m_bDucking"));
	
	gF_VelocityModifier[client] = GetEntPropFloat(client, Prop_Send, "m_flVelocityModifier");
	gF_DuckSpeed[client] = GetEntPropFloat(client, Prop_Send, "m_flDuckSpeed");
	
	GetClientEyeAngles(client, gF_EyeAngles[client]);
	
	
	
	/*==========  Update Dependent Variables  ==========*/
	
	gB_JustDucked[client] = (gB_Ducking[client] && !gB_OldDucking[client]);
	
	gB_OnLadder[client] = (gMT_MoveType[client] == MOVETYPE_LADDER);
	gB_Noclipping[client] = (gMT_MoveType[client] == MOVETYPE_NOCLIP);
	
	if (!gB_OnGround[client] && gB_OldOnGround[client]) // Just took off the ground.
	{
		gB_JustTookOff[client] = true;
		gF_TakeoffOrigin[client] = gF_OldGroundOrigin[client];
		gF_TakeoffVelocity[client] = gF_OldVelocity[client];
		gF_TakeoffSpeed[client] = gF_OldSpeed[client];
		gI_TakeoffTick[client] = GetGameTickCount() - 1;
		gF_JumpMaxHeight[client] = gF_Origin[client][2] - gF_TakeoffOrigin[client][2];
	}
	else if (!gB_OnLadder[client] && gB_OldOnLadder[client]
		 || !gB_Noclipping[client] && gB_OldNoclipping[client]) // Just took off a ladder or left noclip.
	{
		gB_JustTookOff[client] = true;
		gF_TakeoffOrigin[client] = gF_OldOrigin[client]; // Note this difference.
		gF_TakeoffVelocity[client] = gF_OldVelocity[client];
		gF_TakeoffSpeed[client] = gF_OldSpeed[client];
		gI_TakeoffTick[client] = GetGameTickCount() - 1;
		gF_JumpMaxHeight[client] = gF_Origin[client][2] - gF_TakeoffOrigin[client][2];
	}
	else if (gB_OnGround[client] && !gB_OldOnGround[client]) // Just landed on the ground.
	{
		gF_LandingOrigin[client] = gF_GroundOrigin[client];
		gF_LandingVelocity[client] = gF_OldVelocity[client];
		gF_LandingSpeed[client] = gF_OldSpeed[client];
		gI_LandingTick[client] = GetGameTickCount() - 1;
		gF_JumpDistance[client] = CalculateHorizontalDistance(gF_TakeoffOrigin[client], gF_GroundOrigin[client]);
		gF_JumpOffset[client] = CalculateVerticalDistance(gF_TakeoffOrigin[client], gF_GroundOrigin[client]);
	}
	
	if (!gB_OnGround[client] && !gB_OnLadder[client] && !gB_Noclipping[client])
	{
		float currentJumpHeight = gF_Origin[client][2] - gF_TakeoffOrigin[client][2];
		if (currentJumpHeight > gF_JumpMaxHeight[client])
		{
			gF_JumpMaxHeight[client] = currentJumpHeight;
		}
	}
}

void ResetVariables(int client)
{
	gF_Velocity[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_Speed[client] = 0.0;
	
	gB_OnLadder[client] = false;
	gB_OnGround[client] = false;
	gB_Noclipping[client] = false;
	
	gB_Ducking[client] = false;
	
	gF_TakeoffOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_TakeoffSpeed[client] = 0.0;
	gI_TakeoffTick[client] = 0;
	
	gF_LandingOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_LandingSpeed[client] = 0.0;
	gI_LandingTick[client] = 0;
	
	gF_JumpMaxHeight[client] = 0.0;
	gF_JumpDistance[client] = 0.0;
	gF_JumpOffset[client] = 0.0;
	
	gB_HitPerf[client] = false;
	
	gB_JustJumped[client] = false;
	gB_JustDucked[client] = false;
	
	gI_OldButtons[client] = 0;
	gF_OldGroundOrigin[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	gF_OldSpeed[client] = 0.0;
	gB_OldDucking[client] = false;
	gB_OldOnGround[client] = false;
	gB_OldOnLadder[client] = false;
	gB_OldNoclipping[client] = false;
	gF_OldEyeAngles[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
} 