/*
 * Public API
 */

stock IsBulletWeapon(WEAPON:weaponid)
{
	return (WEAPON_COLT45 <= weaponid <= WEAPON_SNIPER) || weaponid == WEAPON_MINIGUN;
}

stock IsHighRateWeapon(WEAPON:weaponid)
{
	switch (weaponid) 
	{
		case WEAPON_FLAMETHROWER, WEAPON_SPRAYCAN, WEAPON_FIREEXTINGUISHER,
		     WEAPON_CARPARK, WEAPON_DROWN: 
		{
			return true;
		}
	}

	return false;
}

stock IsMeleeWeapon(WEAPON:weaponid)
{
	return (WEAPON_UNARMED <= weaponid <= WEAPON_CANE) || weaponid == WEAPON_PISTOLWHIP;
}

stock AverageShootRate(playerid, shots, &multiple_weapons = 0)
{
	if (playerid == INVALID_PLAYER_ID || ShotsFired[playerid] < shots) {
		return -1;
	}

	new total = 0, idx = LastShotIdx[playerid];

	multiple_weapons = false;

	for (new i = shots - 2, prev, prev_weap, prev_idx, thiidx; i >= 0; i--) {
		prev_idx = (idx - i - 1) % sizeof(LastShotTicks[]);

		// JIT plugin fix
		if (prev_idx < 0) {
			prev_idx += sizeof(LastShotTicks[]);
		}

		prev = LastShotTicks[playerid][prev_idx];
		prev_weap = LastShotWeapons[playerid][prev_idx];
		thiidx = (idx - i) % sizeof(LastShotTicks[]);

		// JIT plugin fix
		if (thiidx < 0) {
			thiidx += sizeof(LastShotTicks[]);
		}

		if (prev_weap != LastShotWeapons[playerid][thiidx]) {
			multiple_weapons = true;
		}

		total += LastShotTicks[playerid][thiidx] - prev;
	}

	return shots == 1 ? 1 : (total / (shots - 1));
}

stock AverageHitRate(playerid, hits, &multiple_weapons = 0)
{
	if (playerid == INVALID_PLAYER_ID || HitsIssued[playerid] < hits) {
		return -1;
	}

	new total = 0, idx = LastHitIdx[playerid];

	multiple_weapons = false;

	for (new i = hits - 2, prev, prev_weap, prev_idx, thiidx; i >= 0; i--) {
		prev_idx = (idx - i - 1) % sizeof(LastHitTicks[]);

		// JIT plugin fix
		if (prev_idx < 0) {
			prev_idx += sizeof(LastHitTicks[]);
		}

		prev = LastHitTicks[playerid][prev_idx];
		prev_weap = LastHitWeapons[playerid][prev_idx];
		thiidx = (idx - i) % sizeof(LastHitTicks[]);

		// JIT plugin fix
		if (thiidx < 0) {
			thiidx += sizeof(LastHitTicks[]);
		}

		if (prev_weap != LastHitWeapons[playerid][thiidx]) {
			multiple_weapons = true;
		}

		total += LastHitTicks[playerid][thiidx] - prev;
	}

	return hits == 1 ? 1 : (total / (hits - 1));
}

stock SetRespawnTime(ms)
{
	RespawnTime = max(0, ms);
}

stock GetRespawnTime()
{
	return RespawnTime;
}

stock ReturnWeaponName(WEAPON:weaponid)
{
	new name[sizeof(g_WeaponName[])];

	GetWeaponName(weaponid, name);

	return name;
}

stock ReturnBodypartName(id)
{
    new name[64];
    switch(id)
    {
        case 3: name = "Thorax";
        case 4: name = "Stomach";
        case 5: name = "Left arm";
        case 6: name = "Right arm";
        case 7: name = "Left leg";
        case 8: name = "Right leg";
        case 9: name = "Head";
        default: name = "None";
    }
    return name;
}

stock SetWeaponDamage(WEAPON:weaponid, damage_type, Float:amount, Float:...)
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(WeaponDamage)) {
		return 0;
	}

	if (damage_type == DAMAGE_TYPE_RANGE || damage_type == DAMAGE_TYPE_RANGE_MULTIPLIER) {
		if (!IsBulletWeapon(weaponid)) {
			return 0;
		}

		new args = numargs();

		if (!(args & 0b1)) {
			return 0;
		}

		new steps = (args - 1) / 2;

		DamageType[weaponid] = damage_type;
		DamageRangeSteps[weaponid] = steps;

		for (new i = 0; i < steps; i++) {
			if (i) {
				DamageRangeRanges[weaponid][i] = Float:getarg(1 + i * 2);
				DamageRangeValues[weaponid][i] = Float:getarg(2 + i * 2);
			} else {
				DamageRangeValues[weaponid][i] = amount;
			}
		}

		return 1;
	} else if (damage_type == DAMAGE_TYPE_MULTIPLIER || damage_type == DAMAGE_TYPE_STATIC) {
		DamageType[weaponid] = damage_type;
		DamageRangeSteps[weaponid] = 0;
		WeaponDamage[weaponid] = amount;

		return 1;
	}

	return 0;
}

stock Float:GetWeaponDamage(WEAPON:weaponid)
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(WeaponDamage)) {
		return 0.0;
	}

	return WeaponDamage[weaponid];
}

stock SetCustomArmourRules(bool:armour_rules, bool:torso_rules = false)
{
	DamageArmourToggle[0] = armour_rules;
	DamageArmourToggle[1] = torso_rules;
}

stock SetWeaponArmourRule(WEAPON:weaponid, bool:affectarmour, bool:torso_only = false)
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(WeaponDamage)) {
		return 0;
	}

	DamageArmour[weaponid][0] = affectarmour;
	DamageArmour[weaponid][1] = torso_only;

	return 1;
}

stock SetDamageSounds(taken, given)
{
	DamageTakenSound = taken;
	DamageGivenSound = given;
}

stock SetCbugAllowed(bool:enabled, playerid = INVALID_PLAYER_ID)
{
	if (playerid == INVALID_PLAYER_ID) {
		CbugGlobal = enabled;
		foreach (new i : Player) 
		{
			CbugAllowed[i] = enabled;
		}
	} else {
		CbugAllowed[playerid] = enabled;
	}

	return enabled;
}

stock bool:GetCbugAllowed(playerid = INVALID_PLAYER_ID)
{
	if (playerid == INVALID_PLAYER_ID) {
		return CbugGlobal;
	}

	return CbugAllowed[playerid];
}

stock SetVehiclePassengerDamage(bool:toggle)
{
	VehiclePassengerDamage = toggle;
}

stock SetVehicleUnoccupiedDamage(bool:toggle)
{
	VehicleUnoccupiedDamage = toggle;
}

stock SetWeaponShootRate(WEAPON:weaponid, max_rate)
{
	if (_:WEAPON_UNARMED <= _:weaponid < sizeof(MaxWeaponShootRate)) {
		MaxWeaponShootRate[weaponid] = max_rate;

		return 1;
	}

	return 0;
}

stock GetWeaponShootRate(WEAPON:weaponid)
{
	if (_:WEAPON_UNARMED <= _:weaponid < sizeof(MaxWeaponShootRate)) {
		return MaxWeaponShootRate[weaponid];
	}

	return 0;
}

stock IsPlayerDying(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return IsDying[playerid];
	}

	return false;
}

stock SetWeaponMaxRange(WEAPON:weaponid, Float:range)
{
	if (!IsBulletWeapon(weaponid)) {
		return 0;
	}

	WeaponRange[weaponid] = range;

	return 1;
}

stock Float:GetWeaponMaxRange(WEAPON:weaponid)
{
	if (!IsBulletWeapon(weaponid)) {
		return 0.0;
	}

	return WeaponRange[weaponid];
}

stock SetPlayerMaxHealth(playerid, Float:value)
{
	if (0 <= playerid < MAX_PLAYERS) {
		PlayerMaxHealth[playerid] = value;
	}
}

stock SetPlayerMaxArmour(playerid, Float:value)
{
	if (0 <= playerid < MAX_PLAYERS) {
		PlayerMaxArmour[playerid] = value;
	}
}

stock Float:GetPlayerMaxHealth(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return PlayerMaxHealth[playerid];
	}

	return 0.0;
}

stock Float:GetPlayerMaxArmour(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return PlayerMaxArmour[playerid];
	}

	return 0.0;
}

stock Float:GetLastDamageHealth(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return DamageDoneHealth[playerid];
	}

	return 0.0;
}

stock Float:GetLastDamageArmour(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return DamageDoneArmour[playerid];
	}

	return 0.0;
}

stock DamagePlayer(playerid, Float:amount, issuerid = INVALID_PLAYER_ID, WEAPON:weaponid = WEAPON_UNKNOWN, bodypart = BODY_PART_UNKNOWN, bool:ignore_armour = false)
{
	if (playerid < 0 || playerid > MAX_PLAYERS || !IsPlayerConnected(playerid)) {
		return 0;
	}

	if (amount < 0.0) {
		return 0;
	}

	if (weaponid < WEAPON_UNARMED || weaponid > WEAPON_UNKNOWN) {
		weaponid = WEAPON_UNKNOWN;
	}

	if (issuerid < 0 || issuerid > MAX_PLAYERS || !IsPlayerConnected(issuerid)) {
		issuerid = INVALID_PLAYER_ID;
	}

	InflictDamage(playerid, amount, issuerid, weaponid, bodypart, ignore_armour);

	return 1;
}

stock GetRejectedHit(playerid, idx, output[], maxlength = sizeof(output))
{
	if (idx >= MAX_REJECTED_HITS) {
		return 0;
	}

	new real_idx = (RejectedHitsIdx[playerid] - idx) % MAX_REJECTED_HITS;

	// JIT plugin fix
	if (real_idx < 0) {
		real_idx += MAX_REJECTED_HITS;
	}

	if (!RejectedHits[playerid][real_idx][e_Time]) {
		return 0;
	}

	new reason = RejectedHits[playerid][real_idx][e_Reason];
	new hour = RejectedHits[playerid][real_idx][e_Hour];
	new minute = RejectedHits[playerid][real_idx][e_Minute];
	new second = RejectedHits[playerid][real_idx][e_Second];
	new i1 = RejectedHits[playerid][real_idx][e_Info1];
	new i2 = RejectedHits[playerid][real_idx][e_Info2];
	new i3 = RejectedHits[playerid][real_idx][e_Info3];
	new WEAPON:weapon = RejectedHits[playerid][real_idx][e_Weapon];

	new weapon_name[32];

	GetWeaponName(weapon, weapon_name);

	switch (reason) 
	{
		case SHOOTING_RATE_TOO_FAST,
			 HIT_RATE_TOO_FAST: 
	    {
			format(output, maxlength, g_HitRejectReasons[reason], i1, i2, i3);
		}
		case HIT_OUT_OF_RANGE,
			 SHOOTING_RATE_TOO_FAST_MULTIPLE,
			 HIT_RATE_TOO_FAST_MULTIPLE: 
	    {
			format(output, maxlength, g_HitRejectReasons[reason], i1, i2);
		}
		case HIT_MULTIPLE_PLAYERS,
			 HIT_MULTIPLE_PLAYERS_SHOTGUN,
			 HIT_INVALID_HITTYPE,
			 HIT_TOO_FAR_FROM_SHOT,
			 HIT_TOO_FAR_FROM_ORIGIN,
			 HIT_INVALID_DAMAGE,
			 HIT_INVALID_VEHICLE,
			 HIT_DISCONNECTED: 
	    {
			format(output, maxlength, g_HitRejectReasons[reason], i1);
		}

		default: 
	    {
			format(output, maxlength, "%s", g_HitRejectReasons[reason]);
		}
	}

	format(output, maxlength, "[%02d:%02d:%02d] (%s -> %s) %s", hour, minute, second, weapon_name, RejectedHits[playerid][real_idx][e_Name], output);

	return 1;
}

stock ResyncPlayer(playerid)
{
	SaveSyncData(playerid);

	BeingResynced[playerid] = true;

	SpawnPlayerInPlace(playerid);
}

stock SetDisableSyncBugs(toggle)
{
	DisableSyncBugs = !!toggle;
}

stock SetKnifeSync(toggle)
{
	KnifeSync = !!toggle;
}

stock Float:GetPlayerHealthEx(playerid, &Float:health = 0.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		health = 0.0;

		return 0.0;
	}

	health = PlayerHealth[playerid];

	return health;
}

stock SetPlayerHealthEx(playerid, Float:health, Float:armour = -1.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (health <= 0.0) {
		PlayerArmour[playerid] = 0.0;
		PlayerHealth[playerid] = 0.0;

		InflictDamage(playerid, 0.0);
	} else {
		if (armour != -1.0) {
			if (armour > PlayerMaxArmour[playerid]) {
				armour = PlayerMaxArmour[playerid];
			}
			PlayerArmour[playerid] = armour;
		}

		if (health > PlayerMaxHealth[playerid]) {
			health = PlayerMaxHealth[playerid];
		}
		PlayerHealth[playerid] = health;
		UpdateHealthBar(playerid, true);
	}

	return 1;
}

stock Float:GetPlayerArmourEx(playerid, &Float:armour = 0.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		armour = 0.0;

		return 0.0;
	}

	armour = PlayerArmour[playerid];

	return armour;
}

stock SetPlayerArmourEx(playerid, Float:armour)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (armour > PlayerMaxArmour[playerid]) {
		armour = PlayerMaxArmour[playerid];
	}
	PlayerArmour[playerid] = armour;
	UpdateHealthBar(playerid, true);

	return 1;
}

stock SetWeaponName(WEAPON:weaponid, const name[])
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(g_WeaponName)) {
		return 0;
	}

	strunpack(g_WeaponName[weaponid], name, sizeof(g_WeaponName[]));

	return 1;
}

stock Float:AngleBetweenPoints(Float:x1, Float:y1, Float:x2, Float:y2);

forward CbugPunishment(playerid, WEAPON:weapon);
public CbugPunishment(playerid, WEAPON:weapon) {
	FreezeSyncPacket(playerid, false);
	SetPlayerArmedWeapon(playerid, weapon);

	if (!IsDying[playerid]) {
		ClearAnimations(playerid, FORCE_SYNC:1);
	}
}

/*
 * Internal functions
 */

