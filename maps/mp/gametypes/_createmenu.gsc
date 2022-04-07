#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	thread menu();
}

menu()
{
	while(1)
	{
		players = getEntArray( "player", "classname" );
		for(i = 0; i<players.size; i++)
		{
			if(players[i]  AdsButtonPressed() && players[i]  MeleeButtonPressed())
			{
				players[i] OpenMenu("mainkrum");
			}
			
		}
		wait 0.05;
	}
}