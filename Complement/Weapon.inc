#define WC_MAX_REJECTED_HITS 15
#define WC_MAX_DAMAGE_RANGES 5
#define WC_DEATH_WORLD 0x00DEAD00

#define WC_MAX_WEAPON_NAME 21

#define BULLET_HIT_TYPE: _:

#define FORCE_SYNC: _:
#define KEY: _:
#define PLAYER_STATE: _:
#define SPECIAL_ACTION: _:
#define SPECTATE_MODE: _:
#define WEAPON: _:
#define WEAPON_SLOT: _:

// Given in OnInvalidWeaponDamage
enum 
{
	WC_NO_ERROR,
	WC_NO_ISSUER,
	WC_NO_DAMAGED,
	WC_INVALID_DAMAGE,
	WC_INVALID_DISTANCE
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

// When a player takes or gives invalid damage (WC_* errors above)
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

// Define packet IDs
const WC_PLAYER_SYNC = 207;
const WC_VEHICLE_SYNC = 200;
const WC_PASSENGER_SYNC = 211;
const WC_AIM_SYNC = 203;
const WC_BULLET_SYNC = 206;

// Define RPC IDs
const WC_RPC_CLEAR_ANIMATIONS = 87;
const WC_RPC_REQUEST_SPAWN = 129;

// Weapons Slot Types : -1 (Invalid/Ilegal), 0 (Melee), 1 (Utility), 2 (Primary), 3 (Secondary)
static const s_WeaponType[] = {
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
static const s_ValidDamageGiven[] = {
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
static const s_ValidDamageTaken[] = {
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

// Default weapon damage. Connected to s_DamageType.
// Melee weapons are multipliers because the damage differs
// depending on type of punch/kick and fight style.
static Float:s_WeaponDamage[] = {
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
static s_DamageType[] = {
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
static Float:s_WeaponRange[] = {
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
static s_MaxWeaponShootRate[] = {
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
static s_DamageArmour[][2] = {
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
stock const g_WeaponName[57][WC_MAX_WEAPON_NAME] = {
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
static s_LagCompMode;
static WEAPON:s_LastExplosive[MAX_PLAYERS];
static s_LastShot[MAX_PLAYERS][E_SHOT_INFO];
static s_LastShotTicks[MAX_PLAYERS][10];
static s_LastShotWeapons[MAX_PLAYERS][10];
static s_LastShotIdx[MAX_PLAYERS];
static s_LastHitTicks[MAX_PLAYERS][10];
static s_LastHitWeapons[MAX_PLAYERS][10];
static s_LastHitIdx[MAX_PLAYERS];
static s_ShotsFired[MAX_PLAYERS];
static s_HitsIssued[MAX_PLAYERS];
static s_MaxShootRateSamples = 4;
static s_MaxHitRateSamples = 4;
static Float:s_PlayerMaxHealth[MAX_PLAYERS] = {100.0, ...};
static Float:s_PlayerHealth[MAX_PLAYERS] = {100.0, ...};
static Float:s_PlayerMaxArmour[MAX_PLAYERS] = {100.0, ...};
static Float:s_PlayerArmour[MAX_PLAYERS] = {0.0, ...};
static s_LastSentHealth[MAX_PLAYERS];
static s_LastSentArmour[MAX_PLAYERS];
static bool:s_DamageArmourToggle[2] = {false, ...};
static s_PlayerTeam[MAX_PLAYERS] = {NO_TEAM, ...};
static s_IsDying[MAX_PLAYERS];
static s_DeathTimer[MAX_PLAYERS];
static bool:s_SpawnForStreamedIn[MAX_PLAYERS];
static s_RespawnTime = 3000;
static bool:s_CbugGlobal = true;
static bool:s_CbugAllowed[MAX_PLAYERS] = true;
static s_CbugFroze[MAX_PLAYERS];
static s_VehiclePassengerDamage = false;
static s_VehicleUnoccupiedDamage = false;
static s_DamageTakenSound = 1190;
static s_DamageGivenSound = 17802;
static s_RejectedHits[MAX_PLAYERS][WC_MAX_REJECTED_HITS][E_REJECTED_HIT];
static s_RejectedHitsIdx[MAX_PLAYERS];
static s_World[MAX_PLAYERS];
static s_LastAnim[MAX_PLAYERS] = {-1, ...};
static Float:s_LastZVelo[MAX_PLAYERS] = {0.0, ...};
static Float:s_LastZ[MAX_PLAYERS] = {0.0, ...};
static s_LastUpdate[MAX_PLAYERS] = {-1, ...};
static s_Spectating[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
static s_LastStop[MAX_PLAYERS];
static bool:s_FirstSpawn[MAX_PLAYERS] = {true, ...};

static s_BeingResynced[MAX_PLAYERS];
static s_KnifeTimeout[MAX_PLAYERS];
static s_SyncData[MAX_PLAYERS][E_RESYNC_DATA];
static s_DamageRangeSteps[55];
static Float:s_DamageRangeRanges[55][WC_MAX_DAMAGE_RANGES];
static Float:s_DamageRangeValues[55][WC_MAX_DAMAGE_RANGES];
static s_LastVehicleShooter[MAX_VEHICLES + 1] = {INVALID_PLAYER_ID, ...};
static s_LastVehicleEnterTime[MAX_PLAYERS];
static s_TrueDeath[MAX_PLAYERS];
static s_InClassSelection[MAX_PLAYERS];
static s_ForceClassSelection[MAX_PLAYERS];
static s_ClassSpawnInfo[320][E_SPAWN_INFO];
static s_PlayerSpawnInfo[MAX_PLAYERS][E_SPAWN_INFO];
static s_PlayerClass[MAX_PLAYERS] = {-2, ...};
static bool:s_SpawnInfoModified[MAX_PLAYERS];
static bool:s_AlreadyConnected[MAX_PLAYERS];
static s_DeathSkip[MAX_PLAYERS];
static s_DeathSkipTick[MAX_PLAYERS];
static s_LastDeathTick[MAX_PLAYERS];
static s_LastVehicleTick[MAX_PLAYERS];
static s_PreviousHits[MAX_PLAYERS][10][E_HIT_INFO];
static s_PreviousHitI[MAX_PLAYERS];

static s_HitInformer[MAX_PLAYERS];
static s_HitInformerTimer[MAX_PLAYERS];

static Float:s_DamageDoneHealth[MAX_PLAYERS];
static Float:s_DamageDoneArmour[MAX_PLAYERS];
static s_DelayedDeathTimer[MAX_PLAYERS];
static bool:s_VehicleAlive[MAX_VEHICLES] = {false, ...};
static s_VehicleRespawnTimer[MAX_VEHICLES];

static s_FakeHealth[MAX_PLAYERS char];
static s_FakeArmour[MAX_PLAYERS char];

static Float:s_FakeQuat[MAX_PLAYERS][4];
static bool:s_SyncDataFrozen[MAX_PLAYERS];
static s_LastSyncData[MAX_PLAYERS][PR_OnFootSync];
static s_TempSyncData[MAX_PLAYERS][PR_OnFootSync];
static bool:s_TempDataWritten[MAX_PLAYERS];
static s_DisableSyncBugs = true;
static s_KnifeSync = true;
static s_PunchUsed[MAX_PLAYERS];
static s_PunchTick[MAX_PLAYERS];
static s_GogglesUsed[MAX_PLAYERS];
static s_GogglesTick[MAX_PLAYERS];

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

hook function IsPlayerSpawned(playerid)
{
	if (s_IsDying[playerid] || s_BeingResynced[playerid]) {
		return false;
	}

	if (s_InClassSelection[playerid] || s_ForceClassSelection[playerid]) {
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
	return (GetTickCount() - s_LastUpdate[playerid] > 2000);
}

stock AverageShootRate(playerid, shots, &multiple_weapons = 0)
{
	if (playerid == INVALID_PLAYER_ID || s_ShotsFired[playerid] < shots) {
		return -1;
	}

	new total = 0, idx = s_LastShotIdx[playerid];

	multiple_weapons = false;

	for (new i = shots - 2, prev, prev_weap, prev_idx, this_idx; i >= 0; i--) {
		prev_idx = (idx - i - 1) % sizeof(s_LastShotTicks[]);

		// JIT plugin fix
		if (prev_idx < 0) {
			prev_idx += sizeof(s_LastShotTicks[]);
		}

		prev = s_LastShotTicks[playerid][prev_idx];
		prev_weap = s_LastShotWeapons[playerid][prev_idx];
		this_idx = (idx - i) % sizeof(s_LastShotTicks[]);

		// JIT plugin fix
		if (this_idx < 0) {
			this_idx += sizeof(s_LastShotTicks[]);
		}

		if (prev_weap != s_LastShotWeapons[playerid][this_idx]) {
			multiple_weapons = true;
		}

		total += s_LastShotTicks[playerid][this_idx] - prev;
	}

	return shots == 1 ? 1 : (total / (shots - 1));
}

stock AverageHitRate(playerid, hits, &multiple_weapons = 0)
{
	if (playerid == INVALID_PLAYER_ID || s_HitsIssued[playerid] < hits) {
		return -1;
	}

	new total = 0, idx = s_LastHitIdx[playerid];

	multiple_weapons = false;

	for (new i = hits - 2, prev, prev_weap, prev_idx, this_idx; i >= 0; i--) {
		prev_idx = (idx - i - 1) % sizeof(s_LastHitTicks[]);

		// JIT plugin fix
		if (prev_idx < 0) {
			prev_idx += sizeof(s_LastHitTicks[]);
		}

		prev = s_LastHitTicks[playerid][prev_idx];
		prev_weap = s_LastHitWeapons[playerid][prev_idx];
		this_idx = (idx - i) % sizeof(s_LastHitTicks[]);

		// JIT plugin fix
		if (this_idx < 0) {
			this_idx += sizeof(s_LastHitTicks[]);
		}

		if (prev_weap != s_LastHitWeapons[playerid][this_idx]) {
			multiple_weapons = true;
		}

		total += s_LastHitTicks[playerid][this_idx] - prev;
	}

	return hits == 1 ? 1 : (total / (hits - 1));
}

stock SetRespawnTime(ms)
{
	s_RespawnTime = max(0, ms);
}

stock GetRespawnTime()
{
	return s_RespawnTime;
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
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(s_WeaponDamage)) {
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

		s_DamageType[weaponid] = damage_type;
		s_DamageRangeSteps[weaponid] = steps;

		for (new i = 0; i < steps; i++) {
			if (i) {
				s_DamageRangeRanges[weaponid][i] = Float:getarg(1 + i * 2);
				s_DamageRangeValues[weaponid][i] = Float:getarg(2 + i * 2);
			} else {
				s_DamageRangeValues[weaponid][i] = amount;
			}
		}

		return 1;
	} else if (damage_type == DAMAGE_TYPE_MULTIPLIER || damage_type == DAMAGE_TYPE_STATIC) {
		s_DamageType[weaponid] = damage_type;
		s_DamageRangeSteps[weaponid] = 0;
		s_WeaponDamage[weaponid] = amount;

		return 1;
	}

	return 0;
}

stock Float:GetWeaponDamage(WEAPON:weaponid)
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(s_WeaponDamage)) {
		return 0.0;
	}

	return s_WeaponDamage[weaponid];
}

stock SetCustomArmourRules(bool:armour_rules, bool:torso_rules = false)
{
	s_DamageArmourToggle[0] = armour_rules;
	s_DamageArmourToggle[1] = torso_rules;
}

stock SetWeaponArmourRule(WEAPON:weaponid, bool:affects_armour, bool:torso_only = false)
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(s_WeaponDamage)) {
		return 0;
	}

	s_DamageArmour[weaponid][0] = affects_armour;
	s_DamageArmour[weaponid][1] = torso_only;

	return 1;
}

stock SetDamageSounds(taken, given)
{
	s_DamageTakenSound = taken;
	s_DamageGivenSound = given;
}

stock SetCbugAllowed(bool:enabled, playerid = INVALID_PLAYER_ID)
{
	if (playerid == INVALID_PLAYER_ID) {
		s_CbugGlobal = enabled;
		foreach (new i : Player) 
		{
			s_CbugAllowed[i] = enabled;
		}
	} else {
		s_CbugAllowed[playerid] = enabled;
	}

	return enabled;
}

stock bool:GetCbugAllowed(playerid = INVALID_PLAYER_ID)
{
	if (playerid == INVALID_PLAYER_ID) {
		return s_CbugGlobal;
	}

	return s_CbugAllowed[playerid];
}

stock SetVehiclePassengerDamage(bool:toggle)
{
	s_VehiclePassengerDamage = toggle;
}

stock SetVehicleUnoccupiedDamage(bool:toggle)
{
	s_VehicleUnoccupiedDamage = toggle;
}

stock SetWeaponShootRate(WEAPON:weaponid, max_rate)
{
	if (_:WEAPON_UNARMED <= _:weaponid < sizeof(s_MaxWeaponShootRate)) {
		s_MaxWeaponShootRate[weaponid] = max_rate;

		return 1;
	}

	return 0;
}

stock GetWeaponShootRate(WEAPON:weaponid)
{
	if (_:WEAPON_UNARMED <= _:weaponid < sizeof(s_MaxWeaponShootRate)) {
		return s_MaxWeaponShootRate[weaponid];
	}

	return 0;
}

stock IsPlayerDying(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return s_IsDying[playerid];
	}

	return false;
}

stock SetWeaponMaxRange(WEAPON:weaponid, Float:range)
{
	if (!IsBulletWeapon(weaponid)) {
		return 0;
	}

	s_WeaponRange[weaponid] = range;

	return 1;
}

stock Float:GetWeaponMaxRange(WEAPON:weaponid)
{
	if (!IsBulletWeapon(weaponid)) {
		return 0.0;
	}

	return s_WeaponRange[weaponid];
}

stock SetPlayerMaxHealth(playerid, Float:value)
{
	if (0 <= playerid < MAX_PLAYERS) {
		s_PlayerMaxHealth[playerid] = value;
	}
}

stock SetPlayerMaxArmour(playerid, Float:value)
{
	if (0 <= playerid < MAX_PLAYERS) {
		s_PlayerMaxArmour[playerid] = value;
	}
}

stock Float:GetPlayerMaxHealth(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return s_PlayerMaxHealth[playerid];
	}

	return 0.0;
}

stock Float:GetPlayerMaxArmour(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return s_PlayerMaxArmour[playerid];
	}

	return 0.0;
}

stock Float:GetLastDamageHealth(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return s_DamageDoneHealth[playerid];
	}

	return 0.0;
}

stock Float:GetLastDamageArmour(playerid)
{
	if (0 <= playerid < MAX_PLAYERS) {
		return s_DamageDoneArmour[playerid];
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
	if (idx >= WC_MAX_REJECTED_HITS) {
		return 0;
	}

	new real_idx = (s_RejectedHitsIdx[playerid] - idx) % WC_MAX_REJECTED_HITS;

	// JIT plugin fix
	if (real_idx < 0) {
		real_idx += WC_MAX_REJECTED_HITS;
	}

	if (!s_RejectedHits[playerid][real_idx][e_Time]) {
		return 0;
	}

	new reason = s_RejectedHits[playerid][real_idx][e_Reason];
	new hour = s_RejectedHits[playerid][real_idx][e_Hour];
	new minute = s_RejectedHits[playerid][real_idx][e_Minute];
	new second = s_RejectedHits[playerid][real_idx][e_Second];
	new i1 = s_RejectedHits[playerid][real_idx][e_Info1];
	new i2 = s_RejectedHits[playerid][real_idx][e_Info2];
	new i3 = s_RejectedHits[playerid][real_idx][e_Info3];
	new WEAPON:weapon = s_RejectedHits[playerid][real_idx][e_Weapon];

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

	format(output, maxlength, "[%02d:%02d:%02d] (%s -> %s) %s", hour, minute, second, weapon_name, s_RejectedHits[playerid][real_idx][e_Name], output);

	return 1;
}

stock ResyncPlayer(playerid)
{
	SaveSyncData(playerid);

	s_BeingResynced[playerid] = true;

	SpawnPlayerInPlace(playerid);
}

stock SetDisableSyncBugs(toggle)
{
	s_DisableSyncBugs = !!toggle;
}

stock SetKnifeSync(toggle)
{
	s_KnifeSync = !!toggle;
}

/*
 * Hooked natives
 */

hook function SpawnPlayer(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || s_IsDying[playerid]) {
		return 0;
	}

	if (s_PlayerHealth[playerid] == 0.0) {
		s_PlayerHealth[playerid] = s_PlayerMaxHealth[playerid];
	}

	SpawnPlayer(playerid);

	return 1;
}

hook function PLAYER_STATE:GetPlayerState(playerid)
{
	if (s_IsDying[playerid]) {
		return PLAYER_STATE_WASTED;
	}

	return continue(playerid);
}

hook function Float:GetPlayerHealth(playerid, &Float:health = 0.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		health = 0.0;

		return 0.0;
	}

	health = s_PlayerHealth[playerid];

	return health;
}

hook function SetPlayerHealth(playerid, Float:health, Float:armour = -1.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (health <= 0.0) {
		s_PlayerArmour[playerid] = 0.0;
		s_PlayerHealth[playerid] = 0.0;

		InflictDamage(playerid, 0.0);
	} else {
		if (armour != -1.0) {
			if (armour > s_PlayerMaxArmour[playerid]) {
				armour = s_PlayerMaxArmour[playerid];
			}
			s_PlayerArmour[playerid] = armour;
		}

		if (health > s_PlayerMaxHealth[playerid]) {
			health = s_PlayerMaxHealth[playerid];
		}
		s_PlayerHealth[playerid] = health;
		UpdateHealthBar(playerid, true);
	}

	return 1;
}

stock Float:WC_GetPlayerArmour(playerid, &Float:armour = 0.0)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		armour = 0.0;

		return 0.0;
	}

