#define Player:: P_
#define Vehicle:: V_

#include <a_samp>
#include <easyDialog>
#include <EVF2>
#include <PawnPlus>

new List:Vehicle, Map:PlayerVehicle;

enum
{
	DIALOG_VEHICLE_MY,
	DIALOG_VEHICLE_OPTION
}

public OnGameModeInit()
{
	Vehicle = list_new();
    PlayerVehicle = map_new();
    map_set_ordered(PlayerVehicle, true);
	  return 1;
}

public OnPlayerSpawn(playerid)
{
    LoadPlayerVehicle(playerid);
	  return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
  	UnloadPlayerVehicle(playerid);
  	return 1;
}

stock AddVehicleList(id, const arr[e_vehicle_data])
{
    return map_add_arr(PlayerVehicle, id, arr);
}

stock SaveVehicleList(id, const arr[e_vehicle_data])
{
    return map_set_arr(PlayerVehicle, id, arr);
}

stock IsVehicleCanSpawn(id)
{
    new e_veh[e_vehicle_data];
    for_map(vehicleid : PlayerVehicle)
    {
        new aidi;
        if(iter_get_key_safe(vehicleid, aidi))
        {
            if(id == aidi)
            {
                map_get_arr_safe(PlayerVehicle, id, e_veh[Vehicle::Despawned]);
                if(!e_veh[Vehicle::Despawned])
                    return 1;
            }
        }
    }
    return 0;
}

stock DespawnPlayerVehicle(id)
{
    if (!map_has_key(PlayerVehicle, id))
        return print("DespawnPlayerVehicle: Kendaraan dengan ID tidak ditemukan.");

    new e_veh[e_vehicle_data];
    map_get_arr_safe(PlayerVehicle, id, e_veh);

    if (e_veh[Vehicle::Despawned])
        return print("DespawnPlayerVehicle: Kendaraan sudah dalam keadaan despawned.");

    if (IsValidVehicle(e_veh[Vehicle::SpawnID]))
    {
        DestroyVehicle(e_veh[Vehicle::SpawnID]);
        e_veh[Vehicle::SpawnID] = -1;
        e_veh[Vehicle::Despawned] = true;
        map_set_arr(PlayerVehicle, id, e_veh);
        SavePlayerVehicle(e_veh[Vehicle::ID]);
        return 1;
    }

    print("DespawnPlayerVehicle: Kendaraan tidak valid.");
    return 0;
}

stock FreePlayerVehicle()
{
    new e_veh[e_vehicle_data], id = -1, time = 0;
    for_map(vehicleid : PlayerVehicle)
    {
        new aidi;
        if(iter_get_key_safe(vehicleid, aidi))
        {
            map_get_arr_safe(PlayerVehicle, aidi, e_veh[Vehicle::SpawnID]);
            if(e_veh[Vehicle::SpawnID] != -1)
            {
                if((GetTickCount()-e_veh[Vehicle::Time]) > time)
                {
                    time = GetTickCount()-e_veh[Vehicle::Time];
                    id = aidi;
                }
            }
        }
    }
    return DespawnPlayerVehicle(id);
}

stock DestroyPlayerVehicle(id)
{
    if (!map_has_key(PlayerVehicle, id))
        return print("DestroyPlayerVehicle: Kendaraan dengan ID tidak ditemukan.");

    new e_veh[e_vehicle_data];
    map_get_arr_safe(PlayerVehicle, id, e_veh);

    if (IsValidVehicle(e_veh[Vehicle::SpawnID]))
    {
        DestroyVehicle(e_veh[Vehicle::SpawnID]);
    }
    map_remove(PlayerVehicle, id);
    return 1;
}

stock SpawnPlayerVehicle(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, color1 = 0, color2 = 0, respawn_delay = -1)
{
    if(list_size(Vehicle) >= MAX_VEHICLES)
        FreePlayerVehicle();
    
        //return print("Jumlah kendaraan server sudah penuh (1000)! Tidak dapat membuat kendaraan lagi.");

    new vehicleid;
    vehicleid = CreateVehicle(modelid, spawn_x, spawn_y, spawn_z, z_angle, color1, color2, respawn_delay);
    return vehicleid;
}

