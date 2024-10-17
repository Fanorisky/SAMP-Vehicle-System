// Print debug messages in the chat and server log
#if !defined W_DEBUG
	#define W_DEBUG false
#endif

// Print debug messages to the console but not the chat
#if !defined W_DEBUG_SILENT
	#define W_DEBUG_SILENT false
#endif

// Max number of rejected hits (GetRejectedHit)
#if !defined W_MAX_REJECTED_HITS
	#define W_MAX_REJECTED_HITS 15
#endif

// Max ranges for DAMAGE_TYPE_RANGE(_MULTIPLIER)
#if !defined W_MAX_DAMAGE_RANGES
	#define W_MAX_DAMAGE_RANGES 5
#endif

// The world a player has after the death animation finished until he respawns or enters class selection
#if !defined W_DEATH_WORLD
	#define W_DEATH_WORLD 0x00DEAD00
#endif

// For SetWeaponName
#if !defined W_MAX_WEAPON_NAME
	#define W_MAX_WEAPON_NAME 21
#endif

// Pre-hooks for hooking callbacks
#if !defined CHAIN_ORDER
	#define CHAIN_ORDER() 0
#endif

#define CHAIN_HOOK(%0) forward @CO_%0();public @CO_%0(){return CHAIN_ORDER()+1;}
#define CHAIN_NEXT(%0) @CO_%0

#define CHAIN_FORWARD:%0_%2(%1)=%3; \
	forward %0_%2(%1); \
	public %0_%2(%1) <_ALS : _ALS_x0, _ALS : _ALS_x1> { return (%3); } \
	public %0_%2(%1) <> { return (%3); }

#define CHAIN_PUBLIC:%0(%1) %0(%1) <_ALS : _ALS_go>

CHAIN_HOOK(WC)
#undef CHAIN_ORDER
#define CHAIN_ORDER CHAIN_NEXT(WC)

static stock _W_IncludeStates() <_ALS : _ALS_x0, _ALS : _ALS_x1, _ALS : _ALS_x2, _ALS : _ALS_x3> {}
static stock _W_IncludeStates() <_ALS : _ALS_go> {}

// Provides a way for const correctness support
// when used with the newer standard libraries
// https://github.com/sampctl/samp-stdlib/
// https://github.com/sampctl/pawn-stdlib

#if !defined BULLET_HIT_TYPE
	#define BULLET_HIT_TYPE: _:
#endif
#if !defined FORCE_SYNC
	#define FORCE_SYNC: _:
#endif
#if !defined KEY
	#define KEY: _:
#endif
#if !defined PLAYER_STATE
	#define PLAYER_STATE: _:
#endif
#if !defined SPECIAL_ACTION
	#define SPECIAL_ACTION: _:
#endif
#if !defined SPECTATE_MODE
	#define SPECTATE_MODE: _:
#endif
#if !defined WEAPON
	#define WEAPON: _:
#endif
#if !defined WEAPON_SLOT
	#define WEAPON_SLOT: _:
#endif

#define Weapon:: S_ //Weapon Data Namespace

#define BODY_PART_TORSO                 (3)
#define BODY_PART_GROIN                 (4)
#define BODY_PART_RIGHT_ARM             (6)
#define BODY_PART_LEFT_ARM              (5)
#define BODY_PART_RIGHT_LEG             (8)
#define BODY_PART_LEFT_LEG              (7)
#define BODY_PART_HEAD                  (9)

//Function Prototype
forward OnPlayerShootHead(playerid, targetid, Float:amount, weaponid);
forward OnPlayerShootTorso(playerid, targetid, Float:amount, weaponid);
forward OnPlayerShootRightArm(playerid, targetid, Float:amount, weaponid);
forward OnPlayerShootLeftArm(playerid, targetid, Float:amount, weaponid);
forward OnPlayerShootRightLeg(playerid, targetid, Float:amount, weaponid);
forward OnPlayerShootLeftLeg(playerid, targetid, Float:amount, weaponid);
forward OnPlayerShootGroin(playerid, targetid, Float:amount, weaponid);
forward OnPlayerFall(playerid, Float:damage);

// Given in OnInvalidWeaponDamage
enum 
{
	W_NO_ERROR,
	W_NO_ISSUER,
	W_NO_DAMAGED,
	W_INVALID_DAMAGE,
	W_INVALID_DISTANCE
}

// Used in SetWeaponDamage
enum {
	DAMAGE_TYPE_MULTIPLIER,
	DAMAGE_TYPE_STATIC,
	DAMAGE_TYPE_RANGE_MULTIPLIER,
	DAMAGE_TYPE_RANGE
}

// Given in OnRejectedHit
enum E_REJECTED_HIT {
		   e_Time,
		   e_Hour,
		   e_Minute,
		   e_Second,
	WEAPON:e_Weapon,
		   e_Reason,
		   e_Info1,
		   e_Info2,
		   e_Info3,
		   e_Name[MAX_PLAYER_NAME]
}

// e_Reason in E_REJECTED_HIT
enum {
	HIT_NO_DAMAGEDID,
	HIT_INVALID_WEAPON,
	HIT_LAST_SHOT_INVALID,
	HIT_MULTIPLE_PLAYERS,
	HIT_MULTIPLE_PLAYERS_SHOTGUN,
	HIT_DYING_PLAYER,
	HIT_SAME_TEAM,
	HIT_UNSTREAMED,
	HIT_INVALID_HITTYPE,
	HIT_BEING_RESYNCED,
	HIT_NOT_SPAWNED,
	HIT_OUT_OF_RANGE,
	HIT_TOO_FAR_FROM_SHOT,
	SHOOTING_RATE_TOO_FAST,
	SHOOTING_RATE_TOO_FAST_MULTIPLE,
	HIT_RATE_TOO_FAST,
	HIT_RATE_TOO_FAST_MULTIPLE,
	HIT_TOO_FAR_FROM_ORIGIN,
	HIT_INVALID_DAMAGE,
	HIT_SAME_VEHICLE,
	HIT_OWN_VEHICLE,
	HIT_INVALID_VEHICLE,
	HIT_DISCONNECTED
}

// Must be in sync with the enum above
// Used in debug messages and GetRejectedHit
stock const g_HitRejectReasons[][] = {
	"None or invalid player shot",
	"Invalid weapon",
	"Last shot invalid",
	"One bullet hit %d players",
	"Hit too many players with shotgun: %d",
	"Hit a dying player",
	"Hit a teammate",
	"Hit someone that can't see you (not streamed in)",
	"Invalid hit type: %d",
	"Hit while being resynced",
	"Hit when not spawned or dying",
	"Hit out of range (%f > %f)",
	"Hit player too far from hit position (dist %f)",
	"Shooting rate too fast: %d (%d samples, max %d)",
	"Shooting rate too fast: %d (%d samples, multiple weapons)",
	"Hit rate too fast: %d (%d samples, max %d)",
	"Hit rate too fast: %d (%d samples, multiple weapons)",
	"Damage inflicted too far from current position (dist %f)",
	"Invalid weapon damage (%.4f)",
	"Hit a player in the same vehicle",
	"Hit the vehicle you're in",
	"Hit invalid vehicle: %d",
	"Hit a disconnected player ID: %d"
};

// Used to resync players that got team-knifed in lagshot mode
enum E_RESYNC_DATA {
	 Float:e_Health,
	 Float:e_Armour,
		   e_Skin,
		   e_Team,
	 Float:e_PosX,
	 Float:e_PosY,
	 Float:e_PosZ,
	 Float:e_PosA,
	WEAPON:e_Weapon,
	WEAPON:e_WeaponId[13],
		   e_WeaponAmmo[13]
}

// From OnPlayerWeaponShot
enum E_SHOT_INFO {
	       e_Tick,
	WEAPON:e_Weapon,
	       e_HitType,
	       e_HitId,
	       e_Hits,
	 Float:e_X,
	 Float:e_Y,
	 Float:e_Z,
	 Float:e_OX,
	 Float:e_OY,
	 Float:e_OZ,
	 Float:e_HX,
	 Float:e_HY,
	 Float:e_HZ,
	 Float:e_Length,
	  bool:e_Valid
}

enum E_HIT_INFO {
	       e_Tick,
	       e_Issuer,
	WEAPON:e_Weapon,
	 Float:e_Amount,
	 Float:e_Health,
	 Float:e_Armour,
	       e_Bodypart
}

enum E_SPAWN_INFO {
		   e_Skin,
		   e_Team,
	 Float:e_PosX,
	 Float:e_PosY,
	 Float:e_PosZ,
	 Float:e_Rot,
	WEAPON:e_Weapon1,
		   e_Ammo1,
	WEAPON:e_Weapon2,
		   e_Ammo2,
	WEAPON:e_Weapon3,
		   e_Ammo3
}

// When a player takes or gives invalid damage (W_* errors above)
forward OnInvalidWeaponDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart, error, bool:given);
// Before damage is inflicted
forward OnPlayerDamage(&playerid, &Float:amount, &issuerid, &WEAPON:weapon, &bodypart);
// After OnPlayerDamage
forward OnPlayerDamageDone(playerid, Float:amount, issuerid, WEAPON:weapon, bodypart);
// Before the death animation is applied
forward OnPlayerPrepareDeath(playerid, animlib[32], animname[32], &anim_lock, &respawn_time);
// When the death animation is finished and the player has been sent to respawn
forward OnPlayerDeathFinished(playerid, bool:cancelable);
// When a shot or damage given is rejected
forward OnRejectedHit(playerid, hit[E_REJECTED_HIT]);

// If you have your own definitions, remove them and use these instead
#define BODY_PART_UNKNOWN 0
#define WEAPON_UNARMED (WEAPON:0)
#define WEAPON_VEHICLE_M4 (WEAPON:19)
#define WEAPON_VEHICLE_MINIGUN (WEAPON:20)
#define WEAPON_VEHICLE_ROCKETLAUNCHER (WEAPON:21)
#define WEAPON_PISTOLWHIP (WEAPON:48)
#define WEAPON_HELIBLADES (WEAPON:50)
#define WEAPON_EXPLOSION (WEAPON:51)
#define WEAPON_CARPARK (WEAPON:52)
#define WEAPON_UNKNOWN (WEAPON:55)

#if defined W_DEBUG
	static Weapon::DebugMsgBuf[512];

	#define DebugMessage(%1) format(Weapon::DebugMsgBuf,512,"(wc) " %1), SendClientMessageToAll(-1,Weapon::DebugMsgBuf), printf("(wc) " %1)

	#define DebugMessageRed(%1) format(Weapon::DebugMsgBuf,512,"(wc) " %1), SendClientMessageToAll(0xcc0000ff,Weapon::DebugMsgBuf), printf("(wc) WARN: " %1)
#else
	#define DebugMessage(%1);
	#define DebugMessageRed(%1);
#endif

#define RATING_TORSO      0
#define RATING_GROIN      1
#define RATING_LEFT_ARM   2
#define RATING_RIGHT_ARM  3
#define RATING_LEFT_LEG   4
#define RATING_RIGHT_LEG  5

new Float:FitnessRating[MAX_PLAYERS][6];

stock Float:GetOverallFitnessRating(playerid)
{
    return (FitnessRating[playerid][0]+FitnessRating[playerid][1]+FitnessRating[playerid][2]+FitnessRating[playerid][3]+FitnessRating[playerid][4]+FitnessRating[playerid][5])/6;
}

// Weapons Slot Types : -1 (Invalid/Ilegal), 0 (Melee), 1 (Utility), 2 (Primary), 3 (Secondary)
static const Weapon::WeaponType[] = {
	0, // 0 - Fist
	0, // 1 - Brass knuckles
	0, // 2 - Golf club
	0, // 3 - Nitestick
	0, // 4 - Knife
	0, // 5 - Bat
	0, // 6 - Shovel
	0, // 7 - Pool cue
	0, // 8 - Katana
	0, // 9 - Chainsaw
	0, // 10 - Dildo
	0, // 11 - Dildo 2
	0, // 12 - Vibrator
	0, // 13 - Vibrator 2
	0, // 14 - Flowers
	0, // 15 - Cane
	-1, // 16 - Grenade
	-1, // 17 - Teargas
	-1, // 18 - Molotov
	-1, // 19 - Vehicle M4 (custom)
	-1, // 20 - Vehicle minigun (custom)
	-1, // 21 - Vehicle rocket (custom)
	3, // 22 - Colt 45
	3, // 23 - Silenced
	3, // 24 - Deagle
	2, // 25 - Shotgun
	2, // 26 - Sawed-off
	2, // 27 - Spas
	2, // 28 - UZI
	2, // 29 - MP5
	2, // 30 - AK47
	2, // 31 - M4
	2, // 32 - Tec9
	2, // 33 - Cuntgun
	2, // 34 - Sniper
	2, // 35 - Rocket launcher
	2, // 36 - Heatseeker
	2, // 37 - Flamethrower
	2, // 38 - Minigun
	-1, // 39 - Satchel
	-1, // 40 - Detonator
	1, // 41 - Spraycan
	1, // 42 - Fire extinguisher
	1, // 43 - Camera
	-1, // 44 - Night vision
	-1, // 45 - Infrared
	-1  // 46 - Parachute
};

// Weapons allowed in OnPlayerGiveDamage
static const Weapon::ValidDamageGiven[] = {
	1, // 0 - Fist
	1, // 1 - Brass knuckles
	1, // 2 - Golf club
	1, // 3 - Nitestick
	1, // 4 - Knife
	1, // 5 - Bat
	1, // 6 - Shovel
	1, // 7 - Pool cue
	1, // 8 - Katana
	1, // 9 - Chainsaw
	1, // 10 - Dildo
	1, // 11 - Dildo 2
	1, // 12 - Vibrator
	1, // 13 - Vibrator 2
	1, // 14 - Flowers
	1, // 15 - Cane
	0, // 16 - Grenade
	0, // 17 - Teargas
	0, // 18 - Molotov
	0, // 19 - Vehicle M4 (custom)
	0, // 20 - Vehicle minigun (custom)
	0, // 21 - Vehicle rocket (custom)
	1, // 22 - Colt 45
	1, // 23 - Silenced
	1, // 24 - Deagle
	1, // 25 - Shotgun
	1, // 26 - Sawed-off
	1, // 27 - Spas
	1, // 28 - UZI
	1, // 29 - MP5
	1, // 30 - AK47
	1, // 31 - M4
	1, // 32 - Tec9
	1, // 33 - Cuntgun
	1, // 34 - Sniper
	0, // 35 - Rocket launcher
	0, // 36 - Heatseeker
	0, // 37 - Flamethrower
	1, // 38 - Minigun
	0, // 39 - Satchel
	0, // 40 - Detonator
	1, // 41 - Spraycan
	1, // 42 - Fire extinguisher
	0, // 43 - Camera
	0, // 44 - Night vision
	0, // 45 - Infrared
	1  // 46 - Parachute
};

// Weapons allowed in OnPlayerTakeDamage
// 2 = valid in both OnPlayerGiveDamage and OnPlayerTakeDamage
static const Weapon::ValidDamageTaken[] = {
	1, // 0 - Fist
	1, // 1 - Brass knuckles
	1, // 2 - Golf club
	1, // 3 - Nitestick
	1, // 4 - Knife
	1, // 5 - Bat
	1, // 6 - Shovel
	1, // 7 - Pool cue
	1, // 8 - Katana
	1, // 9 - Chainsaw
	1, // 10 - Dildo
	1, // 11 - Dildo 2
	1, // 12 - Vibrator
	1, // 13 - Vibrator 2
	1, // 14 - Flowers
	1, // 15 - Cane
	0, // 16 - Grenade
	0, // 17 - Teargas
	0, // 18 - Molotov
	0, // 19 - Vehicle M4 (custom)
	0, // 20 - Vehicle minigun (custom)
	0, // 21 - Vehicle rocket (custom)
	1, // 22 - Colt 45
	1, // 23 - Silenced
	1, // 24 - Deagle
	1, // 25 - Shotgun
	1, // 26 - Sawed-off
	1, // 27 - Spas
	1, // 28 - UZI
	1, // 29 - MP5
	1, // 30 - AK47
	1, // 31 - M4
	1, // 32 - Tec9
	1, // 33 - Cuntgun
	1, // 34 - Sniper
	0, // 35 - Rocket launcher
	0, // 36 - Heatseeker
	2, // 37 - Flamethrower
	1, // 38 - Minigun
	0, // 39 - Satchel
	0, // 40 - Detonator
	1, // 41 - Spraycan
	1, // 42 - Fire extinguisher
	0, // 43 - Camera
	0, // 44 - Night vision
	0, // 45 - Infrared
	1, // 46 - Parachute
	0, // 47 - Fake pistol
	0, // 48 - Pistol whip (custom)
	2, // 49 - Vehicle
	2, // 50 - Helicopter blades
	2, // 51 - Explosion
	0, // 52 - Car park (custom)
	2, // 53 - Drowning
	2  // 54 - Splat
};

// Default weapon damage. Connected to Weapon::DamageType.
// Melee weapons are multipliers because the damage differs
// depending on type of punch/kick and fight style.
static Float:Weapon::WeaponDamage[] = {
	1.0, // 0 - Fist
	1.0, // 1 - Brass knuckles
	1.0, // 2 - Golf club
	1.0, // 3 - Nitestick
	1.0, // 4 - Knife
	1.0, // 5 - Bat
	1.0, // 6 - Shovel
	1.0, // 7 - Pool cue
	1.0, // 8 - Katana
	1.0, // 9 - Chainsaw
	1.0, // 10 - Dildo
	1.0, // 11 - Dildo 2
	1.0, // 12 - Vibrator
	1.0, // 13 - Vibrator 2
	1.0, // 14 - Flowers
	1.0, // 15 - Cane
	82.5, // 16 - Grenade
	0.0, // 17 - Teargas
	1.0, // 18 - Molotov
	9.9, // 19 - Vehicle M4 (custom)
	46.2, // 20 - Vehicle minigun (custom)
	82.5, // 21 - Vehicle rocket (custom)
	8.25, // 22 - Colt 45
	13.2, // 23 - Silenced
	46.2, // 24 - Deagle
	3.3, // 25 - Shotgun
	3.3, // 26 - Sawed-off
	4.95, // 27 - Spas
	6.6, // 28 - UZI
	8.25, // 29 - MP5
	9.9, // 30 - AK47
	9.9, // 31 - M4
	6.6, // 32 - Tec9
	24.75, // 33 - Cuntgun
	41.25, // 34 - Sniper
	82.5, // 35 - Rocket launcher
	82.5, // 36 - Heatseeker
	1.0, // 37 - Flamethrower
	46.2, // 38 - Minigun
	82.5, // 39 - Satchel
	0.0, // 40 - Detonator
	0.33, // 41 - Spraycan
	0.33, // 42 - Fire extinguisher
	0.0, // 43 - Camera
	0.0, // 44 - Night vision
	0.0, // 45 - Infrared
	0.0, // 46 - Parachute
	0.0, // 47 - Fake pistol
	2.64, // 48 - Pistol whip (custom)
	9.9, // 49 - Vehicle
	330.0, // 50 - Helicopter blades
	82.5, // 51 - Explosion
	1.0, // 52 - Car park (custom)
	1.0, // 53 - Drowning
	165.0  // 54 - Splat
};