	armour = s_PlayerArmour[playerid];

	return armour;
}

hook function SetPlayerArmour(playerid, Float:armour)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (armour > s_PlayerMaxArmour[playerid]) {
		armour = s_PlayerMaxArmour[playerid];
	}
	s_PlayerArmour[playerid] = armour;
	UpdateHealthBar(playerid, true);

	return 1;
}

hook function GetPlayerTeam(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return NO_TEAM;
	}

	if (!IsPlayerConnected(playerid)) {
		return NO_TEAM;
	}

	return s_PlayerTeam[playerid];
}

hook function SetPlayerTeam(playerid, team)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	s_PlayerTeam[playerid] = team;
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

stock SetWeaponName(WEAPON:weaponid, const name[])
{
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(g_WeaponName)) {
		return 0;
	}

	strunpack(g_WeaponName[weaponid], name, sizeof(g_WeaponName[]));

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
	if (playerid < 0 || playerid >= MAX_PLAYERS || s_IsDying[playerid]) {
		return 0;
	}

	return continue(playerid, animlib, animname, fDelta, !!loop, !!lockx, !!locky, !!freeze, time, forcesync);
}

hook function ClearAnimations(playerid, FORCE_SYNC:forcesync = FORCE_SYNC:1)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || s_IsDying[playerid]) {
		return 0;
	}

	s_LastStop[playerid] = GetTickCount();

	return continue(playerid, forcesync);
}

hook function AddPlayerClass(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	new classid = AddPlayerClass(modelid, spawn_x, spawn_y, spawn_z, z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);

	if (0 <= classid <= 319) {
		s_ClassSpawnInfo[classid][e_Skin] = modelid;
		s_ClassSpawnInfo[classid][e_Team] = 0x7FFFFFFF;
		s_ClassSpawnInfo[classid][e_PosX] = spawn_x;
		s_ClassSpawnInfo[classid][e_PosY] = spawn_y;
		s_ClassSpawnInfo[classid][e_PosZ] = spawn_z;
		s_ClassSpawnInfo[classid][e_Rot] = z_angle;
		s_ClassSpawnInfo[classid][e_Weapon1] = weapon1;
		s_ClassSpawnInfo[classid][e_Ammo1] = weapon1_ammo;
		s_ClassSpawnInfo[classid][e_Weapon2] = weapon2;
		s_ClassSpawnInfo[classid][e_Ammo2] = weapon2_ammo;
		s_ClassSpawnInfo[classid][e_Weapon3] = weapon3;
		s_ClassSpawnInfo[classid][e_Ammo3] = weapon3_ammo;
	}

	return classid;
}

hook function AddPlayerClassEx(teamid, modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	new classid = AddPlayerClassEx(teamid, modelid, spawn_x, spawn_y, spawn_z, z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);

	if (0 <= classid <= 319) {
		s_ClassSpawnInfo[classid][e_Skin] = modelid;
		s_ClassSpawnInfo[classid][e_Team] = teamid;
		s_ClassSpawnInfo[classid][e_PosX] = spawn_x;
		s_ClassSpawnInfo[classid][e_PosY] = spawn_y;
		s_ClassSpawnInfo[classid][e_PosZ] = spawn_z;
		s_ClassSpawnInfo[classid][e_Rot] = z_angle;
		s_ClassSpawnInfo[classid][e_Weapon1] = weapon1;
		s_ClassSpawnInfo[classid][e_Ammo1] = weapon1_ammo;
		s_ClassSpawnInfo[classid][e_Weapon2] = weapon2;
		s_ClassSpawnInfo[classid][e_Ammo2] = weapon2_ammo;
		s_ClassSpawnInfo[classid][e_Weapon3] = weapon3;
		s_ClassSpawnInfo[classid][e_Ammo3] = weapon3_ammo;
	}

	return classid;
}

hook function SetSpawnInfo(playerid, team, skin, Float:x, Float:y, Float:z, Float:rotation, WEAPON:weapon1 = WEAPON_UNARMED, weapon1_ammo = 0, WEAPON:weapon2 = WEAPON_UNARMED, weapon2_ammo = 0, WEAPON:weapon3 = WEAPON_UNARMED, weapon3_ammo = 0)
{
	if (SetSpawnInfo(playerid, team, skin, x, y, z, rotation, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)) {
		s_PlayerClass[playerid] = -1;
		s_SpawnInfoModified[playerid] = false;

		s_PlayerSpawnInfo[playerid][e_Skin] = skin;
		s_PlayerSpawnInfo[playerid][e_Team] = team;
		s_PlayerSpawnInfo[playerid][e_PosX] = x;
		s_PlayerSpawnInfo[playerid][e_PosY] = y;
		s_PlayerSpawnInfo[playerid][e_PosZ] = z;
		s_PlayerSpawnInfo[playerid][e_Rot] = rotation;
		s_PlayerSpawnInfo[playerid][e_Weapon1] = weapon1;
		s_PlayerSpawnInfo[playerid][e_Ammo1] = weapon1_ammo;
		s_PlayerSpawnInfo[playerid][e_Weapon2] = weapon2;
		s_PlayerSpawnInfo[playerid][e_Ammo2] = weapon2_ammo;
		s_PlayerSpawnInfo[playerid][e_Weapon3] = weapon3;
		s_PlayerSpawnInfo[playerid][e_Ammo3] = weapon3_ammo;

		return 1;
	}

	return 0;
}

hook function TogglePlayerSpectating(playerid, toggle)
{
	if (TogglePlayerSpectating(playerid, !!toggle)) {
		if (toggle) {
			if (s_DeathTimer[playerid]) {
				KillTimer(s_DeathTimer[playerid]);
				s_DeathTimer[playerid] = 0;
			}

			s_IsDying[playerid] = false;
		}

		return 1;
	}

	return 0;
}

hook function TogglePlayerControllable(playerid, toggle)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || s_IsDying[playerid]) {
		return 0;
	}

	s_LastStop[playerid] = GetTickCount();

	return continue(playerid, !!toggle);
}

hook function SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || s_IsDying[playerid]) {
		return 0;
	}

	s_LastStop[playerid] = GetTickCount();

	return continue(playerid, x, y, z);
}

