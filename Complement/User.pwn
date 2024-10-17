FUNC::CheckConnection(playerid, rcc)
{
    if(rcc != g_RaceCheck{playerid})
        return Kick(playerid);

    InterpolateCameraPos(playerid, 1079.477172, -953.459289, 43.475460, 1205.191894, -943.278503, 43.458969, 25000);
    InterpolateCameraLookAt(playerid, 1084.455200, -953.032836, 43.668437, 1204.466796, -938.353332, 43.924758, 7000);
    
    SetPVarInt(playerid, "Attempt", 0);

    if(IsRoleplayName(GetName(playerid))) {
        SetPVarInt(playerid, "ValidUserName", false);
        CharacterCheck(playerid);
    } else {
        SetPVarInt(playerid, "ValidUserName", true);
        UserCheck(playerid);
    }
    return 1;
}

stock UserCheck(playerid)
{
    new query[256];
    mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM `users` WHERE `User` = '%e' LIMIT 1;", GetName(playerid));
    mysql_query(sqlcon, query);
    new count = cache_num_rows();
    if(count > 0) {
        UserLoadData(playerid);
    } else {
        InvalidUser(playerid);
    }
    return 1;
}

stock InvalidUser(playerid)
{
    new str[350];
    format(str, sizeof(str), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Tidak terdaftar kedalam database\nHarap daftarkan akun kamu terlebih dahulu untuk melanjutkan!", GetName(playerid));
    Dialog_Show(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, "User Account Check", str, "Keluar", "");
    KickEx(playerid);
    return 1;
}

stock CharacterCheck(playerid)
{
    new query[256], cquery[256], str[350];
    mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM `characters` WHERE `Name` = '%s'", GetName(playerid));
    mysql_query(sqlcon, query);
    new count = cache_num_rows();
    if(count > 0) 
    {
        SetPVarString(playerid, "Character", GetName(playerid));
        cache_get_value_name(0, "User",PlayerData[playerid][Player::User]);
        
        mysql_format(sqlcon, cquery, sizeof(cquery), "SELECT * FROM `users` WHERE `User` = '%e' LIMIT 1;", PlayerData[playerid][Player::User]);
        mysql_tquery(sqlcon, cquery, "CharacterLoadData", "d", playerid);
    }
    else 
    {
        format(str, sizeof(str), ""WHITE_E"Karakter ini tidak terdaftar kedalam database\nSilahkan buat karakter ini terlebih dahulu untuk melanjutkan!", GetName(playerid));
        Dialog_Show(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, "User Account Check", str, "Keluar", "");
        KickEx(playerid);
    }
    return 1;
}

FUNC::UserLoadData(playerid)
{
    new rows = cache_num_rows();
    new str[300];
    new bool:banned, banby[24], banreason[32], IP[100];

    if(rows)
    {
        //cache_get_value_name(0, "User", tempUser[playerid]);
        cache_get_value_name(0, "ip", IP);
        cache_get_value_name_int(0, "Banned", banned);
        cache_get_value_name(0, "BannedBy", banby);
        cache_get_value_name(0, "BannedReason", banreason);
        cache_get_value_name_int(0, "Registered", UserData[playerid][User::Time]);
        cache_get_value_name_int(0, "ID", UserData[playerid][User::ID]);
        cache_get_value_name_int(0, "Admin", UserData[playerid][User::Admin]);
        cache_get_value_name(0, "User",PlayerData[playerid][Player::User]);
        cache_get_value_name_int(0, "Active", UserData[playerid][User::Active]);
        cache_get_value_name(0, "email", UserData[playerid][User::Email]);
        if(banned == true)
        {
            format(str, sizeof(str),""YELLOW_E"User ini telah diblokir\n"CYAN_E"User: "WHITE_E"%s\n"CYAN_E"Reason: "WHITE_E"%s. [%s]\n"YELLOW_E"Untuk pembuatan unban request, silakan kunjungi discord kami di: "GREEN_E"https://dsc.gg/harwana", GetName(playerid), banreason, banby);
            Dialog_Show(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, "User Account Blocked", str, "Ok", "");
            KickEx(playerid);       
        }
        else
        {
            if(UserData[playerid][User::Active] == false)
            {
                format(str, sizeof(str), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Silahkan buat password kamu untuk melanjutkan: "GREEN_E"(input below)", GetName(playerid));
                Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "User Account Password", str, "Create", "Keluar");
            }
            else 
            {
                if(UserData[playerid][User::AutoLogIn] == false)
                {
                    format(str, sizeof(str), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Attempts: "YELLOW_E"%d/5\n"WHITE_E"Password: "GREEN_E"(input below)", GetName(playerid), GetPVarInt(playerid, "Attempt"));
                    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "User Account Login", str, "Login", "Keluar");
                    //LoginTimer[playerid] = SetTimerEx("LoginTime", 30000, false, "d", playerid);
                }
                else
                {
                    if(bool:strcmp(IP, ReturnIP(playerid)) == false)
                    {
                        new query[256];
                        mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM `characters` WHERE `User` = '%s' LIMIT %d;", GetName(playerid), MAX_CHARS);
                        mysql_tquery(sqlcon, query, "LoadCharacterList", "d", playerid);
                        SendTrueMessage(playerid, "AUTO-LOGIN", "Account success loadded with auto-login ip1 %s dan ip2 %s", IP, ReturnIP(playerid));
                    }
                    else
                    {
                        format(str, sizeof(str), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Password: "GREEN_E"(input below)", GetName(playerid));
                        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "User Account Login", str, "Login", "Keluar");
                        //LoginTimer[playerid] = SetTimerEx("LoginTime", 30000, false, "d", playerid);
                    }
                }
            }
        }
    }
    return 1;
}

FUNC::CharacterLoadData(playerid)
{
    new rows = cache_num_rows();
    new str[300];
    new bool:banned, banby[24], banreason[32], IP[100];

    if(rows)
    {
        cache_get_value_name_int(0, "uID", UserData[playerid][User::ID]);
        cache_get_value_name_int(0, "Banned", banned);
        cache_get_value_name(0, "BannedBy", banby);
        cache_get_value_name(0, "BannedReason", banreason);
        cache_get_value_name_int(0, "Registered", UserData[playerid][User::Time]);
        cache_get_value_name_int(0, "Admin", UserData[playerid][User::Admin]);
        cache_get_value_name_int(0, "Active", UserData[playerid][User::Active]);
        cache_get_value_name(0, "email", UserData[playerid][User::Email]);
        cache_get_value_name_int(0, "autologin", UserData[playerid][User::AutoLogIn]);
        cache_get_value_name(0, "Ip", IP);
        if(banned == true)
        {
            format(str, sizeof(str),""YELLOW_E"User ini telah diblokir\n"CYAN_E"User: "WHITE_E"%s\n"CYAN_E"Reason: "WHITE_E"%s. [%s]\n"YELLOW_E"Untuk pembuatan unban request, silakan kunjungi discord kami di: "GREEN_E"https://dsc.gg/harwana", PlayerData[playerid][Player::User], banreason, banby);
            Dialog_Show(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, "Account Blocked", str, "Ok", "");
            KickEx(playerid);       
        }
        else 
        {
            new Char[64];
            GetPVarString(playerid, "Character", Char, sizeof(Char));
            if(UserData[playerid][User::Active] == true)
            {
                if(UserData[playerid][User::AutoLogIn] == false)
                {
                    format(str, sizeof(str), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Character: "YELLOW_E"%s\n"WHITE_E"Attempts: "YELLOW_E"%d/5\n"WHITE_E"Password: "GREEN_E"(input below)", PlayerData[playerid][Player::User], Char, GetPVarInt(playerid, "Attempt"));
                    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "User Account Login", str, "Login", "Keluar");
                    //LoginTimer[playerid] = SetTimerEx("LoginTime", 30000, false, "d", playerid);
                }
                else
                {
                    if(bool:strcmp(IP, ReturnIP(playerid)) == false)
                    {
                        mysql_tquery(sqlcon, sprintf("SELECT * FROM `characters` WHERE `Name` = '%s' LIMIT 1;", Char), "LoadCharacterData", "d", playerid);
                        SendTrueMessage(playerid, "DEBUG", "Name: %s", Char);
                        SendTrueMessage(playerid, "AUTO-LOGIN", "Character success loadded with auto-login");
                    }
                    else
                    {
                        format(str, sizeof(str), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Character: "YELLOW_E"%s\n"WHITE_E"Attempts: "YELLOW_E"%d/5\n"WHITE_E"Password: "GREEN_E"(input below)", PlayerData[playerid][Player::User], Char, GetPVarInt(playerid, "Attempt"));
                        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "User Account Login", str, "Login", "Keluar");
                        //LoginTimer[playerid] = SetTimerEx("LoginTime", 30000, false, "d", playerid);
                    }
                }
            }
        }
    }
    return 1;
}

FUNC::CheckUserPassword(playerid, bool:success)
{
    new Char[64];
    GetPVarString(playerid, "Character", Char, sizeof(Char));
    if(GetPVarInt(playerid, "Attempt") == 4)
    {
        KickEx(playerid);
    }
    SetPVarInt(playerid, "Attempt", GetPVarInt(playerid, "Attempt")+1);

    if(bool:GetPVarInt(playerid, "ValidUserName") == true)
    {
        new string[326];
        format(string, sizeof(string), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Attempts: "YELLOW_E"%d/5\n"WHITE_E"Password: "GREEN_E"(input below)", GetName(playerid), GetPVarInt(playerid, "Attempt"));
        
        if(!success)
            return Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "User Account Login", string, "Login", "Keluar");

        new query[256];
        mysql_format(sqlcon, query, sizeof(query), "SELECT * FROM `characters` WHERE `User` = '%s' LIMIT %d;", GetName(playerid), MAX_CHARS);
        mysql_tquery(sqlcon, query, "LoadCharacterList", "d", playerid);
        DeletePVar(playerid, "ValidUserName");
    }
    else
    {
        new string[326];
        format(string, sizeof(string), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Character: "YELLOW_E"%s\n"WHITE_E"Attempts: "YELLOW_E"%d/5\n"WHITE_E"Password: "GREEN_E"(input below)", PlayerData[playerid][Player::User], GetPVarInt(playerid, "Character"), GetPVarInt(playerid, "Attempt"));
        
        if(!success)
            return Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "User Account Login", string, "Login", "Keluar");

        //SetPlayerName(playerid, CurrentCharacter[playerid]);
        mysql_tquery(sqlcon, sprintf("SELECT * FROM `characters` WHERE `Name` = '%s' LIMIT 1;", Char), "LoadCharacterData", "d", playerid);
        SendTrueMessage(playerid, "DEBUG", "Name 1: %s", Char);
        format(PlayerData[playerid][Player::Name], MAX_PLAYER_NAME, Char);
        SendTrueMessage(playerid, "DEBUG", "Name 2: %s", PlayerData[playerid][Player::Name]);
        DeletePVar(playerid, "ValidUserName");
    }
    return 1;
}

FUNC::HashUserPassword(playerid, hashid)
{
    new
        query[256],
        hash[BCRYPT_HASH_LENGTH];

    bcrypt_get_hash(hash, sizeof(hash));

    GetPlayerName(playerid, PlayerData[playerid][Player::User], MAX_PLAYER_NAME + 1);

    mysql_format(sqlcon, query, sizeof(query), "UPDATE `users` SET `Password` = '%s', `Registered` = '%d', `Active` = '1' WHERE `User` = '%s'", hash, gettime(), PlayerData[playerid][Player::User]);
    mysql_query(sqlcon, query, true);

    UserData[playerid][User::ID] = cache_insert_id();

    UserCheck(playerid);
    return 1;
}

stock GetLastLogin(time)
{
    new year, month, day, hour, minute, second,
        str[26], fday[4], fmonth[4]; // Memotong string menjadi hanya 3 huruf

    if(time == -1)
    {
        format(str, sizeof(str), "Never");
    }
    else
    {
        TimestampToDate(time, year, month, day, hour, minute, second, 7); // 7 is +7 GMT or WIB
        format(fday, sizeof(fday), FormatWeekDay(GetWeekDay(day, month, year)));
        format(fmonth, sizeof(fmonth), FormatMonth(month));
        format(str, sizeof(str), "%s %d %s %d, %d:%d:%d", 
            fday, 
            day,
            fmonth,
            year,
            hour,
            minute,
            second
        );
    }
    return str;
}

stock ShowCharacterMenu(playerid)
{
    new
        name[MAX_CHARS * 128], count;

    strcat(name, "Name\tLevel\tLast Login\n");
    for (new i; i < MAX_CHARS; i ++) if(CharacterData[playerid][i][Character::Name][0] != EOS)
    {
        strcat(name, sprintf("%s\t%d\t%s\n", CharacterData[playerid][i][Character::Name], CharacterData[playerid][i][Character::Level], GetLastLogin(CharacterData[playerid][i][Character::LastLogin])));
        count++;
    }
    if(count < MAX_CHARS)
        strcat(name, "Character Option");

    Dialog_Show(playerid, DIALOG_SELECTCHAR, DIALOG_STYLE_TABLIST_HEADERS, "Character Selection", name, "Select", "");
    return 1;
}

Dialog:DIALOG_SELECTCHAR(playerid, response, listitem, inputtext[]) 
{
    if (response) 
    {
        SetPlayerName(playerid, CharacterData[playerid][listitem][Character::Name]);
        mysql_tquery(sqlcon, sprintf("SELECT * FROM `characters` WHERE `Name` = '%s' LIMIT 1;", CharacterData[playerid][listitem][Character::Name]), "LoadCharacterData", "d", playerid);
        SendTrueMessage(playerid, "DEBUG", "Name: %s", CharacterData[playerid][listitem][Character::Name]);
    }
    return 1;
}

stock ShowDeleteCharacterMenu(playerid)
{
    new name[MAX_CHARS * 128], count;
    strcat(name, "Name\tLevel\tLast Login\n");
    for (new i; i < MAX_CHARS; i ++) if(CharacterData[playerid][i][Character::Name][0] != EOS)
    {
        strcat(name, sprintf("%s\t%d\t%s\n", CharacterData[playerid][i][Character::Name], CharacterData[playerid][i][Character::Level], CharacterData[playerid][i][Character::LastLogin]));
        count++;
    }
    
    Dialog_Show(playerid, DIALOG_CONFIRMCHAR, DIALOG_STYLE_TABLIST_HEADERS, "Delete Character", name, "Delete", "Back");
    return 1;
}

Dialog:DIALOG_CONFIRMCHAR(playerid, response, listitem, inputtext[]) 
{
    if(response)
    {
        SetPVarInt(playerid, "DeleteCharacter", listitem);
        ShowPlayerDialog(playerid, DIALOG_CONFIRMDELETECHAR, DIALOG_STYLE_MSGBOX, "Delete Character", "Apakah kamu yakin untuk menghapus karakter ini?\n"RED_E"PERINGATAN: "YELLOW_E"Karakter yang dihapus tidak dapat dikembalikan!", "Delete", "Back");
    }
    else
    {
        DeletePVar(playerid, "DeleteCharacter");
        ShowCharacterMenu(playerid);
    }
    return 1;
}

Dialog:DIALOG_CONFIRMDELETECHAR(playerid, response, listitem, inputtext[]) 
{
    if(response)
    {
        new string[256];
        format(string, sizeof(string), "DELETE FROM `characters` WHERE `Name` = '%s'", CharacterData[playerid][GetPVarInt(playerid, "DeleteCharacter")][Character::Name]);
        mysql_tquery(sqlcon, string);

        CharacterData[playerid][GetPVarInt(playerid, "DeleteCharacter")][Character::Name][0] = EOS;

        SendTrueMessage(playerid, "CHARACTER", "Penghapusan karakter kamu berhasil.");
        ShowCharacterMenu(playerid);
    }
    else
    {
        ShowCharacterMenu(playerid);
    }
    return 1;
}

FUNC::LoadCharacterList(playerid)
{
    for (new i = 0; i < MAX_CHARS; i ++)
    {
        CharacterData[playerid][i][Character::Name][0] = EOS;
    }
    for (new i = 0; i < cache_num_rows(); i ++)
    {
        cache_get_value_name(i, "Name", CharacterData[playerid][i][Character::Name]);
        cache_get_value_name_int(i, "Level", CharacterData[playerid][i][Character::Level]);
        cache_get_value_name_int(i, "LastLogin", CharacterData[playerid][i][Character::LastLogin]);
    }
    ShowCharacterMenu(playerid);
    return 1;
}

FUNC::LoadCharacterData(playerid)
{
    //KillTimer(LoginTimer[playerid]);
    //SetPlayerName(playerid, CurrentCharacter[playerid]);
    cache_get_value_name_int(0, "ID", PlayerData[playerid][Player::ID]);
    cache_get_value_name(0, "User", PlayerData[playerid][Player::User]);
    cache_get_value_name(0, "Name", PlayerData[playerid][Player::Name]);
    cache_get_value_name_float(0, "PosX", PlayerData[playerid][Player::Pos][0]);
    cache_get_value_name_float(0, "PosY", PlayerData[playerid][Player::Pos][1]);
    cache_get_value_name_float(0, "PosZ", PlayerData[playerid][Player::Pos][2]);
    cache_get_value_name_float(0, "Angle", PlayerData[playerid][Player::Angle]);
    cache_get_value_name_float(0, "Health", PlayerData[playerid][Player::Health]);
    cache_get_value_name_float(0, "Armour", PlayerData[playerid][Player::Armour]);

    cache_get_value_name_int(0, "Skin", PlayerData[playerid][Player::Skin]);
    cache_get_value_name_int(0, "Gender", PlayerData[playerid][Player::Gender]);
    cache_get_value_name_int(0, "Money", PlayerData[playerid][Player::Money]);
    cache_get_value_name_int(0, "Admin", PlayerData[playerid][Player::Admin]);
    cache_get_value_name_int(0, "Level", PlayerData[playerid][Player::Level]);
    cache_get_value_name_int(0, "Exp", PlayerData[playerid][Player::Exp]);

    cache_get_value_name_int(0, "Hunger", PlayerData[playerid][Player::Hunger]);
    cache_get_value_name_int(0, "Thirst", PlayerData[playerid][Player::Thirst]);

    cache_get_value_name_int(0, "Interior", PlayerData[playerid][Player::Interior]);
    cache_get_value_name_int(0, "World", PlayerData[playerid][Player::World]);

    printf("Data Player Dimuat, UID: %d", PlayerData[playerid][Player::ID]);

    //SetPlayerName(playerid, PlayerData[playerid][Player::Name]);
    TogglePlayerSpectating(playerid, false);
    SetSpawnInfo(playerid, 1, PlayerData[playerid][Player::Skin], PlayerData[playerid][Player::Pos][0], PlayerData[playerid][Player::Pos][1], PlayerData[playerid][Player::Pos][2]-0.5, PlayerData[playerid][Player::Angle], 0, 0, 0, 0, 0, 0);
    PlayerData[playerid][Player::Spawned] = true;
    SpawnPlayer(playerid);
    
    new query[256];
    mysql_format(sqlcon, query,sizeof(query),"UPDATE `users` SET `ip` = '%s' WHERE `User` = '%e'", ReturnIP(playerid), PlayerData[playerid][Player::User]);
    mysql_query(sqlcon, query, true);
    return 1;
}

stock SaveCharacterData(playerid)
{
    new query[7512];
    if(PlayerData[playerid][Player::Spawned] == true)
    {
        GetPlayerPos(playerid, PlayerData[playerid][Player::Pos][0], PlayerData[playerid][Player::Pos][1], PlayerData[playerid][Player::Pos][2]);
        GetPlayerFacingAngle(playerid, PlayerData[playerid][Player::Angle]);

        mysql_format(sqlcon, query, sizeof(query), "UPDATE `characters` SET ");
        mysql_format(sqlcon, query, sizeof(query), "%s`PosX`='%f', ", query, PlayerData[playerid][Player::Pos][0]);
        mysql_format(sqlcon, query, sizeof(query), "%s`PosY`='%f', ", query, PlayerData[playerid][Player::Pos][1]);
        mysql_format(sqlcon, query, sizeof(query), "%s`PosZ`='%f', ", query, PlayerData[playerid][Player::Pos][2]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Angle`='%f', ", query, PlayerData[playerid][Player::Angle]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Health`='%f', ", query, PlayerData[playerid][Player::Health]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Armour`='%f', ", query, PlayerData[playerid][Player::Armour]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Hunger`='%d', ", query, PlayerData[playerid][Player::Hunger]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Thirst`='%d', ", query, PlayerData[playerid][Player::Thirst]);
        mysql_format(sqlcon, query, sizeof(query), "%s`World`='%d', ", query, GetPlayerVirtualWorld(playerid));
        mysql_format(sqlcon, query, sizeof(query), "%s`Interior`='%d', ", query, GetPlayerInterior(playerid));
        mysql_format(sqlcon, query, sizeof(query), "%s`Gender`='%d', ", query, PlayerData[playerid][Player::Gender]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Skin`='%d', ", query, PlayerData[playerid][Player::Skin]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Money`='%d', ", query, PlayerData[playerid][Player::Money]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Admin`='%d', ", query, PlayerData[playerid][Player::Admin]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Level`='%d', ", query, PlayerData[playerid][Player::Level]);
        mysql_format(sqlcon, query, sizeof(query), "%s`Exp`='%d' ", query, PlayerData[playerid][Player::Exp]);
        mysql_format(sqlcon, query, sizeof(query), "%sWHERE `ID` = %d", query, PlayerData[playerid][Player::ID]);
        mysql_query(sqlcon, query, true);
        printf("Data Player Disimpan, UID: %d", PlayerData[playerid][Player::ID]);
    }
    return 1;
}

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[]) 
{
    if (response) 
    {
        new str[356];
        format(str, sizeof(str), ""WHITE_E"User: "YELLOW_E"%s\n"WHITE_E"Silahkan buat password kamu untuk melanjutkan: "GREEN_E"(input below)", GetName(playerid));

        if(strlen(inputtext) < 7)
            return Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "User Account Password", str, "Create", "Quit");

        if(strlen(inputtext) > 32)
            return Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "User Account Password", str, "Create", "Quit");

        bcrypt_hash(playerid, "HashUserPassword", inputtext, BCRYPT_COST);
    } 
    else Kick(playerid);
    return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[]) 
{
    if (response) 
    {
        new pwQuery[256], hash[BCRYPT_HASH_LENGTH];
        mysql_format(sqlcon, pwQuery, sizeof(pwQuery), "SELECT Password FROM users WHERE User = '%e' LIMIT 1", PlayerData[playerid][Player::User]);
        mysql_query(sqlcon, pwQuery);
        
        cache_get_value_name(0, "Password", hash, sizeof(hash));
        
        bcrypt_verify(playerid, "CheckUserPassword", inputtext, hash);
    }
    else Kick(playerid);
    return 1;
}