//#define HIDE_MAIN // hapus jika ingin menggunakan main() pada script
//#pragma warning disable 213, 201, 208, 239, 214
#pragma option -d3 // Untuk melihat/debug ukuran data kode setelah di compile

//#define TF_DEBUG
#define CGEN_MEMORY 60000
#define W_DEBUG
#define WC

#include <a_samp>

#include <a_http>
#include <a_mysql>

// PawnPlus
#define PP_SYNTAX_AWAIT
#include <PawnPlus>
//#include <async-dialogs> // Pawnplus efficient dialog task aSync // jangan menggunakan Profiler jika tidak mau server crash
///////////////////

#include <compat> // untuk mengizinkan client versi selain 0.3DL agar bisa tetap masuk server. contoh: 0.3.7 R1-R5


//#include <hWeapon-Config>

#include <YSI_Coding\y_va>
#include <YSI_Coding\y_timers>
#include <YSI_Coding\y_hooks>

#include <Pawn.RakNet>
#include <Pawn.CMD>

#include <sscanf2>
#include <strlib>
#include <samp_bcrypt>
#include <streamer>
#include <streamer_extra>
#include <streamer-tp>
//#include <objectlabels>
//#include <colandreas>
#include <mapandreas>
#include <YSF>
#include <GPS>

#include <easyDialog>
//#include <safeDialog>

//#include <nex-ac>

#include <hTime>

//#include <vLibrary\vLibrary>


//#include <hDamages> //Damage manager

#include <DataConvert> // konversi data: binary, float ke int, hex ke int
#include <Timestamp> // Timestamp converter

//#include <samp-precise-timers>
#include <timerfix>

//#include <FCNPC>

//Anti Cheat
//#include <H-AC\vMurder> disable bentar
//////////////////
// Utility
#include "Complement\Define.pwn"
#include "Complement\Color.pwn"
#include "Complement\Connection.pwn"

#include "Complement\Variable.pwn"
#include "Complement\Function.pwn"
#include "Complement\Dialog.pwn"

#include "Complement\Timer.pwn"
#include "Complement\User.pwn"
#include "Complement\Player.pwn"

// Game Behavior
#include "Complement\RakNet.pwn"

#if defined WC
    #include "Complement\Weapon.pwn"
#endif

#include "Complement\Condition.pwn"

main(){
} // don't delete this shit or you will have big problem at running server

// Fungsi untuk memfilter ID dan durasi dari HTML yang tidak terstruktur
stock FilterHTML(const inputFile[], const outputFile[])
{
    new File:inputHandle = fopen(inputFile, io_read);

    new File:outputHandle = fopen(outputFile, io_write);

    new line[512];  // Buffer untuk setiap baris yang dibaca
    new tempStr[64];
    new id;
    new Float:duration;
    new icount;
    new index1[20], index2[20], index3[64];
    new frame;
    
    // Membaca setiap baris dari file input
    while (fread(inputHandle, line, 512, false))
    {
        //strtrim(line);
    
        strmid(line, line, strfind(line, "(") + 1, strfind(line, ");"), sizeof(line));
    
        if(sscanf(line, "p<,>is[20]s[20]dfs[64]", id, index1, index2, frame, duration, index3))
            continue;

        icount++;

        // Simpan hasil parsing ke file output
        format(tempStr, sizeof(tempStr), "%d, %.2f, ID: %d\n", id, duration, icount);
        printf(tempStr);
        fwrite(outputHandle, tempStr);
    }

    fclose(inputHandle);
    fclose(outputHandle);

    printf("Filter selesai. Hasil disimpan di: %s", outputFile);
}

forward GachaPull();
public GachaPull()
{
    new Float:roll = RandomFloat(0.0, 1.0); // Menghasilkan angka acak antara 0.0 dan 1.0
    new Float:cumulative_probability = 0.0;

    // Item Legendary (0.20%)
    cumulative_probability += 0.0020;
    if (roll <= cumulative_probability)
    {
        return print("Item Legendary");
    }

    // Item Epic (1.00%)
    cumulative_probability += 0.0100;
    if (roll <= cumulative_probability)
    {
        return print("Item Epic");
    }

    // Item Rare (5.00%)
    cumulative_probability += 0.0500;
    if (roll <= cumulative_probability)
    {
        return print("Item Rare");
    }

    // Item Uncommon (10.00%)
    cumulative_probability += 0.1000;
    if (roll <= cumulative_probability)
    {
        return print("Item Uncommon");
    }

    // Item Common (20.00%)
    cumulative_probability += 0.2000;
    if (roll <= cumulative_probability)
    {
        return print("Item Common");
    }

    return GachaPull();
}

public OnGameModeInit()
{
	printf("%f", RandomFloat(0.0, 101.0));
	//SetTimer("GachaPull", 2000, true);
	new Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz;
    //CA_GetModelBoundingBox(19387, minx, miny, minz, maxx, maxy, maxz);
    printf("%f | %f | %f | %f | %f | %f", minx, miny, minz, maxx, maxy, maxz);
    
    #if defined WC
        SetDisableSyncBugs(true);
    #endif

	//CA_Init();
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
	Database_Connect();
	AddPlayerClassEx(NO_TEAM, 0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

	Streamer_SetTickRate(150);
    Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT, 950);
	return 1;
}