hook function SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || s_IsDying[playerid]) {
		return 0;
	}

	s_LastStop[playerid] = GetTickCount();

	return continue(playerid, x, y, z);
}

hook function SetPlayerVelocity(playerid, Float:X, Float:Y, Float:Z)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS || s_IsDying[playerid]) {
		return 0;
	}

	if (X == 0.0 && Y == 0.0 && Z == 0.0) {
		s_LastStop[playerid] = GetTickCount();
	}

	return continue(playerid, X, Y, Z);
}

hook function SetPlayerVirtualWorld(playerid, worldid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	s_World[playerid] = worldid;

	if (s_IsDying[playerid]) {
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

	if (worldid == WC_DEATH_WORLD) {
		return s_World[playerid];
	}

	return worldid;
}

hook function PlayerSpectatePlayer(playerid, targetplayerid, SPECTATE_MODE:mode = SPECTATE_MODE_NORMAL)
{
	if (PlayerSpectatePlayer(playerid, targetplayerid, mode)) {
		s_Spectating[playerid] = targetplayerid;
		return 1;
	}

	return 0;
}

hook function DestroyVehicle(vehicleid)
{
	if (DestroyVehicle(vehicleid)) {
		s_LastVehicleShooter[vehicleid] = INVALID_PLAYER_ID;
		s_VehicleAlive[vehicleid] = false;

		if (s_VehicleRespawnTimer[vehicleid]) {
			KillTimer(s_VehicleRespawnTimer[vehicleid]);
			s_VehicleRespawnTimer[vehicleid] = 0;
		}

		return 1;
	}

	return 0;
}

hook function CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay, addsiren = 0)
{
	new id = CreateVehicle(modelid, x, y, z, angle, color1, color2, respawn_delay, !!addsiren);

	if (0 < id < MAX_VEHICLES) {
		s_VehicleAlive[id] = true;
	}

	return id;
}

hook function AddStaticVehicle(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2)
{
	new id = AddStaticVehicle(modelid, x, y, z, angle, color1, color2);

	if (0 < id < MAX_VEHICLES) {
		s_VehicleAlive[id] = true;
	}

	return id;
}

hook function AddStaticVehicleEx(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay, addsiren = 0)
{
	new id = AddStaticVehicleEx(modelid, x, y, z, angle, color1, color2, respawn_delay, !!addsiren);

	if (0 < id < MAX_VEHICLES) {
		s_VehicleAlive[id] = true;
	}

	return id;
}