#assert DAMAGE_TYPE_MULTIPLIER == 0
#assert DAMAGE_TYPE_STATIC == 1

// Whether the damage is multiplied by the given/taken value (0) or always the same value (1)
static Weapon::DamageType[] = {
	0, // 0 - Fist
	0, // 1 - Brass knuckles
	0, // 2 - Golf club
	0, // 3 - Nitestick
	0, // 4 - Knife
	0, // 5 - Bat
	0, // 6 - Shovel
	0, // 7 - Pool cue
	0, // 8 - Katana
	0, // 9 - Chainsaw
	0, // 10 - Dildo
	0, // 11 - Dildo 2
	0, // 12 - Vibrator
	0, // 13 - Vibrator 2
	0, // 14 - Flowers
	0, // 15 - Cane
	0, // 16 - Grenade
	1, // 17 - Teargas
	0, // 18 - Molotov
	1, // 19 - Vehicle M4 (custom)
	1, // 20 - Vehicle minigun (custom)
	0, // 21 - Vehicle rocket (custom)
	1, // 22 - Colt 45
	1, // 23 - Silenced
	1, // 24 - Deagle
	1, // 25 - Shotgun
	1, // 26 - Sawed-off
	1, // 27 - Spas
	1, // 28 - UZI
	1, // 29 - MP5
	1, // 30 - AK47
	1, // 31 - M4
	1, // 32 - Tec9
	1, // 33 - Cuntgun
	1, // 34 - Sniper
	0, // 35 - Rocket launcher
	0, // 36 - Heatseeker
	0, // 37 - Flamethrower
	1, // 38 - Minigun
	0, // 39 - Satchel
	0, // 40 - Detonator
	1, // 41 - Spraycan
	1, // 42 - Fire extinguisher
	0, // 43 - Camera
	0, // 44 - Night vision
	0, // 45 - Infrared
	0, // 46 - Parachute
	0, // 47 - Fake pistol
	1, // 48 - Pistol whip (custom)
	1, // 49 - Vehicle
	1, // 50 - Helicopter blades
	0, // 51 - Explosion
	0, // 52 - Car park (custom)
	0, // 53 - Drowning
	0  // 54 - Splat
};

// The default weapon range (from weapon.dat)
// Note that due to various bugs, these can be exceeded, but
// this include blocks out-of-range values.
static Float:Weapon::WeaponRange[] = {
	1.76, // 0 - Fist
	1.76, // 1 - Brass knuckles
	1.76, // 2 - Golf club
	1.76, // 3 - Nitestick
	1.76, // 4 - Knife
	1.76, // 5 - Bat
	1.6, // 6 - Shovel
	1.76, // 7 - Pool cue
	1.76, // 8 - Katana
	1.76, // 9 - Chainsaw
	1.76, // 10 - Dildo
	1.76, // 11 - Dildo 2
	1.76, // 12 - Vibrator
	1.76, // 13 - Vibrator 2
	1.76, // 14 - Flowers
	1.76, // 15 - Cane
	40.0, // 16 - Grenade
	40.0, // 17 - Teargas
	40.0, // 18 - Molotov
	90.0, // 19 - Vehicle M4 (custom)
	75.0, // 20 - Vehicle minigun (custom)
	0.0, // 21 - Vehicle rocket (custom)
	35.0, // 22 - Colt 45
	35.0, // 23 - Silenced
	35.0, // 24 - Deagle
	40.0, // 25 - Shotgun
	35.0, // 26 - Sawed-off
	40.0, // 27 - Spas
	35.0, // 28 - UZI
	45.0, // 29 - MP5
	70.0, // 30 - AK47
	90.0, // 31 - M4
	35.0, // 32 - Tec9
	100.0, // 33 - Cuntgun
	320.0, // 34 - Sniper
	55.0, // 35 - Rocket launcher
	55.0, // 36 - Heatseeker
	5.1, // 37 - Flamethrower
	75.0, // 38 - Minigun
	40.0, // 39 - Satchel
	25.0, // 40 - Detonator
	6.1, // 41 - Spraycan
	10.1, // 42 - Fire extinguisher
	100.0, // 43 - Camera
	100.0, // 44 - Night vision
	100.0, // 45 - Infrared
	1.76  // 46 - Parachute
};

// The fastest possible gap between weapon shots in milliseconds
static Weapon::MaxWeaponShootRate[] = {
	250, // 0 - Fist
	250, // 1 - Brass knuckles
	250, // 2 - Golf club
	250, // 3 - Nitestick
	250, // 4 - Knife
	250, // 5 - Bat
	250, // 6 - Shovel
	250, // 7 - Pool cue
	250, // 8 - Katana
	30, // 9 - Chainsaw
	250, // 10 - Dildo
	250, // 11 - Dildo 2
	250, // 12 - Vibrator
	250, // 13 - Vibrator 2
	250, // 14 - Flowers
	250, // 15 - Cane
	0, // 16 - Grenade
	0, // 17 - Teargas
	0, // 18 - Molotov
	90, // 19 - Vehicle M4 (custom)
	20, // 20 - Vehicle minigun (custom)
	0, // 21 - Vehicle rocket (custom)
	160, // 22 - Colt 45
	120, // 23 - Silenced
	120, // 24 - Deagle
	800, // 25 - Shotgun
	120, // 26 - Sawed-off
	120, // 27 - Spas
	50, // 28 - UZI
	90, // 29 - MP5
	90, // 30 - AK47
	90, // 31 - M4
	70, // 32 - Tec9
	800, // 33 - Cuntgun
	900, // 34 - Sniper
	0, // 35 - Rocket launcher
	0, // 36 - Heatseeker
	0, // 37 - Flamethrower
	20, // 38 - Minigun
	0, // 39 - Satchel
	0, // 40 - Detonator
	10, // 41 - Spraycan
	10, // 42 - Fire extinguisher
	0, // 43 - Camera
	0, // 44 - Night vision
	0, // 45 - Infrared
	0, // 46 - Parachute
	0, // 47 - Fake pistol
	400 // 48 - Pistol whip (custom)
};

// Whether the damage is applied directly to health (1) or is distributed between health and armour (0), and whether this rule applies only to the torso (1) or not (0)
static Weapon::DamageArmour[][2] = {
	{0, 0}, // 0 - Fist
	{0, 0}, // 1 - Brass knuckles
	{0, 0}, // 2 - Golf club
	{0, 0}, // 3 - Nitestick
	{0, 0}, // 4 - Knife
	{0, 0}, // 5 - Bat
	{0, 0}, // 6 - Shovel
	{0, 0}, // 7 - Pool cue
	{0, 0}, // 8 - Katana
	{0, 0}, // 9 - Chainsaw
	{0, 0}, // 10 - Dildo
	{0, 0}, // 11 - Dildo 2
	{0, 0}, // 12 - Vibrator
	{0, 0}, // 13 - Vibrator 2
	{0, 0}, // 14 - Flowers
	{0, 0}, // 15 - Cane
	{0, 0}, // 16 - Grenade
	{0, 0}, // 17 - Teargas
	{0, 0}, // 18 - Molotov
	{1, 1}, // 19 - Vehicle M4 (custom)
	{1, 1}, // 20 - Vehicle minigun (custom)
	{0, 0}, // 21 - Vehicle rocket (custom)
	{1, 1}, // 22 - Colt 45
	{1, 1}, // 23 - Silenced
	{1, 1}, // 24 - Deagle
	{1, 1}, // 25 - Shotgun
	{1, 1}, // 26 - Sawed-off
	{1, 1}, // 27 - Spas
	{1, 1}, // 28 - UZI
	{1, 1}, // 29 - MP5
	{1, 1}, // 30 - AK47
	{1, 1}, // 31 - M4
	{1, 1}, // 32 - Tec9
	{1, 1}, // 33 - Cuntgun
	{1, 1}, // 34 - Sniper
	{0, 0}, // 35 - Rocket launcher
	{0, 0}, // 36 - Heatseeker
	{0, 0}, // 37 - Flamethrower
	{1, 1}, // 38 - Minigun
	{0, 0}, // 39 - Satchel
	{0, 0}, // 40 - Detonator
	{0, 0}, // 41 - Spraycan
	{0, 0}, // 42 - Fire extinguisher
	{1, 0}, // 43 - Camera
	{1, 0}, // 44 - Night vision
	{1, 0}, // 45 - Infrared
	{1, 0}, // 46 - Parachute
	{1, 0}, // 47 - Fake pistol
	{0, 0}, // 48 - Pistol whip (custom)
	{0, 0}, // 49 - Vehicle
	{0, 1}, // 50 - Helicopter blades
	{0, 0}, // 51 - Explosion
	{0, 0}, // 52 - Car park (custom)
	{0, 0}, // 53 - Drowning
	{0, 0}  // 54 - Splat
};

// That's right, it's called cuntgun
stock const g_WeaponName[57][W_MAX_WEAPON_NAME] = {
	{"Fist"             }, {"Brass knuckles"}, {"Golf club"           },
	{"Nightstick"       }, {"Knife"         }, {"Bat"                 },
	{"Shovel"           }, {"Pool cue"      }, {"Katana"              },
	{"Chainsaw"         }, {"Purple dildo"  }, {"Dildo"               },
	{"Vibrator"         }, {"Vibrator"      }, {"Flowers"             },
	{"Cane"             }, {"Grenade"       }, {"Tear gas"            },
	{"Molotov"          }, {"Vehicle gun"   }, {"Vehicle gun"         },
	{"Vehicle gun"      }, {"Colt 45"       }, {"Silenced pistol"     },
	{"Deagle"           }, {"Shotgun"       }, {"Sawn-off shotgun"    },
	{"Combat shotgun"   }, {"Mac-10"        }, {"MP5"                 },
	{"AK-47"            }, {"M4"            }, {"Tec-9"               },
	{"Cuntgun"          }, {"Sniper"        }, {"Rocket launcher"     },
	{"Heat seeking RPG" }, {"Flamethrower"  }, {"Minigun"             },
	{"Satchel"          }, {"Detonator"     }, {"Spraycan"            },
	{"Fire extinguisher"}, {"Camera"        }, {"Night vision goggles"},
	{"Infrared goggles" }, {"Parachute"     }, {"Fake pistol"         },
	{"Pistol whip"      }, {"Vehicle"       }, {"Helicopter blades"   },
	{"Explosion"        }, {"Car parking"   }, {"Drowning"            },
	{"Collision"        }, {"Splat"         }, {"Unknown"             }
};

// Sorry about the mess..
static Weapon::LagCompMode;
static WEAPON:Weapon::LastExplosive[MAX_PLAYERS];
static Weapon::LastShot[MAX_PLAYERS][E_SHOT_INFO];
static Weapon::LastShotTicks[MAX_PLAYERS][10];
static Weapon::LastShotWeapons[MAX_PLAYERS][10];
static Weapon::LastShotIdx[MAX_PLAYERS];
static Weapon::LastHitTicks[MAX_PLAYERS][10];
static Weapon::LastHitWeapons[MAX_PLAYERS][10];
static Weapon::LastHitIdx[MAX_PLAYERS];
static Weapon::ShotsFired[MAX_PLAYERS];
static Weapon::HitsIssued[MAX_PLAYERS];
static Weapon::MaxShootRateSamples = 4;
static Weapon::MaxHitRateSamples = 4;
static Float:Weapon::PlayerMaxHealth[MAX_PLAYERS] = {100.0, ...};
static Float:Weapon::PlayerHealth[MAX_PLAYERS] = {100.0, ...};
static Float:Weapon::PlayerMaxArmour[MAX_PLAYERS] = {100.0, ...};
static Float:Weapon::PlayerArmour[MAX_PLAYERS] = {0.0, ...};
static Weapon::LastSentHealth[MAX_PLAYERS];
static Weapon::LastSentArmour[MAX_PLAYERS];
static bool:Weapon::DamageArmourToggle[2] = {false, ...};
static Weapon::PlayerTeam[MAX_PLAYERS] = {NO_TEAM, ...};
static Weapon::IsDying[MAX_PLAYERS];
static Weapon::DeathTimer[MAX_PLAYERS];
static bool:Weapon::SpawnForStreamedIn[MAX_PLAYERS];
static Weapon::RespawnTime = 3000;
static bool:Weapon::CbugGlobal = true;
static bool:Weapon::CbugAllowed[MAX_PLAYERS] = true;
static Weapon::CbugFroze[MAX_PLAYERS];
static Weapon::CbugCount[MAX_PLAYERS];
static Weapon::VehiclePassengerDamage = false;
static Weapon::VehicleUnoccupiedDamage = false;
static Weapon::RejectedHits[MAX_PLAYERS][W_MAX_REJECTED_HITS][E_REJECTED_HIT];
static Weapon::RejectedHitsIdx[MAX_PLAYERS];
static Weapon::World[MAX_PLAYERS];
static Weapon::LastAnim[MAX_PLAYERS] = {-1, ...};
static Float:Weapon::LastZVelo[MAX_PLAYERS] = {0.0, ...};
static Float:Weapon::LastZ[MAX_PLAYERS] = {0.0, ...};
static Weapon::LastUpdate[MAX_PLAYERS] = {-1, ...};
static Weapon::Spectating[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
static Weapon::LastStop[MAX_PLAYERS];
static bool:Weapon::FirstSpawn[MAX_PLAYERS] = {true, ...};

static Weapon::BeingResynced[MAX_PLAYERS];
static Weapon::KnifeTimeout[MAX_PLAYERS];
static Weapon::SyncData[MAX_PLAYERS][E_RESYNC_DATA];
static Weapon::DamageRangeSteps[55];
static Float:Weapon::DamageRangeRanges[55][W_MAX_DAMAGE_RANGES];
static Float:Weapon::DamageRangeValues[55][W_MAX_DAMAGE_RANGES];
static Weapon::LastVehicleShooter[MAX_VEHICLES + 1] = {INVALID_PLAYER_ID, ...};
static Weapon::LastVehicleEnterTime[MAX_PLAYERS];
static Weapon::TrueDeath[MAX_PLAYERS];
static Weapon::InClassSelection[MAX_PLAYERS];
static Weapon::ForceClassSelection[MAX_PLAYERS];
static Weapon::ClassSpawnInfo[320][E_SPAWN_INFO];
static Weapon::PlayerSpawnInfo[MAX_PLAYERS][E_SPAWN_INFO];
static Weapon::PlayerClass[MAX_PLAYERS] = {-2, ...};
static bool:Weapon::SpawnInfoModified[MAX_PLAYERS];
static bool:Weapon::AlreadyConnected[MAX_PLAYERS];
static Weapon::DeathSkip[MAX_PLAYERS];
static Weapon::DeathSkipTick[MAX_PLAYERS];
static Weapon::LastDeathTick[MAX_PLAYERS];
static Weapon::LastVehicleTick[MAX_PLAYERS];
static Weapon::PreviousHits[MAX_PLAYERS][10][E_HIT_INFO];
static Weapon::PreviousHitI[MAX_PLAYERS];

static Weapon::HitInformer[MAX_PLAYERS];
static Weapon::HitInformerTimer[MAX_PLAYERS];

static Float:Weapon::DamageDoneHealth[MAX_PLAYERS];
static Float:Weapon::DamageDoneArmour[MAX_PLAYERS];
static Weapon::DelayedDeathTimer[MAX_PLAYERS];
static bool:Weapon::VehicleAlive[MAX_VEHICLES] = {false, ...};
static Weapon::VehicleRespawnTimer[MAX_VEHICLES];

static Weapon::FakeHealth[MAX_PLAYERS char];
static Weapon::FakeArmour[MAX_PLAYERS char];
static Float:Weapon::FakeQuat[MAX_PLAYERS][4];
static bool:Weapon::SyncDataFrozen[MAX_PLAYERS];
static Weapon::LastSyncData[MAX_PLAYERS][PR_OnFootSync];
static Weapon::TempSyncData[MAX_PLAYERS][PR_OnFootSync];
static bool:Weapon::TempDataWritten[MAX_PLAYERS];
static Weapon::DisableSyncBugs = true;
static Weapon::KnifeSync = true;
static Weapon::PunchUsed[MAX_PLAYERS];
static Weapon::PunchTick[MAX_PLAYERS];
static Weapon::GogglesUsed[MAX_PLAYERS];
static Weapon::GogglesTick[MAX_PLAYERS];

native W_IsValidVehicle(vehicleid) = IsValidVehicle;

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

stock W_IsPlayerSpawned(playerid)
{
	if (Weapon::IsDying[playerid] || Weapon::BeingResynced[playerid]) {
		return false;
	}

	if (Weapon::InClassSelection[playerid] || Weapon::ForceClassSelection[playerid]) {
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

stock W_IsPlayerPaused(playerid)
{
	return (GetTickCount() - Weapon::LastUpdate[playerid] > 2000);
}

stock AverageShootRate(playerid, shots, &multiple_weapons = 0)
{
	if (playerid == INVALID_PLAYER_ID || Weapon::ShotsFired[playerid] < shots) {
		return -1;
	}

	new total = 0, idx = Weapon::LastShotIdx[playerid];

	multiple_weapons = false;

	for (new i = shots - 2, prev, prev_weap, prev_idx, this_idx; i >= 0; i--) {
		prev_idx = (idx - i - 1) % sizeof(Weapon::LastShotTicks[]);

		// JIT plugin fix
		if (prev_idx < 0) {
			prev_idx += sizeof(Weapon::LastShotTicks[]);
		}

		prev = Weapon::LastShotTicks[playerid][prev_idx];
		prev_weap = Weapon::LastShotWeapons[playerid][prev_idx];
		this_idx = (idx - i) % sizeof(Weapon::LastShotTicks[]);

		// JIT plugin fix
		if (this_idx < 0) {
			this_idx += sizeof(Weapon::LastShotTicks[]);
		}

		if (prev_weap != Weapon::LastShotWeapons[playerid][this_idx]) {
			multiple_weapons = true;
		}

		total += Weapon::LastShotTicks[playerid][this_idx] - prev;
	}

	return shots == 1 ? 1 : (total / (shots - 1));
}

stock AverageHitRate(playerid, hits, &multiple_weapons = 0)
{
	if (playerid == INVALID_PLAYER_ID || Weapon::HitsIssued[playerid] < hits) {
		return -1;
	}

	new total = 0, idx = Weapon::LastHitIdx[playerid];

	multiple_weapons = false;

	for (new i = hits - 2, prev, prev_weap, prev_idx, this_idx; i >= 0; i--) {
		prev_idx = (idx - i - 1) % sizeof(Weapon::LastHitTicks[]);

		// JIT plugin fix
		if (prev_idx < 0) {
			prev_idx += sizeof(Weapon::LastHitTicks[]);
		}

		prev = Weapon::LastHitTicks[playerid][prev_idx];
		prev_weap = Weapon::LastHitWeapons[playerid][prev_idx];
		this_idx = (idx - i) % sizeof(Weapon::LastHitTicks[]);

		// JIT plugin fix
		if (this_idx < 0) {
			this_idx += sizeof(Weapon::LastHitTicks[]);
		}

		if (prev_weap != Weapon::LastHitWeapons[playerid][this_idx]) {
			multiple_weapons = true;
		}

		total += Weapon::LastHitTicks[playerid][this_idx] - prev;
	}

	return hits == 1 ? 1 : (total / (hits - 1));
}

stock SetRespawnTime(ms)
{
	Weapon::RespawnTime = max(0, ms);
}

stock GetRespawnTime()
{
	return Weapon::RespawnTime;
}

stock ReturnWeaponName(WEAPON:weaponid)
{
	new name[sizeof(g_WeaponName[])];

	W_GetWeaponName(weaponid, name);

	return name;
}

stock ReturnBodypartName(id)
{
    new part[64];
    switch(id)
    {
    	case 2: part = "Neck";
        case 3: part = "Torso";
        case 4: part = "Groin";
        case 5: part = "Left arm";
        case 6: part = "Right arm";
        case 7: part = "Left leg";
        case 8: part = "Right leg";
        case 9: part = "Head";
        default: part = "None";
    }
    return part;
}

stock SetWeaponDamage(WEAPON:weaponid, damage_type, Float:amount, Float:...)
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(Weapon::WeaponDamage)) {
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

		Weapon::DamageType[weaponid] = damage_type;
		Weapon::DamageRangeSteps[weaponid] = steps;

		for (new i = 0; i < steps; i++) {
			if (i) {
				Weapon::DamageRangeRanges[weaponid][i] = Float:getarg(1 + i * 2);
				Weapon::DamageRangeValues[weaponid][i] = Float:getarg(2 + i * 2);
			} else {
				Weapon::DamageRangeValues[weaponid][i] = amount;
			}
		}

		return 1;
	} else if (damage_type == DAMAGE_TYPE_MULTIPLIER || damage_type == DAMAGE_TYPE_STATIC) {
		Weapon::DamageType[weaponid] = damage_type;
		Weapon::DamageRangeSteps[weaponid] = 0;
		Weapon::WeaponDamage[weaponid] = amount;

		return 1;
	}

	return 0;
}

stock Float:GetWeaponDamage(WEAPON:weaponid)
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(Weapon::WeaponDamage)) {
		return 0.0;
	}

	return Weapon::WeaponDamage[weaponid];
}

