
SpawnBotsActivate()
{
	self endon("death");
	self endon("disconnect");

	for(;;)
	{
		if(self UseButtonPressed() && self AdsButtonPressed())
		{
			bot = AddTestClient();
			bot.pers["isBot"] = true;
			team = self.pers[ "team" ];
			switch(team)
			{
				case "axis":
					otherteam = "allies";
					bot SetupBot(otherteam);
					break;
				case "allies":
					otherteam = "axis";
					bot SetupBot(otherteam);
					break;
			}
			self SpawnBot(bot);
		}
	wait 0.01;
	}
}

SetupBot(team)
{
	self endon( "disconnect" ); 
    wait .05;
	self notify("menuresponse", game["menu_team"], team);
	wait 0.5;
	self notify("menuresponse", "changeclass", self RandomClass() );
	wait 0.5;
}

SpawnBot(bot)
{
	bot.initpos = self GetOrigin();
	bot.initangles = self GetPlayerAngles();
	bot SetOrigin(bot.initpos);
	bot SetPlayerAngles(bot.initangles);
	bot freezeControls(true);
	wait 0.01;
	bot thread monitorBotDeath(bot.initpos, bot.initangles);
}

monitorBotDeath(initpos,initangles)
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		self freezeControls(true);
		self setOrigin(initpos);
		self SetPlayerAngles(initangles);
	}
	wait 0.01;
}

RandomClass() {
	classes = [];
	classes[0] = "assault_mp";
	classes[1] = "specops_mp";
	classes[2] = "heavygunner_mp";
	classes[3] = "demolitions_mp";
	classes[4] = "sniper_mp";
	index = RandomIntRange( 0, 5 );
	return classes[index];
}