stock ScriptInit()
{
	LagCompMode = GetConsoleVarAsInt("lagcompmode");

	if (LagCompMode) {
		SetKnifeSync(false);
	} else {
		DamageTakenSound = 0;
		SetKnifeSync(true);
	}

	for (new i = 0; i < sizeof(ClassSpawnInfo); i++) {
		ClassSpawnInfo[i][e_Skin] = -1;
	}

	new worldid, tick = GetTickCount();

	foreach (new playerid : Player) {
		PlayerTeam[playerid] = GetPlayerTeam(playerid);

		SetPlayerTeam(playerid, PlayerTeam[playerid]);

		worldid = GetPlayerVirtualWorld(playerid);

		if (worldid == DEATH_WORLD) {
			worldid = 0;

			SetPlayerVirtualWorld(playerid, worldid);
		}

		World[playerid] = worldid;
		LastUpdate[playerid] = tick;
		LastStop[playerid] = tick;
		LastVehicleEnterTime[playerid] = 0;
		TrueDeath[playerid] = true;
		InClassSelection[playerid] = true;
		AlreadyConnected[playerid] = true;

		if (PLAYER_STATE_ONFOOT <= GetPlayerState(playerid) <= PLAYER_STATE_PASSENGER) {
			GetPlayerHealth(playerid, PlayerHealth[playerid]);
			GetPlayerArmour(playerid, PlayerArmour[playerid]);

			if (PlayerHealth[playerid] == 0.0) {
				PlayerHealth[playerid] = PlayerMaxHealth[playerid];
			}

			UpdateHealthBar(playerid);
		}
	}
}

stock ScriptExit()
{
	SetKnifeSync(true);

	new Float:health;

	foreach (new playerid : Player) {
		// Put things back the way they were
		SetPlayerTeam(playerid, PlayerTeam[playerid]);

		if (PLAYER_STATE_ONFOOT <= GetPlayerState(playerid) <= PLAYER_STATE_PASSENGER) {
			health = PlayerHealth[playerid];

			if (health == 0.0) {
				health = PlayerMaxHealth[playerid];
			}

			SetPlayerHealth(playerid, health);
			SetPlayerArmourEx(playerid, PlayerArmour[playerid]);
		}

		SetFakeHealth(playerid, 255);
		SetFakeArmour(playerid, 255);
		FreezeSyncPacket(playerid, false);
		SetFakeFacingAngle(playerid, _);
	}
}

stock UpdatePlayerVirtualWorld(playerid)
{
	new worldid = GetPlayerVirtualWorld(playerid);

	if (worldid == DEATH_WORLD) {
		worldid = World[playerid];
	} else if (worldid != World[playerid]) {
		World[playerid] = worldid;
	}

	SetPlayerVirtualWorld(playerid, worldid);
}

stock HasSameTeam(playerid, otherid)
{
	if (otherid < 0 || otherid >= MAX_PLAYERS || playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (PlayerTeam[playerid] == NO_TEAM || PlayerTeam[otherid] == NO_TEAM) {
		return 0;
	}

	return (PlayerTeam[playerid] == PlayerTeam[otherid]);
}

stock UpdateHealthBar(playerid, bool:force = false)
{
	if (BeingResynced[playerid] || pForceClassSelection[playerid]) {
		return;
	}

	new health = floatround(PlayerHealth[playerid] / PlayerMaxHealth[playerid] * 100.0, floatround_ceil);
	new armour = floatround(PlayerArmour[playerid] / PlayerMaxArmour[playerid] * 100.0, floatround_ceil);

	// Make the values reflect what the client should see
	if (IsDying[playerid]) {
		health = 0;
		armour = 0;
	} else {
		if (health > 100) {
			health = 100;
		}

		if (armour > 100) {
			armour = 100;
		}
	}

	if (force) 
	{
		LastSentHealth[playerid] = -1;
		LastSentArmour[playerid] = -1;
	} 
	else if (!IsDying[playerid]) 
	{
		LastSentHealth[playerid] = -1;
	} 
	else if (health == LastSentHealth[playerid] && armour == LastSentArmour[playerid]) 
	{
		return;
	}

	SetFakeHealth(playerid, health);
	SetFakeArmour(playerid, armour);

	// Hit Mark Status
    HitInformer[playerid] = 1;
    if(HitInformerTimer[playerid] == 0)
    {
    	SetPlayerColor(playerid, 0xFF0000FF);
        HitInformerTimer[playerid] = SetTimerEx("HitInformer", 350, true, "d", playerid);
    }

	UpdateSyncData(playerid);

	if (health != LastSentHealth[playerid]) {
		LastSentHealth[playerid] = health;
		if(health == 0.0)
		{
			SetPlayerHealth(playerid, 0.9);
		}
		else
		{
            SetPlayerHealth(playerid, float(health));
		}
	}

	if (armour != LastSentArmour[playerid]) {
		LastSentArmour[playerid] = armour;

		SetPlayerArmourEx(playerid, float(armour));
	}
}

forward HitInformer(playerid);
public HitInformer(playerid)
{
    if(HitInformer[playerid] == 0)
    {
    	SetPlayerColor(playerid, 0xFFFFFFFF);
        KillTimer(HitInformerTimer[playerid]);
        HitInformerTimer[playerid] = 0;
    }
    else
    {
        HitInformer[playerid] = 0;
    }
    return 1;
}

stock SpawnPlayerInPlace(playerid) {
	new Float:x, Float:y, Float:z, Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	SetSpawnInfo(playerid, PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);

	SpawnInfoModified[playerid] = true;

	SpawnPlayer(playerid);
}

stock Float:AngleBetweenPoints(Float:x1, Float:y1, Float:x2, Float:y2)
{
	return -(90.0 - atan2(y1 - y2, x1 - x2));
}

stock UpdateSyncData(playerid)
{
	// Currently re-sending onfoot data is only supported
	if (!IsPlayerConnected(playerid) || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) {
		return;
	}

	foreach (new i : Player) {
		if (i != playerid && IsPlayerStreamedIn(playerid, i)) {
			SendLastSyncPacket(playerid, i);
		}
	}
}

stock WasPlayerInVehicle(playerid, time) {
	if (!LastVehicleTick[playerid]) {
		return 0;
	}

	if (GetTickCount() - time < LastVehicleTick[playerid]) {
		return 1;
	}

	return 0;
}

hook function IsPlayerSpawned(playerid)
{
	if (IsDying[playerid] || BeingResynced[playerid]) {
		return false;
	}

	if (InClassSelection[playerid] || pForceClassSelection[playerid]) {
		return false;
	}

	switch (GetPlayerState(playerid)) {
		case PLAYER_STATE_ONFOOT .. PLAYER_STATE_PASSENGER,
		     PLAYER_STATE_SPAWNED: 
		{
			return true;
		}
	}

	return false;
}

hook function IsPlayerPaused(playerid)
{
	return (GetTickCount() - LastUpdate[playerid] > 2000);
}

/*
 * Hooked natives
 */

hook function SpawnPlayer(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || IsDying[playerid]) {
		return 0;
	}

	if (PlayerHealth[playerid] == 0.0) {
		PlayerHealth[playerid] = PlayerMaxHealth[playerid];
	}

	SpawnPlayer(playerid);

	return 1;
}

hook function PLAYER_STATE:GetPlayerState(playerid)
{
	if (IsDying[playerid]) {
		return PLAYER_STATE_WASTED;
	}

	return continue(playerid);
}

hook function GetPlayerTeam(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return NO_TEAM;
	}

	if (!IsPlayerConnected(playerid)) {
		return NO_TEAM;
	}

	return PlayerTeam[playerid];
}

hook function SetPlayerTeam(playerid, team)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	PlayerTeam[playerid] = team;
	SetPlayerTeam(playerid, team);

	return 1;
}

hook function SendDeathMessage(killer, killee, weapon)
{
	switch (weapon) {

		case WEAPON_VEHICLE_M4: 
		{
			weapon = WEAPON_M4;
		}
		case WEAPON_VEHICLE_MINIGUN: 
		{
			weapon = WEAPON_MINIGUN;
		}
		case WEAPON_VEHICLE_ROCKETLAUNCHER: 
		{
			weapon = WEAPON_ROCKETLAUNCHER;
		}
		case WEAPON_PISTOLWHIP: 
		{
			weapon = WEAPON_UNARMED;
		}
		case WEAPON_CARPARK: 
		{
			weapon = WEAPON_VEHICLE;
		}
		case WEAPON_UNKNOWN: 
		{
			weapon = WEAPON_DROWN;
		}
	}

	SendDeathMessage(killer, killee, weapon);

	return 1;
}

hook function GetWeaponName(WEAPON:weaponid, weapon[], len = sizeof(weapon))
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(g_WeaponName)) {
		format(weapon, len, "Weapon %d", weaponid);
	} else {
		strunpack(weapon, g_WeaponName[weaponid], len);
	}

	return 1;
}

hook function ApplyAnimation(playerid, const animlib[], const animname[], Float:fDelta, loop, lockx, locky, freeze, time, FORCE_SYNC:forcesync = FORCE_SYNC:0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || IsDying[playerid]) {
		return 0;
	}

	return continue(playerid, animlib, animname, fDelta, !!loop, !!lockx, !!locky, !!freeze, time, forcesync);
}

hook function ClearAnimations(playerid, FORCE_SYNC:forcesync = FORCE_SYNC:1)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || IsDying[playerid]) {
		return 0;
	}

	LastStop[playerid] = GetTickCount();

	return continue(playerid, forcesync);
}

hook function AddPlayerClass(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	new classid = AddPlayerClass(modelid, spawn_x, spawn_y, spawn_z, z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);

	if (0 <= classid <= 319) {
		ClassSpawnInfo[classid][e_Skin] = modelid;
		ClassSpawnInfo[classid][e_Team] = 0x7FFFFFFF;
		ClassSpawnInfo[classid][e_PosX] = spawn_x;
		ClassSpawnInfo[classid][e_PosY] = spawn_y;
		ClassSpawnInfo[classid][e_PosZ] = spawn_z;
		ClassSpawnInfo[classid][e_Rot] = z_angle;
		ClassSpawnInfo[classid][e_Weapon1] = weapon1;
		ClassSpawnInfo[classid][e_Ammo1] = weapon1_ammo;
		ClassSpawnInfo[classid][e_Weapon2] = weapon2;
		ClassSpawnInfo[classid][e_Ammo2] = weapon2_ammo;
		ClassSpawnInfo[classid][e_Weapon3] = weapon3;
		ClassSpawnInfo[classid][e_Ammo3] = weapon3_ammo;
	}

	return classid;
}

hook function AddPlayerClassEx(teamid, modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	new classid = AddPlayerClassEx(teamid, modelid, spawn_x, spawn_y, spawn_z, z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);

	if (0 <= classid <= 319) {
		ClassSpawnInfo[classid][e_Skin] = modelid;
		ClassSpawnInfo[classid][e_Team] = teamid;
		ClassSpawnInfo[classid][e_PosX] = spawn_x;
		ClassSpawnInfo[classid][e_PosY] = spawn_y;
		ClassSpawnInfo[classid][e_PosZ] = spawn_z;
		ClassSpawnInfo[classid][e_Rot] = z_angle;
		ClassSpawnInfo[classid][e_Weapon1] = weapon1;
		ClassSpawnInfo[classid][e_Ammo1] = weapon1_ammo;
		ClassSpawnInfo[classid][e_Weapon2] = weapon2;
		ClassSpawnInfo[classid][e_Ammo2] = weapon2_ammo;
		ClassSpawnInfo[classid][e_Weapon3] = weapon3;
		ClassSpawnInfo[classid][e_Ammo3] = weapon3_ammo;
	}

	return classid;
}

hook function SetSpawnInfo(playerid, team, skin, Float:x, Float:y, Float:z, Float:rotation, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	if (SetSpawnInfo(playerid, team, skin, x, y, z, rotation, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)) {
		PlayerClass[playerid] = -1;
		SpawnInfoModified[playerid] = false;

		PlayerSpawnInfo[playerid][e_Skin] = skin;
		PlayerSpawnInfo[playerid][e_Team] = team;
		PlayerSpawnInfo[playerid][e_PosX] = x;
		PlayerSpawnInfo[playerid][e_PosY] = y;
		PlayerSpawnInfo[playerid][e_PosZ] = z;
		PlayerSpawnInfo[playerid][e_Rot] = rotation;
		PlayerSpawnInfo[playerid][e_Weapon1] = weapon1;
		PlayerSpawnInfo[playerid][e_Ammo1] = weapon1_ammo;
		PlayerSpawnInfo[playerid][e_Weapon2] = weapon2;
		PlayerSpawnInfo[playerid][e_Ammo2] = weapon2_ammo;
		PlayerSpawnInfo[playerid][e_Weapon3] = weapon3;
		PlayerSpawnInfo[playerid][e_Ammo3] = weapon3_ammo;

		return 1;
	}

	return 0;
}

hook function TogglePlayerSpectating(playerid, toggle)
{
	if (TogglePlayerSpectating(playerid, !!toggle)) {
		if (toggle) {
			if (DeathTimer[playerid]) {
				KillTimer(DeathTimer[playerid]);
				DeathTimer[playerid] = 0;
			}

			IsDying[playerid] = false;
		}

		return 1;
	}

	return 0;
}

stock W_TogglePlayerControllable(playerid, toggle)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || IsDying[playerid]) {
		return 0;
	}

	LastStop[playerid] = GetTickCount();

	return TogglePlayerControllable(playerid, !!toggle);
}

#if defined _ALS_TogglePlayerControllable
	#undef TogglePlayerControllable
#else
	#define _ALS_TogglePlayerControllable
#endif
#define TogglePlayerControllable W_TogglePlayerControllable

hook function SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || IsDying[playerid]) {
		return 0;
	}

	LastStop[playerid] = GetTickCount();

	return continue(playerid, x, y, z);
}

hook function SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || IsDying[playerid]) {
		return 0;
	}

	LastStop[playerid] = GetTickCount();

	return continue(playerid, x, y, z);
}

hook function SetPlayerVelocity(playerid, Float:X, Float:Y, Float:Z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || IsDying[playerid]) {
		return 0;
	}

	if (X == 0.0 && Y == 0.0 && Z == 0.0) {
		LastStop[playerid] = GetTickCount();
	}

	return continue(playerid, X, Y, Z);
}

hook function SetPlayerVirtualWorld(playerid, worldid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	World[playerid] = worldid;

	if (IsDying[playerid]) {
		return 1;
	}

	return continue(playerid, worldid);
}