stock SetCustomArmourRules(bool:armour_rules, bool:torso_rules = false)
{
	Weapon::DamageArmourToggle[0] = armour_rules;
	Weapon::DamageArmourToggle[1] = torso_rules;
}

stock SetWeaponArmourRule(WEAPON:weaponid, bool:affects_armour, bool:torso_only = false)
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(Weapon::WeaponDamage)) {
		return 0;
	}

	Weapon::DamageArmour[weaponid][0] = affects_armour;
	Weapon::DamageArmour[weaponid][1] = torso_only;

	return 1;
}

stock SetCbugAllowed(bool:enabled, playerid = INVALID_PLAYER_ID)
{
	if (playerid == INVALID_PLAYER_ID) {
		Weapon::CbugGlobal = enabled;
		foreach (new i : Player) 
		{
			Weapon::CbugAllowed[i] = enabled;
		}
	} else {
		Weapon::CbugAllowed[playerid] = enabled;
	}

	return enabled;
}

stock bool:GetCbugAllowed(playerid = INVALID_PLAYER_ID)
{
	if (playerid == INVALID_PLAYER_ID) {
		return Weapon::CbugGlobal;
	}

	return Weapon::CbugAllowed[playerid];
}

stock SetVehiclePassengerDamage(bool:toggle)
{
	Weapon::VehiclePassengerDamage = toggle;
}

stock SetVehicleUnoccupiedDamage(bool:toggle)
{
	Weapon::VehicleUnoccupiedDamage = toggle;
}

stock SetWeaponShootRate(WEAPON:weaponid, max_rate)
{
	if (_:WEAPON_UNARMED <= _:weaponid < sizeof(Weapon::MaxWeaponShootRate)) {
		Weapon::MaxWeaponShootRate[weaponid] = max_rate;

		return 1;
	}

	return 0;
}

stock GetWeaponShootRate(WEAPON:weaponid)
{
	if (_:WEAPON_UNARMED <= _:weaponid < sizeof(Weapon::MaxWeaponShootRate)) {
		return Weapon::MaxWeaponShootRate[weaponid];
	}

	return 0;
}

stock IsPlayerDying(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return Weapon::IsDying[playerid];
	}

	return false;
}

stock SetWeaponMaxRange(WEAPON:weaponid, Float:range)
{
	if (!IsBulletWeapon(weaponid)) {
		return 0;
	}

	Weapon::WeaponRange[weaponid] = range;

	return 1;
}

stock Float:GetWeaponMaxRange(WEAPON:weaponid)
{
	if (!IsBulletWeapon(weaponid)) {
		return 0.0;
	}

	return Weapon::WeaponRange[weaponid];
}

stock SetPlayerMaxHealth(playerid, Float:value)
{
	if (0 <= playerid < MAX_PLAYERS) {
		Weapon::PlayerMaxHealth[playerid] = value;
	}
}

stock SetPlayerMaxArmour(playerid, Float:value)
{
	if (0 <= playerid < MAX_PLAYERS) {
		Weapon::PlayerMaxArmour[playerid] = value;
	}
}

stock Float:GetPlayerMaxHealth(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return Weapon::PlayerMaxHealth[playerid];
	}

	return 0.0;
}

stock Float:GetPlayerMaxArmour(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return Weapon::PlayerMaxArmour[playerid];
	}

	return 0.0;
}

stock Float:GetLastDamageHealth(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return Weapon::DamageDoneHealth[playerid];
	}

	return 0.0;
}

stock Float:GetLastDamageArmour(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return Weapon::DamageDoneArmour[playerid];
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
	if (idx >= W_MAX_REJECTED_HITS) {
		return 0;
	}

	new real_idx = (Weapon::RejectedHitsIdx[playerid] - idx) % W_MAX_REJECTED_HITS;

	// JIT plugin fix
	if (real_idx < 0) {
		real_idx += W_MAX_REJECTED_HITS;
	}

	if (!Weapon::RejectedHits[playerid][real_idx][e_Time]) {
		return 0;
	}

	new reason = Weapon::RejectedHits[playerid][real_idx][e_Reason];
	new hour = Weapon::RejectedHits[playerid][real_idx][e_Hour];
	new minute = Weapon::RejectedHits[playerid][real_idx][e_Minute];
	new second = Weapon::RejectedHits[playerid][real_idx][e_Second];
	new i1 = Weapon::RejectedHits[playerid][real_idx][e_Info1];
	new i2 = Weapon::RejectedHits[playerid][real_idx][e_Info2];
	new i3 = Weapon::RejectedHits[playerid][real_idx][e_Info3];
	new WEAPON:weapon = Weapon::RejectedHits[playerid][real_idx][e_Weapon];

	new weapon_name[32];

	W_GetWeaponName(weapon, weapon_name);

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

	format(output, maxlength, "[%02d:%02d:%02d] (%s -> %s) %s", hour, minute, second, weapon_name, Weapon::RejectedHits[playerid][real_idx][e_Name], output);

	return 1;
}

stock ResyncPlayer(playerid)
{
	SaveSyncData(playerid);

	Weapon::BeingResynced[playerid] = true;

	SpawnPlayerInPlace(playerid);
}

stock SetDisableSyncBugs(toggle)
{
	Weapon::DisableSyncBugs = !!toggle;
}

stock SetKnifeSync(toggle)
{
	Weapon::KnifeSync = !!toggle;
}

/*
 * Hooked natives
 */

stock W_SpawnPlayer(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || Weapon::IsDying[playerid]) {
		return 0;
	}

	if (Weapon::PlayerHealth[playerid] == 0.0) {
		Weapon::PlayerHealth[playerid] = Weapon::PlayerMaxHealth[playerid];
	}

	SpawnPlayer(playerid);

	return 1;
}

stock PLAYER_STATE:W_GetPlayerState(playerid)
{
	if (Weapon::IsDying[playerid]) {
		return PLAYER_STATE_WASTED;
	}

	return GetPlayerState(playerid);
}

stock Float:W_GetPlayerHealth(playerid, &Float:health = 0.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		health = 0.0;

		return 0.0;
	}

	health = Weapon::PlayerHealth[playerid];

	return health;
}

stock W_SetPlayerHealth(playerid, Float:health, Float:armour = -1.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (health <= 0.0) {
		Weapon::PlayerArmour[playerid] = 0.0;
		Weapon::PlayerHealth[playerid] = 0.0;

		InflictDamage(playerid, 0.0);
	} else {
		if (armour != -1.0) {
			if (armour > Weapon::PlayerMaxArmour[playerid]) {
				armour = Weapon::PlayerMaxArmour[playerid];
			}
			Weapon::PlayerArmour[playerid] = armour;
		}

		if (health > Weapon::PlayerMaxHealth[playerid]) {
			health = Weapon::PlayerMaxHealth[playerid];
		}
		Weapon::PlayerHealth[playerid] = health;
		UpdateHealthBar(playerid, true);
	}

	return 1;
}

stock Float:W_GetPlayerArmour(playerid, &Float:armour = 0.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		armour = 0.0;

		return 0.0;
	}

	armour = Weapon::PlayerArmour[playerid];

	return armour;
}

stock W_SetPlayerArmour(playerid, Float:armour)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (armour > Weapon::PlayerMaxArmour[playerid]) {
		armour = Weapon::PlayerMaxArmour[playerid];
	}
	Weapon::PlayerArmour[playerid] = armour;
	UpdateHealthBar(playerid, true);

	return 1;
}

stock W_GetPlayerTeam(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return NO_TEAM;
	}

	if (!IsPlayerConnected(playerid)) {
		return NO_TEAM;
	}

	return Weapon::PlayerTeam[playerid];
}

stock W_SetPlayerTeam(playerid, team)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	Weapon::PlayerTeam[playerid] = team;
	SetPlayerTeam(playerid, team);

	return 1;
}

stock W_SendDeathMessage(killer, killee, weapon)
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

stock SetWeaponName(WEAPON:weaponid, const name[])
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(g_WeaponName)) {
		return 0;
	}

	strunpack(g_WeaponName[weaponid], name, sizeof(g_WeaponName[]));

	return 1;
}

stock W_GetWeaponName(WEAPON:weaponid, weapon[], len = sizeof(weapon))
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(g_WeaponName)) {
		format(weapon, len, "Weapon %d", weaponid);
	} else {
		strunpack(weapon, g_WeaponName[weaponid], len);
	}

	return 1;
}

stock W_ApplyAnimation(playerid, const animlib[], const animname[], Float:fDelta, loop, lockx, locky, freeze, time, FORCE_SYNC:forcesync = FORCE_SYNC:0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || Weapon::IsDying[playerid]) {
		return 0;
	}

	return ApplyAnimation(playerid, animlib, animname, fDelta, !!loop, !!lockx, !!locky, !!freeze, time, forcesync);
}

stock W_ClearAnimations(playerid, FORCE_SYNC:forcesync = FORCE_SYNC:1)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || Weapon::IsDying[playerid]) {
		return 0;
	}

	Weapon::LastStop[playerid] = GetTickCount();

	return ClearAnimations(playerid, forcesync);
}

stock W_AddPlayerClass(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	new classid = AddPlayerClass(modelid, spawn_x, spawn_y, spawn_z, z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);

	if (0 <= classid <= 319) {
		Weapon::ClassSpawnInfo[classid][e_Skin] = modelid;
		Weapon::ClassSpawnInfo[classid][e_Team] = 0x7FFFFFFF;
		Weapon::ClassSpawnInfo[classid][e_PosX] = spawn_x;
		Weapon::ClassSpawnInfo[classid][e_PosY] = spawn_y;
		Weapon::ClassSpawnInfo[classid][e_PosZ] = spawn_z;
		Weapon::ClassSpawnInfo[classid][e_Rot] = z_angle;
		Weapon::ClassSpawnInfo[classid][e_Weapon1] = weapon1;
		Weapon::ClassSpawnInfo[classid][e_Ammo1] = weapon1_ammo;
		Weapon::ClassSpawnInfo[classid][e_Weapon2] = weapon2;
		Weapon::ClassSpawnInfo[classid][e_Ammo2] = weapon2_ammo;
		Weapon::ClassSpawnInfo[classid][e_Weapon3] = weapon3;
		Weapon::ClassSpawnInfo[classid][e_Ammo3] = weapon3_ammo;
	}

	return classid;
}

stock W_AddPlayerClassEx(teamid, modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	new classid = AddPlayerClassEx(teamid, modelid, spawn_x, spawn_y, spawn_z, z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);

	if (0 <= classid <= 319) {
		Weapon::ClassSpawnInfo[classid][e_Skin] = modelid;
		Weapon::ClassSpawnInfo[classid][e_Team] = teamid;
		Weapon::ClassSpawnInfo[classid][e_PosX] = spawn_x;
		Weapon::ClassSpawnInfo[classid][e_PosY] = spawn_y;
		Weapon::ClassSpawnInfo[classid][e_PosZ] = spawn_z;
		Weapon::ClassSpawnInfo[classid][e_Rot] = z_angle;
		Weapon::ClassSpawnInfo[classid][e_Weapon1] = weapon1;
		Weapon::ClassSpawnInfo[classid][e_Ammo1] = weapon1_ammo;
		Weapon::ClassSpawnInfo[classid][e_Weapon2] = weapon2;
		Weapon::ClassSpawnInfo[classid][e_Ammo2] = weapon2_ammo;
		Weapon::ClassSpawnInfo[classid][e_Weapon3] = weapon3;
		Weapon::ClassSpawnInfo[classid][e_Ammo3] = weapon3_ammo;
	}

	return classid;
}

stock W_SetSpawnInfo(playerid, team, skin, Float:x, Float:y, Float:z, Float:rotation, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	if (SetSpawnInfo(playerid, team, skin, x, y, z, rotation, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)) {
		Weapon::PlayerClass[playerid] = -1;
		Weapon::SpawnInfoModified[playerid] = false;

		Weapon::PlayerSpawnInfo[playerid][e_Skin] = skin;
		Weapon::PlayerSpawnInfo[playerid][e_Team] = team;
		Weapon::PlayerSpawnInfo[playerid][e_PosX] = x;
		Weapon::PlayerSpawnInfo[playerid][e_PosY] = y;
		Weapon::PlayerSpawnInfo[playerid][e_PosZ] = z;
		Weapon::PlayerSpawnInfo[playerid][e_Rot] = rotation;
		Weapon::PlayerSpawnInfo[playerid][e_Weapon1] = weapon1;
		Weapon::PlayerSpawnInfo[playerid][e_Ammo1] = weapon1_ammo;
		Weapon::PlayerSpawnInfo[playerid][e_Weapon2] = weapon2;
		Weapon::PlayerSpawnInfo[playerid][e_Ammo2] = weapon2_ammo;
		Weapon::PlayerSpawnInfo[playerid][e_Weapon3] = weapon3;
		Weapon::PlayerSpawnInfo[playerid][e_Ammo3] = weapon3_ammo;

		return 1;
	}

	return 0;
}

stock W_TogglePlayerSpectating(playerid, toggle)
{
	if (TogglePlayerSpectating(playerid, !!toggle)) {
		if (toggle) {
			if (Weapon::DeathTimer[playerid]) {
				KillTimer(Weapon::DeathTimer[playerid]);
				Weapon::DeathTimer[playerid] = 0;
			}

			Weapon::IsDying[playerid] = false;
		}

		return 1;
	}

	return 0;
}

stock W_TogglePlayerControllable(playerid, toggle)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || Weapon::IsDying[playerid]) {
		return 0;
	}

	Weapon::LastStop[playerid] = GetTickCount();

	return TogglePlayerControllable(playerid, !!toggle);
}

stock W_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || Weapon::IsDying[playerid]) {
		return 0;
	}

	Weapon::LastStop[playerid] = GetTickCount();

	return SetPlayerPos(playerid, x, y, z);
}

stock W_SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || Weapon::IsDying[playerid]) {
		return 0;
	}

	Weapon::LastStop[playerid] = GetTickCount();

	return SetPlayerPosFindZ(playerid, x, y, z);
}

stock W_SetPlayerVelocity(playerid, Float:X, Float:Y, Float:Z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || Weapon::IsDying[playerid]) {
		return 0;
	}

	if (X == 0.0 && Y == 0.0 && Z == 0.0) {
		Weapon::LastStop[playerid] = GetTickCount();
	}

	return SetPlayerVelocity(playerid, X, Y, Z);
}

stock W_SetPlayerVirtualWorld(playerid, worldid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	Weapon::World[playerid] = worldid;

	if (Weapon::IsDying[playerid]) {
		return 1;
	}

	return SetPlayerVirtualWorld(playerid, worldid);
}

stock W_GetPlayerVirtualWorld(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	new worldid = GetPlayerVirtualWorld(playerid);

	if (worldid == W_DEATH_WORLD) {
		return Weapon::World[playerid];
	}

	return worldid;
}

stock W_PlayerSpectatePlayer(playerid, targetplayerid, SPECTATE_MODE:mode = SPECTATE_MODE_NORMAL)
{
	if (PlayerSpectatePlayer(playerid, targetplayerid, mode)) {
		Weapon::Spectating[playerid] = targetplayerid;
		return 1;
	}

	return 0;
}

stock W_DestroyVehicle(vehicleid)
{
	if (DestroyVehicle(vehicleid)) {
		Weapon::LastVehicleShooter[vehicleid] = INVALID_PLAYER_ID;
		Weapon::VehicleAlive[vehicleid] = false;

		if (Weapon::VehicleRespawnTimer[vehicleid]) {
			KillTimer(Weapon::VehicleRespawnTimer[vehicleid]);
			Weapon::VehicleRespawnTimer[vehicleid] = 0;
		}

		return 1;
	}

	return 0;
}

stock W_CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay, addsiren = 0)
{
	new id = CreateVehicle(modelid, x, y, z, angle, color1, color2, respawn_delay, !!addsiren);

	if (0 < id < MAX_VEHICLES) {
		Weapon::VehicleAlive[id] = true;
	}

	return id;
}

stock W_AddStaticVehicle(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2)
{
	new id = AddStaticVehicle(modelid, x, y, z, angle, color1, color2);

	if (0 < id < MAX_VEHICLES) {
		Weapon::VehicleAlive[id] = true;
	}

	return id;
}

stock W_AddStaticVehicleEx(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay, addsiren = 0)
{
	new id = AddStaticVehicleEx(modelid, x, y, z, angle, color1, color2, respawn_delay, !!addsiren);

	if (0 < id < MAX_VEHICLES) {
		Weapon::VehicleAlive[id] = true;
	}

	return id;
}