stock CreatePlayerVehicle(ownerid, modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, color1 = 0, color2 = 0)
{
    if(list_size(Vehicle) >= MAX_VEHICLES)
        FreePlayerVehicle();
    
        //return print("Jumlah kendaraan server sudah penuh (1000)! Tidak dapat membuat kendaraan lagi.");

    new vehicleid;
    vehicleid = SpawnPlayerVehicle(modelid, spawn_x, spawn_y, spawn_z, z_angle, color1, color2, 10000);
    mysql_tquery(sqlcon, "INSERT INTO `vehicle` (`Model`) VALUES(0)", "VehicleCreated", "dddffffdd", vehicleid, ownerid, modelid, spawn_x, spawn_y, spawn_z, z_angle, color1, color2);
    return vehicleid;
}

FUNC::VehicleCreated(vehicleid, ownerid, modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, color1, color2)
{   
    new e_veh[e_vehicle_data];
    e_veh[Vehicle::ID] = cache_insert_id();
    e_veh[Vehicle::Despawned] = false;
    e_veh[Vehicle::SpawnID] = vehicleid;
    e_veh[Vehicle::Model] = modelid;
    e_veh[Vehicle::Locked] = true;
    e_veh[Vehicle::Key][0] = ownerid;
    e_veh[Vehicle::Key][1] = -1;
    e_veh[Vehicle::Key][2] = -1; 
    e_veh[Vehicle::Color][0] = color1;
    e_veh[Vehicle::Color][1] = color2;
    e_veh[Vehicle::Pos][0] = spawn_x;
    e_veh[Vehicle::Pos][1] = spawn_y;
    e_veh[Vehicle::Pos][2] = spawn_z;
    e_veh[Vehicle::Angle] = z_angle;
    e_veh[Vehicle::Fuel] = 100;
    e_veh[Vehicle::Health] = 1000.0;
    e_veh[Vehicle::Time] = GetTickCount();
    format(e_veh[Vehicle::Plate], 16, "None");
    AddVehicleList(e_veh[Vehicle::ID], e_veh);
    SavePlayerVehicle(e_veh[Vehicle::ID]);
    return 1;
}

stock SavePlayerVehicle(id)
{
    new e_veh[e_vehicle_data];
    map_get_arr_safe(PlayerVehicle, id, e_veh);
    new cQuery[2512];
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "UPDATE `vehicle` SET ");
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`Model`='%d', ", cQuery, e_veh[Vehicle::Model]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`posX`='%f', ", cQuery, e_veh[Vehicle::Pos][0]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`posY`='%f', ", cQuery, e_veh[Vehicle::Pos][1]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`posZ`='%f', ", cQuery, e_veh[Vehicle::Pos][2]+0.1);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`Angle`='%f', ", cQuery, e_veh[Vehicle::Angle]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`PrimaryKey`='%d', ", cQuery, e_veh[Vehicle::Key][0]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`SecondaryKey`='%d', ", cQuery, e_veh[Vehicle::Key][1]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`TertiaryKey`='%d', ", cQuery, e_veh[Vehicle::Key][2]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`Color1`='%d', ", cQuery, e_veh[Vehicle::Color][0]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`Color2`='%d', ", cQuery, e_veh[Vehicle::Color][1]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`Health`='%f', ", cQuery, e_veh[Vehicle::Health]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`Fuel`='%f', ", cQuery, e_veh[Vehicle::Fuel]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%s`Plate`='%s' ", cQuery, e_veh[Vehicle::Plate]);
    mysql_format(sqlcon, cQuery, sizeof(cQuery), "%sWHERE `ID` = %d", cQuery, e_veh[Vehicle::ID]);
    mysql_query(sqlcon, cQuery, true);
}

stock UnloadPlayerVehicle(playerid)
{
    new e_veh[e_vehicle_data];
    for_map(vehicleid : PlayerVehicle)
    {
        new aidi;
        if(iter_get_key_safe(vehicleid, aidi))
        {
            map_get_arr_safe(PlayerVehicle, aidi, e_veh[Vehicle::Key][0]);
            if(pData[playerid][Player::ID] == e_veh[Vehicle::Key][0])
            {
                DestroyPlayerVehicle(aidi);
            }
        }
    }
    return 1;
}

stock LoadPlayerVehicle(playerid)
{
    new query[128];
    mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM `vehicle` WHERE `PrimaryKey` = %d", pData[playerid][Player::ID]);
    mysql_tquery(sqlcon, query, "VehicleLoaded", "d", playerid);
    return 1;
}

