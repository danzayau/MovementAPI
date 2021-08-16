stock void GameMove_SetVelocity(Address addr, float velocity[3])
{
	if (velocity[0] != velocity[0] || velocity[1] != velocity[1] || velocity[2] != velocity[2])
	{
		return;
	}
	static int mvOffset;
	static int velocityOffset;
	if (!mvOffset)
	{
		char buffer[8];
		if (!gH_GameData.GetKeyValue("CGameMovement::mv", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CGameMovement::mv offset.");
			return;
		}
		mvOffset = StringToInt(buffer);
		if (!gH_GameData.GetKeyValue("CMoveData::m_vecVelocity", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CMoveData::m_vecVelocity offset.");
			return;
		}
		velocityOffset = StringToInt(buffer);
	}

	Address mvAddress = view_as<Address>(LoadFromAddress(view_as<Address>(view_as<int>(addr) + mvOffset), NumberType_Int32));
	// TODO: idk if raw cast works here or not
	StoreToAddress(view_as<Address>(view_as<int>(mvAddress) + velocityOffset), view_as<int>(velocity[0]), NumberType_Int32);
	StoreToAddress(view_as<Address>(view_as<int>(mvAddress) + velocityOffset + 4), view_as<int>(velocity[1]), NumberType_Int32);
	StoreToAddress(view_as<Address>(view_as<int>(mvAddress) + velocityOffset + 8), view_as<int>(velocity[2]), NumberType_Int32);
}

stock void GameMove_SetOrigin(Address addr, float origin[3])
{
	if (origin[0] != origin[0] || origin[1] != origin[1] || origin[2] != origin[2])
	{
		return;
	}
	static int mvOffset;
	static int originOffset;
	if (!mvOffset)
	{
		char buffer[8];
		if (!gH_GameData.GetKeyValue("CGameMovement::mv", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CGameMovement::mv offset.");
			return;
		}
		mvOffset = StringToInt(buffer);
		if (!gH_GameData.GetKeyValue("CMoveData::m_vecAbsOrigin", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CMoveData::m_vecAbsOrigin offset.");
			return;
		}
		originOffset = StringToInt(buffer);
	}

	Address mvAddress = view_as<Address>(LoadFromAddress(view_as<Address>(view_as<int>(addr) + mvOffset), NumberType_Int32));
	// TODO: idk if raw cast works here or not
	StoreToAddress(view_as<Address>(view_as<int>(mvAddress) + originOffset), view_as<int>(origin[0]), NumberType_Int32);
	StoreToAddress(view_as<Address>(view_as<int>(mvAddress) + originOffset + 4), view_as<int>(origin[1]), NumberType_Int32);
	StoreToAddress(view_as<Address>(view_as<int>(mvAddress) + originOffset + 8), view_as<int>(origin[2]), NumberType_Int32);
}

stock void GameMove_GetVelocity(Address addr, float result[3])
{
	static int mvOffset;
	static int velocityOffset;
	if (!mvOffset)
	{
		char buffer[8];
		if (!gH_GameData.GetKeyValue("CGameMovement::mv", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CGameMovement::mv offset.");
			return;
		}
		mvOffset = StringToInt(buffer);
		if (!gH_GameData.GetKeyValue("CMoveData::m_vecVelocity", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CMoveData::m_vecVelocity offset.");
			return;
		}
		velocityOffset = StringToInt(buffer);
	}

	Address mvAddress = view_as<Address>(LoadFromAddress(view_as<Address>(view_as<int>(addr) + mvOffset), NumberType_Int32));
	result[0] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + velocityOffset), NumberType_Int32));
	result[1] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + velocityOffset + 4), NumberType_Int32));
	result[2] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + velocityOffset + 8), NumberType_Int32));
}

stock void GameMove_GetOrigin(Address addr, float result[3])
{
	static int mvOffset;
	static int originOffset;
	if (!mvOffset)
	{
		char buffer[8];
		if (!gH_GameData.GetKeyValue("CGameMovement::mv", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CGameMovement::mv offset.");
			return;
		}
		mvOffset = StringToInt(buffer);
		if (!gH_GameData.GetKeyValue("CMoveData::m_vecAbsOrigin", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CMoveData::m_vecAbsOrigin offset.");
			return;
		}
		originOffset = StringToInt(buffer);
	}
	
	Address mvAddress = view_as<Address>(LoadFromAddress(view_as<Address>(view_as<int>(addr) + mvOffset), NumberType_Int32));
	result[0] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + originOffset), NumberType_Int32));
	result[1] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + originOffset + 4), NumberType_Int32));
	result[2] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + originOffset + 8), NumberType_Int32));
}

stock void GameMove_GetEyeAngles(Address addr, float result[3])
{
	static int mvOffset;
	static int viewAngleOffset;
	if (!mvOffset)
	{
		char buffer[8];
		if (!gH_GameData.GetKeyValue("CGameMovement::mv", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CGameMovement::mv offset.");
			return;
		}
		mvOffset = StringToInt(buffer);
		if (!gH_GameData.GetKeyValue("CMoveData::m_viewAngleOffset", buffer, sizeof(buffer)))
		{
			ThrowError("Failed to get CMoveData::m_viewAngleOffset offset.");
			return;
		}
		originOffset = StringToInt(buffer);
	}
	
	Address mvAddress = view_as<Address>(LoadFromAddress(view_as<Address>(view_as<int>(addr) + mvOffset), NumberType_Int32));
	result[0] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + viewAngleOffset), NumberType_Int32));
	result[1] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + viewAngleOffset + 4), NumberType_Int32));
	result[2] = view_as<float>(LoadFromAddress(view_as<Address>(view_as<int>(mvAddress) + viewAngleOffset + 8), NumberType_Int32));
}

