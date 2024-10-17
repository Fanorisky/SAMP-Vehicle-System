// Define packet IDs
const PLAYER_SYNC = 207;
const VEHICLE_SYNC = 200;
const PASSENGER_SYNC = 211;
const AIM_SYNC = 203;
const BULLET_SYNC = 206;

// Define RPC IDs
const RPC_CLEAR_ANIMATIONS = 87;
const RPC_REQUEST_SPAWN = 129;

public OnIncomingPacket(playerid, packetid, BitStream:bs)
{
	return 1;
}

public OnIncomingRPC(playerid, rpcid, BitStream:bs)
{
    return 1;
}

public OnOutgoingPacket(playerid, packetid, BitStream:bs)
{
	return 1;
}

public OnOutgoingRPC(playerid, rpcid, BitStream:bs)
{
	return 1;
}