FUNC::VehicleLoaded(playerid)
{
    new count = cache_num_rows();
    if(count > 0)
    {
        forex(z, count)
        {
            new vehicleid, e_veh[e_vehicle_data];
            if(list_size(Vehicle) >= MAX_VEHICLES)
                return print("Jumlah kendaraan server sudah penuh (1000)! Tidak dapat membuat kendaraan lagi.");

            cache_get_value_name_int(z, "ID", e_veh[Vehicle::ID]);
            cache_get_value_name_int(z, "PrimaryKey", e_veh[Vehicle::Key][0]);
            cache_get_value_name_int(z, "SecondaryKey", e_veh[Vehicle::Key][1]);
            cache_get_value_name_int(z, "TertiaryKey", e_veh[Vehicle::Key][2]);
            cache_get_value_name_float(z, "posX", e_veh[Vehicle::Pos][0]);
            cache_get_value_name_float(z, "posY", e_veh[Vehicle::Pos][1]);
            cache_get_value_name_float(z, "posZ", e_veh[Vehicle::Pos][2]);
            cache_get_value_name_float(z, "Angle", e_veh[Vehicle::Angle]);
            cache_get_value_name_float(z, "Health", e_veh[Vehicle::Health]);
            cache_get_value_name_float(z, "Fuel", e_veh[Vehicle::Fuel]);
            cache_get_value_name_int(z, "Model", e_veh[Vehicle::Model]);
            cache_get_value_name_int(z, "Color1", e_veh[Vehicle::Color][0]);
            cache_get_value_name_int(z, "Color2", e_veh[Vehicle::Color][1]);
            cache_get_value_name(z, "Plate", e_veh[Vehicle::Plate]);
            
            vehicleid = SpawnPlayerVehicle(
                e_veh[Vehicle::Model], 
                e_veh[Vehicle::Pos][0], 
                e_veh[Vehicle::Pos][1], 
                e_veh[Vehicle::Pos][2], 
                e_veh[Vehicle::Angle], 
                e_veh[Vehicle::Color][0], 
                e_veh[Vehicle::Color][1], 
                10000
            );
            e_veh[Vehicle::Time] = GetTickCount();
            e_veh[Vehicle::Despawned] = false;
            e_veh[Vehicle::SpawnID] = vehicleid;
            AddVehicleList(e_veh[Vehicle::ID], e_veh);
        }
        printf("[VEHICLE] Memuat %d kendaraan player dari: %s(%d)", count, GetName(playerid), playerid);
    }
    return 1;
}

//CMD: Test
CMD:createveh(playerid, params[])
{
    new id;
    new modelid, color1, color2,
        Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle;

    GetPlayerPos(playerid, spawn_x, spawn_y, spawn_z);
    GetPlayerFacingAngle(playerid, z_angle);

    if(sscanf(params, "ddd", modelid, color1, color2))
        return SFM(playerid, "SYNTAX", "/createveh [modelid] [color1] [color2]");

    id = CreatePlayerVehicle(pData[playerid][Player::ID], modelid, spawn_x, spawn_y, spawn_z, z_angle, color1, color2);
    STM(playerid, "VEHICLE", "Sukses membuat vehicle dengan id: %d", id);
    return 1;
}

CMD:mv(playerid)
{
    new str[512],
        buffer[2500], // Tambahkan buffer untuk dialog besar
        e_veh[e_vehicle_data], count = 0;
    
    for_map(vehicleid : PlayerVehicle)
    {
        new aidi;
        if(iter_get_key_safe(vehicleid, aidi))
        {
            map_get_arr_safe(PlayerVehicle, aidi, e_veh);
            if(e_veh[Vehicle::Key][0] == pData[playerid][Player::ID])
            {
                format(str, sizeof(str), "%s[%d]<%d> ID: %d\t%s\n", str, count, e_veh[Vehicle::SpawnID], e_veh[Vehicle::ID], ReturnVehicleModelName(e_veh[Vehicle::Model]));
                strcat(buffer, str, sizeof(buffer));
                count++;
            }
        }
    }
    Dialog_Show(playerid, DIALOG_VEHICLE_MY, DIALOG_STYLE_TABLIST, "My Vehicle", str, "Select", "Close");
    return 1;
}

