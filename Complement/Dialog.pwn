enum
{
	DIALOG_NONE,
	DIALOG_REGISTER,
	DIALOG_RESPOND,
	DIALOG_LOGIN,
	DIALOG_SELECTCHAR,
	DIALOG_DELETECHAR,
	DIALOG_CONFIRMDELETECHAR
};

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{   
	return 1;
}

public OnDialogPerformed(playerid, const dialog[], response, success) 
{
    return 1;
}