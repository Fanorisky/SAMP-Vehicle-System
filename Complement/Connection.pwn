#define DATABASE_ADDRESS "localhost" //Change this to your Database Address
#define DATABASE_USERNAME "root" // Change this to your database username
#define DATABASE_PASSWORD "" //Change this to your database password
#define DATABASE_NAME "hrp"

new MySQL:sqlcon;

stock Database_Connect()
{
	sqlcon = mysql_connect(DATABASE_ADDRESS,DATABASE_USERNAME,DATABASE_PASSWORD,DATABASE_NAME);

	if(mysql_errno(sqlcon) != 0)
	{
	    print("[MySQL] - Connection Failed!");
	    SetGameModeText("Server-Error | Connection Failed!");
	}
	else
	{
		print("[MySQL] - Connection Estabilished!");
		SetGameModeText("Project "SERVER_VERSION"");
	}
}