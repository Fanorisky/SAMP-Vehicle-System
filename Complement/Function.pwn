stock ReturnIP(playerid)
{
    static
        ip[16];

    GetPlayerIp(playerid, ip, sizeof(ip));
    return ip;
}

stock GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid,name,sizeof(name));
    return name;
}

stock IsRoleplayName(const player[])
{
    forex(n,strlen(player))
    {
        if (player[n] == '_' && player[n+1] >= 'A' && player[n+1] <= 'Z') return 1;
        if (player[n] == ']' || player[n] == '[') return 0;
    }
    return 0;
}

stock KickEx(playerid)
{
    wait_ticks(1);
    Kick(playerid);
    return 1;
}

stock SendClientMessageEx(playerid, colour, const text[], va_args<>)
{
    new str[145];
    va_format(str, sizeof(str), text, va_start<3>);
    //ChatLog(playerid, str);
    return SendClientMessage(playerid, colour, str);
}

stock SendTrueMessage(playerid, const title[], const text[], va_args<>)
{
    new rtr[150], tl[50], str[150];
    va_format(tl, sizeof(tl), title, va_start<3>);
    va_format(str, sizeof(str), text, va_start<3>);
    format(rtr, sizeof(rtr), "%s: {FFFFFF}%s", tl, str);
    //ChatLog(playerid, str);
    return SendClientMessage(playerid, COLOR_SERVER, rtr);
}

stock SendFalseMessage(playerid, const title[], const text[], va_args<>)
{
    new rtr[150], tl[50], str[150];
    va_format(tl, sizeof(tl), title, va_start<3>);
    va_format(str, sizeof(str), text, va_start<3>);
    format(rtr, sizeof(rtr), "%s: %s", tl, str);
    //ChatLog(playerid, str);
    return SendClientMessage(playerid, COLOR_GREY, rtr);
}

stock PlayerPlayNearbySound(playerid, soundid)
{
    new Float:plPos[3];
    GetPlayerPos(playerid, plPos[0], plPos[1], plPos[2]);
    foreach(new p: Player)
    {
        if(IsPlayerInRangeOfPoint(p, 5.0, plPos[0], plPos[1], plPos[2]))
        {
            PlayerPlaySound(p, soundid, plPos[0], plPos[1], plPos[2]);
        }
    }
    return true;
}

//stock ChatLog(playerid, text[])
//{
//    new LogName[100], fyear, fmonth, fday;
//    getdate(fyear, fmonth, fday);
//    format(LogName, sizeof(LogName), "ChatLog/%s [ %d-%d-%d ].txt", GetName(playerid), fyear, fmonth, fday);
//    //new File:lFile = fopen(LogName, io_append), logData[178];
//      
//    //format(logData, sizeof(logData),"[%02d:%02d:%02d] %s\r\n", Gtimer[0], Gtimer[1], Gtimer[2], text);
//    //fwrite(lFile, logData);
//
//    //fclose(lFile);
//    return 1;
//}
//