hook function GetPlayerVirtualWorld(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	new worldid = GetPlayerVirtualWorld(playerid);

	if (worldid == DEATH_WORLD) {
		return World[playerid];
	}

	return worldid;
}

hook function PlayerSpectatePlayer(playerid, targetplayerid, SPECTATE_MODE:mode = SPECTATE_MODE_NORMAL)
{
	if (PlayerSpectatePlayer(playerid, targetplayerid, mode)) {
		Spectating[playerid] = targetplayerid;
		return 1;
	}

	return 0;
}

hook function DestroyVehicle(vehicleid)
{
	if (DestroyVehicle(vehicleid)) {
		LastVehicleShooter[vehicleid] = INVALID_PLAYER_ID;
		VehicleAlive[vehicleid] = false;

		if (VehicleRespawnTimer[vehicleid]) {
			KillTimer(VehicleRespawnTimer[vehicleid]);
			VehicleRespawnTimer[vehicleid] = 0;
		}

		return 1;
	}

	return 0;
}

hook function CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay, addsiren = 0)
{
	new id = CreateVehicle(modelid, x, y, z, angle, color1, color2, respawn_delay, !!addsiren);

	if (0 < id < MAX_VEHICLES) {
		VehicleAlive[id] = true;
	}

	return id;
}

hook function AddStaticVehicle(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2)
{
	new id = AddStaticVehicle(modelid, x, y, z, angle, color1, color2);

	if (0 < id < MAX_VEHICLES) {
		VehicleAlive[id] = true;
	}

	return id;
}

hook function AddStaticVehicleEx(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay, addsiren = 0)
{
	new id = AddStaticVehicleEx(modelid, x, y, z, angle, color1, color2, respawn_delay, !!addsiren);

	if (0 < id < MAX_VEHICLES) {
		VehicleAlive[id] = true;
	}

	return id;
}

hook function SetPlayerSpecialAction(playerid, SPECIAL_ACTION:actionid)
{
	if (!IsPlayerSpawned(playerid)) {
		return 0;
	}

	return continue(playerid, actionid);
}

/*
 * Hooked callbacks
 */


stock OnWeaponConnect(playerid)
{
	new tick = GetTickCount();

	PlayerMaxHealth[playerid] = 100.0;
	PlayerHealth[playerid] = 100.0;
	PlayerMaxArmour[playerid] = 100.0;
	PlayerArmour[playerid] = 0.0;
	LastExplosive[playerid] = WEAPON_UNARMED;
	LastShotIdx[playerid] = 0;
	LastShot[playerid][e_Tick] = 0;
	LastHitIdx[playerid] = 0;
	RejectedHitsIdx[playerid] = 0;
	ShotsFired[playerid] = 0;
	HitsIssued[playerid] = 0;
	PlayerTeam[playerid] = NO_TEAM;
	IsDying[playerid] = false;
	BeingResynced[playerid] = false;
	SpawnForStreamedIn[playerid] = false;
	World[playerid] = 0;
	LastAnim[playerid] = -1;
	LastZVelo[playerid] = 0.0;
	LastZ[playerid] = 0.0;
	LastUpdate[playerid] = tick;
	Spectating[playerid] = INVALID_PLAYER_ID;
	LastSentHealth[playerid] = 0;
	LastSentArmour[playerid] = 0;
	LastStop[playerid] = tick;
	FirstSpawn[playerid] = true;
	LastVehicleEnterTime[playerid] = 0;
	TrueDeath[playerid] = true;
	InClassSelection[playerid] = false;
	pForceClassSelection[playerid] = false;
	PlayerClass[playerid] = -2;
	SpawnInfoModified[playerid] = false;
	DeathSkip[playerid] = 0;
	LastVehicleTick[playerid] = 0;
	PreviousHitI[playerid] = 0;
	HitInformer[playerid] = 0;
	HitInformerTimer[playerid] = 0;
	CbugAllowed[playerid] = CbugGlobal;
	CbugFroze[playerid] = 0;
	DeathTimer[playerid] = 0;
	DelayedDeathTimer[playerid] = 0;

	FakeHealth{playerid} = 255;
	FakeArmour{playerid} = 255;
	FakeQuat[playerid][0] = Float:0x7FFFFFFF;
	FakeQuat[playerid][1] = Float:0x7FFFFFFF;
	FakeQuat[playerid][2] = Float:0x7FFFFFFF;
	FakeQuat[playerid][3] = Float:0x7FFFFFFF;
	TempDataWritten[playerid] = false;
	SyncDataFrozen[playerid] = false;
	GogglesUsed[playerid] = 0;

	for (new i = 0; i < sizeof(PreviousHits[]); i++) {
		PreviousHits[playerid][i][e_Tick] = 0;
	}

	for (new i = 0; i < sizeof(RejectedHits[]); i++) {
		RejectedHits[playerid][i][e_Time] = 0;
	}

	SetPlayerTeam(playerid, PlayerTeam[playerid]);
	FreezeSyncPacket(playerid, false);
	SetFakeFacingAngle(playerid, _);

	AlreadyConnected[playerid] = false;
}

stock OnWeaponDisconnect(playerid, reason)
{
	//OnPlayerDisconnect(playerid, reason);

	if (DelayedDeathTimer[playerid]) {
		KillTimer(DelayedDeathTimer[playerid]);
		DelayedDeathTimer[playerid] = 0;
	}

	if (DeathTimer[playerid]) {
		KillTimer(DeathTimer[playerid]);
		DeathTimer[playerid] = 0;
	}

	if (KnifeTimeout[playerid]) {
		KillTimer(KnifeTimeout[playerid]);
		KnifeTimeout[playerid] = 0;
	}

	Spectating[playerid] = INVALID_PLAYER_ID;

	for (new i = 0; i < sizeof(LastVehicleShooter); i++) {
		if (LastVehicleShooter[i] == playerid) {
			LastVehicleShooter[i] = INVALID_PLAYER_ID;
		}
	}

	new j = 0;

	foreach (new i : Player) {
		for (j = 0; j < sizeof(PreviousHits[]); j++) {
			if (PreviousHits[i][j][e_Issuer] == playerid) {
				PreviousHits[i][j][e_Issuer] = INVALID_PLAYER_ID;
			}
		}
	}
}

stock OnWeaponSpawn(playerid)
{
	TrueDeath[playerid] = false;
	InClassSelection[playerid] = false;

	if (pForceClassSelection[playerid]) {
		ForceClassSelection(playerid);
		SetPlayerHealth(playerid, 0.0);

		return 1;
	}

	new tick = GetTickCount();
	LastUpdate[playerid] = tick;
	LastStop[playerid] = tick;

	if (BeingResynced[playerid]) {
		BeingResynced[playerid] = false;

		UpdateHealthBar(playerid);

		SetPlayerPos(playerid, SyncData[playerid][e_PosX], SyncData[playerid][e_PosY], SyncData[playerid][e_PosZ]);
		SetPlayerFacingAngle(playerid, SyncData[playerid][e_PosA]);

		SetPlayerSkin(playerid, SyncData[playerid][e_Skin]);
		SetPlayerTeam(playerid, SyncData[playerid][e_Team]);

		for (new i = 0; i < 13; i++) {
			if (SyncData[playerid][e_WeaponId][i]) {
				GivePlayerWeapon(playerid, SyncData[playerid][e_WeaponId][i], SyncData[playerid][e_WeaponAmmo][i]);
			}
		}

		SetPlayerArmedWeapon(playerid, SyncData[playerid][e_Weapon]);

		return 1;
	}

	if (SpawnInfoModified[playerid]) {
		new spawn_info[E_SPAWN_INFO], classid = PlayerClass[playerid];

		SpawnInfoModified[playerid] = false;

		if (classid == -1) 
		{
			spawn_info = PlayerSpawnInfo[playerid];
		} 
		else 
		{
			spawn_info = ClassSpawnInfo[classid];
		}

		if (spawn_info[e_Skin] != -1) {
			SetSpawnInfo(
				playerid,
				spawn_info[e_Team],
				spawn_info[e_Skin],
				spawn_info[e_PosX],
				spawn_info[e_PosY],
				spawn_info[e_PosZ],
				spawn_info[e_Rot],
				spawn_info[e_Weapon1],
				spawn_info[e_Ammo1],
				spawn_info[e_Weapon2],
				spawn_info[e_Ammo2],
				spawn_info[e_Weapon3],
				spawn_info[e_Ammo3]
			);
		}
	}

	if (DeathTimer[playerid]) {
		KillTimer(DeathTimer[playerid]);
		DeathTimer[playerid] = 0;
	}

	if (IsDying[playerid]) {
		IsDying[playerid] = false;
	}

	if (PlayerHealth[playerid] == 0.0) {
		PlayerHealth[playerid] = PlayerMaxHealth[playerid];
	}

	UpdatePlayerVirtualWorld(playerid);
	UpdateHealthBar(playerid, true);
	FreezeSyncPacket(playerid, false);
	SetFakeFacingAngle(playerid, _);

	if (GetPlayerTeam(playerid) != PlayerTeam[playerid]) {
		SetPlayerTeam(playerid, PlayerTeam[playerid]);
	}

	new animlib[32], animname[32];

	if (DeathSkip[playerid] == 2) {
		new WEAPON:w, a;
		GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		SetPlayerArmedWeapon(playerid, w);
		ClearAnimations(playerid);

		animlib = "PED", animname = "IDLE_stance";
		ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 1, FORCE_SYNC:1);

		DeathSkip[playerid] = 1;
		DeathSkipTick[playerid] = tick;

		return 1;
	}

	if (FirstSpawn[playerid]) {
		FirstSpawn[playerid] = false;

	}

	return 1;
}

stock OnWeaponRequestClass(playerid, classid)
{
	if (DeathSkip[playerid]) {
		SpawnPlayer(playerid);
		return 0;
	}

	if (pForceClassSelection[playerid]) {
		pForceClassSelection[playerid] = false;
	}

	if (BeingResynced[playerid]) {
		TrueDeath[playerid] = false;

		SpawnPlayerInPlace(playerid);

		return 0;
	}

	if (DeathTimer[playerid]) {
		KillTimer(DeathTimer[playerid]);
		DeathTimer[playerid] = 0;
	}

	if (IsDying[playerid]) {
		OnPlayerDeathFinished(playerid, false);
		IsDying[playerid] = false;
	}

	if (TrueDeath[playerid]) {
		if (!InClassSelection[playerid]) {
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			RemoveBuildingForPlayer(playerid, 1484, x, y, z, 350.0),
			RemoveBuildingForPlayer(playerid, 1485, x, y, z, 350.0),
			RemoveBuildingForPlayer(playerid, 1486, x, y, z, 350.0);

			InClassSelection[playerid] = true;
		}

		UpdatePlayerVirtualWorld(playerid);

		if (OnPlayerRequestClass(playerid, classid)) {
			PlayerClass[playerid] = classid;

			return 1;
		} else {
			return 0;
		}
	} else {
		pForceClassSelection[playerid] = true;

		SetPlayerVirtualWorld(playerid, DEATH_WORLD);
		SpawnPlayerInPlace(playerid);

		return 0;
	}
}

stock OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
	TrueDeath[playerid] = true;
	InClassSelection[playerid] = false;

	if (BeingResynced[playerid] || pForceClassSelection[playerid]) {
		return 1;
	}

	// Probably fake death
	if (killerid != INVALID_PLAYER_ID && !IsPlayerStreamedIn(killerid, playerid)) {
		killerid = INVALID_PLAYER_ID;
	}

	if (DeathTimer[playerid]) {
		KillTimer(DeathTimer[playerid]);
		DeathTimer[playerid] = 0;
	}

	if (IsDying[playerid]) {
		return 1;
	}

	if (reason < WEAPON_UNARMED || reason > WEAPON_UNKNOWN) {
		reason = WEAPON_UNKNOWN;
	}

	new vehicleid = GetPlayerVehicleID(playerid);

	// Let's assume they died from an exploading vehicle
	if (vehicleid != INVALID_VEHICLE_ID && IsValidVehicle(vehicleid)) {
		reason = WEAPON_EXPLOSION;
		killerid = INVALID_PLAYER_ID;

		if (!HasSameTeam(playerid, LastVehicleShooter[vehicleid])) {
			killerid = LastVehicleShooter[vehicleid];
		}
	}

	new Float:amount = 0.0;
	new bodypart = BODY_PART_UNKNOWN;

	if (reason == WEAPON_PARACHUTE) {
		reason = WEAPON_COLLISION;
	}

	if (OnPlayerDamage(playerid, amount, killerid, reason, bodypart)) {
		if (reason < WEAPON_UNARMED || reason > WEAPON_UNKNOWN) {
			reason = WEAPON_UNKNOWN;
		}

		if (amount == 0.0) {
			amount = PlayerHealth[playerid] + PlayerArmour[playerid];
		}

		if (reason == WEAPON_COLLISION || reason == WEAPON_DROWN || reason == WEAPON_CARPARK) {
			if (amount <= 0.0) {
				amount = PlayerHealth[playerid];
			}

			PlayerHealth[playerid] -= amount;
		} else {
			if (amount <= 0.0) {
				amount = PlayerHealth[playerid] + PlayerArmour[playerid];
			}

			PlayerArmour[playerid] -= amount;
		}

		if (PlayerArmour[playerid] < 0.0) {
			DamageDoneArmour[playerid] = amount + PlayerArmour[playerid];
			DamageDoneHealth[playerid] = -PlayerArmour[playerid];
			PlayerHealth[playerid] += PlayerArmour[playerid];
			PlayerArmour[playerid] = 0.0;
		} else {
			DamageDoneArmour[playerid] = amount;
			DamageDoneHealth[playerid] = 0.0;
		}

		if (PlayerHealth[playerid] <= 0.0) {
			amount += PlayerHealth[playerid];
			DamageDoneHealth[playerid] += PlayerHealth[playerid];
			PlayerHealth[playerid] = 0.0;
		}

		OnPlayerDamageDone(playerid, amount, killerid, reason, bodypart);
	}

	if (PlayerHealth[playerid] <= 0.0005) {
		PlayerHealth[playerid] = 0.0;
		IsDying[playerid] = true;

		LastDeathTick[playerid] = GetTickCount();

		new animlib[32], animname[32], anim_lock, respawn_time;

		OnPlayerPrepareDeath(playerid, animlib, animname, anim_lock, respawn_time);

		OnPlayerDeath(playerid, killerid, reason);

		OnPlayerDeathFinished(playerid, false);
	} else {
		if (vehicleid || WasPlayerInVehicle(playerid, 10000)) {
			new Float:x, Float:y, Float:z, Float:r;

			GetPlayerPos(playerid, x, y, z);
			SetPlayerPos(playerid, x, y, z);
			SaveSyncData(playerid);

			if (vehicleid) {
				GetVehicleZAngle(vehicleid, r);
			} else {
				GetPlayerFacingAngle(playerid, r);
			}

			DeathSkip[playerid] = 2;

			new WEAPON:w, a;
			GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

			ForceClassSelection(playerid);
			SetSpawnInfo(playerid, PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);
			TogglePlayerSpectating(playerid, true);
			TogglePlayerSpectating(playerid, false);
			SetSpawnInfo(playerid, PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);
			TogglePlayerControllable(playerid, true);
			SetPlayerArmedWeapon(playerid, w);
		} else {
			SpawnPlayerInPlace(playerid);
		}
	}

	UpdateHealthBar(playerid);

	return 1;
}

