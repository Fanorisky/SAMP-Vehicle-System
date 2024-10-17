/*
 * Pawn.RakNet handlers
 */
IPacket:PLAYER_SYNC(playerid, BitStream:bs)
{
	new onFootData[PR_OnFootSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadOnFootSync(bs, onFootData);

	// Because of detonator crasher - Sends KEY_HANDBRAKE/KEY_AIM in this packet and cam mode IDs 7, 8, 34, 45, 46, 51 and 65 in AIM_SYNC
	if (onFootData[PR_weaponId] == _:WEAPON_BOMB) {
		onFootData[PR_keys] &= ~_:KEY_HANDBRAKE;
	}

	if (DisableSyncBugs) {
		// Prevent "ghost shooting" bugs
		if (IsBulletWeapon(WEAPON:onFootData[PR_weaponId])) {
			if (1222 <= onFootData[PR_animationId] <= 1236 // PED_RUN_*
			|| onFootData[PR_animationId] == 1249 // PED_SWAT_RUN
			|| 1275 <= onFootData[PR_animationId] <= 1287 // PED_WOMAN_(RUN/WALK)_*
			|| onFootData[PR_animationId] == 459 // FAT_FATRUN_ARMED
			|| 908 <= onFootData[PR_animationId] <= 909 // MUSCULAR_MUSCLERUN*
			|| onFootData[PR_animationId] == 1274 // PED_WEAPON_CROUCH
			|| onFootData[PR_animationId] == 1266 // PED_WALK_PLAYER
			|| 1241 <= onFootData[PR_animationId] <= 1242 // PED_SHOT_PARTIAL(_B)
			|| 17 <= onFootData[PR_animationId] <= 27 // Baseball bat
			|| 745 <= onFootData[PR_animationId] <= 760 // Knife
			|| 1545 <= onFootData[PR_animationId] <= 1554 // Sword
			|| 471 <= onFootData[PR_animationId] <= 507 || 1135 <= onFootData[PR_animationId] <= 1151) { // Fight
				// Only remove action key if holding aim
				if (onFootData[PR_keys] & _:KEY_HANDBRAKE) {
					onFootData[PR_keys] &= ~_:KEY_ACTION;
				}

				// Remove fire key
				onFootData[PR_keys] &= ~_:KEY_FIRE;

				// Remove aim key
				onFootData[PR_keys] &= ~_:KEY_HANDBRAKE;
			}
		} else if (onFootData[PR_weaponId] == _:WEAPON_SPRAYCAN
		|| onFootData[PR_weaponId] == _:WEAPON_FIREEXTINGUISHER
		|| onFootData[PR_weaponId] == _:WEAPON_FLAMETHROWER) {
			if (!(1160 <= onFootData[PR_animationId] <= 1167)) {
				// Only remove action key if holding aim
				if (onFootData[PR_keys] & _:KEY_HANDBRAKE) {
					onFootData[PR_keys] &= ~_:KEY_ACTION;
				}

				// Remove fire key
				onFootData[PR_keys] &= ~_:KEY_FIRE;

				// Remove aim key
				onFootData[PR_keys] &= ~_:KEY_HANDBRAKE;
			}
		} else if (onFootData[PR_weaponId] == _:WEAPON_GRENADE) {
			if (!(644 <= onFootData[PR_animationId] <= 646)) {
				onFootData[PR_keys] &= ~_:KEY_ACTION;
			}
		}
	}

	if (SyncDataFrozen[playerid]) {
		onFootData = LastSyncData[playerid];
	} else {
		TempSyncData[playerid] = onFootData;
		TempDataWritten[playerid] = true;
	}

	if (FakeHealth{playerid} != 255) {
		onFootData[PR_health] = FakeHealth{playerid};
	}

	if (FakeArmour{playerid} != 255) {
		onFootData[PR_armour] = FakeArmour{playerid};
	}

	if (FakeQuat[playerid][0] == FakeQuat[playerid][0]) {
		onFootData[PR_quaternion] = FakeQuat[playerid];
	}

	if (onFootData[PR_weaponId] == _:WEAPON_KNIFE && !KnifeSync) {
		// Remove aim key
		onFootData[PR_keys] &= ~_:KEY_HANDBRAKE;
	} else if (onFootData[PR_weaponId] == 0) { // Punch Sync PC - Mobile
        if(onFootData[PR_keys] & _:KEY_FIRE) {
        	// Remove fire key
        	if(onFootData[PR_animationId] == 0) { // Fix punch sync mobile)
        	    if(GetTickCount() - PunchTick[playerid] > 300)
        	    {
        	    	onFootData[PR_keys] = 4;
                    PunchTick[playerid] = GetTickCount();
        	    }
        	    else
        	    {
        	    	onFootData[PR_keys] = 0;
        	    }
        	}
        	else 
        	{
                if(PunchUsed[playerid] == 0)
                {
                	PunchUsed[playerid] = 1;
                }
                else
                {
                	onFootData[PR_keys] &= ~_:KEY_FIRE;
                }
        	}
        }
        else
        {
            PunchUsed[playerid] = 0;
        }
	} else if (44 <= onFootData[PR_weaponId] <= 45) {
		// Remove fire key
		onFootData[PR_keys] &= ~_:KEY_FIRE;

		// Keep preventing for some more packets
		GogglesTick[playerid] = GetTickCount();
		GogglesUsed[playerid] = 1;
	} else if (GogglesUsed[playerid]) {
		if (GogglesUsed[playerid] == 2 && GetTickCount() - GogglesTick[playerid] > 40) {
			GogglesUsed[playerid] = 0;
		} else {
			// Remove fire key
			onFootData[PR_keys] &= ~_:KEY_FIRE;

			GogglesTick[playerid] = GetTickCount();
			GogglesUsed[playerid] = 2;
		}
	}

	BS_SetWriteOffset(bs, 8);
	BS_WriteOnFootSync(bs, onFootData); // rewrite

	return 1;
}

IPacket:VEHICLE_SYNC(playerid, BitStream:bs)
{
	new inCarData[PR_InCarSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadInCarSync(bs, inCarData);

	if (FakeHealth{playerid} != 255) {
		inCarData[PR_playerHealth] = FakeHealth{playerid};
	}

	if (FakeArmour{playerid} != 255) {
		inCarData[PR_armour] = FakeArmour{playerid};
	}

	BS_SetWriteOffset(bs, 8);
	BS_WriteInCarSync(bs, inCarData); // rewrite

	return 1;
}

IPacket:PASSENGER_SYNC(playerid, BitStream:bs)
{
	new passengerData[PR_PassengerSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadPassengerSync(bs, passengerData);

	if (FakeHealth{playerid} != 255) {
		passengerData[PR_playerHealth] = FakeHealth{playerid};
	}

	if (FakeArmour{playerid} != 255) {
		passengerData[PR_playerArmour] = FakeArmour{playerid};
	}

	BS_SetWriteOffset(bs, 8);
	BS_WritePassengerSync(bs, passengerData); // rewrite

	return 1;
}

IPacket:AIM_SYNC(playerid, BitStream:bs)
{
	new aimData[PR_AimSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadAimSync(bs, aimData);

	// Fix first-person up/down aim sync
	if (_:WEAPON_SNIPER <= LastSyncData[playerid][PR_weaponId] <= _:WEAPON_HEATSEEKER
	|| LastSyncData[playerid][PR_weaponId] == _:WEAPON_CAMERA) {
		aimData[PR_aimZ] = -aimData[PR_camFrontVec][2];

		if (aimData[PR_aimZ] > 1.0) {
			aimData[PR_aimZ] = 1.0;
		} else if (aimData[PR_aimZ] < -1.0) {
			aimData[PR_aimZ] = -1.0;
		}
	}

	BS_SetWriteOffset(bs, 8);
	BS_WriteAimSync(bs, aimData); // rewrite

	return 1;
}

IPacket:BULLET_SYNC(playerid, BitStream:bs)
{
	new BulletData[PR_BulletSync], str[64];
    BS_IgnoreBits(bs, 8);
    BS_ReadBulletSync(bs, BulletData);
    if(BulletData[PR_hitType] == BULLET_HIT_TYPE_PLAYER)
    {
    	if(HasSameTeam(playerid, BulletData[PR_hitId]))
    	{
    		BulletData[PR_hitType] = BULLET_HIT_TYPE_NONE;
    		BulletData[PR_hitId] = 65535;
    	}
    	else
    	{
    		SetPlayerHealth(BulletData[PR_hitId], 1000);
    	}
    }
    BS_SetWriteOffset(bs, 8);
    BS_WriteBulletSync(bs, BulletData);
	return 1;
}