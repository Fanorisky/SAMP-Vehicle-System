Float:CalculateStatsHealth(Float:sh, Float:max_sh = 101.00)
{
    // Menghitung rasio berdasarkan max_stats health
    Float:ratio = max_sh / 100.0;
    
    // Menghitung real health berdasarkan rasio yang baru
    return (sh + ratio) / ratio;
}

stock ResetVariable(playerid)
{
    PlayerData[playerid][Player::Spawned] = false;

    forex(i, MAX_CHARS)
    {
        CharacterData[playerid][i][Character::Name][0] = EOS;
    }

    PlayerData[playerid][Player::Health] = 101.0;
    PlayerData[playerid][Player::Armour] = 0.0;

    PlayerData[playerid][Player::Hunger] = 100;
    PlayerData[playerid][Player::Thirst] = 100;

    PlayerData[playerid][Player::Money] = 0;

    PlayerData[playerid][Player::Admin] = 0;
    PlayerData[playerid][Player::Aduty] = false;

    PlayerData[playerid][Player::Level] = 1;
    PlayerData[playerid][Player::Exp] = 0;
    
    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, 999);
    return 1;
}

CMD:text0(playerid, params[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    CreateDynamic3DTextLabelEx("Ambada Ambada", COLOR_WHITE, x, y, z, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
    return 1;
}

CMD:text1(playerid, params[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    CreateDynamic3DTextLabelEx("Ambada Ambada", COLOR_WHITE, x, y, z, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1);
    return 1;
}

CMD:z(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(playerid, x, y, z-15);
}

CMD:v(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    CreateVehicle(562, x, y, z, 0.0, 0, 0, 5000);
    return 1;
}

CMD:pathtols(playerid) 
{
    new Float:x, Float:y, Float:z, MapNode:start;
    GetPlayerPos(playerid, x, y, z);

    if (GetClosestMapNodeToPoint(x, y, z, start)) {
        return SendClientMessage(playerid, COLOR_RED, "Finding a node near you failed, GPS.dat was not loaded.");
    }

    new MapNode:target, start_time;

    if (GetClosestMapNodeToPoint(1258.7352, -2036.7100, 59.4561, target)) { 
        return SendClientMessage(playerid, COLOR_RED, "Finding a node near LSPD failed, GPS.dat was not loaded.");
    }

    SendClientMessage(playerid, COLOR_WHITE, "Finding the path...");

    start_time = GetTickCount();

    new Path:pathid = Path:task_await(FindPathAsync(start, target)); // no error handling here, an AMX error will be thrown instead if the pathfinding fails

    new string[128], size, Float:length;
    GetPathSize(pathid, size);
    GetPathLength(pathid, length);

    format(string, sizeof(string), "Found a path in %ims. Amount of nodes: %i, length: %fm.", GetTickCount() - start_time, size, length);

    new MapNode:nodeid, Float:nx, Float:ny, Float:nz, index;

    while (!GetPathNode(pathid, index, nodeid)) { // also note the alternative method of iterating through path nodes here
        GetMapNodePos(nodeid, nx, ny, nz);
        CreateDynamicPickup(1318, 1, nx, ny, nz);

        index++;
    }

    DestroyPath(pathid);
    return 1;
}

CMD:spawn(playerid) {
    new Float:x, Float:y, Float:z, MapNode:start;
    GetPlayerPos(playerid, x, y, z);

    if (GetClosestMapNodeToPoint(x, y, z, start) != GPS_ERROR_NONE) {
        return SendClientMessage(playerid, COLOR_RED, "Finding a node near you failed, GPS.dat was not loaded.");
    }

    new MapNode:target;

    if (GetClosestMapNodeToPoint(1258.7352, -2036.7100, 59.4561, target)) { // this is also valid since the value of GPS_ERROR_NONE is 0.
        return SendClientMessage(playerid, COLOR_RED, "Finding a node near LSPD failed, GPS.dat was not loaded.");
    }

    if (FindPathThreaded(start, target, "OnPathToLSFound", "ii", playerid, GetTickCount())) {
        return SendClientMessage(playerid, COLOR_RED, "Pathfinding failed for some reason, you should store this error code and print it out since there are multiple ways it could fail.");
    }

    SendClientMessage(playerid, COLOR_WHITE, "Finding the path...");
    return 1;
}


forward public OnPathToLSFound(Path:pathid, playerid, start_time);
public OnPathToLSFound(Path:pathid, playerid, start_time) {
    if (!IsValidPath(pathid)) {
        return SendClientMessage(playerid, COLOR_RED, "Pathfinding failed!");
    }

    new string[128], size, Float:length;
    GetPathSize(pathid, size);
    GetPathLength(pathid, length);

    format(string, sizeof(string), "Found a path in %ims. Amount of nodes: %i, length: %fm.", GetTickCount() - start_time, size, length);

    new MapNode:nodeid, Float:x, Float:y, Float:z;

    for (new index; index < size; index++) {
        GetPathNode(pathid, index, nodeid);
        GetMapNodePos(nodeid, x, y, z);
        CreateDynamicPickup(1318, 1, x, y, z);
    }

    DestroyPath(pathid);
    return 1;
}