stock OnWeaponKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	new animlib[32], animname[32];
	if (!CbugAllowed[playerid] && !IsDying[playerid] && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		if (newkeys & KEY_CROUCH) {
			new tick = GetTickCount();
			new diff = tick - LastShot[playerid][e_Tick];

			if (LastShot[playerid][e_Tick] && diff < 1200 && !CbugFroze[playerid]) {
				PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);

				if (LastShot[playerid][e_Valid] && floatabs(LastShot[playerid][e_HX]) > 1.0 && floatabs(LastShot[playerid][e_HY]) > 1.0) {
					SetPlayerFacingAngle(playerid, AngleBetweenPoints(
						LastShot[playerid][e_HX],
						LastShot[playerid][e_HY],
						LastShot[playerid][e_OX],
						LastShot[playerid][e_OY]
					));
				}

				new WEAPON:w, a;
				GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

				animlib = "PED", animname = "IDLE_stance";
				ClearAnimations(playerid, FORCE_SYNC:1);
				ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 0, FORCE_SYNC:1);
				FreezeSyncPacket(playerid, true);
				SetPlayerArmedWeapon(playerid, w);
				SetTimerEx("CbugPunishment", 600, false, "ii", playerid, GetPlayerWeapon(playerid));

				CbugFroze[playerid] = tick;

				new j = 0, Float:health, Float:armour;

				foreach (new i : Player) {
					for (j = 0; j < sizeof(PreviousHits[]); j++) {
						if (PreviousHits[i][j][e_Issuer] == playerid && tick - PreviousHits[i][j][e_Tick] <= 1200) {
							PreviousHits[i][j][e_Issuer] = INVALID_PLAYER_ID;

							health = GetPlayerHealthEx(i);
							armour = GetPlayerArmourEx(i);

							if (IsDying[i]) {
								if (!DelayedDeathTimer[i]) {
									continue;
								}

								KillTimer(DelayedDeathTimer[i]);
								DelayedDeathTimer[i] = 0;
								ClearAnimations(i, FORCE_SYNC:1);
								SetFakeFacingAngle(i, _);
								FreezeSyncPacket(i, false);

								IsDying[i] = false;

								if (DeathTimer[i]) {
									KillTimer(DeathTimer[i]);
									DeathTimer[i] = 0;
								}
							}

							health += PreviousHits[i][j][e_Health];
							armour += PreviousHits[i][j][e_Armour];

							SetPlayerHealthEx(i, health, armour);
						}
					}
				}
			}
		}
	}

	if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		if (newkeys & KEY_FIRE) {
			new WEAPON:weap = GetPlayerWeapon(playerid);

			switch (weap) 
			{
				case WEAPON_BOMB, WEAPON_SATCHEL: 
			    {
					LastExplosive[playerid] = WEAPON_SATCHEL;
				}

				case WEAPON_ROCKETLAUNCHER, WEAPON_HEATSEEKER, WEAPON_GRENADE: 
				{
					LastExplosive[playerid] = weap;
				}
			}
		}
	}
}

stock OnWeaponStreamIn(playerid, forplayerid)
{
	// Send ped floor_hit_f
	if (IsDying[playerid] || InClassSelection[playerid]) {
		SendLastSyncPacket(playerid, forplayerid, .animation = 0x2e040000 + 1150);
	}
}

stock OnWeaponEnterVehicle(playerid, vehicleid, ispassenger)
{
	LastVehicleEnterTime[playerid] = gettime();
	LastVehicleTick[playerid] = GetTickCount();

	if (IsDying[playerid]) {
		TogglePlayerControllable(playerid, false);
		ApplyAnimation(playerid, "PED", "KO_skid_back", 4.1, false, false, false, true, 0, FORCE_SYNC:1);
	}
}

stock OnWeaponExitVehicle(playerid, vehicleid)
{
	LastVehicleTick[playerid] = GetTickCount();
}

stock OnWeaponStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
	if (Spectating[playerid] != INVALID_PLAYER_ID && newstate != PLAYER_STATE_SPECTATING) {
		Spectating[playerid] = INVALID_PLAYER_ID;
	}

	if (IsDying[playerid] && (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)) {
		TogglePlayerControllable(playerid, false);
	}

	if (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) {
		LastVehicleTick[playerid] = GetTickCount();

		if (newstate == PLAYER_STATE_ONFOOT) {
			new Float:vx, Float:vy, Float:vz;
			GetPlayerVelocity(playerid, vx, vy, vz);

			if (vx * vx + vy * vy + vz * vz <= 0.05) {
				foreach (new i : Player) {
					if (i != playerid && IsPlayerStreamedIn(playerid, i)) {
						SendLastSyncPacket(playerid, i);
						ClearAnimationsForPlayer(playerid, i);
					}
				}
			}
		}
	}
}