stock W_IsPlayerInCheckpoint(playerid)
{
	if (!W_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return IsPlayerInCheckpoint(playerid);
}

stock W_IsPlayerInRaceCheckpoint(playerid)
{
	if (!W_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return IsPlayerInRaceCheckpoint(playerid);
}

stock W_SetPlayerSpecialAction(playerid, SPECIAL_ACTION:actionid)
{
	if (!W_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return SetPlayerSpecialAction(playerid, actionid);
}

/*
 * Hooked callbacks
 */

public OnGameModeInit()
{
	state _ALS : _ALS_go;

	ScriptInit();

	return W_OnGameModeInit();
}

public OnGameModeExit()
{
	ScriptExit();

	return W_OnGameModeExit();
}

public OnPlayerConnect(playerid)
{
	new tick = GetTickCount();
    
    //forex(r, 6)
    //{
    //    FitnessRating[playerid][r] = 94.90;
    //}
    FitnessRating[playerid][0] = 98.62;
    FitnessRating[playerid][1] = 99.36;
    FitnessRating[playerid][2] = 126.73;
    FitnessRating[playerid][3] = 125.30;
    FitnessRating[playerid][4] = 125.76;
    FitnessRating[playerid][5] = 122.40;

	Weapon::PlayerMaxHealth[playerid] = 100.0;
	Weapon::PlayerHealth[playerid] = 100.0;
	Weapon::PlayerMaxArmour[playerid] = 100.0;
	Weapon::PlayerArmour[playerid] = 0.0;
	Weapon::LastExplosive[playerid] = WEAPON_UNARMED;
	Weapon::LastShotIdx[playerid] = 0;
	Weapon::LastShot[playerid][e_Tick] = 0;
	Weapon::LastHitIdx[playerid] = 0;
	Weapon::RejectedHitsIdx[playerid] = 0;
	Weapon::ShotsFired[playerid] = 0;
	Weapon::HitsIssued[playerid] = 0;
	Weapon::PlayerTeam[playerid] = NO_TEAM;
	Weapon::IsDying[playerid] = false;
	Weapon::BeingResynced[playerid] = false;
	Weapon::SpawnForStreamedIn[playerid] = false;
	Weapon::World[playerid] = 0;
	Weapon::LastAnim[playerid] = -1;
	Weapon::LastZVelo[playerid] = 0.0;
	Weapon::LastZ[playerid] = 0.0;
	Weapon::LastUpdate[playerid] = tick;
	Weapon::Spectating[playerid] = INVALID_PLAYER_ID;
	Weapon::LastSentHealth[playerid] = 0;
	Weapon::LastSentArmour[playerid] = 0;
	Weapon::LastStop[playerid] = tick;
	Weapon::FirstSpawn[playerid] = true;
	Weapon::LastVehicleEnterTime[playerid] = 0;
	Weapon::TrueDeath[playerid] = true;
	Weapon::InClassSelection[playerid] = false;
	Weapon::ForceClassSelection[playerid] = false;
	Weapon::PlayerClass[playerid] = -2;
	Weapon::SpawnInfoModified[playerid] = false;
	Weapon::DeathSkip[playerid] = 0;
	Weapon::LastVehicleTick[playerid] = 0;
	Weapon::PreviousHitI[playerid] = 0;
	Weapon::HitInformer[playerid] = 0;
	Weapon::HitInformerTimer[playerid] = 0;
	Weapon::CbugAllowed[playerid] = Weapon::CbugGlobal;
	Weapon::CbugFroze[playerid] = 0;
	Weapon::CbugCount[playerid] = 0;
	Weapon::DeathTimer[playerid] = 0;
	Weapon::DelayedDeathTimer[playerid] = 0;

	Weapon::FakeHealth{playerid} = 255;
	Weapon::FakeArmour{playerid} = 255;
	Weapon::FakeQuat[playerid][0] = Float:0x7FFFFFFF;
	Weapon::FakeQuat[playerid][1] = Float:0x7FFFFFFF;
	Weapon::FakeQuat[playerid][2] = Float:0x7FFFFFFF;
	Weapon::FakeQuat[playerid][3] = Float:0x7FFFFFFF;
	Weapon::TempDataWritten[playerid] = false;
	Weapon::SyncDataFrozen[playerid] = false;
	Weapon::GogglesUsed[playerid] = 0;

	for (new i = 0; i < sizeof(Weapon::PreviousHits[]); i++) {
		Weapon::PreviousHits[playerid][i][e_Tick] = 0;
	}

	for (new i = 0; i < sizeof(Weapon::RejectedHits[]); i++) {
		Weapon::RejectedHits[playerid][i][e_Time] = 0;
	}

	SetPlayerTeam(playerid, Weapon::PlayerTeam[playerid]);
	FreezeSyncPacket(playerid, .toggle = false);
	SetFakeFacingAngle(playerid, _);

	Weapon::AlreadyConnected[playerid] = false;

	return W_OnPlayerConnect(playerid);
}

public OnPlayerDisconnect(playerid, reason)
{
	W_OnPlayerDisconnect(playerid, reason);

	if (Weapon::DelayedDeathTimer[playerid]) {
		KillTimer(Weapon::DelayedDeathTimer[playerid]);
		Weapon::DelayedDeathTimer[playerid] = 0;
	}

	if (Weapon::DeathTimer[playerid]) {
		KillTimer(Weapon::DeathTimer[playerid]);
		Weapon::DeathTimer[playerid] = 0;
	}

	if (Weapon::KnifeTimeout[playerid]) {
		KillTimer(Weapon::KnifeTimeout[playerid]);
		Weapon::KnifeTimeout[playerid] = 0;
	}

	Weapon::Spectating[playerid] = INVALID_PLAYER_ID;

	for (new i = 0; i < sizeof(Weapon::LastVehicleShooter); i++) {
		if (Weapon::LastVehicleShooter[i] == playerid) {
			Weapon::LastVehicleShooter[i] = INVALID_PLAYER_ID;
		}
	}

	new j = 0;

	foreach (new i : Player) {
		for (j = 0; j < sizeof(Weapon::PreviousHits[]); j++) {
			if (Weapon::PreviousHits[i][j][e_Issuer] == playerid) {
				Weapon::PreviousHits[i][j][e_Issuer] = INVALID_PLAYER_ID;
			}
		}
	}

	return 1;
}

public OnPlayerSpawn(playerid)
{
	Weapon::TrueDeath[playerid] = false;
	Weapon::InClassSelection[playerid] = false;

	if (Weapon::ForceClassSelection[playerid]) {
		DebugMessage("Being forced into class selection");
		ForceClassSelection(playerid);
		SetPlayerHealth(playerid, 0.0);

		return 1;
	}

	new tick = GetTickCount();
	Weapon::LastUpdate[playerid] = tick;
	Weapon::LastStop[playerid] = tick;

	if (Weapon::BeingResynced[playerid]) {
		Weapon::BeingResynced[playerid] = false;

		UpdateHealthBar(playerid);

		SetPlayerPos(playerid, Weapon::SyncData[playerid][e_PosX], Weapon::SyncData[playerid][e_PosY], Weapon::SyncData[playerid][e_PosZ]);
		SetPlayerFacingAngle(playerid, Weapon::SyncData[playerid][e_PosA]);

		SetPlayerSkin(playerid, Weapon::SyncData[playerid][e_Skin]);
		SetPlayerTeam(playerid, Weapon::SyncData[playerid][e_Team]);

		for (new i = 0; i < 13; i++) {
			if (Weapon::SyncData[playerid][e_WeaponId][i]) {
				GivePlayerWeapon(playerid, Weapon::SyncData[playerid][e_WeaponId][i], Weapon::SyncData[playerid][e_WeaponAmmo][i]);
			}
		}

		SetPlayerArmedWeapon(playerid, Weapon::SyncData[playerid][e_Weapon]);

		return 1;
	}

	if (Weapon::SpawnInfoModified[playerid]) {
		new spawn_info[E_SPAWN_INFO], classid = Weapon::PlayerClass[playerid];

		Weapon::SpawnInfoModified[playerid] = false;

		if (classid == -1) 
		{
			spawn_info = Weapon::PlayerSpawnInfo[playerid];
		} 
		else 
		{
			spawn_info = Weapon::ClassSpawnInfo[classid];
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

	if (Weapon::DeathTimer[playerid]) {
		KillTimer(Weapon::DeathTimer[playerid]);
		Weapon::DeathTimer[playerid] = 0;
	}

	if (Weapon::IsDying[playerid]) {
		Weapon::IsDying[playerid] = false;
	}

	if (Weapon::PlayerHealth[playerid] == 0.0) {
		Weapon::PlayerHealth[playerid] = Weapon::PlayerMaxHealth[playerid];
	}

	UpdatePlayerVirtualWorld(playerid);
	UpdateHealthBar(playerid, true);
	FreezeSyncPacket(playerid, .toggle = false);
	SetFakeFacingAngle(playerid, _);

	if (GetPlayerTeam(playerid) != Weapon::PlayerTeam[playerid]) {
		SetPlayerTeam(playerid, Weapon::PlayerTeam[playerid]);
	}

	new animlib[32], animname[32];

	if (Weapon::DeathSkip[playerid] == 2) {
		new WEAPON:w, a;
		GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

		DebugMessage("Death skipped");
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		SetPlayerArmedWeapon(playerid, w);
		ClearAnimations(playerid);

		animlib = "PED", animname = "IDLE_stance";
		ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 1, FORCE_SYNC:1);

		Weapon::DeathSkip[playerid] = 1;
		Weapon::DeathSkipTick[playerid] = tick;

		return 1;
	}

	if (Weapon::FirstSpawn[playerid]) {
		Weapon::FirstSpawn[playerid] = false;

	}

	return W_OnPlayerSpawn(playerid);
}

public OnPlayerRequestClass(playerid, classid)
{
	DebugMessage("Requested class: %d", classid);

	if (Weapon::DeathSkip[playerid]) {
		DebugMessage("Skipping death - class selection skipped");
		SpawnPlayer(playerid);

		return 0;
	}

	if (Weapon::ForceClassSelection[playerid]) {
		Weapon::ForceClassSelection[playerid] = false;
	}

	if (Weapon::BeingResynced[playerid]) {
		Weapon::TrueDeath[playerid] = false;

		SpawnPlayerInPlace(playerid);

		return 0;
	}

	if (Weapon::DeathTimer[playerid]) {
		KillTimer(Weapon::DeathTimer[playerid]);
		Weapon::DeathTimer[playerid] = 0;
	}

	if (Weapon::IsDying[playerid]) {
		OnPlayerDeathFinished(playerid, false);
		Weapon::IsDying[playerid] = false;
	}

	if (Weapon::TrueDeath[playerid]) {
		if (!Weapon::InClassSelection[playerid]) {
			DebugMessage("True death class selection");

			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			RemoveBuildingForPlayer(playerid, 1484, x, y, z, 350.0),
			RemoveBuildingForPlayer(playerid, 1485, x, y, z, 350.0),
			RemoveBuildingForPlayer(playerid, 1486, x, y, z, 350.0);

			Weapon::InClassSelection[playerid] = true;
		}

		UpdatePlayerVirtualWorld(playerid);

		if (W_OnPlayerRequestClass(playerid, classid)) {
			Weapon::PlayerClass[playerid] = classid;

			return 1;
		} else {
			return 0;
		}
	} else {
		DebugMessage("Not true death - being respawned");

		Weapon::ForceClassSelection[playerid] = true;

		SetPlayerVirtualWorld(playerid, W_DEATH_WORLD);
		SpawnPlayerInPlace(playerid);

		return 0;
	}
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
	Weapon::TrueDeath[playerid] = true;
	Weapon::InClassSelection[playerid] = false;

	if (Weapon::BeingResynced[playerid] || Weapon::ForceClassSelection[playerid]) {
		return 1;
	}

	// Probably fake death
	if (killerid != INVALID_PLAYER_ID && !IsPlayerStreamedIn(killerid, playerid)) {
		killerid = INVALID_PLAYER_ID;
	}

	DebugMessageRed("OnPlayerDeath(%d died by %d from %d)", playerid, reason, killerid);

	if (Weapon::DeathTimer[playerid]) {
		KillTimer(Weapon::DeathTimer[playerid]);
		Weapon::DeathTimer[playerid] = 0;
	}

	if (Weapon::IsDying[playerid]) {
		DebugMessageRed("death while dying %d", playerid);

		return 1;
	}

	if (reason < WEAPON_UNARMED || reason > WEAPON_UNKNOWN) {
		reason = WEAPON_UNKNOWN;
	}

	new vehicleid = GetPlayerVehicleID(playerid);

	// Let's assume they died from an exploading vehicle
	if (vehicleid != INVALID_VEHICLE_ID && W_IsValidVehicle(vehicleid)) {
		reason = WEAPON_EXPLOSION;
		killerid = INVALID_PLAYER_ID;

		if (!HasSameTeam(playerid, Weapon::LastVehicleShooter[vehicleid])) {
			killerid = Weapon::LastVehicleShooter[vehicleid];
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
			amount = Weapon::PlayerHealth[playerid] + Weapon::PlayerArmour[playerid];
		}

		if (reason == WEAPON_COLLISION || reason == WEAPON_DROWN || reason == WEAPON_CARPARK) {
			if (amount <= 0.0) {
				amount = Weapon::PlayerHealth[playerid];
			}

			Weapon::PlayerHealth[playerid] -= amount;
		} else {
			if (amount <= 0.0) {
				amount = Weapon::PlayerHealth[playerid] + Weapon::PlayerArmour[playerid];
			}

			Weapon::PlayerArmour[playerid] -= amount;
		}

		if (Weapon::PlayerArmour[playerid] < 0.0) {
			Weapon::DamageDoneArmour[playerid] = amount + Weapon::PlayerArmour[playerid];
			Weapon::DamageDoneHealth[playerid] = -Weapon::PlayerArmour[playerid];
			Weapon::PlayerHealth[playerid] += Weapon::PlayerArmour[playerid];
			Weapon::PlayerArmour[playerid] = 0.0;
		} else {
			Weapon::DamageDoneArmour[playerid] = amount;
			Weapon::DamageDoneHealth[playerid] = 0.0;
		}

		if (Weapon::PlayerHealth[playerid] <= 0.0) {
			amount += Weapon::PlayerHealth[playerid];
			Weapon::DamageDoneHealth[playerid] += Weapon::PlayerHealth[playerid];
			Weapon::PlayerHealth[playerid] = 0.0;
		}

		OnPlayerDamageDone(playerid, amount, killerid, reason, bodypart);
	}

	if (Weapon::PlayerHealth[playerid] <= 0.0005) {
		Weapon::PlayerHealth[playerid] = 0.0;
		Weapon::IsDying[playerid] = true;

		Weapon::LastDeathTick[playerid] = GetTickCount();

		new animlib[32], animname[32], anim_lock, respawn_time;

		OnPlayerPrepareDeath(playerid, animlib, animname, anim_lock, respawn_time);

		W_OnPlayerDeath(playerid, killerid, reason);

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

			Weapon::DeathSkip[playerid] = 2;

			new WEAPON:w, a;
			GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

			ForceClassSelection(playerid);
			SetSpawnInfo(playerid, Weapon::PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);
			TogglePlayerSpectating(playerid, true);
			TogglePlayerSpectating(playerid, false);
			SetSpawnInfo(playerid, Weapon::PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);
			TogglePlayerControllable(playerid, true);
			SetPlayerArmedWeapon(playerid, w);
		} else {
			SpawnPlayerInPlace(playerid);
		}
	}

	UpdateHealthBar(playerid);

	return 1;
}

static Float:AngleBetweenPoints(Float:x1, Float:y1, Float:x2, Float:y2);

forward W_CbugPunishment(playerid, WEAPON:weapon);
public W_CbugPunishment(playerid, WEAPON:weapon) {
	FreezeSyncPacket(playerid, .toggle = false);
	//SetPlayerArmedWeapon(playerid, weapon);

	if (!Weapon::IsDying[playerid]) {
		ClearAnimations(playerid, FORCE_SYNC:1);
	}
}

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	//new animlib[32], animname[32];
	if (!Weapon::CbugAllowed[playerid] && !Weapon::IsDying[playerid] && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		if (newkeys & KEY_CROUCH) {
			new tick = GetTickCount();
			new diff = tick - Weapon::LastShot[playerid][e_Tick];

			if (Weapon::LastShot[playerid][e_Tick] && diff < 1200 && !Weapon::CbugFroze[playerid]) 
			{
				Weapon::CbugFroze[playerid] = tick;
				if(Weapon::CbugCount[playerid] != 0)
				{
    				if (Weapon::LastShot[playerid][e_Valid] && floatabs(Weapon::LastShot[playerid][e_HX]) > 1.0 && floatabs(Weapon::LastShot[playerid][e_HY]) > 1.0) {
    					SetPlayerFacingAngle(playerid, AngleBetweenPoints(
    						Weapon::LastShot[playerid][e_HX],
    						Weapon::LastShot[playerid][e_HY],
    						Weapon::LastShot[playerid][e_OX],
    						Weapon::LastShot[playerid][e_OY]
    					));
    				}
    
    				new WEAPON:w, a;
    				GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);
    
    				//animlib = "PED", animname = "IDLE_stance";
    				//ClearAnimations(playerid, FORCE_SYNC:1);
    				//ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 0, FORCE_SYNC:1);
    				FreezeSyncPacket(playerid, .toggle = true);
    				//SetPlayerArmedWeapon(playerid, w);
    				SendFalseMessage(playerid, "C-BUG", "terdeteksi, damage menjadi tidak valid! (1 detik)");
    				SetTimerEx("W_CbugPunishment", 1000, false, "ii", playerid, GetPlayerWeapon(playerid));
    
    				new j = 0, Float:health, Float:armour;
    
    				foreach (new i : Player) {
    					for (j = 0; j < sizeof(Weapon::PreviousHits[]); j++) {
    						if (Weapon::PreviousHits[i][j][e_Issuer] == playerid && tick - Weapon::PreviousHits[i][j][e_Tick] <= 1200) {
    							Weapon::PreviousHits[i][j][e_Issuer] = INVALID_PLAYER_ID;
    
    							health = W_GetPlayerHealth(i);
    							armour = W_GetPlayerArmour(i);
    
    							if (Weapon::IsDying[i]) {
    								if (!Weapon::DelayedDeathTimer[i]) {
    									continue;
    								}
    
    								KillTimer(Weapon::DelayedDeathTimer[i]);
    								Weapon::DelayedDeathTimer[i] = 0;
    								ClearAnimations(i, FORCE_SYNC:1);
    								SetFakeFacingAngle(i, _);
    								FreezeSyncPacket(i, .toggle = false);
    
    								Weapon::IsDying[i] = false;
    
    								if (Weapon::DeathTimer[i]) {
    									KillTimer(Weapon::DeathTimer[i]);
    									Weapon::DeathTimer[i] = 0;
    								}
    							}
    
    							health += Weapon::PreviousHits[i][j][e_Health];
    							armour += Weapon::PreviousHits[i][j][e_Armour];
    
    							W_SetPlayerHealth(i, health, armour);
    						}
    					}
    				}
    				Weapon::CbugCount[playerid] = 0;
    			}
    			else
    			{
    				Weapon::CbugCount[playerid]++;
    				Weapon::CbugFroze[playerid] = tick;
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
					Weapon::LastExplosive[playerid] = WEAPON_SATCHEL;
				}

				case WEAPON_ROCKETLAUNCHER, WEAPON_HEATSEEKER, WEAPON_GRENADE: 
				{
					Weapon::LastExplosive[playerid] = weap;
				}
			}
		}
	}

	return W_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	// Send ped floor_hit_f
	if (Weapon::IsDying[playerid] || Weapon::InClassSelection[playerid]) {
		SendLastSyncPacket(playerid, forplayerid, .animation = 0x2e040000 + 1150);
	}

	return W_OnPlayerStreamIn(playerid, forplayerid);
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	Weapon::LastVehicleEnterTime[playerid] = gettime();
	Weapon::LastVehicleTick[playerid] = GetTickCount();

	if (Weapon::IsDying[playerid]) {
		TogglePlayerControllable(playerid, false);
		ApplyAnimation(playerid, "PED", "KO_skid_back", 4.1, false, false, false, true, 0, FORCE_SYNC:1);
	}

	return W_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	Weapon::LastVehicleTick[playerid] = GetTickCount();

	return W_OnPlayerExitVehicle(playerid, vehicleid);
}

public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
	if (Weapon::Spectating[playerid] != INVALID_PLAYER_ID && newstate != PLAYER_STATE_SPECTATING) {
		Weapon::Spectating[playerid] = INVALID_PLAYER_ID;
	}

	if (Weapon::IsDying[playerid] && (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)) {
		TogglePlayerControllable(playerid, false);
	}

	if (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) {
		Weapon::LastVehicleTick[playerid] = GetTickCount();

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
	return W_OnPlayerStateChange(playerid, newstate, oldstate);
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if (!W_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return W_OnPlayerPickUpPickup(playerid, pickupid);
}

public OnPlayerUpdate(playerid)
{
	if (Weapon::TempDataWritten[playerid]) {
		if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
			Weapon::LastSyncData[playerid] = Weapon::TempSyncData[playerid];
			Weapon::TempDataWritten[playerid] = false;
		}
	}

	if (Weapon::IsDying[playerid]) {
		return 1;
	}

	if (Weapon::ForceClassSelection[playerid]) {
		return 0;
	}

	new tick = GetTickCount();

	if (Weapon::DeathSkip[playerid] == 1) {
		if (Weapon::DeathSkipTick[playerid]) {
			if (tick - Weapon::DeathSkipTick[playerid] > 1000) {
				new Float:x, Float:y, Float:z, Float:r;

				GetPlayerPos(playerid, x, y, z);
				GetPlayerFacingAngle(playerid, r);

				SetSpawnInfo(playerid, Weapon::PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);

				Weapon::DeathSkipTick[playerid] = 0;

				new animlib[] = "PED", animname[] = "IDLE_stance";
				ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 1, FORCE_SYNC:1);
			}
		} else {
			if (GetPlayerAnimationIndex(playerid) != 1189) {
				Weapon::DeathSkip[playerid] = 0;

				W_DeathSkipEnd(playerid);

				DebugMessage("Death skip end");
			}
		}
	}

	if (Weapon::SpawnForStreamedIn[playerid]) {
		W_SpawnForStreamedIn(playerid);

		Weapon::SpawnForStreamedIn[playerid] = false;
	}

	Weapon::LastUpdate[playerid] = tick;
	return W_OnPlayerUpdate(playerid);
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
	DebugMessage("pID: %d, DamagedID: %d, Amount: %f, weaponid: %d, bodypart: %d", playerid, damagedid, amount, weaponid, bodypart);
	if (!IsHighRateWeapon(weaponid)) {
		DebugMessage("OnPlayerGiveDamage(%d gave %f to %d using %d on bodypart %s)", playerid, amount, damagedid, weaponid, ReturnBodypartName(bodypart));
	}

	// Nobody got damaged
	if (!IsPlayerConnected(damagedid)) 
	{
		OnInvalidWeaponDamage(playerid, damagedid, amount, weaponid, bodypart, W_NO_DAMAGED, true);

		AddRejectedHit(playerid, damagedid, HIT_NO_DAMAGEDID, weaponid);

		return 0;
	}

	if (Weapon::IsDying[damagedid]) {
		AddRejectedHit(playerid, damagedid, HIT_DYING_PLAYER, weaponid);
		return 0;
	}

	if (!Weapon::LagCompMode) {
		new npc = IsPlayerNPC(damagedid);

		if (weaponid == WEAPON_KNIFE && _:amount == _:0.0) {
			if (damagedid == playerid) {
				return 0;
			}

			if (Weapon::KnifeTimeout[damagedid]) {
				KillTimer(Weapon::KnifeTimeout[damagedid]);
			}

			Weapon::KnifeTimeout[damagedid] = SetTimerEx("W_SetSpawnForStreamedIn", 2500, false, "i", damagedid);
		}

		if (!npc) {
			return 0;
		}
	}

	// Ignore unreliable and invalid damage
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(Weapon::ValidDamageGiven) || !Weapon::ValidDamageGiven[weaponid]) {
		// Fire is synced as taken damage (because it's not reliable as given), so no need to show a rejected hit.
		// Vehicle damage is also synced as taken, so no need to show that either.
		if (weaponid != WEAPON_FLAMETHROWER && weaponid != WEAPON_VEHICLE) {
			AddRejectedHit(playerid, damagedid, HIT_INVALID_WEAPON, weaponid);
		}

		return 0;
	}

	new tick = GetTickCount();
	if (tick == 0) tick = 1;

	if (!W_IsPlayerSpawned(playerid) && tick - Weapon::LastDeathTick[playerid] > 80) {
		// Make sure the rejected hit wasn't added in OnPlayerWeaponShot
		if (!IsBulletWeapon(weaponid) || Weapon::LastShot[playerid][e_Valid]) {
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
				if (Weapon::KnifeTimeout[damagedid]) {
					KillTimer(Weapon::KnifeTimeout[damagedid]);
				}

				Weapon::KnifeTimeout[damagedid] = SetTimerEx("W_SpawnForStreamedIn", 150, false, "i", damagedid);
				ClearAnimations(playerid, FORCE_SYNC:1);
				SetPlayerArmedWeapon(playerid, w);

				return 0;
			} else {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);

				if (GetPlayerDistanceFromPoint(damagedid, x, y, z) > Weapon::WeaponRange[weaponid] + 2.0) {
					if (Weapon::KnifeTimeout[damagedid]) {
						KillTimer(Weapon::KnifeTimeout[damagedid]);
					}

					Weapon::KnifeTimeout[damagedid] = SetTimerEx("W_SpawnForStreamedIn", 150, false, "i", damagedid);
					ClearAnimations(playerid, FORCE_SYNC:1);
					SetPlayerArmedWeapon(playerid, w);

					return 0;
				}
			}

			if (!OnPlayerDamage(damagedid, amount, playerid, weaponid, bodypart)) {
				if (Weapon::KnifeTimeout[damagedid]) {
					KillTimer(Weapon::KnifeTimeout[damagedid]);
				}

				Weapon::KnifeTimeout[damagedid] = SetTimerEx("W_SpawnForStreamedIn", 150, false, "i", damagedid);
				ClearAnimations(playerid, FORCE_SYNC:1);
				SetPlayerArmedWeapon(playerid, w);

				return 0;
			}

			Weapon::DamageDoneHealth[playerid] = Weapon::PlayerHealth[playerid];
			Weapon::DamageDoneArmour[playerid] = Weapon::PlayerArmour[playerid];

			OnPlayerDamageDone(damagedid, Weapon::PlayerHealth[damagedid] + Weapon::PlayerArmour[damagedid], playerid, weaponid, bodypart);

			ClearAnimations(damagedid, FORCE_SYNC:1);

			new animlib[32] = "KNIFE", animname[32] = "KILL_Knife_Ped_Damage";
			PlayerDeath(damagedid, animlib, animname, _, 5200);

			SetTimerEx("W_SecondKnifeAnim", 2200, false, "i", damagedid);

			W_OnPlayerDeath(damagedid, playerid, weaponid);

			DebugMessage("being knifed by %d", playerid);
			DebugMessage("knifing %d", damagedid);

			new Float:angle;

			GetPlayerFacingAngle(damagedid, angle);
			SetPlayerFacingAngle(playerid, angle);

			SetPlayerVelocity(damagedid, 0.0, 0.0, 0.0);
			SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);

			new forcesync = 2;

			if (747 < GetPlayerAnimationIndex(playerid) > 748) {
				DebugMessageRed("applying knife anim for you too (current: %d)", GetPlayerAnimationIndex(playerid));

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
	if ((!IsPlayerStreamedIn(playerid, damagedid) && !W_IsPlayerPaused(damagedid)) || !IsPlayerStreamedIn(damagedid, playerid)) {
		AddRejectedHit(playerid, damagedid, HIT_UNSTREAMED, weaponid, damagedid);
		return 0;
	}

	new Float:bullets, err;

	if ((err = ProcessDamage(damagedid, playerid, amount, weaponid, bodypart, bullets))) 
	{
		//if (err == W_INVALID_DAMAGE) 
		//{
		//	amount = Weapon::WeaponDamage[weaponid];
		//	//AddRejectedHit(playerid, damagedid, HIT_INVALID_DAMAGE, weaponid, _:amount);
		//}

		if (err != W_INVALID_DISTANCE && err != W_INVALID_DAMAGE) 
		{
			OnInvalidWeaponDamage(playerid, damagedid, amount, weaponid, bodypart, err, true);
			return 0;
		}

		//return 0;
	}

	new idx = (Weapon::LastHitIdx[playerid] + 1) % sizeof(Weapon::LastHitTicks[]);

	// JIT plugin fix
	if (idx < 0) 
	{
		idx += sizeof(Weapon::LastHitTicks[]);
	}

	Weapon::LastHitIdx[playerid] = idx;
	Weapon::LastHitTicks[playerid][idx] = tick;
	Weapon::LastHitWeapons[playerid][idx] = weaponid;
	Weapon::HitsIssued[playerid] += 1;

	#if defined W_DEBUG
		if (Weapon::HitsIssued[playerid] > 1) {
			new prev_tick_idx = (idx - 1) % sizeof(Weapon::LastHitTicks[]);

			// JIT plugin fix
			if (prev_tick_idx < 0) {
				prev_tick_idx += sizeof(Weapon::LastHitTicks[]);
			}

			new prev_tick = Weapon::LastHitTicks[playerid][prev_tick_idx];

			DebugMessage("(hit) last: %d last 3: %d", tick - prev_tick, AverageHitRate(playerid, 3));
		}
	#endif

	new multiple_weapons;
	new avg_rate = AverageHitRate(playerid, Weapon::MaxHitRateSamples, multiple_weapons);

	// Hit issue flood?
	// Could be either a cheat or just lag
	if (avg_rate != -1) 
	{
		if (multiple_weapons) 
		{
			if (avg_rate < 100) 
			{
				AddRejectedHit(playerid, damagedid, HIT_RATE_TOO_FAST_MULTIPLE, weaponid, avg_rate, Weapon::MaxHitRateSamples);
				return 0;
			}
		} 
		else if (Weapon::MaxWeaponShootRate[weaponid] - avg_rate > 20) 
		{
			AddRejectedHit(playerid, damagedid, HIT_RATE_TOO_FAST, weaponid, avg_rate, Weapon::MaxHitRateSamples, Weapon::MaxWeaponShootRate[weaponid]);
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
		if (!Weapon::LastShot[playerid][e_Valid]) 
		{
			valid = false;
			//AddRejectedHit(playerid, damagedid, HIT_LAST_SHOT_INVALID, weaponid);
			DebugMessageRed("last shot not valid");
		} 
		else if (WEAPON_SHOTGUN <= weaponid <= WEAPON_SHOTGSPA) 
		{
			// Let's assume someone won't hit 2 players with 1 shotgun shot, and that one OnPlayerWeaponShot can be out of sync
			if (Weapon::LastShot[playerid][e_Hits] >= 2) 
			{
				valid = false;
				AddRejectedHit(playerid, damagedid, HIT_MULTIPLE_PLAYERS_SHOTGUN, weaponid, Weapon::LastShot[playerid][e_Hits] + 1);
			}
		} 
		else if (Weapon::LastShot[playerid][e_Hits] > 0) 
		{
			// Sniper doesn't always send OnPlayerWeaponShot
			if (Weapon::LastShot[playerid][e_Hits] >= 3 && weaponid != WEAPON_SNIPER) 
			{
				valid = false;
				AddRejectedHit(playerid, damagedid, HIT_MULTIPLE_PLAYERS, weaponid, Weapon::LastShot[playerid][e_Hits] + 1);
			} 
			else 
			{
				DebugMessageRed("hit %d players with 1 shot", Weapon::LastShot[playerid][e_Hits] + 1);
			}
		}

		if (valid) 
		{
			new Float:dist = GetPlayerDistanceFromPoint(damagedid, Weapon::LastShot[playerid][e_HX], Weapon::LastShot[playerid][e_HY], Weapon::LastShot[playerid][e_HZ]);

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

		Weapon::LastShot[playerid][e_Hits] += 1;
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

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
	if(weaponid == WEAPON_COLLISION && issuerid == INVALID_PLAYER_ID && amount >= 4.95)
	{
		CallLocalFunction("OnPlayerFall", "if", playerid, amount);
	}
	
	DebugMessage("pID: %d, Issuer: %d, Amount: %f, weaponid: %d, bodypart: %d", playerid, issuerid, amount, weaponid, bodypart);
	if (IsPlayerNPC(playerid)) 
	{
		return 0;
	}

	UpdateHealthBar(playerid, true);

	if (!W_IsPlayerSpawned(playerid)) 
	{
		return 0;
	}

	if (!IsHighRateWeapon(weaponid)) 
	{
		DebugMessage("OnPlayerTakeDamage(%d took %f from %d by %d on bodypart %d)", playerid, amount, issuerid, weaponid, bodypart);
	}

	// Ignore unreliable and invalid damage
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(Weapon::ValidDamageTaken) || !Weapon::ValidDamageTaken[weaponid]) 
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
			DebugMessage("climb bug prevented");
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

			if (Weapon::KnifeTimeout[playerid]) 
			{
				KillTimer(Weapon::KnifeTimeout[playerid]);

				Weapon::KnifeTimeout[playerid] = 0;
			}

			if (issuerid == INVALID_PLAYER_ID || HasSameTeam(playerid, issuerid)) {
				ResyncPlayer(playerid);

				return 0;
			} else {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(issuerid, x, y, z);

				if (GetPlayerDistanceFromPoint(playerid, x, y, z) > Weapon::WeaponRange[weaponid] + 2.0) {
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

			Weapon::DamageDoneHealth[playerid] = Weapon::PlayerHealth[playerid];
			Weapon::DamageDoneArmour[playerid] = Weapon::PlayerArmour[playerid];

			OnPlayerDamageDone(playerid, Weapon::PlayerHealth[playerid] + Weapon::PlayerArmour[playerid], issuerid, weaponid, bodypart);

			new animlib[32] = "KNIFE", animname[32] = "KILL_Knife_Ped_Die";
			PlayerDeath(playerid, animlib, animname, _, 4000 - GetPlayerPing(playerid));

			W_OnPlayerDeath(playerid, issuerid, weaponid);

			SetPlayerHealth(playerid, 0.9);

			DebugMessage("being knifed by %d", issuerid);
			DebugMessage("knifing %d", playerid);

			new Float:a;

			GetPlayerFacingAngle(playerid, a);
			SetPlayerFacingAngle(issuerid, a);

			SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
			SetPlayerVelocity(issuerid, 0.0, 0.0, 0.0);

			new forcesync = 2;

			if (GetPlayerAnimationIndex(issuerid) != 747) {
				DebugMessageRed("applying knife anim for you too (current: %d)", GetPlayerAnimationIndex(issuerid));

				forcesync = 1;
			}

			animname = "KILL_Knife_Player";
			ApplyAnimation(issuerid, animlib, animname, 4.1, false, true, true, false, 1800, FORCE_SYNC:forcesync);

			return 0;
		}
	}

	// If it's lagcomp, only allow damage that's valid for both modes
	if (Weapon::LagCompMode && Weapon::ValidDamageTaken[weaponid] != 2) {
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

		if (Weapon::IsDying[issuerid] && (IsBulletWeapon(weaponid) || IsMeleeWeapon(weaponid)) && GetTickCount() - Weapon::LastDeathTick[issuerid] > 80) {
			DebugMessageRed("shot/punched by dead player (%d)", issuerid);
			return 0;
		}

		if (Weapon::BeingResynced[issuerid]) {
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
		if ((!IsPlayerStreamedIn(playerid, issuerid) && !W_IsPlayerPaused(issuerid)) || !IsPlayerStreamedIn(issuerid, playerid)) {
			// Probably fake or belated damage, so let's just reset issuerid
			issuerid = INVALID_PLAYER_ID;
		}
	}

	new Float:bullets = 0.0, err;

	if ((err = ProcessDamage(playerid, issuerid, amount, weaponid, bodypart, bullets))) 
	{
		//if (err == W_INVALID_DAMAGE) 
		//{
		//	amount = Weapon::WeaponDamage[weaponid];
		//	//AddRejectedHit(issuerid, playerid, HIT_INVALID_DAMAGE, weaponid, _:amount);
		//}

		if (err != W_INVALID_DISTANCE) 
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

		if (dist > Weapon::WeaponRange[weaponid] + 2.0) 
		{
			AddRejectedHit(issuerid, playerid, HIT_OUT_OF_RANGE, weaponid, _:dist, _:Weapon::WeaponRange[weaponid]);
			return 0;
		}
	}

	InflictDamage(playerid, amount, issuerid, weaponid, bodypart);

	return 0;
}

public OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{

	Weapon::LastShot[playerid][e_Valid] = false;

	new tick = GetTickCount();
	if (tick == 0) tick = 1;

	if (Weapon::CbugFroze[playerid] && tick - Weapon::CbugFroze[playerid] < 900) {
		return 0;
	}

	Weapon::CbugFroze[playerid] = 0;

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

	//#if defined W_DEBUG
	//	if (hittype == BULLET_HIT_TYPE_PLAYER) {
	//		DebugMessage("OnPlayerWeaponShot(%d shot %d with %d at %f, %f, %f)", playerid, hitid, weaponid, fX, fY, fZ);
	//	} else if (hittype) {
	//		DebugMessage("OnPlayerWeaponShot(%d shot %d %d with %d at %f, %f, %f)", playerid, hittype, hitid, weaponid, fX, fY, fZ);
	//	} else {
	//		DebugMessage("OnPlayerWeaponShot(%d shot with %d at %f, %f, %f)", playerid, weaponid, fX, fY, fZ);
	//	}
	//#endif

	if (Weapon::BeingResynced[playerid]) {
		AddRejectedHit(playerid, damagedid, HIT_BEING_RESYNCED, weaponid);

		return 0;
	}

	if (!W_IsPlayerSpawned(playerid) && tick - Weapon::LastDeathTick[playerid] > 80) {
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
		if (length > Weapon::WeaponRange[weaponid]) {
			if (hittype == BULLET_HIT_TYPE_PLAYER) {
				AddRejectedHit(playerid, damagedid, HIT_OUT_OF_RANGE, weaponid, _:length, _:Weapon::WeaponRange[weaponid]);
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

	new idx = (Weapon::LastShotIdx[playerid] + 1) % sizeof(Weapon::LastShotTicks[]);

	// JIT plugin fix
	if (idx < 0) {
		idx += sizeof(Weapon::LastShotTicks[]);
	}

	Weapon::LastShotIdx[playerid] = idx;
	Weapon::LastShotTicks[playerid][idx] = tick;
	Weapon::LastShotWeapons[playerid][idx] = weaponid;
	Weapon::ShotsFired[playerid] += 1;

	#if defined W_DEBUG
		if (Weapon::ShotsFired[playerid] > 1) {
			new prev_tick_idx = (idx - 1) % sizeof(Weapon::LastShotTicks[]);

			// JIT plugin fix
			if (prev_tick_idx < 0) {
				prev_tick_idx += sizeof(Weapon::LastShotTicks[]);
			}

			//new prev_tick = Weapon::LastShotTicks[playerid][prev_tick_idx];

			//DebugMessage("(shot) last: %d last 3: %d", tick - prev_tick, AverageShootRate(playerid, 3));
		}
	#endif

	Weapon::LastShot[playerid][e_Tick] = tick;
	Weapon::LastShot[playerid][e_Weapon] = weaponid;
	Weapon::LastShot[playerid][e_HitType] = hittype;
	Weapon::LastShot[playerid][e_HitId] = hitid;
	Weapon::LastShot[playerid][e_X] = fX;
	Weapon::LastShot[playerid][e_Y] = fY;
	Weapon::LastShot[playerid][e_Z] = fZ;
	Weapon::LastShot[playerid][e_OX] = fOriginX;
	Weapon::LastShot[playerid][e_OY] = fOriginY;
	Weapon::LastShot[playerid][e_OZ] = fOriginZ;
	Weapon::LastShot[playerid][e_HX] = fHitPosX;
	Weapon::LastShot[playerid][e_HY] = fHitPosY;
	Weapon::LastShot[playerid][e_HZ] = fHitPosZ;
	Weapon::LastShot[playerid][e_Length] = length;
	Weapon::LastShot[playerid][e_Hits] = 0;

	new multiple_weapons;
	new avg_rate = AverageShootRate(playerid, Weapon::MaxShootRateSamples, multiple_weapons);

	// Bullet flood?
	// Could be either a cheat or just lag
	if (avg_rate != -1) {
		if (multiple_weapons) {
			if (avg_rate < 100) {
				AddRejectedHit(playerid, damagedid, SHOOTING_RATE_TOO_FAST_MULTIPLE, weaponid, avg_rate, Weapon::MaxShootRateSamples);
				return 0;
			}
		} else if (Weapon::MaxWeaponShootRate[weaponid] - avg_rate > 20) {
			AddRejectedHit(playerid, damagedid, SHOOTING_RATE_TOO_FAST, weaponid, avg_rate, Weapon::MaxShootRateSamples, Weapon::MaxWeaponShootRate[weaponid]);
			return 0;
		}
	}

	// Destroy vehicles with passengers in them
	if (hittype == BULLET_HIT_TYPE_VEHICLE) {
		if (hitid < 0 || hitid > MAX_VEHICLES || !W_IsValidVehicle(hitid)) {
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

		if (Weapon::VehiclePassengerDamage) {
			new has_driver = false;
			new has_passenger = false;
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
					has_driver = true;
				} else {
					has_passenger = true;
				}
			}

			if (!has_driver && has_passenger) {
				new Float:health;

				GetVehicleHealth(hitid, health);

				if (WEAPON_SHOTGUN <= weaponid <= WEAPON_SHOTGSPA) {
					health -= 120.0;
				} else {
					health -= Weapon::WeaponDamage[weaponid] * 3.0;
				}

				if (health <= 0.0) {
					health = 0.0;
				}

				SetVehicleHealth(hitid, health);
			}
		}

		if (Weapon::VehicleUnoccupiedDamage) {
			new has_occupent = false;

			foreach (new otherid : Player) {
				if (otherid == playerid) {
					continue;
				}

				if (GetPlayerVehicleID(otherid) != hitid) {
					continue;
				}

				has_occupent = true;
			}

			if (!has_occupent) {
				new Float:health;

				GetVehicleHealth(hitid, health);
				if (health >= 250.0) { // vehicles start on fire below 250 hp
					if (WEAPON_SHOTGUN <= weaponid <= WEAPON_SHOTGSPA) {
						health -= 120.0;
					} else {
						health -= Weapon::WeaponDamage[weaponid] * 3.0;
					}

					if (health < 250.0) {
						if (!Weapon::VehicleRespawnTimer[hitid]) {
							health = 249.0;
							Weapon::VehicleRespawnTimer[hitid] = SetTimerEx("W_KillVehicle", 6000, false, "ii", hitid, playerid);
						}
					}

					SetVehicleHealth(hitid, health);
				}
			}
		}
	}

	new retval = W_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, fX, fY, fZ);

	Weapon::LastShot[playerid][e_Valid] = !!retval;

	// Valid shot?
	if (retval) {
		if (hittype == BULLET_HIT_TYPE_VEHICLE) {
			Weapon::LastVehicleShooter[hitid] = playerid;
		}
	}

	return retval;
}

forward W_KillVehicle(vehicleid, killerid);
public W_KillVehicle(vehicleid, killerid)
{
	OnVehicleDeath(vehicleid, killerid);
	Weapon::VehicleRespawnTimer[vehicleid] = SetTimerEx("W_OnDeadVehicleSpawn", 10000, false, "i", vehicleid);
	return 1;
}

forward W_OnDeadVehicleSpawn(vehicleid);
public W_OnDeadVehicleSpawn(vehicleid)
{
	Weapon::VehicleRespawnTimer[vehicleid] = 0;
	return SetVehicleToRespawn(vehicleid);
}

public OnVehicleSpawn(vehicleid)
{
	if (Weapon::VehicleRespawnTimer[vehicleid]) {
		KillTimer(Weapon::VehicleRespawnTimer[vehicleid]);
		Weapon::VehicleRespawnTimer[vehicleid] = 0;
	}

	Weapon::VehicleAlive[vehicleid] = true;
	Weapon::LastVehicleShooter[vehicleid] = INVALID_PLAYER_ID;

	return W_OnVehicleSpawn(vehicleid);
}

public OnVehicleDeath(vehicleid, killerid)
{
	if (Weapon::VehicleRespawnTimer[vehicleid]) {
		KillTimer(Weapon::VehicleRespawnTimer[vehicleid]);
		Weapon::VehicleRespawnTimer[vehicleid] = 0;
	}

	if (Weapon::VehicleAlive[vehicleid]) {
		Weapon::VehicleAlive[vehicleid] = false;

		return W_OnVehicleDeath(vehicleid, killerid);
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if (!W_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return W_OnPlayerEnterCheckpoint(playerid);
}

public OnPlayerLeaveCheckpoint(playerid)
{
	// If they're dying, it will be called in PlayerDeath (when the death anim begins)
	if (Weapon::IsDying[playerid]) {
		return 0;
	}

	return W_OnPlayerLeaveCheckpoint(playerid);
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if (!W_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return W_OnPlayerEnterRaceCheckpoint(playerid);
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	// If they're dying, it will be called in PlayerDeath (when the death anim begins)
	if (Weapon::IsDying[playerid]) {
		return 0;
	}

	return W_OnPlayerLeaveRaceCheckpoint(playerid);
}

/*
 * Pawn.RakNet handlers
 */
IPacket:PLAYER_SYNC(playerid, BitStream:bs)
{
	new onFootData[PR_OnFootSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadOnFootSync(bs, onFootData);

	// Because of detonator crasher - Sends KEY_HANDBRAKE/KEY_AIM in this packet and cam mode IDs 7, 8, 34, 45, 46, 51 and 65 in W_AIM_SYNC
	if (onFootData[PR_weaponId] == _:WEAPON_BOMB) {
		onFootData[PR_keys] &= ~_:KEY_HANDBRAKE;
	}

	if (Weapon::DisableSyncBugs) {
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

	if (Weapon::SyncDataFrozen[playerid]) {
		onFootData = Weapon::LastSyncData[playerid];
	} else {
		Weapon::TempSyncData[playerid] = onFootData;
		Weapon::TempDataWritten[playerid] = true;
	}

	if (Weapon::FakeHealth{playerid} != 255) {
		onFootData[PR_health] = Weapon::FakeHealth{playerid};
	}

	if (Weapon::FakeArmour{playerid} != 255) {
		onFootData[PR_armour] = Weapon::FakeArmour{playerid};
	}

	if (Weapon::FakeQuat[playerid][0] == Weapon::FakeQuat[playerid][0]) {
		onFootData[PR_quaternion] = Weapon::FakeQuat[playerid];
	}

	if (onFootData[PR_weaponId] == _:WEAPON_KNIFE && !Weapon::KnifeSync) {
		// Remove aim key
		onFootData[PR_keys] &= ~_:KEY_HANDBRAKE;
	} else if (onFootData[PR_weaponId] == 0) { // Punch Sync PC - Mobile
        if(onFootData[PR_keys] & _:KEY_FIRE) {
        	// Remove fire key
        	if(onFootData[PR_animationId] == 0) { // Fix punch sync mobile)
        	    if(GetTickCount() - Weapon::PunchTick[playerid] > 300)
        	    {
        	    	onFootData[PR_keys] = 4;
                    Weapon::PunchTick[playerid] = GetTickCount();
        	    }
        	    else
        	    {
        	    	onFootData[PR_keys] = 0;
        	    }
        	}
        	else 
        	{
                if(Weapon::PunchUsed[playerid] == 0)
                {
                	Weapon::PunchUsed[playerid] = 1;
                }
                else
                {
                	onFootData[PR_keys] &= ~_:KEY_FIRE;
                }
        	}
        }
        else
        {
            Weapon::PunchUsed[playerid] = 0;
        }
	} else if (44 <= onFootData[PR_weaponId] <= 45) {
		// Remove fire key
		onFootData[PR_keys] &= ~_:KEY_FIRE;

		// Keep preventing for some more packets
		Weapon::GogglesTick[playerid] = GetTickCount();
		Weapon::GogglesUsed[playerid] = 1;
	} else if (Weapon::GogglesUsed[playerid]) {
		if (Weapon::GogglesUsed[playerid] == 2 && GetTickCount() - Weapon::GogglesTick[playerid] > 40) {
			Weapon::GogglesUsed[playerid] = 0;
		} else {
			// Remove fire key
			onFootData[PR_keys] &= ~_:KEY_FIRE;

			Weapon::GogglesTick[playerid] = GetTickCount();
			Weapon::GogglesUsed[playerid] = 2;
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

	if (Weapon::FakeHealth{playerid} != 255) {
		inCarData[PR_playerHealth] = Weapon::FakeHealth{playerid};
	}

	if (Weapon::FakeArmour{playerid} != 255) {
		inCarData[PR_armour] = Weapon::FakeArmour{playerid};
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

	if (Weapon::FakeHealth{playerid} != 255) {
		passengerData[PR_playerHealth] = Weapon::FakeHealth{playerid};
	}

	if (Weapon::FakeArmour{playerid} != 255) {
		passengerData[PR_playerArmour] = Weapon::FakeArmour{playerid};
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
	if (_:WEAPON_SNIPER <= Weapon::LastSyncData[playerid][PR_weaponId] <= _:WEAPON_HEATSEEKER
	|| Weapon::LastSyncData[playerid][PR_weaponId] == _:WEAPON_CAMERA) {
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
	new BulletData[PR_BulletSync];
	new str[64];
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
    //format(str, 64, "oX: %f | oY: %f | oZ: %f", BulletData[PR_offsets][0], BulletData[PR_offsets][1], BulletData[PR_offsets][2]);
    //SendClientMessageToAll(-1, str);
    BS_SetWriteOffset(bs, 8);
    BS_WriteBulletSync(bs, BulletData);
	return 1;
}

/*
 * Internal functions
 */

static ScriptInit()
{
	Weapon::LagCompMode = GetConsoleVarAsInt("lagcompmode");

	if (Weapon::LagCompMode) {
		SetKnifeSync(false);
	} else {
		SetKnifeSync(true);
	}

	for (new i = 0; i < sizeof(Weapon::ClassSpawnInfo); i++) {
		Weapon::ClassSpawnInfo[i][e_Skin] = -1;
	}

	new worldid, tick = GetTickCount();

	foreach (new playerid : Player) {
		Weapon::PlayerTeam[playerid] = GetPlayerTeam(playerid);

		SetPlayerTeam(playerid, Weapon::PlayerTeam[playerid]);

		worldid = GetPlayerVirtualWorld(playerid);

		if (worldid == W_DEATH_WORLD) {
			worldid = 0;

			SetPlayerVirtualWorld(playerid, worldid);
		}

		Weapon::World[playerid] = worldid;
		Weapon::LastUpdate[playerid] = tick;
		Weapon::LastStop[playerid] = tick;
		Weapon::LastVehicleEnterTime[playerid] = 0;
		Weapon::TrueDeath[playerid] = true;
		Weapon::InClassSelection[playerid] = true;
		Weapon::AlreadyConnected[playerid] = true;

		if (PLAYER_STATE_ONFOOT <= GetPlayerState(playerid) <= PLAYER_STATE_PASSENGER) {
			GetPlayerHealth(playerid, Weapon::PlayerHealth[playerid]);
			GetPlayerArmour(playerid, Weapon::PlayerArmour[playerid]);

			if (Weapon::PlayerHealth[playerid] == 0.0) {
				Weapon::PlayerHealth[playerid] = Weapon::PlayerMaxHealth[playerid];
			}

			UpdateHealthBar(playerid);
		}
	}
}

static ScriptExit()
{
	SetKnifeSync(true);

	new Float:health;

	foreach (new playerid : Player) {
		// Put things back the way they were
		SetPlayerTeam(playerid, Weapon::PlayerTeam[playerid]);

		if (PLAYER_STATE_ONFOOT <= GetPlayerState(playerid) <= PLAYER_STATE_PASSENGER) {
			health = Weapon::PlayerHealth[playerid];

			if (health == 0.0) {
				health = Weapon::PlayerMaxHealth[playerid];
			}

			SetPlayerHealth(playerid, health);
			SetPlayerArmour(playerid, Weapon::PlayerArmour[playerid]);
		}

		SetFakeHealth(playerid, 255);
		SetFakeArmour(playerid, 255);
		FreezeSyncPacket(playerid, .toggle = false);
		SetFakeFacingAngle(playerid, _);
	}
}

static UpdatePlayerVirtualWorld(playerid)
{
	new worldid = GetPlayerVirtualWorld(playerid);

	if (worldid == W_DEATH_WORLD) {
		worldid = Weapon::World[playerid];
	} else if (worldid != Weapon::World[playerid]) {
		Weapon::World[playerid] = worldid;
	}

	SetPlayerVirtualWorld(playerid, worldid);
}

static HasSameTeam(playerid, otherid)
{
	if (otherid < 0 || otherid >= MAX_PLAYERS || playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (Weapon::PlayerTeam[playerid] == NO_TEAM || Weapon::PlayerTeam[otherid] == NO_TEAM) {
		return 0;
	}

	return (Weapon::PlayerTeam[playerid] == Weapon::PlayerTeam[otherid]);
}

static UpdateHealthBar(playerid, bool:force = false)
{
	if (Weapon::BeingResynced[playerid] || Weapon::ForceClassSelection[playerid]) {
		return;
	}

	new health = floatround(Weapon::PlayerHealth[playerid] / Weapon::PlayerMaxHealth[playerid] * 100.0, floatround_ceil);
	new armour = floatround(Weapon::PlayerArmour[playerid] / Weapon::PlayerMaxArmour[playerid] * 100.0, floatround_ceil);

	// Make the values reflect what the client should see
	if (Weapon::IsDying[playerid]) {
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
		Weapon::LastSentHealth[playerid] = -1;
		Weapon::LastSentArmour[playerid] = -1;
	} 
	else if (!Weapon::IsDying[playerid]) 
	{
		Weapon::LastSentHealth[playerid] = -1;
	} 
	else if (health == Weapon::LastSentHealth[playerid] && armour == Weapon::LastSentArmour[playerid]) 
	{
		return;
	}

	SetFakeHealth(playerid, health);
	SetFakeArmour(playerid, armour);

	// Hit Mark Status
    Weapon::HitInformer[playerid] = 1;
    if(Weapon::HitInformerTimer[playerid] == 0)
    {
    	SetPlayerColor(playerid, 0xFF0000FF);
        Weapon::HitInformerTimer[playerid] = SetTimerEx("HitInformer", 350, true, "d", playerid);
    }

	UpdateSyncData(playerid);

	if (health != Weapon::LastSentHealth[playerid]) {
		Weapon::LastSentHealth[playerid] = health;
		if(health == 0.0)
		{
			SetPlayerHealth(playerid, 0.9);
		}
		else
		{
            SetPlayerHealth(playerid, float(health));
		}
	}

	if (armour != Weapon::LastSentArmour[playerid]) {
		Weapon::LastSentArmour[playerid] = armour;

		SetPlayerArmour(playerid, float(armour));
	}
}

forward HitInformer(playerid);
public HitInformer(playerid)
{
    if(Weapon::HitInformer[playerid] == 0)
    {
    	SetPlayerColor(playerid, 0xFFFFFFFF);
        KillTimer(Weapon::HitInformerTimer[playerid]);
        Weapon::HitInformerTimer[playerid] = 0;
    }
    else
    {
        Weapon::HitInformer[playerid] = 0;
    }
    return 1;
}

static SpawnPlayerInPlace(playerid) {
	new Float:x, Float:y, Float:z, Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	SetSpawnInfo(playerid, Weapon::PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);

	Weapon::SpawnInfoModified[playerid] = true;

	SpawnPlayer(playerid);
}

static Float:AngleBetweenPoints(Float:x1, Float:y1, Float:x2, Float:y2)
{
	return -(90.0 - atan2(y1 - y2, x1 - x2));
}

static UpdateSyncData(playerid)
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

static WasPlayerInVehicle(playerid, time) {
	if (!Weapon::LastVehicleTick[playerid]) {
		return 0;
	}

	if (GetTickCount() - time < Weapon::LastVehicleTick[playerid]) {
		return 1;
	}

	return 0;
}

forward W_DeathSkipEnd(playerid);
public W_DeathSkipEnd(playerid)
{
	TogglePlayerControllable(playerid, true);

	ResetPlayerWeapons(playerid);

	for (new i = 0; i < 13; i++) {
		if (Weapon::SyncData[playerid][e_WeaponId][i]) {
			GivePlayerWeapon(playerid, Weapon::SyncData[playerid][e_WeaponId][i], Weapon::SyncData[playerid][e_WeaponAmmo][i]);
		}
	}

	SetPlayerArmedWeapon(playerid, Weapon::SyncData[playerid][e_Weapon]);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
}

forward W_SpawnForStreamedIn(playerid);
public W_SpawnForStreamedIn(playerid)
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

forward W_SetSpawnForStreamedIn(playerid);
public W_SetSpawnForStreamedIn(playerid)
{
	Weapon::SpawnForStreamedIn[playerid] = true;
}

static ProcessDamage(&playerid, &issuerid, &Float:amount, &WEAPON:weaponid, &bodypart, &Float:bullets)
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
		//if (_:Weapon::WeaponDamage[weaponid] != _:1.0) 
		//{
		//	amount *= Weapon::WeaponDamage[weaponid];
		//}

		// Make sure the distance and issuer is valid; carpark can be self-inflicted so it doesn't require an issuer
		if (weaponid == WEAPON_SPRAYCAN || weaponid == WEAPON_FIREEXTINGUISHER || (weaponid == WEAPON_CARPARK && issuerid != INVALID_PLAYER_ID)) {
			if (issuerid == INVALID_PLAYER_ID) {
				return W_NO_ISSUER;
			}

			new Float:x, Float:y, Float:z, Float:dist;
			GetPlayerPos(issuerid, x, y, z);
			dist = GetPlayerDistanceFromPoint(playerid, x, y, z);

			if (weaponid == WEAPON_CARPARK) 
			{
				if (dist > 15.0) 
				{
					AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist);
					return W_INVALID_DISTANCE;
				}
			} 
			else 
			{
				if (dist > Weapon::WeaponRange[weaponid] + 2.0) 
				{
					AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist, _:Weapon::WeaponRange[weaponid]);
					return W_INVALID_DISTANCE;
				}
			}
		}

		return W_NO_ERROR;
	}

	// Bullet or melee damage must have an issuerid, otherwise something has gone wrong (e.g. sniper bug)
	if (issuerid == INVALID_PLAYER_ID && (IsBulletWeapon(weaponid) || IsMeleeWeapon(weaponid))) 
	{
		return W_NO_ISSUER;
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
			else if (Weapon::LastExplosive[issuerid]) 
			{
				weaponid = Weapon::LastExplosive[issuerid];
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
		return W_INVALID_DAMAGE;
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
					DebugMessage("weapon changed from %d to melee (punch & swap)", weaponid);
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
							DebugMessage("weapon changed from %d to melee (punch & swap)", weaponid);
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
					DebugMessage("weapon changed from %d to melee (punch & swap)", weaponid);
					melee = true;
					weaponid = WEAPON_UNARMED;
					amount = 1.32000005245208740234375;
				}

				// Be extra sure about this one
				if (GetPlayerFightingStyle(issuerid) != FIGHT_STYLE_KNEEHEAD) 
				{
					return W_INVALID_DAMAGE;
				}
			}

			// Melee damage has been tampered with
			default: 
			{
				if (melee) 
				{
					return W_INVALID_DAMAGE;
				}
			}
		}
	}

	if (melee) 
	{
		new Float:x, Float:y, Float:z, Float:dist;
		GetPlayerPos(issuerid, x, y, z);
		dist = GetPlayerDistanceFromPoint(playerid, x, y, z);

		if (_:WEAPON_UNARMED <= _:weaponid < sizeof(Weapon::WeaponRange) && dist > Weapon::WeaponRange[weaponid] + 2.0) 
		{
			AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist, _:Weapon::WeaponRange[weaponid]);
			return W_INVALID_DISTANCE;
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
				return W_INVALID_DAMAGE;
			}
		}

		// Shotguns and sawed-off shotguns shoot 15 bullets, each inflicting 3.3 damage
		case WEAPON_SHOTGUN, WEAPON_SAWEDOFF: 
		{
			bullets = amount / 3.30000019073486328125;

			if (15.0 - bullets < -0.05) 
			{
				return W_INVALID_DAMAGE;
			}
		}
	}

	if (_:bullets) 
	{
		new Float:f = floatfract(bullets);

		// The damage for each bullet has been tampered with
		if (f > 0.01 && f < 0.99) 
		{
			return W_INVALID_DAMAGE;
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
				return W_INVALID_DAMAGE;
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
				return W_INVALID_DAMAGE;
			}
		}
	}

	// Adjust the damage
	switch (Weapon::DamageType[weaponid]) 
	{
		case DAMAGE_TYPE_MULTIPLIER: 
		{
			if (_:Weapon::WeaponDamage[weaponid] != _:1.0) 
			{
				amount *= Weapon::WeaponDamage[weaponid];
			}
		}

		case DAMAGE_TYPE_STATIC: 
		{
			new Float:length = 0.0;
			if (Weapon::LagCompMode) 
			{
				length = Weapon::LastShot[issuerid][e_Length];
				if (_:bullets) 
			    {
			    	amount = Weapon::WeaponDamage[weaponid] * bullets;
			    } 
			    else 
			    {
			    	amount = Weapon::WeaponDamage[weaponid];
			    }
			} 
			else 
			{
				new Float:X, Float:Y, Float:Z;
				GetPlayerPos(issuerid, X, Y, Z);
				length = GetPlayerDistanceFromPoint(playerid, X, Y, Z);

				if (_:bullets) 
			    {
			    	amount = Weapon::WeaponDamage[weaponid] * bullets;
			    } 
			    else 
			    {
			    	amount = Weapon::WeaponDamage[weaponid];
			    }
			}
		}
	}

	return W_NO_ERROR;
}

static InflictDamage(playerid, Float:amount, issuerid = INVALID_PLAYER_ID, WEAPON:weaponid = WEAPON_UNKNOWN, bodypart = BODY_PART_UNKNOWN, bool:ignore_armour = false)
{
	if (!W_IsPlayerSpawned(playerid) || amount < 0.0) 
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

		#if defined W_DEBUG
			new Float:length = 0.0;

			if (issuerid != INVALID_PLAYER_ID) 
			{
				if (IsBulletWeapon(weaponid)) 
				{
					length = Weapon::LastShot[issuerid][e_Length];
				}
			}

			if (!IsHighRateWeapon(weaponid)) 
			{
				DebugMessage("!InflictDamage(%d, %.4f, %d, %d, %d) length = %f", playerid, amount, issuerid, weaponid, bodypart, length);
			}
		#endif

		return;
	}

	if (weaponid < WEAPON_UNARMED || weaponid > WEAPON_UNKNOWN) 
	{
		weaponid = WEAPON_UNKNOWN;
	}

	#if defined W_DEBUG
		new Float:length = 0.0;

		if (issuerid != INVALID_PLAYER_ID) 
		{
			if (IsBulletWeapon(weaponid)) 
			{
				length = Weapon::LastShot[issuerid][e_Length];
			}
		}

		if (!IsHighRateWeapon(weaponid)) 
		{
			DebugMessage("InflictDamage(%d, %.4f, %d, %d, %d) length = %f", playerid, amount, issuerid, weaponid, bodypart, length);
		}
	#endif

	if (!ignore_armour && weaponid != WEAPON_COLLISION && weaponid != WEAPON_DROWN && weaponid != WEAPON_CARPARK && weaponid != WEAPON_UNKNOWN
	&& (!Weapon::DamageArmourToggle[0] || (Weapon::DamageArmour[weaponid][0] && (!Weapon::DamageArmourToggle[1] || ((Weapon::DamageArmour[weaponid][1] && bodypart == 3) || (!Weapon::DamageArmour[weaponid][1])))))) 
	{
		if (amount <= 0.0) 
		{
			amount = Weapon::PlayerHealth[playerid] + Weapon::PlayerArmour[playerid];
		}

		Weapon::PlayerArmour[playerid] -= amount;
	} else {
		if (amount <= 0.0) 
		{
			amount = Weapon::PlayerHealth[playerid];
		}

		Weapon::PlayerHealth[playerid] -= amount;
	}

	if (Weapon::PlayerArmour[playerid] < 0.0) 
	{
		Weapon::DamageDoneArmour[playerid] = amount + Weapon::PlayerArmour[playerid];
		Weapon::DamageDoneHealth[playerid] = -Weapon::PlayerArmour[playerid];
		Weapon::PlayerHealth[playerid] += Weapon::PlayerArmour[playerid];
		Weapon::PlayerArmour[playerid] = 0.0;
	} 
	else 
	{
		Weapon::DamageDoneArmour[playerid] = amount;
		Weapon::DamageDoneHealth[playerid] = 0.0;
	}

	if (Weapon::PlayerHealth[playerid] <= 0.0) {
		amount += Weapon::PlayerHealth[playerid];
		Weapon::DamageDoneHealth[playerid] += Weapon::PlayerHealth[playerid];
		Weapon::PlayerHealth[playerid] = 0.0;
	}

	OnPlayerDamageDone(playerid, amount, issuerid, weaponid, bodypart);
	new animlib[32] = "PED", animname[32];

	if (Weapon::PlayerHealth[playerid] <= 0.0005) {
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
			if (gettime() - Weapon::LastVehicleEnterTime[playerid] < 10) {
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

		if (Weapon::CbugAllowed[playerid]) {
			W_OnPlayerDeath(playerid, issuerid, weaponid);
		} else {
			Weapon::DelayedDeathTimer[playerid] = SetTimerEx(#W_DelayedDeath, 1200, false, "iii", playerid, issuerid, weaponid);
		}
	}

	UpdateHealthBar(playerid);
}

forward W_DelayedDeath(playerid, issuerid, WEAPON:reason);
public W_DelayedDeath(playerid, issuerid, WEAPON:reason) {
	Weapon::DelayedDeathTimer[playerid] = 0;

	W_OnPlayerDeath(playerid, issuerid, reason);
}

static PlayerDeath(playerid, animlib[32], animname[32], bool:anim_lock = false, respawn_time = -1, bool:freeze_sync = true, bool:anim_freeze = true)
{
	Weapon::PlayerHealth[playerid] = 0.0;
	Weapon::PlayerArmour[playerid] = 0.0;
	Weapon::IsDying[playerid] = true;

	Weapon::LastDeathTick[playerid] = GetTickCount();

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
	FreezeSyncPacket(playerid, .toggle = freeze_sync);

	if (respawn_time == -1) {
		respawn_time = Weapon::RespawnTime;
	}

	if (animlib[0] && animname[0]) {
		ApplyAnimation(playerid, animlib, animname, 4.1, false, anim_lock, anim_lock, anim_freeze, 0, FORCE_SYNC:1);
	}

	if (Weapon::DeathTimer[playerid]) {
		KillTimer(Weapon::DeathTimer[playerid]);
	}

	Weapon::DeathTimer[playerid] = SetTimerEx("W_PlayerDeathRespawn", respawn_time, false, "i", playerid);

	if (IsPlayerInCheckpoint(playerid)) {
		W_OnPlayerLeaveCheckpoint(playerid);
	}

	if (IsPlayerInRaceCheckpoint(playerid)) {
		W_OnPlayerLeaveRaceCheckpoint(playerid);
	}
}

public OnPlayerPrepareDeath(playerid, animlib[32], animname[32], &anim_lock, &respawn_time)
{
	return W_OnPlayerPrepareDeath(playerid, animlib, animname, anim_lock, respawn_time);
}

public OnRejectedHit(playerid, hit[E_REJECTED_HIT])
{
	#if defined W_DEBUG
		new output[256];
		new reason = hit[e_Reason];
		new i1 = hit[e_Info1];
		new i2 = hit[e_Info2];
		new i3 = hit[e_Info3];
		new WEAPON:weapon = hit[e_Weapon];

		new weapon_name[32];

		W_GetWeaponName(weapon, weapon_name);

		format(output, sizeof(output), "(%s -> %s) %s", weapon_name, hit[e_Name], g_HitRejectReasons[reason]);

		format(output, sizeof(output), output, i1, i2, i3);

		DebugMessageRed("Rejected hit: %s", output);
	#endif

	W_OnRejectedHit(playerid, hit);
}

public OnPlayerDeathFinished(playerid, bool:cancelable)
{
	if (Weapon::PlayerHealth[playerid] == 0.0) {
		Weapon::PlayerHealth[playerid] = Weapon::PlayerMaxHealth[playerid];
	}

	if (Weapon::DeathTimer[playerid]) {
		KillTimer(Weapon::DeathTimer[playerid]);
		Weapon::DeathTimer[playerid] = 0;
	}

	new retval = W_OnPlayerDeathFinished(playerid, cancelable);

	if (!retval && cancelable) {
		return 0;
	}

	ResetPlayerWeapons(playerid);

	return 1;
}

static SaveSyncData(playerid)
{
	GetPlayerHealth(playerid, Weapon::SyncData[playerid][e_Health]);
	GetPlayerArmour(playerid, Weapon::SyncData[playerid][e_Armour]);

	GetPlayerPos(playerid, Weapon::SyncData[playerid][e_PosX], Weapon::SyncData[playerid][e_PosY], Weapon::SyncData[playerid][e_PosZ]);
	GetPlayerFacingAngle(playerid, Weapon::SyncData[playerid][e_PosA]);

	Weapon::SyncData[playerid][e_Skin] = GetPlayerSkin(playerid);
	Weapon::SyncData[playerid][e_Team] = GetPlayerTeam(playerid);

	Weapon::SyncData[playerid][e_Weapon] = GetPlayerWeapon(playerid);

	for (new WEAPON_SLOT:i; _:i < 13; i++) 
	{
		GetPlayerWeaponData(playerid, i, Weapon::SyncData[playerid][e_WeaponId][i], Weapon::SyncData[playerid][e_WeaponAmmo][i]);
	}
}

static MakePlayerFacePlayer(playerid, targetid, opposite = false, forcesync = true)
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

static IsPlayerBehindPlayer(playerid, targetid, Float:diff = 90.0)
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

static AddRejectedHit(playerid, damagedid, reason, WEAPON:weapon, i1 = 0, i2 = 0, i3 = 0)
{
	if (0 <= playerid < MAX_PLAYERS) 
	{
		new idx = Weapon::RejectedHitsIdx[playerid];

		if (Weapon::RejectedHits[playerid][idx][e_Time]) 
		{
			idx += 1;

			if (idx >= sizeof(Weapon::RejectedHits[])) 
			{
				idx = 0;
			}

			Weapon::RejectedHitsIdx[playerid] = idx;
		}

		new time, hour, minute, second;

		time = gettime(hour, minute, second);

		Weapon::RejectedHits[playerid][idx][e_Reason] = reason;
		Weapon::RejectedHits[playerid][idx][e_Time] = time;
		Weapon::RejectedHits[playerid][idx][e_Weapon] = weapon;
		Weapon::RejectedHits[playerid][idx][e_Hour] = hour;
		Weapon::RejectedHits[playerid][idx][e_Minute] = minute;
		Weapon::RejectedHits[playerid][idx][e_Second] = second;
		Weapon::RejectedHits[playerid][idx][e_Info1] = _:i1;
		Weapon::RejectedHits[playerid][idx][e_Info2] = _:i2;
		Weapon::RejectedHits[playerid][idx][e_Info3] = _:i3;

		if (0 <= damagedid < MAX_PLAYERS) 
		{
			GetPlayerName(damagedid, Weapon::RejectedHits[playerid][idx][e_Name], MAX_PLAYER_NAME);
		} else {
			Weapon::RejectedHits[playerid][idx][e_Name][0] = '#';
			Weapon::RejectedHits[playerid][idx][e_Name][1] = '\0';
		}

		OnRejectedHit(playerid, Weapon::RejectedHits[playerid][idx]);
	}
}

static SpawnPlayerForWorld(playerid)
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

static FreezeSyncPacket(playerid, bool:toggle)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	Weapon::LastSyncData[playerid][PR_keys] = 0;
	Weapon::LastSyncData[playerid][PR_udKey] = 0;
	Weapon::LastSyncData[playerid][PR_lrKey] = 0;
	Weapon::LastSyncData[playerid][PR_specialAction] = SPECIAL_ACTION_NONE;
	Weapon::LastSyncData[playerid][PR_velocity][0] = 0.0;
	Weapon::LastSyncData[playerid][PR_velocity][1] = 0.0;
	Weapon::LastSyncData[playerid][PR_velocity][2] = 0.0;

	Weapon::SyncDataFrozen[playerid] = toggle;

	return 1;
}

static SetFakeHealth(playerid, health)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	Weapon::FakeHealth{playerid} = health;

	return 1;
}

static SetFakeArmour(playerid, armour)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	Weapon::FakeArmour{playerid} = armour;

	return 1;
}

static GetRotationQuaternion(Float:x, Float:y, Float:z, &Float:qw, &Float:qx, &Float:qy, &Float:qz)
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

static SetFakeFacingAngle(playerid, Float:angle = Float:0x7FFFFFFF)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	if (angle != angle) {
		Weapon::FakeQuat[playerid][0] = Float:0x7FFFFFFF;
		Weapon::FakeQuat[playerid][1] = Float:0x7FFFFFFF;
		Weapon::FakeQuat[playerid][2] = Float:0x7FFFFFFF;
		Weapon::FakeQuat[playerid][3] = Float:0x7FFFFFFF;
	} else {
		GetRotationQuaternion(0.0, 0.0, angle, Weapon::FakeQuat[playerid][0], Weapon::FakeQuat[playerid][1], Weapon::FakeQuat[playerid][2], Weapon::FakeQuat[playerid][3]);
	}

	return 1;
}

static SendLastSyncPacket(playerid, toplayerid, animation = 0)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerConnected(toplayerid)) {
		return 0;
	}

	new BitStream:bs = BS_New();

	BS_WriteValue(bs, PR_UINT8, PLAYER_SYNC, PR_UINT16, playerid);

	if (Weapon::FakeQuat[playerid][0] == Weapon::FakeQuat[playerid][0]) {
		Weapon::LastSyncData[playerid][PR_quaternion] = Weapon::FakeQuat[playerid];
	}

	if (Weapon::FakeHealth{playerid} != 255) {
		Weapon::LastSyncData[playerid][PR_health] = Weapon::FakeHealth{playerid};
	}

	if (Weapon::FakeArmour{playerid} != 255) {
		Weapon::LastSyncData[playerid][PR_armour] = Weapon::FakeArmour{playerid};
	}

	// Make them appear standing still if paused
	if (W_IsPlayerPaused(playerid)) {
		Weapon::LastSyncData[playerid][PR_velocity][0] = 0.0;
		Weapon::LastSyncData[playerid][PR_velocity][1] = 0.0;
		Weapon::LastSyncData[playerid][PR_velocity][2] = 0.0;
	}

	// Animations are only sent when they are changed
	if (!animation) {
		Weapon::LastSyncData[playerid][PR_animationId] = 0;
		Weapon::LastSyncData[playerid][PR_animationFlags] = 0;
	}

	BS_WriteOnFootSync(bs, Weapon::LastSyncData[playerid], true);
	PR_SendPacket(bs, toplayerid, _, PR_RELIABLE_SEQUENCED);
	BS_Delete(bs);

	return 1;
}

static ClearAnimationsForPlayer(playerid, forplayerid)
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

forward W_SecondKnifeAnim(playerid);
public W_SecondKnifeAnim(playerid)
{
	new animlib[] = "KNIFE", animname[] = "KILL_Knife_Ped_Die";
	ApplyAnimation(playerid, animlib, animname, 4.1, false, true, true, true, 3000, FORCE_SYNC:1);
}

forward W_PlayerDeathRespawn(playerid);
public W_PlayerDeathRespawn(playerid)
{
	if (!Weapon::IsDying[playerid]) {
		return;
	}

	Weapon::IsDying[playerid] = false;

	if (!OnPlayerDeathFinished(playerid, true)) {
		UpdateHealthBar(playerid);
		SetFakeFacingAngle(playerid, _);
		FreezeSyncPacket(playerid, .toggle = false);

		return;
	}

	Weapon::IsDying[playerid] = true;
	Weapon::TrueDeath[playerid] = false;

	if (IsPlayerInAnyVehicle(playerid)) {
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetPlayerPos(playerid, x, y, z);
	}

	SetPlayerVirtualWorld(playerid, W_DEATH_WORLD);
	SetFakeFacingAngle(playerid, _);
	TogglePlayerSpectating(playerid, true);
	TogglePlayerSpectating(playerid, false);
}

public OnInvalidWeaponDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart, error, bool:given)
{
	DebugMessageRed("OnInvalidWeaponDamage(%d, %d, %f, %d, %d, %d, %d)", playerid, damagedid, amount, weaponid, bodypart, error, given);

	W_OnInvalidWeaponDamage(playerid, damagedid, Float:amount, weaponid, bodypart, error, bool:given);
}