stock int GetEntityFromAddress(Address pEntity) {
	static int offs_RefEHandle;
	if (offs_RefEHandle) {
		return EntRefToEntIndex(LoadFromAddress(pEntity + view_as<Address>(offs_RefEHandle), NumberType_Int32) | (1 << 31));
	}

	// if we don't have it already, attempt to lookup offset based on SDK information
	// CWorld is derived from CBaseEntity so it should have both offsets
	int offs_angRotation = FindDataMapInfo(0, "m_angRotation"),
			offs_vecViewOffset = FindDataMapInfo(0, "m_vecViewOffset");
	if (offs_angRotation == -1) {
		ThrowError("Could not find offset for ((CBaseEntity) CWorld)::m_angRotation");
	} else if (offs_vecViewOffset == -1) {
		ThrowError("Could not find offset for ((CBaseEntity) CWorld)::m_vecViewOffset");
	} else if ((offs_angRotation + 0x0C) != (offs_vecViewOffset - 0x04)) {
		char game[32];
		GetGameFolderName(game, sizeof(game));
		ThrowError("Could not confirm offset of CBaseEntity::m_RefEHandle "
				... "(incorrect assumption for game '%s'?)", game);
	}
	
	// offset seems right, cache it for the next call
	offs_RefEHandle = offs_angRotation + 0x0C;
	return GetEntityFromAddress(pEntity);
}

stock int GetClientFromGameMovementAddress(Address addr) 
{
	char buffer[8];
	if (!gH_GameData.GetKeyValue("CGameMovement::player", buffer, sizeof(buffer)))
	{
		ThrowError("Failed to get CGameMovement::player offset.");
		return -1;
	}
	int offset = StringToInt(buffer);
	Address playerAddr = view_as<Address>(LoadFromAddress(view_as<Address>(view_as<int>(addr) + offset), NumberType_Int32));
	return GetEntityFromAddress(playerAddr);
}

stock void NobugLandingOrigin(int client, const float oldOrigin[3], const float oldVelocity[3], float landingOrigin[3])
{
	float firstTraceEndpoint[3], velocity[3];
	float hullMin[3] =  { -16.0, -16.0, 0.0 };
	float hullMax[3] =  { 16.0, 16.0, 0.0 };
	
	velocity[0] = oldVelocity[0] * GetTickInterval();
	velocity[1] = oldVelocity[1] * GetTickInterval();
	velocity[2] = oldVelocity[2] * GetTickInterval();
	AddVectors(oldOrigin, velocity, firstTraceEndpoint);
	
	Handle trace = TR_TraceHullFilterEx(oldOrigin, firstTraceEndpoint, hullMin, hullMax, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
	if (!TR_DidHit(trace))
	{
		// Nobug jump, extrapolating landing position
		delete trace;
		
		float secondTraceEndpoint[3];
		// Movement_GetGravity is not sv_gravity. Normally this is 1 or 0, sometimes 40 on antibhop triggers.		
		// We will (boldly) assume that player's gravity wasn't changed between OnPlayerRunCmd and PostThink.

		velocity[2] -= GetTickInterval() * GetTickInterval() * gCV_sv_gravity.FloatValue;	
		AddVectors(firstTraceEndpoint, velocity, secondTraceEndpoint);
		trace = TR_TraceHullFilterEx(firstTraceEndpoint, secondTraceEndpoint, hullMin, hullMax, MASK_PLAYERSOLID, TraceEntityFilterPlayers, client);
		
		// It is possible to not hit the trace, if your vertical velocity is low enough.
		// In an extreme case, you would need 10 more traces for this to hit.
		// It is also possible to miss the trace on a flat jump, by hitting the very edge of a block.
		if (!TR_DidHit(trace))
		{
			// Invalidate the landing origin	
			landingOrigin[0] = 0.0 / 0.0;
			landingOrigin[1] = 0.0 / 0.0;
			landingOrigin[2] = 0.0 / 0.0;
			delete trace;
			return;
		}
	}
	
	TR_GetEndPosition(landingOrigin, trace);
	// The trace is correct, the player will be at least 0.03125 unit above the ground.
	// So do not subtract the z origin by 0.03125.
	
	delete trace;
}

stock void HookGameMovementFunction(DynamicDetour handle, char[] fName, DHookCallback preCallback, DHookCallback postCallback)
{
	handle = DynamicDetour.FromConf(gH_GameData, fName);
	if (!handle)
	{
		SetFailState("Failed to find %s config", fName);
	}
	if (!handle.Enable(Hook_Pre, preCallback))
	{
		SetFailState("Failed to enable detour on %s", fName);
	}
	if (!handle.Enable(Hook_Post, postCallback))
	{
		SetFailState("Failed to enable detour on %s", fName);
	}
}