stock OnWeaponUpdate(playerid)
{
	if (TempDataWritten[playerid]) {
		if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
			LastSyncData[playerid] = TempSyncData[playerid];
			TempDataWritten[playerid] = false;
		}
	}

	if (IsDying[playerid]) {
		return 1;
	}

	if (pForceClassSelection[playerid]) {
		return 0;
	}

	new tick = GetTickCount();

	if (DeathSkip[playerid] == 1) {
		if (DeathSkipTick[playerid]) {
			if (tick - DeathSkipTick[playerid] > 1000) {
				new Float:x, Float:y, Float:z, Float:r;

				GetPlayerPos(playerid, x, y, z);
				GetPlayerFacingAngle(playerid, r);

				SetSpawnInfo(playerid, PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);

				DeathSkipTick[playerid] = 0;

				new animlib[] = "PED", animname[] = "IDLE_stance";
				ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 1, FORCE_SYNC:1);
			}
		} else {
			if (GetPlayerAnimationIndex(playerid) != 1189) {
				DeathSkip[playerid] = 0;

				DeathSkipEnd(playerid);
			}
		}
	}

	if (SpawnForStreamedIn[playerid]) {
		SpawnForStreamedIn(playerid);

		SpawnForStreamedIn[playerid] = false;
	}

	LastUpdate[playerid] = tick;
}

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
	//if (!IsHighRateWeapon(weaponid)) {
	//	DebugMessage("OnPlayerGiveDamage(%d gave %f to %d using %d on bodypart %s)", playerid, amount, damagedid, weaponid, ReturnBodypartName(bodypart));
	//}

	// Nobody got damaged
	if (!IsPlayerConnected(damagedid)) 
	{
		OnInvalidWeaponDamage(playerid, damagedid, amount, weaponid, bodypart, NO_DAMAGED, true);

		AddRejectedHit(playerid, damagedid, HIT_NO_DAMAGEDID, weaponid);

		return 0;
	}

	if (IsDying[damagedid]) {
		AddRejectedHit(playerid, damagedid, HIT_DYING_PLAYER, weaponid);
		return 0;
	}

	if (!LagCompMode) {
		new npc = IsPlayerNPC(damagedid);

		if (weaponid == WEAPON_KNIFE && _:amount == _:0.0) {
			if (damagedid == playerid) {
				return 0;
			}

			if (KnifeTimeout[damagedid]) {
				KillTimer(KnifeTimeout[damagedid]);
			}

			KnifeTimeout[damagedid] = SetTimerEx("SetSpawnForStreamedIn", 2500, false, "i", damagedid);
		}

		if (!npc) {
			return 0;
		}
	}

	// Ignore unreliable and invalid damage
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(ValidDamageGiven) || !ValidDamageGiven[weaponid]) {
		// Fire is synced as taken damage (because it's not reliable as given), so no need to show a rejected hit.
		// Vehicle damage is also synced as taken, so no need to show that either.
		if (weaponid != WEAPON_FLAMETHROWER && weaponid != WEAPON_VEHICLE) {
			AddRejectedHit(playerid, damagedid, HIT_INVALID_WEAPON, weaponid);
		}

		return 0;
	}

	new tick = GetTickCount();
	if (tick == 0) tick = 1;

	if (!IsPlayerSpawned(playerid) && tick - LastDeathTick[playerid] > 80) {
		// Make sure the rejected hit wasn't added in OnPlayerWeaponShot
		if (!IsBulletWeapon(weaponid) || LastShot[playerid][e_Valid]) {
			AddRejectedHit(playerid, damagedid, HIT_NOT_SPAWNED, weaponid);
		}

		return 0;
	}

	new npc = IsPlayerNPC(damagedid);

	// From stealth knife, can be any weapon
	if (_:amount == _:1833.33154296875) {
		return 0;
	}

	if (weaponid == WEAPON_KNIFE) {
		if (_:amount == _:0.0) {
			new WEAPON:w, a;
			GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

			if (damagedid == playerid) {
				return 0;
			}

			// Resync without bothering the player being knifed
			if (npc || HasSameTeam(playerid, damagedid)) {
				if (KnifeTimeout[damagedid]) {
					KillTimer(KnifeTimeout[damagedid]);
				}

				KnifeTimeout[damagedid] = SetTimerEx("SpawnForStreamedIn", 150, false, "i", damagedid);
				ClearAnimations(playerid, FORCE_SYNC:1);
				SetPlayerArmedWeapon(playerid, w);

				return 0;
			} else {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);

				if (GetPlayerDistanceFromPoint(damagedid, x, y, z) > WeaponRange[weaponid] + 2.0) {
					if (KnifeTimeout[damagedid]) {
						KillTimer(KnifeTimeout[damagedid]);
					}

					KnifeTimeout[damagedid] = SetTimerEx("SpawnForStreamedIn", 150, false, "i", damagedid);
					ClearAnimations(playerid, FORCE_SYNC:1);
					SetPlayerArmedWeapon(playerid, w);

					return 0;
				}
			}

			if (!OnPlayerDamage(damagedid, amount, playerid, weaponid, bodypart)) {
				if (KnifeTimeout[damagedid]) {
					KillTimer(KnifeTimeout[damagedid]);
				}

				KnifeTimeout[damagedid] = SetTimerEx("SpawnForStreamedIn", 150, false, "i", damagedid);
				ClearAnimations(playerid, FORCE_SYNC:1);
				SetPlayerArmedWeapon(playerid, w);

				return 0;
			}

			DamageDoneHealth[playerid] = PlayerHealth[playerid];
			DamageDoneArmour[playerid] = PlayerArmour[playerid];

			OnPlayerDamageDone(damagedid, PlayerHealth[damagedid] + PlayerArmour[damagedid], playerid, weaponid, bodypart);

			ClearAnimations(damagedid, FORCE_SYNC:1);

			new animlib[32] = "KNIFE", animname[32] = "KILL_Knife_Ped_Damage";
			PlayerDeath(damagedid, animlib, animname, _, 5200);

			SetTimerEx("SecondKnifeAnim", 2200, false, "i", damagedid);

			OnPlayerDeath(damagedid, playerid, weaponid);

			new Float:angle;

			GetPlayerFacingAngle(damagedid, angle);
			SetPlayerFacingAngle(playerid, angle);

			SetPlayerVelocity(damagedid, 0.0, 0.0, 0.0);
			SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);

			new forcesync = 2;

			if (747 < GetPlayerAnimationIndex(playerid) > 748) {
				forcesync = 1;
			}

			animname = "KILL_Knife_Player";
			ApplyAnimation(playerid, animlib, animname, 4.1, false, true, true, false, 1800, FORCE_SYNC:forcesync);

			return 0;
		}
	}

	if (HasSameTeam(playerid, damagedid)) {
		AddRejectedHit(playerid, damagedid, HIT_SAME_TEAM, weaponid);
		return 0;
	}

	// Both players should see eachother
	if ((!IsPlayerStreamedIn(playerid, damagedid) && !IsPlayerPaused(damagedid)) || !IsPlayerStreamedIn(damagedid, playerid)) {
		AddRejectedHit(playerid, damagedid, HIT_UNSTREAMED, weaponid, damagedid);
		return 0;
	}

	new Float:bullets, err;

	if ((err = ProcessDamage(damagedid, playerid, amount, weaponid, bodypart, bullets))) 
	{
		//if (err == INVALID_DAMAGE) 
		//{
		//	amount = WeaponDamage[weaponid];
		//	//AddRejectedHit(playerid, damagedid, HIT_INVALID_DAMAGE, weaponid, _:amount);
		//}

		if (err != INVALID_DISTANCE && err != INVALID_DAMAGE) 
		{
			OnInvalidWeaponDamage(playerid, damagedid, amount, weaponid, bodypart, err, true);
			return 0;
		}

		//return 0;
	}

	new idx = (LastHitIdx[playerid] + 1) % sizeof(LastHitTicks[]);

	// JIT plugin fix
	if (idx < 0) 
	{
		idx += sizeof(LastHitTicks[]);
	}

	LastHitIdx[playerid] = idx;
	LastHitTicks[playerid][idx] = tick;
	LastHitWeapons[playerid][idx] = weaponid;
	HitsIssued[playerid] += 1;

	new multiple_weapons;
	new avg_rate = AverageHitRate(playerid, MaxHitRateSamples, multiple_weapons);

	// Hit issue flood?
	// Could be either a cheat or just lag
	if (avg_rate != -1) 
	{
		if (multiple_weapons) 
		{
			if (avg_rate < 100) 
			{
				AddRejectedHit(playerid, damagedid, HIT_RATE_TOO_FAST_MULTIPLE, weaponid, avg_rate, MaxHitRateSamples);
				return 0;
			}
		} 
		else if (MaxWeaponShootRate[weaponid] - avg_rate > 20) 
		{
			AddRejectedHit(playerid, damagedid, HIT_RATE_TOO_FAST, weaponid, avg_rate, MaxHitRateSamples, MaxWeaponShootRate[weaponid]);
			return 0;
		}
	}

	new valid = true;

	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) 
	{
		if (WEAPON_UZI <= weaponid <= WEAPON_MP5 || weaponid == WEAPON_TEC9) 
		{
			new KEY:keys, ud, lr;
			GetPlayerKeys(playerid, keys, ud, lr);

			// It is only possible to shoot if you look right or left from car
			valid = (keys & KEY_LOOK_RIGHT) || (keys & KEY_LOOK_LEFT);
		} 
		else 
		{
			// Damage from something unusable from the driver's seat
			valid = false;
		}
	} 
	else if (IsBulletWeapon(weaponid) && _:amount != _:2.6400001049041748046875) 
	{
		if (!LastShot[playerid][e_Valid]) 
		{
			valid = false;
			//AddRejectedHit(playerid, damagedid, HIT_LAST_SHOT_INVALID, weaponid);
		} 
		else if (WEAPON_SHOTGUN <= weaponid <= WEAPON_SHOTGSPA) 
		{
			// Let's assume someone won't hit 2 players with 1 shotgun shot, and that one OnPlayerWeaponShot can be out of sync
			if (LastShot[playerid][e_Hits] >= 2) 
			{
				valid = false;
				AddRejectedHit(playerid, damagedid, HIT_MULTIPLE_PLAYERS_SHOTGUN, weaponid, LastShot[playerid][e_Hits] + 1);
			}
		} 
		else if (LastShot[playerid][e_Hits] > 0) 
		{
			// Sniper doesn't always send OnPlayerWeaponShot
			if (LastShot[playerid][e_Hits] >= 3 && weaponid != WEAPON_SNIPER) 
			{
				valid = false;
				AddRejectedHit(playerid, damagedid, HIT_MULTIPLE_PLAYERS, weaponid, LastShot[playerid][e_Hits] + 1);
			} 
		}

		if (valid) 
		{
			new Float:dist = GetPlayerDistanceFromPoint(damagedid, LastShot[playerid][e_HX], LastShot[playerid][e_HY], LastShot[playerid][e_HZ]);

			if (dist > 20.0) 
			{
				new in_veh = IsPlayerInAnyVehicle(damagedid) || GetPlayerSurfingVehicleID(damagedid) != INVALID_VEHICLE_ID;

				if ((!in_veh && GetPlayerSurfingObjectID(damagedid) == INVALID_OBJECT_ID) || dist > 50.0) 
				{
					valid = false;
					AddRejectedHit(playerid, damagedid, HIT_TOO_FAR_FROM_SHOT, weaponid, _:dist);
				}
			}
		}

		LastShot[playerid][e_Hits] += 1;
	}

	if (!valid) 
	{
		return 0;
	}

	if (npc) 
	{
		OnPlayerDamageDone(damagedid, amount, playerid, weaponid, bodypart);
	} 
	else 
	{
		InflictDamage(damagedid, amount, playerid, weaponid, bodypart);
	}

	// Don't send OnPlayerGiveDamage to the rest of the script, since it should not be used
	return 0;
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
	if (IsPlayerNPC(playerid)) 
	{
		return 0;
	}

	UpdateHealthBar(playerid, true);

	if (!IsPlayerSpawned(playerid)) 
	{
		return 0;
	}

	//if (!IsHighRateWeapon(weaponid)) 
	//{
	//	DebugMessage("OnPlayerTakeDamage(%d took %f from %d by %d on bodypart %d)", playerid, amount, issuerid, weaponid, bodypart);
	//}

	// Ignore unreliable and invalid damage
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(ValidDamageTaken) || !ValidDamageTaken[weaponid]) 
	{
		return 0;
	}

	// Carjack damage
	if (weaponid == WEAPON_COLLISION && issuerid != playerid && _:amount == _:0.0) 
	{
		return 0;
	}

	// From stealth knife, can be any weaponid
	if (_:amount == _:1833.33154296875) 
	{
		return 0;
	}

	// Climb bug
	if (weaponid == WEAPON_COLLISION) 
	{
		new anim = GetPlayerAnimationIndex(playerid);

		if (1061 <= anim <= 1067) 
		{
			//DebugMessage("climb bug prevented");
			return 0;
		}
	} 
	else if (weaponid == WEAPON_KNIFE) 
	{
		// Being knifed client-side

		// With the plugin, this part is never actually used (it can't happen)
		if (_:amount == _:0.0) 
		{
			if (issuerid == playerid) 
			{
				return 0;
			}

			if (KnifeTimeout[playerid]) 
			{
				KillTimer(KnifeTimeout[playerid]);

				KnifeTimeout[playerid] = 0;
			}

			if (issuerid == INVALID_PLAYER_ID || HasSameTeam(playerid, issuerid)) {
				ResyncPlayer(playerid);

				return 0;
			} else {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(issuerid, x, y, z);

				if (GetPlayerDistanceFromPoint(playerid, x, y, z) > WeaponRange[weaponid] + 2.0) {
					ResyncPlayer(playerid);

					return 0;
				}
			}

			if (!OnPlayerDamage(playerid, amount, issuerid, weaponid, bodypart)) 
			{
				ResyncPlayer(playerid);

				return 0;
			}

			// Make sure the values were not modified
			weaponid = WEAPON_KNIFE;
			amount = 0.0;

			DamageDoneHealth[playerid] = PlayerHealth[playerid];
			DamageDoneArmour[playerid] = PlayerArmour[playerid];

			OnPlayerDamageDone(playerid, PlayerHealth[playerid] + PlayerArmour[playerid], issuerid, weaponid, bodypart);

			new animlib[32] = "KNIFE", animname[32] = "KILL_Knife_Ped_Die";
			PlayerDeath(playerid, animlib, animname, _, 4000 - GetPlayerPing(playerid));

			OnPlayerDeath(playerid, issuerid, weaponid);

			SetPlayerHealth(playerid, 0.9);

			new Float:a;

			GetPlayerFacingAngle(playerid, a);
			SetPlayerFacingAngle(issuerid, a);

			SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
			SetPlayerVelocity(issuerid, 0.0, 0.0, 0.0);

			new forcesync = 2;

			if (GetPlayerAnimationIndex(issuerid) != 747) {
				forcesync = 1;
			}

			animname = "KILL_Knife_Player";
			ApplyAnimation(issuerid, animlib, animname, 4.1, false, true, true, false, 1800, FORCE_SYNC:forcesync);

			return 0;
		}
	}

	// If it's lagcomp, only allow damage that's valid for both modes
	if (LagCompMode && ValidDamageTaken[weaponid] != 2) {
		if (issuerid != INVALID_PLAYER_ID
		&& (weaponid == WEAPON_M4 || weaponid == WEAPON_MINIGUN)
		&& GetPlayerState(issuerid) == PLAYER_STATE_DRIVER) {
			new modelid = GetVehicleModel(GetPlayerVehicleID(issuerid));

			if (weaponid == WEAPON_M4) {
				if (modelid == 447 || modelid == 464 || modelid == 476) {
					weaponid = WEAPON_VEHICLE_M4;
				} else {
					return 0;
				}
			} else if (weaponid == WEAPON_MINIGUN && modelid == 425) {
				weaponid = WEAPON_VEHICLE_MINIGUN;
			} else {
				return 0;
			}
		} else {
			return 0;
		}
	}

	// Should still be damaged by grenades or fire after someone has died
	if (issuerid != INVALID_PLAYER_ID && IsPlayerConnected(issuerid)) {
		if (HasSameTeam(playerid, issuerid)) {
			return 0;
		}

		if (IsDying[issuerid] && (IsBulletWeapon(weaponid) || IsMeleeWeapon(weaponid)) && GetTickCount() - LastDeathTick[issuerid] > 80) {
			return 0;
		}

		if (BeingResynced[issuerid]) {
			return 0;
		}

		// https://github.com/oscar-broman/samp-weapon-config/issues/104
		if (weaponid == WEAPON_COLLISION
		|| weaponid == WEAPON_DROWN) {
			return 0;
		}

		// https://github.com/oscar-broman/samp-weapon-config/issues/104
		if (weaponid == WEAPON_VEHICLE
		|| weaponid == WEAPON_HELIBLADES) {
			if (GetPlayerState(issuerid) != PLAYER_STATE_DRIVER) {
				return 0;
			}
		}

		// Will be applied on fire, explosion, vehicle and heliblades (carpark) damage
		// Both players should see eachother, if playerid claims to keep issuerid valid
		if ((!IsPlayerStreamedIn(playerid, issuerid) && !IsPlayerPaused(issuerid)) || !IsPlayerStreamedIn(issuerid, playerid)) {
			// Probably fake or belated damage, so let's just reset issuerid
			issuerid = INVALID_PLAYER_ID;
		}
	}

	new Float:bullets = 0.0, err;

	if ((err = ProcessDamage(playerid, issuerid, amount, weaponid, bodypart, bullets))) 
	{
		//if (err == INVALID_DAMAGE) 
		//{
		//	amount = WeaponDamage[weaponid];
		//	//AddRejectedHit(issuerid, playerid, HIT_INVALID_DAMAGE, weaponid, _:amount);
		//}

		if (err != INVALID_DISTANCE) 
		{
			OnInvalidWeaponDamage(issuerid, playerid, amount, weaponid, bodypart, err, false);
			return 0;
		}
	}

	if (IsBulletWeapon(weaponid)) 
	{
		new Float:x, Float:y, Float:z, Float:dist;
		GetPlayerPos(issuerid, x, y, z);
		dist = GetPlayerDistanceFromPoint(playerid, x, y, z);

		if (dist > WeaponRange[weaponid] + 2.0) 
		{
			AddRejectedHit(issuerid, playerid, HIT_OUT_OF_RANGE, weaponid, _:dist, _:WeaponRange[weaponid]);
			return 0;
		}
	}

	InflictDamage(playerid, amount, issuerid, weaponid, bodypart);

	return 0;
}