hook function IsPlayerInCheckpoint(playerid)
{
	if (!WC_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return continue(playerid);
}

hook function IsPlayerInRaceCheckpoint(playerid)
{
	if (!WC_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return continue(playerid);
}

hook function SetPlayerSpecialAction(playerid, SPECIAL_ACTION:actionid)
{
	if (!WC_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return continue(playerid, actionid);
}

/*
 * Hooked callbacks
 */

hook callback OnGameModeInit()
{
	state _ALS : _ALS_go;

	ScriptInit();

	return continue();
}

hook callback OnGameModeExit()
{
	ScriptExit();

	return continue();
}

hook callback OnPlayerConnect(playerid)
{
	new tick = GetTickCount();

	s_PlayerMaxHealth[playerid] = 100.0;
	s_PlayerHealth[playerid] = 100.0;
	s_PlayerMaxArmour[playerid] = 100.0;
	s_PlayerArmour[playerid] = 0.0;
	s_LastExplosive[playerid] = WEAPON_UNARMED;
	s_LastShotIdx[playerid] = 0;
	s_LastShot[playerid][e_Tick] = 0;
	s_LastHitIdx[playerid] = 0;
	s_RejectedHitsIdx[playerid] = 0;
	s_ShotsFired[playerid] = 0;
	s_HitsIssued[playerid] = 0;
	s_PlayerTeam[playerid] = NO_TEAM;
	s_IsDying[playerid] = false;
	s_BeingResynced[playerid] = false;
	s_SpawnForStreamedIn[playerid] = false;
	s_World[playerid] = 0;
	s_LastAnim[playerid] = -1;
	s_LastZVelo[playerid] = 0.0;
	s_LastZ[playerid] = 0.0;
	s_LastUpdate[playerid] = tick;
	s_Spectating[playerid] = INVALID_PLAYER_ID;
	s_LastSentHealth[playerid] = 0;
	s_LastSentArmour[playerid] = 0;
	s_LastStop[playerid] = tick;
	s_FirstSpawn[playerid] = true;
	s_LastVehicleEnterTime[playerid] = 0;
	s_TrueDeath[playerid] = true;
	s_InClassSelection[playerid] = false;
	s_ForceClassSelection[playerid] = false;
	s_PlayerClass[playerid] = -2;
	s_SpawnInfoModified[playerid] = false;
	s_DeathSkip[playerid] = 0;
	s_LastVehicleTick[playerid] = 0;
	s_PreviousHitI[playerid] = 0;
	s_HitInformer[playerid] = 0;
	s_HitInformerTimer[playerid] = 0;
	s_CbugAllowed[playerid] = s_CbugGlobal;
	s_CbugFroze[playerid] = 0;
	s_DeathTimer[playerid] = 0;
	s_DelayedDeathTimer[playerid] = 0;

	s_FakeHealth{playerid} = 255;
	s_FakeArmour{playerid} = 255;
	s_FakeQuat[playerid][0] = Float:0x7FFFFFFF;
	s_FakeQuat[playerid][1] = Float:0x7FFFFFFF;
	s_FakeQuat[playerid][2] = Float:0x7FFFFFFF;
	s_FakeQuat[playerid][3] = Float:0x7FFFFFFF;
	s_TempDataWritten[playerid] = false;
	s_SyncDataFrozen[playerid] = false;
	s_GogglesUsed[playerid] = 0;

	for (new i = 0; i < sizeof(s_PreviousHits[]); i++) {
		s_PreviousHits[playerid][i][e_Tick] = 0;
	}

	for (new i = 0; i < sizeof(s_RejectedHits[]); i++) {
		s_RejectedHits[playerid][i][e_Time] = 0;
	}

	SetPlayerTeam(playerid, s_PlayerTeam[playerid]);
	FreezeSyncPacket(playerid, .toggle = false);
	SetFakeFacingAngle(playerid, _);

	s_AlreadyConnected[playerid] = false;

	return continue(playerid);
}

hook callback OnPlayerDisconnect(playerid, reason)
{
	//OnPlayerDisconnect(playerid, reason);

	if (s_DelayedDeathTimer[playerid]) {
		KillTimer(s_DelayedDeathTimer[playerid]);
		s_DelayedDeathTimer[playerid] = 0;
	}

	if (s_DeathTimer[playerid]) {
		KillTimer(s_DeathTimer[playerid]);
		s_DeathTimer[playerid] = 0;
	}

	if (s_KnifeTimeout[playerid]) {
		KillTimer(s_KnifeTimeout[playerid]);
		s_KnifeTimeout[playerid] = 0;
	}

	s_Spectating[playerid] = INVALID_PLAYER_ID;

	for (new i = 0; i < sizeof(s_LastVehicleShooter); i++) {
		if (s_LastVehicleShooter[i] == playerid) {
			s_LastVehicleShooter[i] = INVALID_PLAYER_ID;
		}
	}

	new j = 0;

	foreach (new i : Player) {
		for (j = 0; j < sizeof(s_PreviousHits[]); j++) {
			if (s_PreviousHits[i][j][e_Issuer] == playerid) {
				s_PreviousHits[i][j][e_Issuer] = INVALID_PLAYER_ID;
			}
		}
	}

	return 1;
}

hook callback OnPlayerSpawn(playerid)
{
	s_TrueDeath[playerid] = false;
	s_InClassSelection[playerid] = false;

	if (s_ForceClassSelection[playerid]) {
		DebugMessage("Being forced into class selection");
		ForceClassSelection(playerid);
		SetPlayerHealth(playerid, 0.0);

		return 1;
	}

	new tick = GetTickCount();
	s_LastUpdate[playerid] = tick;
	s_LastStop[playerid] = tick;

	if (s_BeingResynced[playerid]) {
		s_BeingResynced[playerid] = false;

		UpdateHealthBar(playerid);

		SetPlayerPos(playerid, s_SyncData[playerid][e_PosX], s_SyncData[playerid][e_PosY], s_SyncData[playerid][e_PosZ]);
		SetPlayerFacingAngle(playerid, s_SyncData[playerid][e_PosA]);

		SetPlayerSkin(playerid, s_SyncData[playerid][e_Skin]);
		SetPlayerTeam(playerid, s_SyncData[playerid][e_Team]);

		for (new i = 0; i < 13; i++) {
			if (s_SyncData[playerid][e_WeaponId][i]) {
				GivePlayerWeapon(playerid, s_SyncData[playerid][e_WeaponId][i], s_SyncData[playerid][e_WeaponAmmo][i]);
			}
		}

		SetPlayerArmedWeapon(playerid, s_SyncData[playerid][e_Weapon]);

		return 1;
	}

	if (s_SpawnInfoModified[playerid]) {
		new spawn_info[E_SPAWN_INFO], classid = s_PlayerClass[playerid];

		s_SpawnInfoModified[playerid] = false;

		if (classid == -1) 
		{
			spawn_info = s_PlayerSpawnInfo[playerid];
		} 
		else 
		{
			spawn_info = s_ClassSpawnInfo[classid];
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

	if (s_DeathTimer[playerid]) {
		KillTimer(s_DeathTimer[playerid]);
		s_DeathTimer[playerid] = 0;
	}

	if (s_IsDying[playerid]) {
		s_IsDying[playerid] = false;
	}

	if (s_PlayerHealth[playerid] == 0.0) {
		s_PlayerHealth[playerid] = s_PlayerMaxHealth[playerid];
	}

	UpdatePlayerVirtualWorld(playerid);
	UpdateHealthBar(playerid, true);
	FreezeSyncPacket(playerid, .toggle = false);
	SetFakeFacingAngle(playerid, _);

	if (GetPlayerTeam(playerid) != s_PlayerTeam[playerid]) {
		SetPlayerTeam(playerid, s_PlayerTeam[playerid]);
	}

	new animlib[32], animname[32];

	if (s_DeathSkip[playerid] == 2) {
		new WEAPON:w, a;
		GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

		DebugMessage("Death skipped");
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		SetPlayerArmedWeapon(playerid, w);
		ClearAnimations(playerid);

		animlib = "PED", animname = "IDLE_stance";
		ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 1, FORCE_SYNC:1);

		s_DeathSkip[playerid] = 1;
		s_DeathSkipTick[playerid] = tick;

		return 1;
	}

	if (s_FirstSpawn[playerid]) {
		s_FirstSpawn[playerid] = false;

	}

	return continue(playerid);
}

hook callback OnPlayerRequestClass(playerid, classid)
{
	DebugMessage("Requested class: %d", classid);

	if (s_DeathSkip[playerid]) {
		DebugMessage("Skipping death - class selection skipped");
		SpawnPlayer(playerid);

		return 0;
	}

	if (s_ForceClassSelection[playerid]) {
		s_ForceClassSelection[playerid] = false;
	}

	if (s_BeingResynced[playerid]) {
		s_TrueDeath[playerid] = false;

		SpawnPlayerInPlace(playerid);

		return 0;
	}

	if (s_DeathTimer[playerid]) {
		KillTimer(s_DeathTimer[playerid]);
		s_DeathTimer[playerid] = 0;
	}

	if (s_IsDying[playerid]) {
		OnPlayerDeathFinished(playerid, false);
		s_IsDying[playerid] = false;
	}

	if (s_TrueDeath[playerid]) {
		if (!s_InClassSelection[playerid]) {
			DebugMessage("True death class selection");

			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			RemoveBuildingForPlayer(playerid, 1484, x, y, z, 350.0),
			RemoveBuildingForPlayer(playerid, 1485, x, y, z, 350.0),
			RemoveBuildingForPlayer(playerid, 1486, x, y, z, 350.0);

			s_InClassSelection[playerid] = true;
		}

		UpdatePlayerVirtualWorld(playerid);

		if (OnPlayerRequestClass(playerid, classid)) {
			s_PlayerClass[playerid] = classid;

			return 1;
		} else {
			return 0;
		}
	} else {
		DebugMessage("Not true death - being respawned");

		s_ForceClassSelection[playerid] = true;

		SetPlayerVirtualWorld(playerid, WC_DEATH_WORLD);
		SpawnPlayerInPlace(playerid);

		return 0;
	}
}

hook callback OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
	s_TrueDeath[playerid] = true;
	s_InClassSelection[playerid] = false;

	if (s_BeingResynced[playerid] || s_ForceClassSelection[playerid]) {
		return 1;
	}

	// Probably fake death
	if (killerid != INVALID_PLAYER_ID && !IsPlayerStreamedIn(killerid, playerid)) {
		killerid = INVALID_PLAYER_ID;
	}

	DebugMessageRed("OnPlayerDeath(%d died by %d from %d)", playerid, reason, killerid);

	if (s_DeathTimer[playerid]) {
		KillTimer(s_DeathTimer[playerid]);
		s_DeathTimer[playerid] = 0;
	}

	if (s_IsDying[playerid]) {
		DebugMessageRed("death while dying %d", playerid);

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

		if (!HasSameTeam(playerid, s_LastVehicleShooter[vehicleid])) {
			killerid = s_LastVehicleShooter[vehicleid];
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
			amount = s_PlayerHealth[playerid] + s_PlayerArmour[playerid];
		}

		if (reason == WEAPON_COLLISION || reason == WEAPON_DROWN || reason == WEAPON_CARPARK) {
			if (amount <= 0.0) {
				amount = s_PlayerHealth[playerid];
			}

			s_PlayerHealth[playerid] -= amount;
		} else {
			if (amount <= 0.0) {
				amount = s_PlayerHealth[playerid] + s_PlayerArmour[playerid];
			}

			s_PlayerArmour[playerid] -= amount;
		}

		if (s_PlayerArmour[playerid] < 0.0) {
			s_DamageDoneArmour[playerid] = amount + s_PlayerArmour[playerid];
			s_DamageDoneHealth[playerid] = -s_PlayerArmour[playerid];
			s_PlayerHealth[playerid] += s_PlayerArmour[playerid];
			s_PlayerArmour[playerid] = 0.0;
		} else {
			s_DamageDoneArmour[playerid] = amount;
			s_DamageDoneHealth[playerid] = 0.0;
		}

		if (s_PlayerHealth[playerid] <= 0.0) {
			amount += s_PlayerHealth[playerid];
			s_DamageDoneHealth[playerid] += s_PlayerHealth[playerid];
			s_PlayerHealth[playerid] = 0.0;
		}

		OnPlayerDamageDone(playerid, amount, killerid, reason, bodypart);
	}

	if (s_PlayerHealth[playerid] <= 0.0005) {
		s_PlayerHealth[playerid] = 0.0;
		s_IsDying[playerid] = true;

		s_LastDeathTick[playerid] = GetTickCount();

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

			s_DeathSkip[playerid] = 2;

			new WEAPON:w, a;
			GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

			ForceClassSelection(playerid);
			SetSpawnInfo(playerid, s_PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);
			TogglePlayerSpectating(playerid, true);
			TogglePlayerSpectating(playerid, false);
			SetSpawnInfo(playerid, s_PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);
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

forward WC_CbugPunishment(playerid, WEAPON:weapon);
public WC_CbugPunishment(playerid, WEAPON:weapon) {
	FreezeSyncPacket(playerid, .toggle = false);
	SetPlayerArmedWeapon(playerid, weapon);

	if (!s_IsDying[playerid]) {
		ClearAnimations(playerid, FORCE_SYNC:1);
	}
}

hook callback OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	new animlib[32], animname[32];
	if (!s_CbugAllowed[playerid] && !s_IsDying[playerid] && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		if (newkeys & KEY_CROUCH) {
			new tick = GetTickCount();
			new diff = tick - s_LastShot[playerid][e_Tick];

			if (s_LastShot[playerid][e_Tick] && diff < 1200 && !s_CbugFroze[playerid]) {
				PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);

				if (s_LastShot[playerid][e_Valid] && floatabs(s_LastShot[playerid][e_HX]) > 1.0 && floatabs(s_LastShot[playerid][e_HY]) > 1.0) {
					SetPlayerFacingAngle(playerid, AngleBetweenPoints(
						s_LastShot[playerid][e_HX],
						s_LastShot[playerid][e_HY],
						s_LastShot[playerid][e_OX],
						s_LastShot[playerid][e_OY]
					));
				}

				new WEAPON:w, a;
				GetPlayerWeaponData(playerid, WEAPON_SLOT:0, w, a);

				animlib = "PED", animname = "IDLE_stance";
				ClearAnimations(playerid, FORCE_SYNC:1);
				ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 0, FORCE_SYNC:1);
				FreezeSyncPacket(playerid, .toggle = true);
				SetPlayerArmedWeapon(playerid, w);
				SetTimerEx("WC_CbugPunishment", 600, false, "ii", playerid, GetPlayerWeapon(playerid));

				s_CbugFroze[playerid] = tick;

				new j = 0, Float:health, Float:armour;

				foreach (new i : Player) {
					for (j = 0; j < sizeof(s_PreviousHits[]); j++) {
						if (s_PreviousHits[i][j][e_Issuer] == playerid && tick - s_PreviousHits[i][j][e_Tick] <= 1200) {
							s_PreviousHits[i][j][e_Issuer] = INVALID_PLAYER_ID;

							health = WC_GetPlayerHealth(i);
							armour = WC_GetPlayerArmour(i);

							if (s_IsDying[i]) {
								if (!s_DelayedDeathTimer[i]) {
									continue;
								}

								KillTimer(s_DelayedDeathTimer[i]);
								s_DelayedDeathTimer[i] = 0;
								ClearAnimations(i, FORCE_SYNC:1);
								SetFakeFacingAngle(i, _);
								FreezeSyncPacket(i, .toggle = false);

								s_IsDying[i] = false;

								if (s_DeathTimer[i]) {
									KillTimer(s_DeathTimer[i]);
									s_DeathTimer[i] = 0;
								}
							}

							health += s_PreviousHits[i][j][e_Health];
							armour += s_PreviousHits[i][j][e_Armour];

							WC_SetPlayerHealth(i, health, armour);
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
					s_LastExplosive[playerid] = WEAPON_SATCHEL;
				}

				case WEAPON_ROCKETLAUNCHER, WEAPON_HEATSEEKER, WEAPON_GRENADE: 
				{
					s_LastExplosive[playerid] = weap;
				}
			}
		}
	}

	return continue(playerid, newkeys, oldkeys);
}

hook callback OnPlayerStreamIn(playerid, forplayerid)
{
	// Send ped floor_hit_f
	if (s_IsDying[playerid] || s_InClassSelection[playerid]) {
		SendLastSyncPacket(playerid, forplayerid, .animation = 0x2e040000 + 1150);
	}

	return continue(playerid, forplayerid);
}

hook callback OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	s_LastVehicleEnterTime[playerid] = gettime();
	s_LastVehicleTick[playerid] = GetTickCount();

	if (s_IsDying[playerid]) {
		TogglePlayerControllable(playerid, false);
		ApplyAnimation(playerid, "PED", "KO_skid_back", 4.1, false, false, false, true, 0, FORCE_SYNC:1);
	}

	return continue(playerid, vehicleid, ispassenger);
}

hook callback OnPlayerExitVehicle(playerid, vehicleid)
{
	s_LastVehicleTick[playerid] = GetTickCount();

	return continue(playerid, vehicleid);
}

hook callback OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
	if (s_Spectating[playerid] != INVALID_PLAYER_ID && newstate != PLAYER_STATE_SPECTATING) {
		s_Spectating[playerid] = INVALID_PLAYER_ID;
	}

	if (s_IsDying[playerid] && (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)) {
		TogglePlayerControllable(playerid, false);
	}

	if (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) {
		s_LastVehicleTick[playerid] = GetTickCount();

		if (newstate == PLAYER_STATE_ONFOOT) {
			new Float:vx, Float:vy, Float:vz;
			GetPlayerVelocity(playerid, vx, vy, vz);

			if (vx * vx + vy * vy + vz * vz <= 0.05) {
				#if defined _Y_ITERATE_LOCAL_VERSION && defined _FOREACH_STREAMED && !defined FOREACH_NO_STREAMED
				    foreach (new i : StreamedPlayer[playerid]) {
				    	SendLastSyncPacket(playerid, i);
				    	ClearAnimationsForPlayer(playerid, i);
				    }
				#elseif defined _Y_ITERATE_LOCAL_VERSION || defined _FOREACH_LOCAL_VERSION
				    foreach (new i : Player) {
				    	if (i != playerid && IsPlayerStreamedIn(playerid, i)) {
				    		SendLastSyncPacket(playerid, i);
				    		ClearAnimationsForPlayer(playerid, i);
				    	}
				    }
				#endif
			}
		}
	}
	return continue(playerid, newstate, oldstate);
}

hook callback OnPlayerPickUpPickup(playerid, pickupid)
{
	if (!WC_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return continue(playerid, pickupid);
}

hook callback OnPlayerUpdate(playerid)
{
	if (s_TempDataWritten[playerid]) {
		if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
			s_LastSyncData[playerid] = s_TempSyncData[playerid];
			s_TempDataWritten[playerid] = false;
		}
	}

	if (s_IsDying[playerid]) {
		return 1;
	}

	if (s_ForceClassSelection[playerid]) {
		return 0;
	}

	new tick = GetTickCount();

	if (s_DeathSkip[playerid] == 1) {
		if (s_DeathSkipTick[playerid]) {
			if (tick - s_DeathSkipTick[playerid] > 1000) {
				new Float:x, Float:y, Float:z, Float:r;

				GetPlayerPos(playerid, x, y, z);
				GetPlayerFacingAngle(playerid, r);

				SetSpawnInfo(playerid, s_PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);

				s_DeathSkipTick[playerid] = 0;

				new animlib[] = "PED", animname[] = "IDLE_stance";
				ApplyAnimation(playerid, animlib, animname, 4.1, true, false, false, false, 1, FORCE_SYNC:1);
			}
		} else {
			if (GetPlayerAnimationIndex(playerid) != 1189) {
				s_DeathSkip[playerid] = 0;

				WC_DeathSkipEnd(playerid);

				DebugMessage("Death skip end");
			}
		}
	}

	if (s_SpawnForStreamedIn[playerid]) {
		WC_SpawnForStreamedIn(playerid);

		s_SpawnForStreamedIn[playerid] = false;
	}

	s_LastUpdate[playerid] = tick;
	return continue(playerid);
}

hook callback OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
	if (!IsHighRateWeapon(weaponid)) {
		DebugMessage("OnPlayerGiveDamage(%d gave %f to %d using %d on bodypart %s)", playerid, amount, damagedid, weaponid, ReturnBodypartName(bodypart));
	}

	// Nobody got damaged
	if (!IsPlayerConnected(damagedid)) 
	{
		OnInvalidWeaponDamage(playerid, damagedid, amount, weaponid, bodypart, WC_NO_DAMAGED, true);

		AddRejectedHit(playerid, damagedid, HIT_NO_DAMAGEDID, weaponid);

		return 0;
	}

	if (s_IsDying[damagedid]) {
		AddRejectedHit(playerid, damagedid, HIT_DYING_PLAYER, weaponid);
		return 0;
	}

	if (!s_LagCompMode) {
		new npc = IsPlayerNPC(damagedid);

		if (weaponid == WEAPON_KNIFE && _:amount == _:0.0) {
			if (damagedid == playerid) {
				return 0;
			}

			if (s_KnifeTimeout[damagedid]) {
				KillTimer(s_KnifeTimeout[damagedid]);
			}

			s_KnifeTimeout[damagedid] = SetTimerEx("WC_SetSpawnForStreamedIn", 2500, false, "i", damagedid);
		}

		if (!npc) {
			return 0;
		}
	}

	// Ignore unreliable and invalid damage
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(s_ValidDamageGiven) || !s_ValidDamageGiven[weaponid]) {
		// Fire is synced as taken damage (because it's not reliable as given), so no need to show a rejected hit.
		// Vehicle damage is also synced as taken, so no need to show that either.
		if (weaponid != WEAPON_FLAMETHROWER && weaponid != WEAPON_VEHICLE) {
			AddRejectedHit(playerid, damagedid, HIT_INVALID_WEAPON, weaponid);
		}

		return 0;
	}

	new tick = GetTickCount();
	if (tick == 0) tick = 1;

	if (!WC_IsPlayerSpawned(playerid) && tick - s_LastDeathTick[playerid] > 80) {
		// Make sure the rejected hit wasn't added in OnPlayerWeaponShot
		if (!IsBulletWeapon(weaponid) || s_LastShot[playerid][e_Valid]) {
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
				if (s_KnifeTimeout[damagedid]) {
					KillTimer(s_KnifeTimeout[damagedid]);
				}

				s_KnifeTimeout[damagedid] = SetTimerEx("WC_SpawnForStreamedIn", 150, false, "i", damagedid);
				ClearAnimations(playerid, FORCE_SYNC:1);
				SetPlayerArmedWeapon(playerid, w);

				return 0;
			} else {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);

				if (GetPlayerDistanceFromPoint(damagedid, x, y, z) > s_WeaponRange[weaponid] + 2.0) {
					if (s_KnifeTimeout[damagedid]) {
						KillTimer(s_KnifeTimeout[damagedid]);
					}

					s_KnifeTimeout[damagedid] = SetTimerEx("WC_SpawnForStreamedIn", 150, false, "i", damagedid);
					ClearAnimations(playerid, FORCE_SYNC:1);
					SetPlayerArmedWeapon(playerid, w);

					return 0;
				}
			}

			if (!OnPlayerDamage(damagedid, amount, playerid, weaponid, bodypart)) {
				if (s_KnifeTimeout[damagedid]) {
					KillTimer(s_KnifeTimeout[damagedid]);
				}

				s_KnifeTimeout[damagedid] = SetTimerEx("WC_SpawnForStreamedIn", 150, false, "i", damagedid);
				ClearAnimations(playerid, FORCE_SYNC:1);
				SetPlayerArmedWeapon(playerid, w);

				return 0;
			}

			s_DamageDoneHealth[playerid] = s_PlayerHealth[playerid];
			s_DamageDoneArmour[playerid] = s_PlayerArmour[playerid];

			OnPlayerDamageDone(damagedid, s_PlayerHealth[damagedid] + s_PlayerArmour[damagedid], playerid, weaponid, bodypart);

			ClearAnimations(damagedid, FORCE_SYNC:1);

			new animlib[32] = "KNIFE", animname[32] = "KILL_Knife_Ped_Damage";
			PlayerDeath(damagedid, animlib, animname, _, 5200);

			SetTimerEx("WC_SecondKnifeAnim", 2200, false, "i", damagedid);

			OnPlayerDeath(damagedid, playerid, weaponid);

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
	if ((!IsPlayerStreamedIn(playerid, damagedid) && !WC_IsPlayerPaused(damagedid)) || !IsPlayerStreamedIn(damagedid, playerid)) {
		AddRejectedHit(playerid, damagedid, HIT_UNSTREAMED, weaponid, damagedid);
		return 0;
	}

	new Float:bullets, err;

	if ((err = ProcessDamage(damagedid, playerid, amount, weaponid, bodypart, bullets))) 
	{
		//if (err == WC_INVALID_DAMAGE) 
		//{
		//	amount = s_WeaponDamage[weaponid];
		//	//AddRejectedHit(playerid, damagedid, HIT_INVALID_DAMAGE, weaponid, _:amount);
		//}

		if (err != WC_INVALID_DISTANCE && err != WC_INVALID_DAMAGE) 
		{
			OnInvalidWeaponDamage(playerid, damagedid, amount, weaponid, bodypart, err, true);
			return 0;
		}

		//return 0;
	}

	new idx = (s_LastHitIdx[playerid] + 1) % sizeof(s_LastHitTicks[]);

	// JIT plugin fix
	if (idx < 0) 
	{
		idx += sizeof(s_LastHitTicks[]);
	}

	s_LastHitIdx[playerid] = idx;
	s_LastHitTicks[playerid][idx] = tick;
	s_LastHitWeapons[playerid][idx] = weaponid;
	s_HitsIssued[playerid] += 1;

	new multiple_weapons;
	new avg_rate = AverageHitRate(playerid, s_MaxHitRateSamples, multiple_weapons);

	// Hit issue flood?
	// Could be either a cheat or just lag
	if (avg_rate != -1) 
	{
		if (multiple_weapons) 
		{
			if (avg_rate < 100) 
			{
				AddRejectedHit(playerid, damagedid, HIT_RATE_TOO_FAST_MULTIPLE, weaponid, avg_rate, s_MaxHitRateSamples);
				return 0;
			}
		} 
		else if (s_MaxWeaponShootRate[weaponid] - avg_rate > 20) 
		{
			AddRejectedHit(playerid, damagedid, HIT_RATE_TOO_FAST, weaponid, avg_rate, s_MaxHitRateSamples, s_MaxWeaponShootRate[weaponid]);
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
		if (!s_LastShot[playerid][e_Valid]) 
		{
			valid = false;
			//AddRejectedHit(playerid, damagedid, HIT_LAST_SHOT_INVALID, weaponid);
			DebugMessageRed("last shot not valid");
		} 
		else if (WEAPON_SHOTGUN <= weaponid <= WEAPON_SHOTGSPA) 
		{
			// Let's assume someone won't hit 2 players with 1 shotgun shot, and that one OnPlayerWeaponShot can be out of sync
			if (s_LastShot[playerid][e_Hits] >= 2) 
			{
				valid = false;
				AddRejectedHit(playerid, damagedid, HIT_MULTIPLE_PLAYERS_SHOTGUN, weaponid, s_LastShot[playerid][e_Hits] + 1);
			}
		} 
		else if (s_LastShot[playerid][e_Hits] > 0) 
		{
			// Sniper doesn't always send OnPlayerWeaponShot
			if (s_LastShot[playerid][e_Hits] >= 3 && weaponid != WEAPON_SNIPER) 
			{
				valid = false;
				AddRejectedHit(playerid, damagedid, HIT_MULTIPLE_PLAYERS, weaponid, s_LastShot[playerid][e_Hits] + 1);
			} 
			else 
			{
				DebugMessageRed("hit %d players with 1 shot", s_LastShot[playerid][e_Hits] + 1);
			}
		}

		if (valid) 
		{
			new Float:dist = GetPlayerDistanceFromPoint(damagedid, s_LastShot[playerid][e_HX], s_LastShot[playerid][e_HY], s_LastShot[playerid][e_HZ]);

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

		s_LastShot[playerid][e_Hits] += 1;
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

hook callback OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
	if (IsPlayerNPC(playerid)) 
	{
		return 0;
	}

	UpdateHealthBar(playerid, true);

	if (!WC_IsPlayerSpawned(playerid)) 
	{
		return 0;
	}

	if (!IsHighRateWeapon(weaponid)) 
	{
		DebugMessage("OnPlayerTakeDamage(%d took %f from %d by %d on bodypart %d)", playerid, amount, issuerid, weaponid, bodypart);
	}

	// Ignore unreliable and invalid damage
	if (weaponid < WEAPON_UNARMED || _:weaponid >= sizeof(s_ValidDamageTaken) || !s_ValidDamageTaken[weaponid]) 
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

			if (s_KnifeTimeout[playerid]) 
			{
				KillTimer(s_KnifeTimeout[playerid]);

				s_KnifeTimeout[playerid] = 0;
			}

			if (issuerid == INVALID_PLAYER_ID || HasSameTeam(playerid, issuerid)) {
				ResyncPlayer(playerid);

				return 0;
			} else {
				new Float:x, Float:y, Float:z;
				GetPlayerPos(issuerid, x, y, z);

				if (GetPlayerDistanceFromPoint(playerid, x, y, z) > s_WeaponRange[weaponid] + 2.0) {
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

			s_DamageDoneHealth[playerid] = s_PlayerHealth[playerid];
			s_DamageDoneArmour[playerid] = s_PlayerArmour[playerid];

			OnPlayerDamageDone(playerid, s_PlayerHealth[playerid] + s_PlayerArmour[playerid], issuerid, weaponid, bodypart);

			new animlib[32] = "KNIFE", animname[32] = "KILL_Knife_Ped_Die";
			PlayerDeath(playerid, animlib, animname, _, 4000 - GetPlayerPing(playerid));

			OnPlayerDeath(playerid, issuerid, weaponid);

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
	if (s_LagCompMode && s_ValidDamageTaken[weaponid] != 2) {
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

		if (s_IsDying[issuerid] && (IsBulletWeapon(weaponid) || IsMeleeWeapon(weaponid)) && GetTickCount() - s_LastDeathTick[issuerid] > 80) {
			DebugMessageRed("shot/punched by dead player (%d)", issuerid);
			return 0;
		}

		if (s_BeingResynced[issuerid]) {
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
		if ((!IsPlayerStreamedIn(playerid, issuerid) && !WC_IsPlayerPaused(issuerid)) || !IsPlayerStreamedIn(issuerid, playerid)) {
			// Probably fake or belated damage, so let's just reset issuerid
			issuerid = INVALID_PLAYER_ID;
		}
	}

	new Float:bullets = 0.0, err;

	if ((err = ProcessDamage(playerid, issuerid, amount, weaponid, bodypart, bullets))) 
	{
		//if (err == WC_INVALID_DAMAGE) 
		//{
		//	amount = s_WeaponDamage[weaponid];
		//	//AddRejectedHit(issuerid, playerid, HIT_INVALID_DAMAGE, weaponid, _:amount);
		//}

		if (err != WC_INVALID_DISTANCE) 
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

		if (dist > s_WeaponRange[weaponid] + 2.0) 
		{
			AddRejectedHit(issuerid, playerid, HIT_OUT_OF_RANGE, weaponid, _:dist, _:s_WeaponRange[weaponid]);
			return 0;
		}
	}

	InflictDamage(playerid, amount, issuerid, weaponid, bodypart);

	return 0;
}

hook callback OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{

	s_LastShot[playerid][e_Valid] = false;

	new tick = GetTickCount();
	if (tick == 0) tick = 1;

	if (s_CbugFroze[playerid] && tick - s_CbugFroze[playerid] < 900) {
		return 0;
	}

	s_CbugFroze[playerid] = 0;

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

	if (s_BeingResynced[playerid]) {
		AddRejectedHit(playerid, damagedid, HIT_BEING_RESYNCED, weaponid);

		return 0;
	}

	if (!WC_IsPlayerSpawned(playerid) && tick - s_LastDeathTick[playerid] > 80) {
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
		if (length > s_WeaponRange[weaponid]) {
			if (hittype == BULLET_HIT_TYPE_PLAYER) {
				AddRejectedHit(playerid, damagedid, HIT_OUT_OF_RANGE, weaponid, _:length, _:s_WeaponRange[weaponid]);
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

	new idx = (s_LastShotIdx[playerid] + 1) % sizeof(s_LastShotTicks[]);

	// JIT plugin fix
	if (idx < 0) {
		idx += sizeof(s_LastShotTicks[]);
	}

	s_LastShotIdx[playerid] = idx;
	s_LastShotTicks[playerid][idx] = tick;
	s_LastShotWeapons[playerid][idx] = weaponid;
	s_ShotsFired[playerid] += 1;

	s_LastShot[playerid][e_Tick] = tick;
	s_LastShot[playerid][e_Weapon] = weaponid;
	s_LastShot[playerid][e_HitType] = hittype;
	s_LastShot[playerid][e_HitId] = hitid;
	s_LastShot[playerid][e_X] = fX;
	s_LastShot[playerid][e_Y] = fY;
	s_LastShot[playerid][e_Z] = fZ;
	s_LastShot[playerid][e_OX] = fOriginX;
	s_LastShot[playerid][e_OY] = fOriginY;
	s_LastShot[playerid][e_OZ] = fOriginZ;
	s_LastShot[playerid][e_HX] = fHitPosX;
	s_LastShot[playerid][e_HY] = fHitPosY;
	s_LastShot[playerid][e_HZ] = fHitPosZ;
	s_LastShot[playerid][e_Length] = length;
	s_LastShot[playerid][e_Hits] = 0;

	new multiple_weapons;
	new avg_rate = AverageShootRate(playerid, s_MaxShootRateSamples, multiple_weapons);

	// Bullet flood?
	// Could be either a cheat or just lag
	if (avg_rate != -1) {
		if (multiple_weapons) {
			if (avg_rate < 100) {
				AddRejectedHit(playerid, damagedid, SHOOTING_RATE_TOO_FAST_MULTIPLE, weaponid, avg_rate, s_MaxShootRateSamples);
				return 0;
			}
		} else if (s_MaxWeaponShootRate[weaponid] - avg_rate > 20) {
			AddRejectedHit(playerid, damagedid, SHOOTING_RATE_TOO_FAST, weaponid, avg_rate, s_MaxShootRateSamples, s_MaxWeaponShootRate[weaponid]);
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

		if (s_VehiclePassengerDamage) {
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
					health -= s_WeaponDamage[weaponid] * 3.0;
				}

				if (health <= 0.0) {
					health = 0.0;
				}

				SetVehicleHealth(hitid, health);
			}
		}

		if (s_VehicleUnoccupiedDamage) {
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
						health -= s_WeaponDamage[weaponid] * 3.0;
					}

					if (health < 250.0) {
						if (!s_VehicleRespawnTimer[hitid]) {
							health = 249.0;
							s_VehicleRespawnTimer[hitid] = SetTimerEx("WC_KillVehicle", 6000, false, "ii", hitid, playerid);
						}
					}

					SetVehicleHealth(hitid, health);
				}
			}
		}
	}

	new retval = OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, fX, fY, fZ);

	s_LastShot[playerid][e_Valid] = !!retval;

	// Valid shot?
	if (retval) {
		if (hittype == BULLET_HIT_TYPE_VEHICLE) {
			s_LastVehicleShooter[hitid] = playerid;
		}
	}

	return retval;
}

forward WC_KillVehicle(vehicleid, killerid);
public WC_KillVehicle(vehicleid, killerid)
{
	OnVehicleDeath(vehicleid, killerid);
	s_VehicleRespawnTimer[vehicleid] = SetTimerEx("OnDeadVehicleSpawn", 10000, false, "i", vehicleid);
	return 1;
}

forward OnDeadVehicleSpawn(vehicleid);
public OnDeadVehicleSpawn(vehicleid)
{
	s_VehicleRespawnTimer[vehicleid] = 0;
	return SetVehicleToRespawn(vehicleid);
}

hook callback OnVehicleSpawn(vehicleid)
{
	if (s_VehicleRespawnTimer[vehicleid]) {
		KillTimer(s_VehicleRespawnTimer[vehicleid]);
		s_VehicleRespawnTimer[vehicleid] = 0;
	}

	s_VehicleAlive[vehicleid] = true;
	s_LastVehicleShooter[vehicleid] = INVALID_PLAYER_ID;

	return continue(vehicleid);
}

hook callback OnVehicleDeath(vehicleid, killerid)
{
	if (s_VehicleRespawnTimer[vehicleid]) {
		KillTimer(s_VehicleRespawnTimer[vehicleid]);
		s_VehicleRespawnTimer[vehicleid] = 0;
	}

	if (s_VehicleAlive[vehicleid]) {
		s_VehicleAlive[vehicleid] = false;

		return continue(vehicleid, killerid);
	}
	return 1;
}

hook callback OnPlayerEnterCheckpoint(playerid)
{
	if (!WC_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return continue(playerid);
}

hook callback OnPlayerLeaveCheckpoint(playerid)
{
	// If they're dying, it will be called in PlayerDeath (when the death anim begins)
	if (s_IsDying[playerid]) {
		return 0;
	}

	return continue(playerid);
}

hook callback OnPlayerEnterRaceCheckpoint(playerid)
{
	if (!WC_IsPlayerSpawned(playerid)) {
		return 0;
	}

	return continue(playerid);
}

hook callback OnPlayerLeaveRaceCheckpoint(playerid)
{
	// If they're dying, it will be called in PlayerDeath (when the death anim begins)
	if (s_IsDying[playerid]) {
		return 0;
	}

	return continue(playerid);
}

/*
 * Pawn.RakNet handlers
 */
IPacket:WC_PLAYER_SYNC(playerid, BitStream:bs)
{
	new onFootData[PR_OnFootSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadOnFootSync(bs, onFootData);

	// Because of detonator crasher - Sends KEY_HANDBRAKE/KEY_AIM in this packet and cam mode IDs 7, 8, 34, 45, 46, 51 and 65 in WC_AIM_SYNC
	if (onFootData[PR_weaponId] == _:WEAPON_BOMB) {
		onFootData[PR_keys] &= ~_:KEY_HANDBRAKE;
	}

	if (s_DisableSyncBugs) {
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

	if (s_SyncDataFrozen[playerid]) {
		onFootData = s_LastSyncData[playerid];
	} else {
		s_TempSyncData[playerid] = onFootData;
		s_TempDataWritten[playerid] = true;
	}

	if (s_FakeHealth{playerid} != 255) {
		onFootData[PR_health] = s_FakeHealth{playerid};
	}

	if (s_FakeArmour{playerid} != 255) {
		onFootData[PR_armour] = s_FakeArmour{playerid};
	}

	if (s_FakeQuat[playerid][0] == s_FakeQuat[playerid][0]) {
		onFootData[PR_quaternion] = s_FakeQuat[playerid];
	}

	if (onFootData[PR_weaponId] == _:WEAPON_KNIFE && !s_KnifeSync) {
		// Remove aim key
		onFootData[PR_keys] &= ~_:KEY_HANDBRAKE;
	} else if (onFootData[PR_weaponId] == 0) { // Punch Sync PC - Mobile
        if(onFootData[PR_keys] & _:KEY_FIRE) {
        	// Remove fire key
        	if(onFootData[PR_animationId] == 0) { // Fix punch sync mobile)
        	    if(GetTickCount() - s_PunchTick[playerid] > 300)
        	    {
        	    	onFootData[PR_keys] = 4;
                    s_PunchTick[playerid] = GetTickCount();
        	    }
        	    else
        	    {
        	    	onFootData[PR_keys] = 0;
        	    }
        	}
        	else 
        	{
                if(s_PunchUsed[playerid] == 0)
                {
                	s_PunchUsed[playerid] = 1;
                }
                else
                {
                	onFootData[PR_keys] &= ~_:KEY_FIRE;
                }
        	}
        }
        else
        {
            s_PunchUsed[playerid] = 0;
        }
	} else if (44 <= onFootData[PR_weaponId] <= 45) {
		// Remove fire key
		onFootData[PR_keys] &= ~_:KEY_FIRE;

		// Keep preventing for some more packets
		s_GogglesTick[playerid] = GetTickCount();
		s_GogglesUsed[playerid] = 1;
	} else if (s_GogglesUsed[playerid]) {
		if (s_GogglesUsed[playerid] == 2 && GetTickCount() - s_GogglesTick[playerid] > 40) {
			s_GogglesUsed[playerid] = 0;
		} else {
			// Remove fire key
			onFootData[PR_keys] &= ~_:KEY_FIRE;

			s_GogglesTick[playerid] = GetTickCount();
			s_GogglesUsed[playerid] = 2;
		}
	}

	BS_SetWriteOffset(bs, 8);
	BS_WriteOnFootSync(bs, onFootData); // rewrite

	return 1;
}

IPacket:WC_VEHICLE_SYNC(playerid, BitStream:bs)
{
	new inCarData[PR_InCarSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadInCarSync(bs, inCarData);

	if (s_FakeHealth{playerid} != 255) {
		inCarData[PR_playerHealth] = s_FakeHealth{playerid};
	}

	if (s_FakeArmour{playerid} != 255) {
		inCarData[PR_armour] = s_FakeArmour{playerid};
	}

	BS_SetWriteOffset(bs, 8);
	BS_WriteInCarSync(bs, inCarData); // rewrite

	return 1;
}

IPacket:WC_PASSENGER_SYNC(playerid, BitStream:bs)
{
	new passengerData[PR_PassengerSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadPassengerSync(bs, passengerData);

	if (s_FakeHealth{playerid} != 255) {
		passengerData[PR_playerHealth] = s_FakeHealth{playerid};
	}

	if (s_FakeArmour{playerid} != 255) {
		passengerData[PR_playerArmour] = s_FakeArmour{playerid};
	}

	BS_SetWriteOffset(bs, 8);
	BS_WritePassengerSync(bs, passengerData); // rewrite

	return 1;
}

IPacket:WC_AIM_SYNC(playerid, BitStream:bs)
{
	new aimData[PR_AimSync];

	BS_IgnoreBits(bs, 8);
	BS_ReadAimSync(bs, aimData);

	// Fix first-person up/down aim sync
	if (_:WEAPON_SNIPER <= s_LastSyncData[playerid][PR_weaponId] <= _:WEAPON_HEATSEEKER
	|| s_LastSyncData[playerid][PR_weaponId] == _:WEAPON_CAMERA) {
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

IPacket:WC_BULLET_SYNC(playerid, BitStream:bs)
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
    format(str, 64, "oX: %f | oY: %f | oZ: %f", BulletData[PR_offsets][0], BulletData[PR_offsets][1], BulletData[PR_offsets][2]);
    SendClientMessageToAll(-1, str);
    BS_SetWriteOffset(bs, 8);
    BS_WriteBulletSync(bs, BulletData);
	return 1;
}

/*
 * Internal functions
 */

static ScriptInit()
{
	s_LagCompMode = GetConsoleVarAsInt("lagcompmode");

	if (s_LagCompMode) {
		SetKnifeSync(false);
	} else {
		s_DamageTakenSound = 0;
		SetKnifeSync(true);
	}

	for (new i = 0; i < sizeof(s_ClassSpawnInfo); i++) {
		s_ClassSpawnInfo[i][e_Skin] = -1;
	}

	new worldid, tick = GetTickCount();

	foreach (new playerid : Player) {
		s_PlayerTeam[playerid] = GetPlayerTeam(playerid);

		SetPlayerTeam(playerid, s_PlayerTeam[playerid]);

		worldid = GetPlayerVirtualWorld(playerid);

		if (worldid == WC_DEATH_WORLD) {
			worldid = 0;

			SetPlayerVirtualWorld(playerid, worldid);
		}

		s_World[playerid] = worldid;
		s_LastUpdate[playerid] = tick;
		s_LastStop[playerid] = tick;
		s_LastVehicleEnterTime[playerid] = 0;
		s_TrueDeath[playerid] = true;
		s_InClassSelection[playerid] = true;
		s_AlreadyConnected[playerid] = true;

		if (PLAYER_STATE_ONFOOT <= GetPlayerState(playerid) <= PLAYER_STATE_PASSENGER) {
			GetPlayerHealth(playerid, s_PlayerHealth[playerid]);
			GetPlayerArmour(playerid, s_PlayerArmour[playerid]);

			if (s_PlayerHealth[playerid] == 0.0) {
				s_PlayerHealth[playerid] = s_PlayerMaxHealth[playerid];
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
		SetPlayerTeam(playerid, s_PlayerTeam[playerid]);

		if (PLAYER_STATE_ONFOOT <= GetPlayerState(playerid) <= PLAYER_STATE_PASSENGER) {
			health = s_PlayerHealth[playerid];

			if (health == 0.0) {
				health = s_PlayerMaxHealth[playerid];
			}

			SetPlayerHealth(playerid, health);
			SetPlayerArmour(playerid, s_PlayerArmour[playerid]);
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

	if (worldid == WC_DEATH_WORLD) {
		worldid = s_World[playerid];
	} else if (worldid != s_World[playerid]) {
		s_World[playerid] = worldid;
	}

	SetPlayerVirtualWorld(playerid, worldid);
}

static HasSameTeam(playerid, otherid)
{
	if (otherid < 0 || otherid >= MAX_PLAYERS || playerid < 0 || playerid >= MAX_PLAYERS) {
		return 0;
	}

	if (s_PlayerTeam[playerid] == NO_TEAM || s_PlayerTeam[otherid] == NO_TEAM) {
		return 0;
	}

	return (s_PlayerTeam[playerid] == s_PlayerTeam[otherid]);
}

static UpdateHealthBar(playerid, bool:force = false)
{
	if (s_BeingResynced[playerid] || s_ForceClassSelection[playerid]) {
		return;
	}

	new health = floatround(s_PlayerHealth[playerid] / s_PlayerMaxHealth[playerid] * 100.0, floatround_ceil);
	new armour = floatround(s_PlayerArmour[playerid] / s_PlayerMaxArmour[playerid] * 100.0, floatround_ceil);

	// Make the values reflect what the client should see
	if (s_IsDying[playerid]) {
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
		s_LastSentHealth[playerid] = -1;
		s_LastSentArmour[playerid] = -1;
	} 
	else if (!s_IsDying[playerid]) 
	{
		s_LastSentHealth[playerid] = -1;
	} 
	else if (health == s_LastSentHealth[playerid] && armour == s_LastSentArmour[playerid]) 
	{
		return;
	}

	SetFakeHealth(playerid, health);
	SetFakeArmour(playerid, armour);

	// Hit Mark Status
    s_HitInformer[playerid] = 1;
    if(s_HitInformerTimer[playerid] == 0)
    {
    	SetPlayerColor(playerid, 0xFF0000FF);
        s_HitInformerTimer[playerid] = SetTimerEx("HitInformer", 350, true, "d", playerid);
    }

	UpdateSyncData(playerid);

	if (health != s_LastSentHealth[playerid]) {
		s_LastSentHealth[playerid] = health;
		if(health == 0.0)
		{
			SetPlayerHealth(playerid, 0.9);
		}
		else
		{
            SetPlayerHealth(playerid, float(health));
		}
	}

	if (armour != s_LastSentArmour[playerid]) {
		s_LastSentArmour[playerid] = armour;

		SetPlayerArmour(playerid, float(armour));
	}
}

forward HitInformer(playerid);
public HitInformer(playerid)
{
    if(s_HitInformer[playerid] == 0)
    {
    	SetPlayerColor(playerid, 0xFFFFFFFF);
        KillTimer(s_HitInformerTimer[playerid]);
        s_HitInformerTimer[playerid] = 0;
    }
    else
    {
        s_HitInformer[playerid] = 0;
    }
    return 1;
}

static SpawnPlayerInPlace(playerid) {
	new Float:x, Float:y, Float:z, Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	SetSpawnInfo(playerid, s_PlayerTeam[playerid], GetPlayerSkin(playerid), x, y, z, r, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0, WEAPON_UNARMED, 0);

	s_SpawnInfoModified[playerid] = true;

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

	#if defined _Y_ITERATE_LOCAL_VERSION && defined _FOREACH_STREAMED && !defined FOREACH_NO_STREAMED
	foreach (new i : StreamedPlayer[playerid]) {
		SendLastSyncPacket(playerid, i);
	}
	#elseif defined _Y_ITERATE_LOCAL_VERSION || defined _FOREACH_LOCAL_VERSION
	foreach (new i : Player) {
		if (i != playerid && IsPlayerStreamedIn(playerid, i)) {
			SendLastSyncPacket(playerid, i);
		}
	}
	#endif
}

static WasPlayerInVehicle(playerid, time) {
	if (!s_LastVehicleTick[playerid]) {
		return 0;
	}

	if (GetTickCount() - time < s_LastVehicleTick[playerid]) {
		return 1;
	}

	return 0;
}

forward WC_DeathSkipEnd(playerid);
public WC_DeathSkipEnd(playerid)
{
	TogglePlayerControllable(playerid, true);

	ResetPlayerWeapons(playerid);

	for (new i = 0; i < 13; i++) {
		if (s_SyncData[playerid][e_WeaponId][i]) {
			GivePlayerWeapon(playerid, s_SyncData[playerid][e_WeaponId][i], s_SyncData[playerid][e_WeaponAmmo][i]);
		}
	}

	SetPlayerArmedWeapon(playerid, s_SyncData[playerid][e_Weapon]);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
}

forward WC_SpawnForStreamedIn(playerid);
public WC_SpawnForStreamedIn(playerid)
{
	if (!IsPlayerConnected(playerid)) {
		return;
	}

	SpawnPlayerForWorld(playerid);

	#if defined _Y_ITERATE_LOCAL_VERSION && defined _FOREACH_STREAMED && !defined FOREACH_NO_STREAMED
	foreach (new i : StreamedPlayer[playerid]) {
		SendLastSyncPacket(playerid, i);
		ClearAnimationsForPlayer(playerid, i);
	}
	#elseif defined _Y_ITERATE_LOCAL_VERSION || defined _FOREACH_LOCAL_VERSION
	foreach (new i : Player) {
		if (i != playerid && IsPlayerStreamedIn(playerid, i)) {
			SendLastSyncPacket(playerid, i);
			ClearAnimationsForPlayer(playerid, i);
		}
	}
	#endif
}

forward WC_SetSpawnForStreamedIn(playerid);
public WC_SetSpawnForStreamedIn(playerid)
{
	s_SpawnForStreamedIn[playerid] = true;
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
		//if (_:s_WeaponDamage[weaponid] != _:1.0) 
		//{
		//	amount *= s_WeaponDamage[weaponid];
		//}

		// Make sure the distance and issuer is valid; carpark can be self-inflicted so it doesn't require an issuer
		if (weaponid == WEAPON_SPRAYCAN || weaponid == WEAPON_FIREEXTINGUISHER || (weaponid == WEAPON_CARPARK && issuerid != INVALID_PLAYER_ID)) {
			if (issuerid == INVALID_PLAYER_ID) {
				return WC_NO_ISSUER;
			}

			new Float:x, Float:y, Float:z, Float:dist;
			GetPlayerPos(issuerid, x, y, z);
			dist = GetPlayerDistanceFromPoint(playerid, x, y, z);

			if (weaponid == WEAPON_CARPARK) 
			{
				if (dist > 15.0) 
				{
					AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist);
					return WC_INVALID_DISTANCE;
				}
			} 
			else 
			{
				if (dist > s_WeaponRange[weaponid] + 2.0) 
				{
					AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist, _:s_WeaponRange[weaponid]);
					return WC_INVALID_DISTANCE;
				}
			}
		}

		return WC_NO_ERROR;
	}

	// Bullet or melee damage must have an issuerid, otherwise something has gone wrong (e.g. sniper bug)
	if (issuerid == INVALID_PLAYER_ID && (IsBulletWeapon(weaponid) || IsMeleeWeapon(weaponid))) 
	{
		return WC_NO_ISSUER;
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
			else if (s_LastExplosive[issuerid]) 
			{
				weaponid = s_LastExplosive[issuerid];
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
		return WC_INVALID_DAMAGE;
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
					return WC_INVALID_DAMAGE;
				}
			}

			// Melee damage has been tampered with
			default: 
			{
				if (melee) 
				{
					return WC_INVALID_DAMAGE;
				}
			}
		}
	}

	if (melee) 
	{
		new Float:x, Float:y, Float:z, Float:dist;
		GetPlayerPos(issuerid, x, y, z);
		dist = GetPlayerDistanceFromPoint(playerid, x, y, z);

		if (_:WEAPON_UNARMED <= _:weaponid < sizeof(s_WeaponRange) && dist > s_WeaponRange[weaponid] + 2.0) 
		{
			AddRejectedHit(issuerid, playerid, HIT_TOO_FAR_FROM_ORIGIN, WEAPON:weaponid, _:dist, _:s_WeaponRange[weaponid]);
			return WC_INVALID_DISTANCE;
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
				return WC_INVALID_DAMAGE;
			}
		}

		// Shotguns and sawed-off shotguns shoot 15 bullets, each inflicting 3.3 damage
		case WEAPON_SHOTGUN, WEAPON_SAWEDOFF: 
		{
			bullets = amount / 3.30000019073486328125;

			if (15.0 - bullets < -0.05) 
			{
				return WC_INVALID_DAMAGE;
			}
		}
	}

	if (_:bullets) 
	{
		new Float:f = floatfract(bullets);

		// The damage for each bullet has been tampered with
		if (f > 0.01 && f < 0.99) 
		{
			return WC_INVALID_DAMAGE;
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
				return WC_INVALID_DAMAGE;
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
				return WC_INVALID_DAMAGE;
			}
		}
	}

	// Adjust the damage
	switch (s_DamageType[weaponid]) 
	{
		case DAMAGE_TYPE_MULTIPLIER: 
		{
			if (_:s_WeaponDamage[weaponid] != _:1.0) 
			{
				amount *= s_WeaponDamage[weaponid];
			}
		}

		case DAMAGE_TYPE_STATIC: 
		{
			new Float:length = 0.0;
			if (s_LagCompMode) 
			{
				length = s_LastShot[issuerid][e_Length];
				if (_:bullets) 
			    {
			    	amount = s_WeaponDamage[weaponid] * bullets;
			    } 
			    else 
			    {
			    	amount = s_WeaponDamage[weaponid];
			    }
			} 
			else 
			{
				new Float:X, Float:Y, Float:Z;
				GetPlayerPos(issuerid, X, Y, Z);
				length = GetPlayerDistanceFromPoint(playerid, X, Y, Z);

				if (_:bullets) 
			    {
			    	amount = s_WeaponDamage[weaponid] * bullets;
			    } 
			    else 
			    {
			    	amount = s_WeaponDamage[weaponid];
			    }
			}
		}
	}

	return WC_NO_ERROR;
}

static InflictDamage(playerid, Float:amount, issuerid = INVALID_PLAYER_ID, WEAPON:weaponid = WEAPON_UNKNOWN, bodypart = BODY_PART_UNKNOWN, bool:ignore_armour = false)
{
	if (!WC_IsPlayerSpawned(playerid) || amount < 0.0) 
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
	&& (!s_DamageArmourToggle[0] || (s_DamageArmour[weaponid][0] && (!s_DamageArmourToggle[1] || ((s_DamageArmour[weaponid][1] && bodypart == 3) || (!s_DamageArmour[weaponid][1])))))) 
	{
		if (amount <= 0.0) 
		{
			amount = s_PlayerHealth[playerid] + s_PlayerArmour[playerid];
		}

		s_PlayerArmour[playerid] -= amount;
	} else {
		if (amount <= 0.0) 
		{
			amount = s_PlayerHealth[playerid];
		}

		s_PlayerHealth[playerid] -= amount;
	}

	if (s_PlayerArmour[playerid] < 0.0) 
	{
		s_DamageDoneArmour[playerid] = amount + s_PlayerArmour[playerid];
		s_DamageDoneHealth[playerid] = -s_PlayerArmour[playerid];
		s_PlayerHealth[playerid] += s_PlayerArmour[playerid];
		s_PlayerArmour[playerid] = 0.0;
	} 
	else 
	{
		s_DamageDoneArmour[playerid] = amount;
		s_DamageDoneHealth[playerid] = 0.0;
	}

	if (s_PlayerHealth[playerid] <= 0.0) {
		amount += s_PlayerHealth[playerid];
		s_DamageDoneHealth[playerid] += s_PlayerHealth[playerid];
		s_PlayerHealth[playerid] = 0.0;
	}

	OnPlayerDamageDone(playerid, amount, issuerid, weaponid, bodypart);
	new animlib[32] = "PED", animname[32];

	if (s_PlayerHealth[playerid] <= 0.0005) {
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
			if (gettime() - s_LastVehicleEnterTime[playerid] < 10) {
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

		if (s_CbugAllowed[playerid]) {
			OnPlayerDeath(playerid, issuerid, weaponid);
		} else {
			s_DelayedDeathTimer[playerid] = SetTimerEx(#WC_DelayedDeath, 1200, false, "iii", playerid, issuerid, weaponid);
		}
	}

	UpdateHealthBar(playerid);
}

forward WC_DelayedDeath(playerid, issuerid, WEAPON:reason);
public WC_DelayedDeath(playerid, issuerid, WEAPON:reason) {
	s_DelayedDeathTimer[playerid] = 0;

	OnPlayerDeath(playerid, issuerid, reason);
}

static PlayerDeath(playerid, animlib[32], animname[32], bool:anim_lock = false, respawn_time = -1, bool:freeze_sync = true, bool:anim_freeze = true)
{
	s_PlayerHealth[playerid] = 0.0;
	s_PlayerArmour[playerid] = 0.0;
	s_IsDying[playerid] = true;

	s_LastDeathTick[playerid] = GetTickCount();

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
		respawn_time = s_RespawnTime;
	}

	if (animlib[0] && animname[0]) {
		ApplyAnimation(playerid, animlib, animname, 4.1, false, anim_lock, anim_lock, anim_freeze, 0, FORCE_SYNC:1);
	}

	if (s_DeathTimer[playerid]) {
		KillTimer(s_DeathTimer[playerid]);
	}

	s_DeathTimer[playerid] = SetTimerEx("WC_PlayerDeathRespawn", respawn_time, false, "i", playerid);

	if (IsPlayerInCheckpoint(playerid)) {
		OnPlayerLeaveCheckpoint(playerid);
	}

	if (IsPlayerInRaceCheckpoint(playerid)) {
		OnPlayerLeaveRaceCheckpoint(playerid);
	}
}

hook callback OnPlayerPrepareDeath(playerid, animlib[32], animname[32], &anim_lock, &respawn_time)
{
	return continue(playerid, animlib, animname, anim_lock, respawn_time);
}

hook callback OnRejectedHit(playerid, hit[E_REJECTED_HIT])
{
	OnRejectedHit(playerid, hit);
}

hook callback OnPlayerDeathFinished(playerid, bool:cancelable)
{
	if (s_PlayerHealth[playerid] == 0.0) {
		s_PlayerHealth[playerid] = s_PlayerMaxHealth[playerid];
	}

	if (s_DeathTimer[playerid]) {
		KillTimer(s_DeathTimer[playerid]);
		s_DeathTimer[playerid] = 0;
	}

	new retval = OnPlayerDeathFinished(playerid, cancelable);

	if (!retval && cancelable) {
		return 0;
	}

	ResetPlayerWeapons(playerid);

	return 1;
}

static SaveSyncData(playerid)
{
	GetPlayerHealth(playerid, s_SyncData[playerid][e_Health]);
	GetPlayerArmour(playerid, s_SyncData[playerid][e_Armour]);

	GetPlayerPos(playerid, s_SyncData[playerid][e_PosX], s_SyncData[playerid][e_PosY], s_SyncData[playerid][e_PosZ]);
	GetPlayerFacingAngle(playerid, s_SyncData[playerid][e_PosA]);

	s_SyncData[playerid][e_Skin] = GetPlayerSkin(playerid);
	s_SyncData[playerid][e_Team] = GetPlayerTeam(playerid);

	s_SyncData[playerid][e_Weapon] = GetPlayerWeapon(playerid);

	for (new WEAPON_SLOT:i; _:i < 13; i++) 
	{
		GetPlayerWeaponData(playerid, i, s_SyncData[playerid][e_WeaponId][i], s_SyncData[playerid][e_WeaponAmmo][i]);
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
		new idx = s_RejectedHitsIdx[playerid];

		if (s_RejectedHits[playerid][idx][e_Time]) 
		{
			idx += 1;

			if (idx >= sizeof(s_RejectedHits[])) 
			{
				idx = 0;
			}

			s_RejectedHitsIdx[playerid] = idx;
		}

		new time, hour, minute, second;

		time = gettime(hour, minute, second);

		s_RejectedHits[playerid][idx][e_Reason] = reason;
		s_RejectedHits[playerid][idx][e_Time] = time;
		s_RejectedHits[playerid][idx][e_Weapon] = weapon;
		s_RejectedHits[playerid][idx][e_Hour] = hour;
		s_RejectedHits[playerid][idx][e_Minute] = minute;
		s_RejectedHits[playerid][idx][e_Second] = second;
		s_RejectedHits[playerid][idx][e_Info1] = _:i1;
		s_RejectedHits[playerid][idx][e_Info2] = _:i2;
		s_RejectedHits[playerid][idx][e_Info3] = _:i3;

		if (0 <= damagedid < MAX_PLAYERS) 
		{
			GetPlayerName(damagedid, s_RejectedHits[playerid][idx][e_Name], MAX_PLAYER_NAME);
		} else {
			s_RejectedHits[playerid][idx][e_Name][0] = '#';
			s_RejectedHits[playerid][idx][e_Name][1] = '\0';
		}

		OnRejectedHit(playerid, s_RejectedHits[playerid][idx]);
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
			PR_SendRPC(bs, i, WC_RPC_REQUEST_SPAWN);
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

	s_LastSyncData[playerid][PR_keys] = 0;
	s_LastSyncData[playerid][PR_udKey] = 0;
	s_LastSyncData[playerid][PR_lrKey] = 0;
	s_LastSyncData[playerid][PR_specialAction] = SPECIAL_ACTION_NONE;
	s_LastSyncData[playerid][PR_velocity][0] = 0.0;
	s_LastSyncData[playerid][PR_velocity][1] = 0.0;
	s_LastSyncData[playerid][PR_velocity][2] = 0.0;

	s_SyncDataFrozen[playerid] = toggle;

	return 1;
}

static SetFakeHealth(playerid, health)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	s_FakeHealth{playerid} = health;

	return 1;
}

static SetFakeArmour(playerid, armour)
{
	if (!IsPlayerConnected(playerid)) {
		return 0;
	}

	s_FakeArmour{playerid} = armour;

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
		s_FakeQuat[playerid][0] = Float:0x7FFFFFFF;
		s_FakeQuat[playerid][1] = Float:0x7FFFFFFF;
		s_FakeQuat[playerid][2] = Float:0x7FFFFFFF;
		s_FakeQuat[playerid][3] = Float:0x7FFFFFFF;
	} else {
		GetRotationQuaternion(0.0, 0.0, angle, s_FakeQuat[playerid][0], s_FakeQuat[playerid][1], s_FakeQuat[playerid][2], s_FakeQuat[playerid][3]);
	}

	return 1;
}

static SendLastSyncPacket(playerid, toplayerid, animation = 0)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerConnected(toplayerid)) {
		return 0;
	}

	new BitStream:bs = BS_New();

	BS_WriteValue(bs, PR_UINT8, WC_PLAYER_SYNC, PR_UINT16, playerid);

	if (s_FakeQuat[playerid][0] == s_FakeQuat[playerid][0]) {
		s_LastSyncData[playerid][PR_quaternion] = s_FakeQuat[playerid];
	}

	if (s_FakeHealth{playerid} != 255) {
		s_LastSyncData[playerid][PR_health] = s_FakeHealth{playerid};
	}

	if (s_FakeArmour{playerid} != 255) {
		s_LastSyncData[playerid][PR_armour] = s_FakeArmour{playerid};
	}

	// Make them appear standing still if paused
	if (WC_IsPlayerPaused(playerid)) {
		s_LastSyncData[playerid][PR_velocity][0] = 0.0;
		s_LastSyncData[playerid][PR_velocity][1] = 0.0;
		s_LastSyncData[playerid][PR_velocity][2] = 0.0;
	}

	// Animations are only sent when they are changed
	if (!animation) {
		s_LastSyncData[playerid][PR_animationId] = 0;
		s_LastSyncData[playerid][PR_animationFlags] = 0;
	}

	BS_WriteOnFootSync(bs, s_LastSyncData[playerid], true);
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
	PR_SendRPC(bs, forplayerid, WC_RPC_CLEAR_ANIMATIONS);
	BS_Delete(bs);

	return 1;
}

forward WC_SecondKnifeAnim(playerid);
public WC_SecondKnifeAnim(playerid)
{
	new animlib[] = "KNIFE", animname[] = "KILL_Knife_Ped_Die";
	ApplyAnimation(playerid, animlib, animname, 4.1, false, true, true, true, 3000, FORCE_SYNC:1);
}

forward WC_PlayerDeathRespawn(playerid);
public WC_PlayerDeathRespawn(playerid)
{
	if (!s_IsDying[playerid]) {
		return;
	}

	s_IsDying[playerid] = false;

	if (!OnPlayerDeathFinished(playerid, true)) {
		UpdateHealthBar(playerid);
		SetFakeFacingAngle(playerid, _);
		FreezeSyncPacket(playerid, .toggle = false);

		return;
	}

	s_IsDying[playerid] = true;
	s_TrueDeath[playerid] = false;

	if (IsPlayerInAnyVehicle(playerid)) {
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetPlayerPos(playerid, x, y, z);
	}

	SetPlayerVirtualWorld(playerid, WC_DEATH_WORLD);
	SetFakeFacingAngle(playerid, _);
	TogglePlayerSpectating(playerid, true);
	TogglePlayerSpectating(playerid, false);
}

hook callback OnInvalidWeaponDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart, error, bool:given)
{
	DebugMessageRed("OnInvalidWeaponDamage(%d, %d, %f, %d, %d, %d, %d)", playerid, damagedid, amount, weaponid, bodypart, error, given);

	OnInvalidWeaponDamage(playerid, damagedid, Float:amount, weaponid, bodypart, error, bool:given);
}

hook callback OnPlayerDamageDone(playerid, Float:amount, issuerid, WEAPON:weapon, bodypart)
{
	new idx = s_PreviousHitI[playerid];

	s_PreviousHitI[playerid] = (s_PreviousHitI[playerid] - 1) % sizeof(s_PreviousHits[]);

	// JIT plugin fix
	if (s_PreviousHitI[playerid] < 0) {
		s_PreviousHitI[playerid] += sizeof(s_PreviousHits[]);
	}

	s_PreviousHits[playerid][idx][e_Tick] = GetTickCount();
	s_PreviousHits[playerid][idx][e_Issuer] = issuerid;
	s_PreviousHits[playerid][idx][e_Weapon] = weapon;
	s_PreviousHits[playerid][idx][e_Amount] = amount;
	s_PreviousHits[playerid][idx][e_Bodypart] = bodypart;
	s_PreviousHits[playerid][idx][e_Health] = s_DamageDoneHealth[playerid];
	s_PreviousHits[playerid][idx][e_Armour] = s_DamageDoneArmour[playerid];

	if (!IsHighRateWeapon(weapon)) {
		DebugMessage("OnPlayerDamageDone(%d did %f to %d with %d on bodypart %d)", issuerid, amount, playerid, weapon, bodypart);

		if (s_DamageTakenSound) {
			PlayerPlaySound(playerid, s_DamageTakenSound, 0.0, 0.0, 0.0);

			foreach (new i : Player) {
				if (s_Spectating[i] == playerid && i != playerid) {
					PlayerPlaySound(i, s_DamageTakenSound, 0.0, 0.0, 0.0);
				}
			}
		}

		if (s_DamageGivenSound && issuerid != INVALID_PLAYER_ID) {
			PlayerPlaySound(issuerid, s_DamageGivenSound, 0.0, 0.0, 0.0);

			foreach (new i : Player) {
				if (s_Spectating[i] == issuerid && i != issuerid) {
					PlayerPlaySound(i, s_DamageGivenSound, 0.0, 0.0, 0.0);
				}
			}
		}
	}

	OnPlayerDamageDone(playerid, amount, issuerid, weapon, bodypart);
}

hook callback OnPlayerDamage(&playerid, &Float:amount, &issuerid, &WEAPON:weapon, &bodypart)
{
	return continue(playerid, amount, issuerid, weapon, bodypart);
}