public OnPlayerDamageDone(playerid, Float:amount, issuerid, WEAPON:weapon, bodypart)
{
	if(issuerid != INVALID_PLAYER_ID)
    {
        switch(bodypart)
        {
            case BODY_PART_HEAD: 
            {
                CallRemoteFunction("OnPlayerShootHead", "ddfd", issuerid, playerid, amount, weapon);
            }
            case BODY_PART_TORSO: 
            {
                CallRemoteFunction("OnPlayerShootTorso", "ddfd", issuerid, playerid, amount, weapon);
            }
            case BODY_PART_LEFT_ARM: 
            {
                CallRemoteFunction("OnPlayerShootLeftArm", "ddfd", issuerid, playerid, amount, weapon);
            }
            case BODY_PART_LEFT_LEG: 
            {
                CallRemoteFunction("OnPlayerShootLeftLeg", "ddfd", issuerid, playerid, amount, weapon);
            }
            case BODY_PART_RIGHT_ARM: 
            {
                CallRemoteFunction("OnPlayerShootRightArm", "ddfd", issuerid, playerid, amount, weapon);
            }
            case BODY_PART_RIGHT_LEG: 
            {
                CallRemoteFunction("OnPlayerShootRightLeg", "ddfd", issuerid, playerid, amount, weapon);
            }
            case BODY_PART_GROIN: 
            {
                CallRemoteFunction("OnPlayerShootGroin", "ddfd", issuerid, playerid, amount, weapon);
            }
        }
    }

	new idx = Weapon::PreviousHitI[playerid];

	Weapon::PreviousHitI[playerid] = (Weapon::PreviousHitI[playerid] - 1) % sizeof(Weapon::PreviousHits[]);

	// JIT plugin fix
	if (Weapon::PreviousHitI[playerid] < 0) {
		Weapon::PreviousHitI[playerid] += sizeof(Weapon::PreviousHits[]);
	}

	Weapon::PreviousHits[playerid][idx][e_Tick] = GetTickCount();
	Weapon::PreviousHits[playerid][idx][e_Issuer] = issuerid;
	Weapon::PreviousHits[playerid][idx][e_Weapon] = weapon;
	Weapon::PreviousHits[playerid][idx][e_Amount] = amount;
	Weapon::PreviousHits[playerid][idx][e_Bodypart] = bodypart;
	Weapon::PreviousHits[playerid][idx][e_Health] = Weapon::DamageDoneHealth[playerid];
	Weapon::PreviousHits[playerid][idx][e_Armour] = Weapon::DamageDoneArmour[playerid];

	if (!IsHighRateWeapon(weapon)) {
		DebugMessage("OnPlayerDamageDone(%d did %f to %d with %d on bodypart %d)", issuerid, amount, playerid, weapon, bodypart);
	}

	W_OnPlayerDamageDone(playerid, amount, issuerid, weapon, bodypart);
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &WEAPON:weapon, &bodypart)
{
	return W_OnPlayerDamage(playerid, amount, issuerid, weapon, bodypart);
}