hook OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{

	LastShot[playerid][e_Valid] = false;

	new tick = GetTickCount();
	if (tick == 0) tick = 1;

	if (CbugFroze[playerid] && tick - CbugFroze[playerid] < 900) {
		return 0;
	}

	CbugFroze[playerid] = 0;

	new damagedid = INVALID_PLAYER_ID;

	if (hittype == BULLET_HIT_TYPE_PLAYER && hitid != INVALID_PLAYER_ID) {
		if (!IsPlayerConnected(hitid)) {
			AddRejectedHit(playerid, hitid, HIT_DISCONNECTED, weaponid, hitid);

			return 0;
		}

		damagedid = hitid;
	}

	if (hittype < BULLET_HIT_TYPE_NONE || hittype > BULLET_HIT_TYPE_PLAYER_OBJECT) {
		AddRejectedHit(playerid, damagedid, HIT_INVALID_HITTYPE, weaponid, hittype);

		return 0;
	}

	if (BeingResynced[playerid]) {
		AddRejectedHit(playerid, damagedid, HIT_BEING_RESYNCED, weaponid);

		return 0;
	}

	if (!IsPlayerSpawned(playerid) && tick - LastDeathTick[playerid] > 80) {
		AddRejectedHit(playerid, damagedid, HIT_NOT_SPAWNED, weaponid);

		return 0;
	}

	if (!IsBulletWeapon(weaponid)) {
		AddRejectedHit(playerid, damagedid, HIT_INVALID_WEAPON, weaponid);

		return 0;
	}

	new Float:fOriginX, Float:fOriginY, Float:fOriginZ, Float:fHitPosX, Float:fHitPosY, Float:fHitPosZ;
	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerLastShotVectors(playerid, fOriginX, fOriginY, fOriginZ, fHitPosX, fHitPosY, fHitPosZ);

	new Float:length = VectorSize(fOriginX - fHitPosX, fOriginY - fHitPosY, fOriginZ - fHitPosZ);
	new Float:origin_dist = VectorSize(fOriginX - x, fOriginY - y, fOriginZ - z);

	if (origin_dist > 15.0) {
		new in_veh = IsPlayerInAnyVehicle(playerid) || GetPlayerSurfingVehicleID(playerid) != INVALID_VEHICLE_ID;

		if ((!in_veh && GetPlayerSurfingObjectID(playerid) == INVALID_OBJECT_ID) || origin_dist > 50.0) {
			AddRejectedHit(playerid, damagedid, HIT_TOO_FAR_FROM_ORIGIN, weaponid, _:origin_dist);

			return 0;
		}
	}

	// Shot exceeding the max range?
	if (hittype != BULLET_HIT_TYPE_NONE) {
		if (length > WeaponRange[weaponid]) {
			if (hittype == BULLET_HIT_TYPE_PLAYER) {
				AddRejectedHit(playerid, damagedid, HIT_OUT_OF_RANGE, weaponid, _:length, _:WeaponRange[weaponid]);
			}

			return 0;
		}

		if (hittype == BULLET_HIT_TYPE_PLAYER) {
			if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == GetPlayerVehicleID(hitid)) {
				AddRejectedHit(playerid, damagedid, HIT_SAME_VEHICLE, weaponid);
				return 0;
			}

			new Float:dist = GetPlayerDistanceFromPoint(hitid, fHitPosX, fHitPosY, fHitPosZ);
			new in_veh = IsPlayerInAnyVehicle(hitid) || GetPlayerSurfingVehicleID(hitid) != INVALID_VEHICLE_ID;

			if (dist > 20.0) {
				if ((!in_veh && GetPlayerSurfingObjectID(hitid) == INVALID_OBJECT_ID) || dist > 50.0) {
					AddRejectedHit(playerid, damagedid, HIT_TOO_FAR_FROM_SHOT, weaponid, _:dist);

					return 0;
				}
			}
		}
	}

	new idx = (LastShotIdx[playerid] + 1) % sizeof(LastShotTicks[]);

	// JIT plugin fix
	if (idx < 0) {
		idx += sizeof(LastShotTicks[]);
	}

	LastShotIdx[playerid] = idx;
	LastShotTicks[playerid][idx] = tick;
	LastShotWeapons[playerid][idx] = weaponid;
	ShotsFired[playerid] += 1;

	LastShot[playerid][e_Tick] = tick;
	LastShot[playerid][e_Weapon] = weaponid;
	LastShot[playerid][e_HitType] = hittype;
	LastShot[playerid][e_HitId] = hitid;
	LastShot[playerid][e_X] = fX;
	LastShot[playerid][e_Y] = fY;
	LastShot[playerid][e_Z] = fZ;
	LastShot[playerid][e_OX] = fOriginX;
	LastShot[playerid][e_OY] = fOriginY;
	LastShot[playerid][e_OZ] = fOriginZ;
	LastShot[playerid][e_HX] = fHitPosX;
	LastShot[playerid][e_HY] = fHitPosY;
	LastShot[playerid][e_HZ] = fHitPosZ;
	LastShot[playerid][e_Length] = length;
	LastShot[playerid][e_Hits] = 0;

	new multiple_weapons;
	new avg_rate = AverageShootRate(playerid, MaxShootRateSamples, multiple_weapons);

	// Bullet flood?
	// Could be either a cheat or just lag
	if (avg_rate != -1) {
		if (multiple_weapons) {
			if (avg_rate < 100) {
				AddRejectedHit(playerid, damagedid, SHOOTING_RATE_TOO_FAST_MULTIPLE, weaponid, avg_rate, MaxShootRateSamples);
				return 0;
			}
		} else if (MaxWeaponShootRate[weaponid] - avg_rate > 20) {
			AddRejectedHit(playerid, damagedid, SHOOTING_RATE_TOO_FAST, weaponid, avg_rate, MaxShootRateSamples, MaxWeaponShootRate[weaponid]);
			return 0;
		}
	}

	// Destroy vehicles with passengers in them
	if (hittype == BULLET_HIT_TYPE_VEHICLE) {
		if (hitid < 0 || hitid > MAX_VEHICLES || !IsValidVehicle(hitid)) {
			AddRejectedHit(playerid, damagedid, HIT_INVALID_VEHICLE, weaponid, hitid);
			return 0;
		}

		if (!IsVehicleStreamedIn(hitid, playerid)) {
			AddRejectedHit(playerid, damagedid, HIT_UNSTREAMED, weaponid, hitid);
			return 0;
		}

		new vehicleid = GetPlayerVehicleID(playerid);

		// Shouldn't be possible to damage the vehicle you're in
		if (hitid == vehicleid) {
			AddRejectedHit(playerid, damagedid, HIT_OWN_VEHICLE, weaponid);
			return 0;
		}

		if (VehiclePassengerDamage) {
			new hadriver = false;
			new hapassenger = false;
			new seat;

			foreach (new otherid : Player) {
				if (otherid == playerid) {
					continue;
				}

				if (GetPlayerVehicleID(otherid) != hitid) {
					continue;
				}

				seat = GetPlayerVehicleSeat(otherid);

				if (seat == 0) {
					hadriver = true;
				} else {
					hapassenger = true;
				}
			}

			if (!hadriver && hapassenger) {
				new Float:health;

				GetVehicleHealth(hitid, health);

				if (WEAPON_SHOTGUN <= weaponid <= WEAPON_SHOTGSPA) {
					health -= 120.0;
				} else {
					health -= WeaponDamage[weaponid] * 3.0;
				}

				if (health <= 0.0) {
					health = 0.0;
				}

				SetVehicleHealth(hitid, health);
			}
		}

		if (VehicleUnoccupiedDamage) {
			new haoccupent = false;

			foreach (new otherid : Player) {
				if (otherid == playerid) {
					continue;
				}

				if (GetPlayerVehicleID(otherid) != hitid) {
					continue;
				}

				haoccupent = true;
			}

			if (!haoccupent) {
				new Float:health;

				GetVehicleHealth(hitid, health);
				if (health >= 250.0) { // vehicles start on fire below 250 hp
					if (WEAPON_SHOTGUN <= weaponid <= WEAPON_SHOTGSPA) {
						health -= 120.0;
					} else {
						health -= WeaponDamage[weaponid] * 3.0;
					}

					if (health < 250.0) {
						if (!VehicleRespawnTimer[hitid]) {
							health = 249.0;
							VehicleRespawnTimer[hitid] = SetTimerEx("KillVehicle", 6000, false, "ii", hitid, playerid);
						}
					}

					SetVehicleHealth(hitid, health);
				}
			}
		}
	}

	new retval = OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, fX, fY, fZ);

	LastShot[playerid][e_Valid] = !!retval;

	// Valid shot?
	if (retval) {
		if (hittype == BULLET_HIT_TYPE_VEHICLE) {
			LastVehicleShooter[hitid] = playerid;
		}
	}

	return retval;
}

forward KillVehicle(vehicleid, killerid);
public KillVehicle(vehicleid, killerid)
{
	OnVehicleDeath(vehicleid, killerid);
	VehicleRespawnTimer[vehicleid] = SetTimerEx("OnDeadVehicleSpawn", 10000, false, "i", vehicleid);
	return 1;
}

forward OnDeadVehicleSpawn(vehicleid);
public OnDeadVehicleSpawn(vehicleid)
{
	VehicleRespawnTimer[vehicleid] = 0;
	return SetVehicleToRespawn(vehicleid);
}

stock OnWeaponSpawn(vehicleid)
{
	if (VehicleRespawnTimer[vehicleid]) {
		KillTimer(VehicleRespawnTimer[vehicleid]);
		VehicleRespawnTimer[vehicleid] = 0;
	}

	VehicleAlive[vehicleid] = true;
	LastVehicleShooter[vehicleid] = INVALID_PLAYER_ID;
}

stock OnWeaponDeath(vehicleid, killerid)
{
	if (VehicleRespawnTimer[vehicleid]) {
		KillTimer(VehicleRespawnTimer[vehicleid]);
		VehicleRespawnTimer[vehicleid] = 0;
	}

	if (VehicleAlive[vehicleid]) {
		VehicleAlive[vehicleid] = false;
	}
	else return 1;
}

/*
 * Internal functions
 */

stock ScriptInit()
{
	LagCompMode = GetConsoleVarAsInt("lagcompmode");

	if (LagCompMode) {
		SetKnifeSync(false);
	} else {
		DamageTakenSound = 0;
		SetKnifeSync(true);
	}

	for (new i = 0; i < sizeof(ClassSpawnInfo); i++) {
		ClassSpawnInfo[i][e_Skin] = -1;
	}

	new worldid, tick = GetTickCount();

	foreach (new playerid : Player) {
		PlayerTeam[playerid] = GetPlayerTeam(playerid);

		SetPlayerTeam(playerid, PlayerTeam[playerid]);

		worldid = GetPlayerVirtualWorld(playerid);

		if (worldid == DEATH_WORLD) {
			worldid = 0;

			SetPlayerVirtualWorld(playerid, worldid);
		}

		World[playerid] = worldid;
		LastUpdate[playerid] = tick;
		LastStop[playerid] = tick;
		LastVehicleEnterTime[playerid] = 0;
		TrueDeath[playerid] = true;
		InClassSelection[playerid] = true;
		AlreadyConnected[playerid] = true;

		if (PLAYER_STATE_ONFOOT <= GetPlayerState(playerid) <= PLAYER_STATE_PASSENGER) {
			GetPlayerHealth(playerid, PlayerHealth[playerid]);
			GetPlayerArmour(playerid, PlayerArmour[playerid]);

			if (PlayerHealth[playerid] == 0.0) {
				PlayerHealth[playerid] = PlayerMaxHealth[playerid];
			}

			UpdateHealthBar(playerid);
		}
	}
}

stock ScriptExit()
{
	SetKnifeSync(true);

	new Float:health;

	foreach (new playerid : Player) {
		// Put things back the way they were
		SetPlayerTeam(playerid, PlayerTeam[playerid]);

		if (PLAYER_STATE_ONFOOT <= GetPlayerState(playerid) <= PLAYER_STATE_PASSENGER) {
			health = PlayerHealth[playerid];

			if (health == 0.0) {
				health = PlayerMaxHealth[playerid];
			}

			SetPlayerHealth(playerid, health);
			SetPlayerArmourEx(playerid, PlayerArmour[playerid]);
		}

		SetFakeHealth(playerid, 255);
		SetFakeArmour(playerid, 255);
		FreezeSyncPacket(playerid, false);
		SetFakeFacingAngle(playerid, _);
	}
}

stock UpdatePlayerVirtualWorld(playerid)
{
	new worldid = GetPlayerVirtualWorld(playerid);

	if (worldid == DEATH_WORLD) {
		worldid = World[playerid];
	} else if (worldid != World[playerid]) {
		World[playerid] = worldid;
	}

	SetPlayerVirtualWorld(playerid, worldid);
}