stock MapCreate()
{
	CreateDynamicObject(19359, 2031.309936, 1343.219726, 9.820312, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19359, 2024.390136, 1348.169555, 10.420300, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    CreateDynamicObject(19359, 2024.390136, 1338.615234, 9.940302, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
    return 1;
}

public OnGameModeExit()
{
	mysql_close(sqlcon);
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    printf("[CMD] %s: /%s", GetName(playerid), cmd);

    if(!PlayerData[playerid][Player::Spawned])
        return 0;

    if(result == -1)
    {
        SendClientMessage(playerid, COLOR_GREY, "ERROR: Perintah tidak ditemukan, lihat '/help'");
  
        return 0;
    }

    return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
//    if (!(flags & pPermissions[playerid]))
//    {
//        printf("player %d doesn’t have access to command '%s'", playerid, cmd);
//  
//        return 0;
//    }

  return 1;
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &WEAPON:weapon, &bodypart)
{
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	#if defined WC
	    SetCbugAllowed(false, playerid);
	#endif
	SetPlayerAdmin(playerid, true); // Rcon Admin

	g_RaceCheck{playerid}++;
	SetPlayerColor(playerid, COLOR_GREY);
	ResetVariable(playerid);
	SpawnPlayer(playerid);
	TogglePlayerSpectating(playerid, true);
	wait_ticks(10);
	CheckConnection(playerid, g_RaceCheck{playerid});
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(PlayerData[playerid][Player::Spawned] == true)
	{
        SetPlayerPos(playerid, PlayerData[playerid][Player::Pos][0], PlayerData[playerid][Player::Pos][1], PlayerData[playerid][Player::Pos][2]);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SaveCharacterData(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	//OnWPlayerEnterVehicle(playerid, vehicleid, ispassenger);
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if (!IsPlayerSpawned(playerid)) {
		return 0;
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	MapAndreas_FindAverageZ(fX, fY, fZ);
    SetPlayerInterior(playerid, 0);
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        SetVehiclePos(GetPlayerVehicleID(playerid), fX, fY, fZ+1);
    else
        SetPlayerPos(playerid, fX, fY, fZ+1);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	SendClientMessageEx(killerid, -1, "Death: Nyata");
    return 1;
}

CMD:sound(playerid, params[])
{
	static
	    id;

	if (sscanf(params, "i", id))
	    return SendFalseMessage(playerid, "SYNTAX", "/sound [soundid]");
    
    PlayerPlayNearbySound(playerid, id);
	return 1;
}

static ambasing_init, ambasing_count;

CMD:ambada(playerid, params[])
{
    ambasing_init = 18;
    ambasing_count = 1;

    SetTimerEx("kontol", 18, false, "i", playerid);
	return 1;
}

FUNC::kontol(playerid)
{
    if(ambasing_count >= 20)
    {
    	PlayerPlayNearbySound(playerid, 1144);
    	return 1;
    }
    else
    {
    	SendClientMessage(playerid, -1, "Asli");
    	PlayerPlayNearbySound(playerid, 1190);
        SetTimerEx("kontol", ambasing_init, false, "i", playerid);
        ambasing_init += 18;
        ambasing_count++;
    }
    return 1;
}

CMD:slap(playerid, params[])
{
	static
	    userid, distance;

	if (sscanf(params, "uI(2)", userid, distance))
	    return SendFalseMessage(playerid, "SYNTAX", "/slap [playerid/name] [distance]");

    if (userid == INVALID_PLAYER_ID)
	    return SendFalseMessage(playerid, "ERROR", "You have specified an invalid player.");

	static
	    Float:x,
	    Float:y,
	    Float:z;

	GetPlayerPos(userid, x, y, z);
	SetPlayerPos(userid, x, y, z + distance);

	PlayerPlaySound(userid, 1130, 0.0, 0.0, 0.0);
	SendTrueMessage(playerid, "SLAP", "You have slapped %d meter", distance);
	return 1;
}

CMD:givegun(playerid, params[])
{
	static
        name[MAX_PLAYER_NAME + 1];

	new
	    userid,
	    weaponid,
	    ammo;

	if (sscanf(params, "udI(100)", userid, weaponid, ammo))
	    return SendFalseMessage(playerid, "SYNTAX", "/givegun [playerid/PartOfName] [weaponid] [opt:ammo]");

	if (userid == INVALID_PLAYER_ID)
	    return SendFalseMessage(playerid, "ERROR", "You cannot give weapons to disconnected players.");

	if (weaponid <= 0 || weaponid > 46 || (weaponid >= 10 && weaponid <= 13) || (weaponid >= 19 && weaponid <= 21))
		return SendFalseMessage(playerid, "ERROR", "You have specified an invalid weapon.");
	
	GetPlayerName(userid, name, sizeof(name));
	GivePlayerWeapon(userid, weaponid, ammo);
	SendTrueMessage(playerid, "WEAPON", "You have gave %s weapon id %d with %d ammo.", name, weaponid, ammo);
	return 1;
}


CMD:health(playerid)
{
	new str[264];
	format(str, sizeof(str), "Thorax: %.2f\nStomach: %.2f\nLeft Arm: %.2f\nRight Arm: %.2f\nLeft Leg: %.2f\nRight Leg: %.2f\n{FFFFFF}Overall: %.2f",
		FitnessRating[playerid][0], FitnessRating[playerid][1], FitnessRating[playerid][2], 
		FitnessRating[playerid][3], FitnessRating[playerid][4], FitnessRating[playerid][5],
		GetOverallFitnessRating(playerid)
	);
	ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, "Health", str, "CLOSE", "CLOSE");
	return 1;
}