/*
 * ALS callbacks
 */

#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit(%0) CHAIN_PUBLIC:W_OnGameModeInit(%0)
CHAIN_FORWARD:W_OnGameModeInit() = 1;


#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif
#define OnGameModeExit(%0) CHAIN_PUBLIC:W_OnGameModeExit(%0)
CHAIN_FORWARD:W_OnGameModeExit() = 1;

#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect(%0) CHAIN_PUBLIC:W_OnPlayerConnect(%0)
CHAIN_FORWARD:W_OnPlayerConnect(playerid) = 1;


#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect(%0) CHAIN_PUBLIC:W_OnPlayerDisconnect(%0)
CHAIN_FORWARD:W_OnPlayerDisconnect(playerid, reason) = 1;


#if defined _ALS_OnPlayerStreamIn
	#undef OnPlayerStreamIn
#else
	#define _ALS_OnPlayerStreamIn
#endif
#define OnPlayerStreamIn(%0) CHAIN_PUBLIC:W_OnPlayerStreamIn(%0)
CHAIN_FORWARD:W_OnPlayerStreamIn(playerid, forplayerid) = 1;


#if defined _ALS_OnVehicleDeath
	#undef OnVehicleDeath
#else
	#define _ALS_OnVehicleDeath
#endif
#define OnVehicleDeath(%0) CHAIN_PUBLIC:W_OnVehicleDeath(%0)
CHAIN_FORWARD:W_OnVehicleDeath(vehicleid, killerid) = 1;