stock HasSameTeam(playerid, otherid)
{
	if (otherid < 0 || otherid >= MAX_PLAYERS || playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (PlayerTeam[playerid] == NO_TEAM || PlayerTeam[otherid] == NO_TEAM) {
		return 0;
	}

	return (PlayerTeam[playerid] == PlayerTeam[otherid]);
}

stock UpdateHealthBar(playerid, bool:force = false)
{
	if (BeingResynced[playerid] || pForceClassSelection[playerid]) {
		return;
	}

	new health = floatround(PlayerHealth[playerid] / PlayerMaxHealth[playerid] * 100.0, floatround_ceil);
	new armour = floatround(PlayerArmour[playerid] / PlayerMaxArmour[playerid] * 100.0, floatround_ceil);

	// Make the values reflect what the client should see
	if (IsDying[playerid]) {
		health = 0;
		armour = 0;
	} else {
		if (health > 100) {
			health = 100;
		}

		if (armour > 100) {
			armour = 100;
		}
	}

	if (force) 
	{
		LastSentHealth[playerid] = -1;
		LastSentArmour[playerid] = -1;
	} 
	else if (!IsDying[playerid]) 
	{
		LastSentHealth[playerid] = -1;
	} 
	else if (health == LastSentHealth[playerid] && armour == LastSentArmour[playerid]) 
	{
		return;
	}

	SetFakeHealth(playerid, health);
	SetFakeArmour(playerid, armour);

	// Hit Mark Status
    HitInformer[playerid] = 1;
    if(HitInformerTimer[playerid] == 0)
    {
    	SetPlayerColor(playerid, 0xFF0000FF);
        HitInformerTimer[playerid] = SetTimerEx("HitInformer", 350, true, "d", playerid);
    }

	UpdateSyncData(playerid);

	if (health != LastSentHealth[playerid]) {
		LastSentHealth[playerid] = health;
		if(health == 0.0)
		{
			SetPlayerHealth(playerid, 0.9);
		}
		else
		{
            SetPlayerHealth(playerid, float(health));
		}
	}

	if (armour != LastSentArmour[playerid]) {
		LastSentArmour[playerid] = armour;

		SetPlayerArmourEx(playerid, float(armour));
	}
}

forward HitInformer(playerid);
public HitInformer(playerid)
{
    if(HitInformer[playerid] == 0)
    {
    	SetPlayerColor(playerid, 0xFFFFFFFF);
        KillTimer(HitInformerTimer[playerid]);
        HitInformerTimer[playerid] = 0;
    }
    else
    {
        HitInformer[playerid] = 0;
    }
    return 1;
}

stock SpawnPlayerInPlace(playerid) {
	new Float:x, Float:y, Float:z, Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	SetSpawnInfo(playerid, PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);

	SpawnInfoModified[playerid] = true;

	SpawnPlayer(playerid);
}

stock Float:AngleBetweenPoints(Float:x1, Float:y1, Float:x2, Float:y2)
{
	return -(90.0 - atan2(y1 - y2, x1 - x2));
}

stock UpdateSyncData(playerid)
{
	// Currently re-sending onfoot data is only supported
	if (!IsPlayerConnected(playerid) || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) {
		return;
	}

	foreach (new i : Player) {
		if (i != playerid && IsPlayerStreamedIn(playerid, i)) {
			SendLastSyncPacket(playerid, i);
		}
	}
}

stock WasPlayerInVehicle(playerid, time) {
	if (!LastVehicleTick[playerid]) {
		return 0;
	}

	if (GetTickCount() - time < LastVehicleTick[playerid]) {
		return 1;
	}

	return 0;
}

forward DeathSkipEnd(playerid);
public DeathSkipEnd(playerid)
{
	TogglePlayerControllable(playerid, true);

	ResetPlayerWeapons(playerid);

	for (new i = 0; i < 13; i++) {
		if (SyncData[playerid][e_WeaponId][i]) {
			GivePlayerWeapon(playerid, SyncData[playerid][e_WeaponId][i], SyncData[playerid][e_WeaponAmmo][i]);
		}
	}

	SetPlayerArmedWeapon(playerid, SyncData[playerid][e_Weapon]);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
}

forward SpawnForStreamedIn(playerid);
public SpawnForStreamedIn(playerid)
{
	if (!IsPlayerConnected(playerid)) {
		return;
	}

	SpawnPlayerForWorld(playerid);

	foreach (new i : Player) {
		if (i != playerid && IsPlayerStreamedIn(playerid, i)) {
			SendLastSyncPacket(playerid, i);
			ClearAnimationsForPlayer(playerid, i);
		}
	}
}

forward SetSpawnForStreamedIn(playerid);
public SetSpawnForStreamedIn(playerid)
{
	SpawnForStreamedIn[playerid] = true;
}

stock ProcessDamage(&playerid, &issuerid, &Float:amount, &WEAPON:weaponid, &bodypart, &Float:bullets)
{
	// Car parking
	if (weaponid == WEAPON_HELIBLADES && _:amount != _:330.0) 
	{
		weaponid = WEAPON_CARPARK;
	}

	// Finish processing drown/fire/carpark quickly, since they are sent at very high rates
	if (IsHighRateWeapon(weaponid)) 
	{
		// Apply reasonable bounds
		if (weaponid == WEAPON_DROWN) 
		{
			if (amount > 10.0) amount = 10.0;
		} 
		else if (amount > 1.0) 
		{
			amount = 1.0;
		}

		// Adjust the damage if the multiplier is not 1.0
		//if (_:WeaponDamage[weaponid] != _:1.0) 
		//{
		//	amount *= WeaponDamage[weaponid];
		//}

		// Make sure the distance and issuer is valid; carpark can be self-inflicted so it doesn't require an issuer
		if (weaponid == WEAPON_SPRAYCAN || weaponid == WEAPON_FIREEXTINGUISHER || (weaponid == WEAPON_CARPARK && issuerid != INVALID_PLAYER_ID)) {
			if (issuerid == INVALID_PLAYER_ID) {
				return NO_ISSUER;
			}

			new Float:x, Float:y, Float:z, Float:dist;
			GetPlayerPos(issuerid, x, y, z);
			dist = GetPlayerDistanceFromPoint(playerid, x, y, z);

			if (weaponid == WEAPON_CARPARK) 
			{
				if (dist > 15.0) 
				{
					AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist);
					return INVALID_DISTANCE;
				}
			} 
			else 
			{
				if (dist > WeaponRange[weaponid] + 2.0) 
				{
					AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist, _:WeaponRange[weaponid]);
					return INVALID_DISTANCE;
				}
			}
		}

		return NO_ERROR;
	}

	// Bullet or melee damage must have an issuerid, otherwise something has gone wrong (e.g. sniper bug)
	if (issuerid == INVALID_PLAYER_ID && (IsBulletWeapon(weaponid) || IsMeleeWeapon(weaponid))) 
	{
		return NO_ISSUER;
	}

	// Punching with a parachute
	if (weaponid == WEAPON_PARACHUTE) 
	{
		weaponid = WEAPON_UNARMED;
	} 
	else if (weaponid == WEAPON_COLLISION) 
	{
		// Collision damage should never be above 165

		if (amount > 165.0) 
		{
			amount = 1.0;
		} 
		else 
		{
			amount /= 165.0;
		}
	} 
	else if (weaponid == WEAPON_EXPLOSION) 
	{
		// Explosions do at most 82.5 damage. This will later be multipled by the damage value
		amount /= 82.5;

		// Figure out what caused the explosion
		if (issuerid != INVALID_PLAYER_ID) 
		{
			if (GetPlayerState(issuerid) == PLAYER_STATE_DRIVER) 
			{
				new modelid = GetVehicleModel(GetPlayerVehicleID(issuerid));

				if (modelid == 425 || modelid == 432 || modelid == 520) 
				{
					weaponid = WEAPON_VEHICLE_ROCKETLAUNCHER;
				}
			} 
			else if (LastExplosive[issuerid]) 
			{
				weaponid = LastExplosive[issuerid];
			}
		} 
		else if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) 
		{
			new modelid = GetVehicleModel(GetPlayerVehicleID(playerid));

			if (modelid == 425 || modelid == 432 || modelid == 520) 
			{
				weaponid = WEAPON_VEHICLE_ROCKETLAUNCHER;
			}
		}
	}

	// Check for pistol whip
	switch (weaponid) 
	{
		case WEAPON_COLT45 .. WEAPON_SNIPER,
		     WEAPON_MINIGUN, WEAPON_SPRAYCAN, WEAPON_FIREEXTINGUISHER: 
		{
			// A pistol whip inflicts 2.64 damage
			if (_:amount == _:2.6400001049041748046875) 
			{
				// Save the weapon in the bodypart argument (it's always BODY_PART_TORSO)
				bodypart = weaponid;
				weaponid = WEAPON_PISTOLWHIP;
			}
		}
	}

	new melee = IsMeleeWeapon(weaponid);

	// Can't punch from a vehicle
	if (melee && IsPlayerInAnyVehicle(issuerid)) 
	{
		return INVALID_DAMAGE;
	}

	if (weaponid != WEAPON_PISTOLWHIP) 
	{
		switch (amount) 
		{
			case 1.32000005245208740234375,
			     1.650000095367431640625,
			     1.980000019073486328125,
			     2.3100001811981201171875,
			     2.6400001049041748046875,
			     2.9700000286102294921875,
			     3.96000003814697265625,
			     4.28999996185302734375,
			     4.62000036239624023437,
			     5.280000209808349609375: 
			     {
				// Damage is most likely from punching and switching weapon quickly
				if (!melee) 
				{
					weaponid = WEAPON_UNARMED;
					melee = true;
				}
			}

			case 6.6000003814697265625: 
			{
				if (!melee) 
				{
					switch (weaponid) 
					{
						case WEAPON_UZI, WEAPON_TEC9,
						     WEAPON_SHOTGUN, WEAPON_SAWEDOFF: {}

						default: 
						{
							weaponid = WEAPON_UNARMED;
							melee = true;
						}
					}
				}
			}

			case 54.12000274658203125: 
			{
				if (!melee) 
				{
					melee = true;
					weaponid = WEAPON_UNARMED;
					amount = 1.32000005245208740234375;
				}

				// Be extra sure about this one
				if (GetPlayerFightingStyle(issuerid) != FIGHT_STYLE_KNEEHEAD) 
				{
					return INVALID_DAMAGE;
				}
			}

			// Melee damage has been tampered with
			default: 
			{
				if (melee) 
				{
					return INVALID_DAMAGE;
				}
			}
		}
	}

	if (melee) 
	{
		new Float:x, Float:y, Float:z, Float:dist;
		GetPlayerPos(issuerid, x, y, z);
		dist = GetPlayerDistanceFromPoint(playerid, x, y, z);

		if (_:WEAPON_UNARMED <= _:weaponid < sizeof(WeaponRange) && dist > WeaponRange[weaponid] + 2.0) 
		{
			AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist, _:WeaponRange[weaponid]);
			return INVALID_DISTANCE;
		}
	}

	switch (weaponid) 
	{
		// The spas shotguns shoot 8 bullets, each inflicting 4.95 damage
		case WEAPON_SHOTGSPA: 
		{
			bullets = amount / 4.950000286102294921875;

			if (8.0 - bullets < -0.05) 
			{
				return INVALID_DAMAGE;
			}
		}

		// Shotguns and sawed-off shotguns shoot 15 bullets, each inflicting 3.3 damage
		case WEAPON_SHOTGUN, WEAPON_SAWEDOFF: 
		{
			bullets = amount / 3.30000019073486328125;

			if (15.0 - bullets < -0.05) 
			{
				return INVALID_DAMAGE;
			}
		}
	}

	if (_:bullets) 
	{
		new Float:f = floatfract(bullets);

		// The damage for each bullet has been tampered with
		if (f > 0.01 && f < 0.99) 
		{
			return INVALID_DAMAGE;
		}

		// Divide the damage amount by the number of bullets
		amount /= bullets;
	}

	// Check chainsaw damage
	if (weaponid == WEAPON_CHAINSAW) 
	{
		switch (amount) 
		{
			case 6.6000003814697265625,
			     13.5300006866455078125,
			     16.1700000762939453125,
			     26.40000152587890625,
			     27.060001373291015625: {}

			default: 
			{
				return INVALID_DAMAGE;
			}
		}
	} else if (weaponid == WEAPON_DEAGLE) 
	{
		// Check deagle damage

		switch (amount) 
		{
			case 46.200000762939453125,
			     23.1000003814697265625: {}

			default: 
			{
				return INVALID_DAMAGE;
			}
		}
	}

	// Adjust the damage
	switch (DamageType[weaponid]) 
	{
		case DAMAGE_TYPE_MULTIPLIER: 
		{
			if (_:WeaponDamage[weaponid] != _:1.0) 
			{
				amount *= WeaponDamage[weaponid];
			}
		}

		case DAMAGE_TYPE_STATIC: 
		{
			new Float:length = 0.0;
			if (LagCompMode) 
			{
				length = LastShot[issuerid][e_Length];
				if (_:bullets) 
			    {
			    	amount = WeaponDamage[weaponid] * bullets;
			    } 
			    else 
			    {
			    	amount = WeaponDamage[weaponid];
			    }
			} 
			else 
			{
				new Float:X, Float:Y, Float:Z;
				GetPlayerPos(issuerid, X, Y, Z);
				length = GetPlayerDistanceFromPoint(playerid, X, Y, Z);

				if (_:bullets) 
			    {
			    	amount = WeaponDamage[weaponid] * bullets;
			    } 
			    else 
			    {
			    	amount = WeaponDamage[weaponid];
			    }
			}
		}
	}

	return NO_ERROR;
}

stock InflictDamage(playerid, Float:amount, issuerid = INVALID_PLAYER_ID, WEAPON:weaponid = WEAPON_UNKNOWN, bodypart = BODY_PART_UNKNOWN, bool:ignore_armour = false)
{
	if (!IsPlayerSpawned(playerid) || amount < 0.0) 
	{
		return;
	}

	if (!OnPlayerDamage(playerid, amount, issuerid, weaponid, bodypart)) 
	{
		UpdateHealthBar(playerid);

		if (weaponid < WEAPON_UNARMED || weaponid > WEAPON_UNKNOWN) 
		{
			weaponid = WEAPON_UNKNOWN;
		}

		return;
	}

	if (weaponid < WEAPON_UNARMED || weaponid > WEAPON_UNKNOWN) 
	{
		weaponid = WEAPON_UNKNOWN;
	}

	if (!ignore_armour && weaponid != WEAPON_COLLISION && weaponid != WEAPON_DROWN && weaponid != WEAPON_CARPARK && weaponid != WEAPON_UNKNOWN
	&& (!DamageArmourToggle[0] || (DamageArmour[weaponid][0] && (!DamageArmourToggle[1] || ((DamageArmour[weaponid][1] && bodypart == 3) || (!DamageArmour[weaponid][1])))))) 
	{
		if (amount <= 0.0) 
		{
			amount = PlayerHealth[playerid] + PlayerArmour[playerid];
		}

		PlayerArmour[playerid] -= amount;
	} else {
		if (amount <= 0.0) 
		{
			amount = PlayerHealth[playerid];
		}

		PlayerHealth[playerid] -= amount;
	}

	if (PlayerArmour[playerid] < 0.0) 
	{
		DamageDoneArmour[playerid] = amount + PlayerArmour[playerid];
		DamageDoneHealth[playerid] = -PlayerArmour[playerid];
		PlayerHealth[playerid] += PlayerArmour[playerid];
		PlayerArmour[playerid] = 0.0;
	} 
	else 
	{
		DamageDoneArmour[playerid] = amount;
		DamageDoneHealth[playerid] = 0.0;
	}

	if (PlayerHealth[playerid] <= 0.0) {
		amount += PlayerHealth[playerid];
		DamageDoneHealth[playerid] += PlayerHealth[playerid];
		PlayerHealth[playerid] = 0.0;
	}

	OnPlayerDamageDone(playerid, amount, issuerid, weaponid, bodypart);
	new animlib[32] = "PED", animname[32];

	if (PlayerHealth[playerid] <= 0.0005) {
		new vehicleid = GetPlayerVehicleID(playerid);

		if (vehicleid) {
			new modelid = GetVehicleModel(vehicleid);
			new seat = GetPlayerVehicleSeat(playerid);

			TogglePlayerControllable(playerid, false);

			switch (modelid) 
			{
				case 509, 481, 510, 462, 448, 581, 522,
				     461, 521, 523, 463, 586, 468, 471: 
				{
					new Float:vx, Float:vy, Float:vz;
					GetVehicleVelocity(vehicleid, vx, vy, vz);

					if (vx * vx + vy * vy + vz * vz >= 0.4) {
						animname = "BIKE_fallR";
						PlayerDeath(playerid, animlib, animname, false);
					} else {
						animname = "BIKE_fall_off";
						PlayerDeath(playerid, animlib, animname, false);
					}
				}

				default: 
				{
					if (seat & 1) {
						animname = "CAR_dead_LHS";
						PlayerDeath(playerid, animlib, animname);
					} else {
						animname = "CAR_dead_RHS";
						PlayerDeath(playerid, animlib, animname);
					}
				}
			}
		} else if (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) {
			animname = "KO_skid_back";
			PlayerDeath(playerid, animlib, animname, .freeze_sync = false);
		} else {
			if (gettime() - LastVehicleEnterTime[playerid] < 10) {
				TogglePlayerControllable(playerid, false);
			}

			new anim = GetPlayerAnimationIndex(playerid);

			if (anim == 1250 || (1538 <= anim <= 1544) || weaponid == WEAPON_DROWN) {
				// In water
				animname = "Drown";
				PlayerDeath(playerid, animlib, animname);
			} else if (1195 <= anim <= 1198) {
				// Jumping animation
				animname = "KO_skid_back";
				PlayerDeath(playerid, animlib, animname);
			} else if (WEAPON_SHOTGUN <= weaponid <= WEAPON_SHOTGSPA) {
				if (IsPlayerBehindPlayer(issuerid, playerid)) {
					animname = "KO_shot_front";
					MakePlayerFacePlayer(playerid, issuerid, true);
					PlayerDeath(playerid, animlib, animname);
				} else {
					animname = "BIKE_fall_off";
					MakePlayerFacePlayer(playerid, issuerid);
					PlayerDeath(playerid, animlib, animname);
				}
			} else if (WEAPON_RIFLE <= weaponid <= WEAPON_SNIPER) {
				if (bodypart == 9) {
					animname = "KO_shot_face";
					PlayerDeath(playerid, animlib, animname);
				} else if (IsPlayerBehindPlayer(issuerid, playerid)) {
					animname = "KO_shot_front";
					PlayerDeath(playerid, animlib, animname);
				} else {
					animname = "KO_shot_stom";
					PlayerDeath(playerid, animlib, animname);
				}
			} else if (IsBulletWeapon(weaponid)) {
				if (bodypart == 9) {
					animname = "KO_shot_face";
					PlayerDeath(playerid, animlib, animname);
				} else {
					animname = "KO_shot_front";
					PlayerDeath(playerid, animlib, animname);
				}
			} else if (weaponid == WEAPON_PISTOLWHIP) {
				animname = "KO_spin_R";
				PlayerDeath(playerid, animlib, animname);
			} else if (weaponid == WEAPON_CARPARK || IsMeleeWeapon(weaponid) && weaponid != WEAPON_CHAINSAW) {
				animname = "KO_skid_front";
				PlayerDeath(playerid, animlib, animname);
			} else if (weaponid == WEAPON_SPRAYCAN || weaponid == WEAPON_FIREEXTINGUISHER) {
				animlib = "KNIFE", animname = "KILL_Knife_Ped_Die";
				PlayerDeath(playerid, animlib, animname);
			} else {
				animname = "KO_skid_back";
				PlayerDeath(playerid, animlib, animname);
			}
		}

		if (CbugAllowed[playerid]) {
			OnPlayerDeath(playerid, issuerid, weaponid);
		} else {
			DelayedDeathTimer[playerid] = SetTimerEx(#DelayedDeath, 1200, false, "iii", playerid, issuerid, weaponid);
		}
	}

	UpdateHealthBar(playerid);
}

forward DelayedDeath(playerid, issuerid, WEAPON:reason);
public DelayedDeath(playerid, issuerid, WEAPON:reason) {
	DelayedDeathTimer[playerid] = 0;

	OnPlayerDeath(playerid, issuerid, reason);
}

stock PlayerDeath(playerid, animlib[32], animname[32], bool:anim_lock = false, respawn_time = -1, bool:freeze_sync = true, bool:anim_freeze = true)
{
	PlayerHealth[playerid] = 0.0;
	PlayerArmour[playerid] = 0.0;
	IsDying[playerid] = true;

	LastDeathTick[playerid] = GetTickCount();

	new SPECIAL_ACTION:action = GetPlayerSpecialAction(playerid);

	if (action != SPECIAL_ACTION_NONE && action != SPECIAL_ACTION_DUCK) {
		if (action == SPECIAL_ACTION_USEJETPACK) {
			ClearAnimations(playerid);
		}

		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);

		if (action == SPECIAL_ACTION_USEJETPACK) {
			new Float:vx, Float:vy, Float:vz;
			GetPlayerVelocity(playerid, vx, vy, vz);
			SetPlayerVelocity(playerid, vx, vy, vz);
		}
	}

	OnPlayerPrepareDeath(playerid, animlib, animname, anim_lock, respawn_time);

	UpdateHealthBar(playerid);
	FreezeSyncPacket(playerid, freeze_sync);

	if (respawn_time == -1) {
		respawn_time = RespawnTime;
	}

	if (animlib[0] && animname[0]) {
		ApplyAnimation(playerid, animlib, animname, 4.1, false, anim_lock, anim_lock, anim_freeze, 0, FORCE_SYNC:1);
	}

	if (DeathTimer[playerid]) {
		KillTimer(DeathTimer[playerid]);
	}

	DeathTimer[playerid] = SetTimerEx("PlayerDeathRespawn", respawn_time, false, "i", playerid);
}