Dialog:DIALOG_VEHICLE_MY(playerid, response, listitem, inputtext[])
{
    new e_veh[e_vehicle_data], count = 0;
    if(response)
    {
        for_map(vehicleid : PlayerVehicle)
        {
            new aidi;
            if(iter_get_key_safe(vehicleid, aidi))
            {
                map_get_arr_safe(PlayerVehicle, aidi, e_veh);
                if(e_veh[Vehicle::Key][0] == pData[playerid][Player::ID])
                {
                    if(count == listitem)
                    {
                        SelectVehicle[playerid] = e_veh[Vehicle::ID];
                        Dialog_Show(playerid, DIALOG_VEHICLE_OPTION, DIALOG_STYLE_TABLIST, "Vehicle Option", "Spawn\nDespawn\nDestroy", "Select", "Back");
                        return 1;
                    }
                    else count++;
                }
            }
        }
    }
    return 1;
}

Dialog:DIALOG_VEHICLE_OPTION(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        new e_veh[e_vehicle_data];
        map_get_arr_safe(PlayerVehicle, SelectVehicle[playerid], e_veh);
        switch(listitem)
        {
            case 0:
            {
                if(e_veh[Vehicle::SpawnID] != -1)
                    return SFM(playerid, "VEHICLE", "Kendaraan ini sudah spawn!");
                
                new vehicleid = SpawnPlayerVehicle(
                    e_veh[Vehicle::Model], 
                    e_veh[Vehicle::Pos][0], 
                    e_veh[Vehicle::Pos][1], 
                    e_veh[Vehicle::Pos][2], 
                    e_veh[Vehicle::Angle], 
                    e_veh[Vehicle::Color][0], 
                    e_veh[Vehicle::Color][1], 
                    10000
                );
                e_veh[Vehicle::Time] = GetTickCount();
                e_veh[Vehicle::SpawnID] = vehicleid;
                e_veh[Vehicle::Despawned] = false;
                map_set_arr(PlayerVehicle, SelectVehicle[playerid], e_veh);
            }
            case 1:
            {
                DespawnPlayerVehicle(SelectVehicle[playerid]);
            }
            case 2:
            {
                DestroyPlayerVehicle(e_veh[Vehicle::ID]);
            }
        }
    }
    return 1;
}

//Hook: CreateVehicle
stock Vehicle::CreateVehicle(modelid,Float:x,Float:y,Float:z,Float:angle,color1,color2,respawn_delay,addsiren = 0){
    new vehicleid = INVALID_VEHICLE_ID;
    vehicleid = CreateVehicle(modelid, x, y, z, angle, color1, color2, respawn_delay, addsiren);
    list_add(Vehicle, vehicleid);
    return vehicleid;
}

#if defined _ALS_CreateVehicle
    #undef CreateVehicle
#else
    #define _ALS_CreateVehicle
#endif
#define CreateVehicle V_CreateVehicle

stock Vehicle::AddStaticVehicle(modelid,Float:spawn_x,Float:spawn_y,Float:spawn_z,Float:z_angle,color1,color2){
    new vehicleid;
    vehicleid = AddStaticVehicle(modelid, spawn_x, spawn_y, spawn_z, z_angle, color1, color2);
    list_add(Vehicle, vehicleid);
    return vehicleid;
}

#if defined _ALS_AddStaticVehicle
    #undef AddStaticVehicle
#else
    #define _ALS_AddStaticVehicle
#endif
#define AddStaticVehicle V_AddStaticVehicle

stock Vehicle::AddStaticVehicleEx(modelid,Float:spawn_x,Float:spawn_y,Float:spawn_z,Float:z_angle,color1,color2, respawn_delay, addsiren=0){
    new vehicleid;
    vehicleid = AddStaticVehicleEx(modelid, spawn_x, spawn_y, spawn_z, z_angle, color1, color2, respawn_delay, addsiren);
    list_add(Vehicle, vehicleid);
    return vehicleid;
}

#if defined _ALS_AddStaticVehicleEx
    #undef AddStaticVehicleEx
#else
    #define _ALS_AddStaticVehicleEx
#endif
#define AddStaticVehicleEx V_AddStaticVehicleEx

//Hook: DestroyVehicle
stock Vehicle::DestroyVehicle(vehicleid){
    list_remove(Vehicle, vehicleid);
    return DestroyVehicle(vehicleid);
}

#if defined _ALS_DestroyVehicle
    #undef DestroyVehicle
#else
    #define _ALS_DestroyVehicle
#endif
#define DestroyVehicle V_DestroyVehicle