#if defined _ALS_OnVehicleSpawn
	#undef OnVehicleSpawn
#else
	#define _ALS_OnVehicleSpawn
#endif
#define OnVehicleSpawn(%0) CHAIN_PUBLIC:W_OnVehicleSpawn(%0)
CHAIN_FORWARD:W_OnVehicleSpawn(vehicleid) = 1;


#if defined _ALS_OnPlayerEnterVehicle
	#undef OnPlayerEnterVehicle
#else
	#define _ALS_OnPlayerEnterVehicle
#endif
#define OnPlayerEnterVehicle(%0) CHAIN_PUBLIC:W_OnPlayerEnterVehicle(%0)
CHAIN_FORWARD:W_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) = 1;


#if defined _ALS_OnPlayerExitVehicle
	#undef OnPlayerExitVehicle
#else
	#define _ALS_OnPlayerExitVehicle
#endif
#define OnPlayerExitVehicle(%0) CHAIN_PUBLIC:W_OnPlayerExitVehicle(%0)
CHAIN_FORWARD:W_OnPlayerExitVehicle(playerid, vehicleid) = 1;


#if defined _ALS_OnPlayerStateChange
	#undef OnPlayerStateChange
#else
	#define _ALS_OnPlayerStateChange
#endif
#define OnPlayerStateChange(%0) CHAIN_PUBLIC:W_OnPlayerStateChange(%0)
CHAIN_FORWARD:W_OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate) = 1;