public OnPlayerPrepareDeath(playerid, animlib[32], animname[32], &anim_lock, &respawn_time)
{
	return continue(playerid, animlib, animname, anim_lock, respawn_time);
}

public OnRejectedHit(playerid, hit[E_REJECTED_HIT])
{
	OnRejectedHit(playerid, hit);
}

public OnPlayerDeathFinished(playerid, bool:cancelable)
{
	if (PlayerHealth[playerid] == 0.0) {
		PlayerHealth[playerid] = PlayerMaxHealth[playerid];
	}

	if (DeathTimer[playerid]) {
		KillTimer(DeathTimer[playerid]);
		DeathTimer[playerid] = 0;
	}

	new retval = OnPlayerDeathFinished(playerid, cancelable);

	if (!retval && cancelable) {
		return 0;
	}

	ResetPlayerWeapons(playerid);

	return 1;
}

stock SaveSyncData(playerid)
{
	GetPlayerHealth(playerid, SyncData[playerid][e_Health]);
	GetPlayerArmour(playerid, SyncData[playerid][e_Armour]);

	GetPlayerPos(playerid, SyncData[playerid][e_PosX], SyncData[playerid][e_PosY], SyncData[playerid][e_PosZ]);
	GetPlayerFacingAngle(playerid, SyncData[playerid][e_PosA]);

	SyncData[playerid][e_Skin] = GetPlayerSkin(playerid);
	SyncData[playerid][e_Team] = GetPlayerTeam(playerid);

	SyncData[playerid][e_Weapon] = GetPlayerWeapon(playerid);

	for (new WEAPON_SLOT:i; _:i < 13; i++) 
	{
		GetPlayerWeaponData(playerid, i, SyncData[playerid][e_WeaponId][i], SyncData[playerid][e_WeaponAmmo][i]);
	}
}

stock MakePlayerFacePlayer(playerid, targetid, opposite = false, forcesync = true)
{
	new Float:x1, Float:y1, Float:z1;
	new Float:x2, Float:y2, Float:z2;

	GetPlayerPos(playerid, x1, y1, z1);
	GetPlayerPos(targetid, x2, y2, z2);
	new Float:angle = AngleBetweenPoints(x2, y2, x1, y1);

	if (opposite) 
	{
		angle += 180.0;
		if (angle > 360.0) angle -= 360.0;
	}

	if (angle < 0.0) angle += 360.0;
	if (angle > 360.0) angle -= 360.0;

	SetPlayerFacingAngle(playerid, angle);

	if (forcesync) 
	{
		SetFakeFacingAngle(playerid, angle);
		UpdateSyncData(playerid);
	}
}

stock IsPlayerBehindPlayer(playerid, targetid, Float:diff = 90.0)
{
	new Float:x1, Float:y1, Float:z1;
	new Float:x2, Float:y2, Float:z2;
	new Float:ang, Float:angdiff;

	GetPlayerPos(playerid, x1, y1, z1);
	GetPlayerPos(targetid, x2, y2, z2);
	GetPlayerFacingAngle(targetid, ang);

	angdiff = AngleBetweenPoints(x1, y1, x2, y2);

	if (angdiff < 0.0) angdiff += 360.0;
	if (angdiff > 360.0) angdiff -= 360.0;

	ang = ang - angdiff;

	if (ang > 180.0) ang -= 360.0;
	if (ang < -180.0) ang += 360.0;

	return floatabs(ang) > diff;
}

stock AddRejectedHit(playerid, damagedid, reason, WEAPON:weapon, i1 = 0, i2 = 0, i3 = 0)
{
	if (0 <= playerid < MAX_PLAYERS) 
	{
		new idx = RejectedHitsIdx[playerid];

		if (RejectedHits[playerid][idx][e_Time]) 
		{
			idx += 1;

			if (idx >= sizeof(RejectedHits[])) 
			{
				idx = 0;
			}

			RejectedHitsIdx[playerid] = idx;
		}

		new time, hour, minute, second;

		time = gettime(hour, minute, second);

		RejectedHits[playerid][idx][e_Reason] = reason;
		RejectedHits[playerid][idx][e_Time] = time;
		RejectedHits[playerid][idx][e_Weapon] = weapon;
		RejectedHits[playerid][idx][e_Hour] = hour;
		RejectedHits[playerid][idx][e_Minute] = minute;
		RejectedHits[playerid][idx][e_Second] = second;
		RejectedHits[playerid][idx][e_Info1] = _:i1;
		RejectedHits[playerid][idx][e_Info2] = _:i2;
		RejectedHits[playerid][idx][e_Info3] = _:i3;

		if (0 <= damagedid < MAX_PLAYERS) 
		{
			GetPlayerName(damagedid, RejectedHits[playerid][idx][e_Name], MAX_PLAYER_NAME);
		} else {
			RejectedHits[playerid][idx][e_Name][0] = '#';
			RejectedHits[playerid][idx][e_Name][1] = '\0';
		}

		OnRejectedHit(playerid, RejectedHits[playerid][idx]);
	}
}

stock SpawnPlayerForWorld(playerid)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	new BitStream:bs = BS_New();

	BS_WriteValue(bs, PR_UINT32, playerid);

	foreach (new i : Player) {
		if (i != playerid) {
			PR_SendRPC(bs, i, RPC_REQUEST_SPAWN);
		}
	}

	BS_Delete(bs);

	return 1;
}

stock FreezeSyncPacket(playerid, bool:toggle)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	LastSyncData[playerid][PR_keys] = 0;
	LastSyncData[playerid][PR_udKey] = 0;
	LastSyncData[playerid][PR_lrKey] = 0;
	LastSyncData[playerid][PR_specialAction] = SPECIAL_ACTION_NONE;
	LastSyncData[playerid][PR_velocity][0] = 0.0;
	LastSyncData[playerid][PR_velocity][1] = 0.0;
	LastSyncData[playerid][PR_velocity][2] = 0.0;

	SyncDataFrozen[playerid] = toggle;

	return 1;
}

stock SetFakeHealth(playerid, health)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	FakeHealth{playerid} = health;

	return 1;
}

stock SetFakeArmour(playerid, armour)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	FakeArmour{playerid} = armour;

	return 1;
}

stock GetRotationQuaternion(Float:x, Float:y, Float:z, &Float:qw, &Float:qx, &Float:qy, &Float:qz)
{
	new
		Float:cx = floatcos(-0.5 * x, degrees),
		Float:sx = floatsin(-0.5 * x, degrees),
		Float:cy = floatcos(-0.5 * y, degrees),
		Float:sy = floatsin(-0.5 * y, degrees),
		Float:cz = floatcos(-0.5 * z, degrees),
		Float:sz = floatsin(-0.5 * z, degrees);

	qw = cx * cy * cz + sx * sy * sz;
	qx = cx * sy * sz + sx * cy * cz;
	qy = cx * sy * cz - sx * cy * sz;
	qz = cx * cy * sz - sx * sy * cz;
}

stock SetFakeFacingAngle(playerid, Float:angle = Float:0x7FFFFFFF)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	if (angle != angle) {
		FakeQuat[playerid][0] = Float:0x7FFFFFFF;
		FakeQuat[playerid][1] = Float:0x7FFFFFFF;
		FakeQuat[playerid][2] = Float:0x7FFFFFFF;
		FakeQuat[playerid][3] = Float:0x7FFFFFFF;
	} else {
		GetRotationQuaternion(0.0, 0.0, angle, FakeQuat[playerid][0], FakeQuat[playerid][1], FakeQuat[playerid][2], FakeQuat[playerid][3]);
	}

	return 1;
}

stock SendLastSyncPacket(playerid, toplayerid, animation = 0)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerConnected(toplayerid)) {
		return 0;
	}

	new BitStream:bs = BS_New();

	BS_WriteValue(bs, PR_UINT8, PLAYER_SYNC, PR_UINT16, playerid);

	if (FakeQuat[playerid][0] == FakeQuat[playerid][0]) {
		LastSyncData[playerid][PR_quaternion] = FakeQuat[playerid];
	}

	if (FakeHealth{playerid} != 255) {
		LastSyncData[playerid][PR_health] = FakeHealth{playerid};
	}

	if (FakeArmour{playerid} != 255) {
		LastSyncData[playerid][PR_armour] = FakeArmour{playerid};
	}

	// Make them appear standing still if paused
	if (IsPlayerPaused(playerid)) {
		LastSyncData[playerid][PR_velocity][0] = 0.0;
		LastSyncData[playerid][PR_velocity][1] = 0.0;
		LastSyncData[playerid][PR_velocity][2] = 0.0;
	}

	// Animations are only sent when they are changed
	if (!animation) {
		LastSyncData[playerid][PR_animationId] = 0;
		LastSyncData[playerid][PR_animationFlags] = 0;
	}

	BS_WriteOnFootSync(bs, LastSyncData[playerid], true);
	PR_SendPacket(bs, toplayerid, _, PR_RELIABLE_SEQUENCED);
	BS_Delete(bs);

	return 1;
}

stock ClearAnimationsForPlayer(playerid, forplayerid)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerConnected(forplayerid)) {
		return 0;
	}

	new BitStream:bs = BS_New();

	BS_WriteValue(bs, PR_UINT16, playerid);
	PR_SendRPC(bs, forplayerid, RPC_CLEAR_ANIMATIONS);
	BS_Delete(bs);

	return 1;
}

forward SecondKnifeAnim(playerid);
public SecondKnifeAnim(playerid)
{
	new animlib[] = "KNIFE", animname[] = "KILL_Knife_Ped_Die";
	ApplyAnimation(playerid, animlib, animname, 4.1, false, true, true, true, 3000, FORCE_SYNC:1);
}

forward PlayerDeathRespawn(playerid);
public PlayerDeathRespawn(playerid)
{
	if (!IsDying[playerid]) {
		return;
	}

	IsDying[playerid] = false;

	if (!OnPlayerDeathFinished(playerid, true)) {
		UpdateHealthBar(playerid);
		SetFakeFacingAngle(playerid, _);
		FreezeSyncPacket(playerid, false);

		return;
	}

	IsDying[playerid] = true;
	TrueDeath[playerid] = false;

	if (IsPlayerInAnyVehicle(playerid)) {
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetPlayerPos(playerid, x, y, z);
	}

	SetPlayerVirtualWorld(playerid, DEATH_WORLD);
	SetFakeFacingAngle(playerid, _);
	TogglePlayerSpectating(playerid, true);
	TogglePlayerSpectating(playerid, false);
}

public OnInvalidWeaponDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart, error, bool:given)
{
	OnInvalidWeaponDamage(playerid, damagedid, Float:amount, weaponid, bodypart, error, bool:given);
}

public OnPlayerDamageDone(playerid, Float:amount, issuerid, WEAPON:weapon, bodypart)
{
	new idx = PreviousHitI[playerid];

	PreviousHitI[playerid] = (PreviousHitI[playerid] - 1) % sizeof(PreviousHits[]);

	// JIT plugin fix
	if (PreviousHitI[playerid] < 0) {
		PreviousHitI[playerid] += sizeof(PreviousHits[]);
	}

	PreviousHits[playerid][idx][e_Tick] = GetTickCount();
	PreviousHits[playerid][idx][e_Issuer] = issuerid;
	PreviousHits[playerid][idx][e_Weapon] = weapon;
	PreviousHits[playerid][idx][e_Amount] = amount;
	PreviousHits[playerid][idx][e_Bodypart] = bodypart;
	PreviousHits[playerid][idx][e_Health] = DamageDoneHealth[playerid];
	PreviousHits[playerid][idx][e_Armour] = DamageDoneArmour[playerid];

	if (!IsHighRateWeapon(weapon)) {
		if (DamageTakenSound) {
			PlayerPlaySound(playerid, DamageTakenSound, 0.0, 0.0, 0.0);

			foreach (new i : Player) {
				if (Spectating[i] == playerid && i != playerid) {
					PlayerPlaySound(i, DamageTakenSound, 0.0, 0.0, 0.0);
				}
			}
		}

		if (DamageGivenSound && issuerid != INVALID_PLAYER_ID) {
			PlayerPlaySound(issuerid, DamageGivenSound, 0.0, 0.0, 0.0);

			foreach (new i : Player) {
				if (Spectating[i] == issuerid && i != issuerid) {
					PlayerPlaySound(i, DamageGivenSound, 0.0, 0.0, 0.0);
				}
			}
		}
	}

	OnPlayerDamageDone(playerid, amount, issuerid, weapon, bodypart);
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &WEAPON:weapon, &bodypart)
{
	return continue(playerid, amount, issuerid, weapon, bodypart);
}