#if defined _ALS_OnPlayerPickUpPickup
	#undef OnPlayerPickUpPickup
#else
	#define _ALS_OnPlayerPickUpPickup
#endif
#define OnPlayerPickUpPickup(%0) CHAIN_PUBLIC:W_OnPlayerPickUpPickup(%0)
CHAIN_FORWARD:W_OnPlayerPickUpPickup(playerid, pickupid) = 1;


#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate(%0) CHAIN_PUBLIC:W_OnPlayerUpdate(%0)
CHAIN_FORWARD:W_OnPlayerUpdate(playerid) = 1;


#if defined _ALS_OnPlayerSpawn
	#undef OnPlayerSpawn
#else
	#define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn(%0) CHAIN_PUBLIC:W_OnPlayerSpawn(%0)
CHAIN_FORWARD:W_OnPlayerSpawn(playerid) = 1;


#if defined _ALS_OnPlayerRequestClass
	#undef OnPlayerRequestClass
#else
	#define _ALS_OnPlayerRequestClass
#endif
#define OnPlayerRequestClass(%0) CHAIN_PUBLIC:W_OnPlayerRequestClass(%0)
CHAIN_FORWARD:W_OnPlayerRequestClass(playerid, classid) = 1;


#if defined _ALS_OnPlayerDeath
	#undef OnPlayerDeath
#else
	#define _ALS_OnPlayerDeath
#endif
#define OnPlayerDeath(%0) CHAIN_PUBLIC:W_OnPlayerDeath(%0)
CHAIN_FORWARD:W_OnPlayerDeath(playerid, killerid, WEAPON:reason) = 1;


#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange(%0) CHAIN_PUBLIC:W_OnPlayerKeyStateChange(%0)
CHAIN_FORWARD:W_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) = 1;


#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
#define OnPlayerWeaponShot(%0) CHAIN_PUBLIC:W_OnPlayerWeaponShot(%0)
CHAIN_FORWARD:W_OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ) = 1;


#if defined _ALS_OnPlayerEnterCheckpoint
	#undef OnPlayerEnterCheckpoint
#else
	#define _ALS_OnPlayerEnterCheckpoint
#endif
#define OnPlayerEnterCheckpoint(%0) CHAIN_PUBLIC:W_OnPlayerEnterCheckpoint(%0)
CHAIN_FORWARD:W_OnPlayerEnterCheckpoint(playerid) = 1;


#if defined _ALS_OnPlayerLeaveCheckpoint
	#undef OnPlayerLeaveCheckpoint
#else
	#define _ALS_OnPlayerLeaveCheckpoint
#endif
#define OnPlayerLeaveCheckpoint(%0) CHAIN_PUBLIC:W_OnPlayerLeaveCheckpoint(%0)
CHAIN_FORWARD:W_OnPlayerLeaveCheckpoint(playerid) = 1;


#if defined _ALS_OnPlayerEnterRaceCP
	#undef OnPlayerEnterRaceCheckpoint
#else
	#define _ALS_OnPlayerEnterRaceCP
#endif
#define OnPlayerEnterRaceCheckpoint(%0) CHAIN_PUBLIC:W_OnPlayerEnterRaceCheckpoint(%0)
CHAIN_FORWARD:W_OnPlayerEnterRaceCheckpoint(playerid) = 1;


#if defined _ALS_OnPlayerLeaveRaceCP
	#undef OnPlayerLeaveRaceCheckpoint
#else
	#define _ALS_OnPlayerLeaveRaceCP
#endif
#define OnPlayerLeaveRaceCheckpoint(%0) CHAIN_PUBLIC:W_OnPlayerLeaveRaceCheckpoint(%0)
CHAIN_FORWARD:W_OnPlayerLeaveRaceCheckpoint(playerid) = 1;

#if defined _ALS_OnInvalidWeaponDamage
	#undef OnInvalidWeaponDamage
#else
	#define _ALS_OnInvalidWeaponDamage
#endif
#define OnInvalidWeaponDamage(%0) CHAIN_PUBLIC:W_OnInvalidWeaponDamage(%0)
CHAIN_FORWARD:W_OnInvalidWeaponDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart, error, bool:given) = 1;


#if defined _ALS_OnPlayerDamageDone
	#undef OnPlayerDamageDone
#else
	#define _ALS_OnPlayerDamageDone
#endif
#define OnPlayerDamageDone(%0) CHAIN_PUBLIC:W_OnPlayerDamageDone(%0)
CHAIN_FORWARD:W_OnPlayerDamageDone(playerid, Float:amount, issuerid, WEAPON:weapon, bodypart) = 1;


#if defined _ALS_OnPlayerDamage
	#undef OnPlayerDamage
#else
	#define _ALS_OnPlayerDamage
#endif
#define OnPlayerDamage(%0) CHAIN_PUBLIC:W_OnPlayerDamage(%0)
CHAIN_FORWARD:W_OnPlayerDamage(&playerid, &Float:amount, &issuerid, &WEAPON:weapon, &bodypart) = 1;


#if defined _ALS_OnPlayerPrepareDeath
	#undef OnPlayerPrepareDeath
#else
	#define _ALS_OnPlayerPrepareDeath
#endif
#define OnPlayerPrepareDeath(%0) CHAIN_PUBLIC:W_OnPlayerPrepareDeath(%0)
CHAIN_FORWARD:W_OnPlayerPrepareDeath(playerid, animlib[32], animname[32], &anim_lock, &respawn_time) = 1;


#if defined _ALS_OnRejectedHit
	#undef OnRejectedHit
#else
	#define _ALS_OnRejectedHit
#endif
#define OnRejectedHit(%0) CHAIN_PUBLIC:W_OnRejectedHit(%0)
CHAIN_FORWARD:W_OnRejectedHit(playerid, hit[E_REJECTED_HIT]) = 1;

#if defined _ALS_OnPlayerDeathFinished
	#undef OnPlayerDeathFinished
#else
	#define _ALS_OnPlayerDeathFinished
#endif
#define OnPlayerDeathFinished(%0) CHAIN_PUBLIC:W_OnPlayerDeathFinished(%0)
CHAIN_FORWARD:W_OnPlayerDeathFinished(playerid, bool:cancelable) = 1;

/*
 * ALS functions
 */

#if defined _ALS_SpawnPlayer
	#undef SpawnPlayer
#else
	#define _ALS_SpawnPlayer
#endif
#define SpawnPlayer W_SpawnPlayer


#if defined _ALS_SetPlayerHealth
	#undef SetPlayerHealth
#else
	#define _ALS_SetPlayerHealth
#endif
#define SetPlayerHealth W_SetPlayerHealth


#if defined _ALS_GetPlayerState
	#undef GetPlayerState
#else
	#define _ALS_GetPlayerState
#endif
#define GetPlayerState W_GetPlayerState


#if defined _ALS_GetPlayerHealth
	#undef GetPlayerHealth
#else
	#define _ALS_GetPlayerHealth
#endif
#define GetPlayerHealth W_GetPlayerHealth


#if defined _ALS_SetPlayerArmour
	#undef SetPlayerArmour
#else
	#define _ALS_SetPlayerArmour
#endif
#define SetPlayerArmour W_SetPlayerArmour


#if defined _ALS_GetPlayerArmour
	#undef GetPlayerArmour
#else
	#define _ALS_GetPlayerArmour
#endif
#define GetPlayerArmour W_GetPlayerArmour


#if defined _ALS_GetPlayerTeam
	#undef GetPlayerTeam
#else
	#define _ALS_GetPlayerTeam
#endif
#define GetPlayerTeam W_GetPlayerTeam


#if defined _ALS_SetPlayerTeam
	#undef SetPlayerTeam
#else
	#define _ALS_SetPlayerTeam
#endif
#define SetPlayerTeam W_SetPlayerTeam


#if defined _ALS_SendDeathMessage
	#undef SendDeathMessage
#else
	#define _ALS_SendDeathMessage
#endif
#define SendDeathMessage W_SendDeathMessage


#if defined _ALS_GetWeaponName
	#undef GetWeaponName
#else
	#define _ALS_GetWeaponName
#endif
#define GetWeaponName W_GetWeaponName


#if defined _ALS_ApplyAnimation
	#undef ApplyAnimation
#else
	#define _ALS_ApplyAnimation
#endif
#define ApplyAnimation W_ApplyAnimation


#if defined _ALS_ClearAnimations
	#undef ClearAnimations
#else
	#define _ALS_ClearAnimations
#endif
#define ClearAnimations W_ClearAnimations


#if defined _ALS_AddPlayerClass
	#undef AddPlayerClass
#else
	#define _ALS_AddPlayerClass
#endif
#define AddPlayerClass W_AddPlayerClass


#if defined _ALS_AddPlayerClassEx
	#undef AddPlayerClassEx
#else
	#define _ALS_AddPlayerClassEx
#endif
#define AddPlayerClassEx W_AddPlayerClassEx


#if defined _ALS_SetSpawnInfo
	#undef SetSpawnInfo
#else
	#define _ALS_SetSpawnInfo
#endif
#define SetSpawnInfo W_SetSpawnInfo


#if defined _ALS_TogglePlayerSpectating
	#undef TogglePlayerSpectating
#else
	#define _ALS_TogglePlayerSpectating
#endif
#define TogglePlayerSpectating W_TogglePlayerSpectating


#if defined _ALS_TogglePlayerControllable
	#undef TogglePlayerControllable
#else
	#define _ALS_TogglePlayerControllable
#endif
#define TogglePlayerControllable W_TogglePlayerControllable


#if defined _ALS_SetPlayerPos
	#undef SetPlayerPos
#else
	#define _ALS_SetPlayerPos
#endif
#define SetPlayerPos W_SetPlayerPos


#if defined _ALS_SetPlayerPosFindZ
	#undef SetPlayerPosFindZ
#else
	#define _ALS_SetPlayerPosFindZ
#endif
#define SetPlayerPosFindZ W_SetPlayerPosFindZ


#if defined _ALS_SetPlayerVelocity
	#undef SetPlayerVelocity
#else
	#define _ALS_SetPlayerVelocity
#endif
#define SetPlayerVelocity W_SetPlayerVelocity


#if defined _ALS_SetPlayerVirtualWorld
	#undef SetPlayerVirtualWorld
#else
	#define _ALS_SetPlayerVirtualWorld
#endif
#define SetPlayerVirtualWorld W_SetPlayerVirtualWorld


#if defined _ALS_GetPlayerVirtualWorld
	#undef GetPlayerVirtualWorld
#else
	#define _ALS_GetPlayerVirtualWorld
#endif
#define GetPlayerVirtualWorld W_GetPlayerVirtualWorld


#if defined _ALS_PlayerSpectatePlayer
	#undef PlayerSpectatePlayer
#else
	#define _ALS_PlayerSpectatePlayer
#endif
#define PlayerSpectatePlayer W_PlayerSpectatePlayer


#if defined _ALS_DestroyVehicle
	#undef DestroyVehicle
#else
	#define _ALS_DestroyVehicle
#endif
#define DestroyVehicle W_DestroyVehicle


#if defined _ALS_CreateVehicle
	#undef CreateVehicle
#else
	#define _ALS_CreateVehicle
#endif
#define CreateVehicle W_CreateVehicle


#if defined _ALS_AddStaticVehicle
	#undef AddStaticVehicle
#else
	#define _ALS_AddStaticVehicle
#endif
#define AddStaticVehicle W_AddStaticVehicle


#if defined _ALS_AddStaticVehicleEx
	#undef AddStaticVehicleEx
#else
	#define _ALS_AddStaticVehicleEx
#endif
#define AddStaticVehicleEx W_AddStaticVehicleEx


#if defined _ALS_IsPlayerInCheckpoint
	#undef IsPlayerInCheckpoint
#else
	#define _ALS_IsPlayerInCheckpoint
#endif
#define IsPlayerInCheckpoint W_IsPlayerInCheckpoint


#if defined _ALS_IsPlayerInRaceCheckpoint
	#undef IsPlayerInRaceCheckpoint
#else
	#define _ALS_IsPlayerInRaceCheckpoint
#endif
#define IsPlayerInRaceCheckpoint W_IsPlayerInRaceCheckpoint


#if defined _ALS_SetPlayerSpecialAction
	#undef SetPlayerSpecialAction
#else
	#define _ALS_SetPlayerSpecialAction
#endif
#define SetPlayerSpecialAction W_SetPlayerSpecialAction