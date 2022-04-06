/*
Init()
{
    thread OnPlayerConnect();
	setDvar( "add_bots", 0 );
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
        
        if(!IsDefined(player.pers["score"]))
            player.welcome = true;
        else
            player.welcome = false;
    
        player thread OnPlayerSpawned();
	}
}

OnPlayerSpawned()
{
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("spawned_player");
        
        //if(self.welcome)
            //self maps\mp\gametypes\_hud_message::hintMessage("Welcome " + self.name);
        
       // self thread AntiGL();
        self thread CheckPerks();
    }
}

AntiGL()
{
    self endon("death");
    self endon("disconnect");
    
    for(;;)
    {
        curWeap = self GetCurrentWeapon();
        new_Weap = undefined;
        
        if(IsSubStr( curWeap, "gl" ))
        {
            switch ( curWeap )
            {
                case "ak47_gl_mp":
                    new_Weap = "ak47_mp";
                    break;
                case "g3_gl_mp":
                    new_Weap = "g3_mp";
                    break;
                case "g36c_gl_mp":
                    new_Weap = "g36c_mp";
                    break;
                case "m16_gl_mp":
                    new_Weap = "m16_mp";
                    break;
                case "m4_gl_mp":
                    new_Weap = "m4_mp";
                    break;
                case "m14_gl_mp":
                    new_Weap = "m14_mp";
                    break;
                default:
                    new_Weap = "m4_mp";
            }
            
            self takeWeapon(curWeap);
            wait 0.5;
            self GiveWeapon(new_Weap);
            self GiveStartAmmo(new_Weap);
            self SwitchToWeapon(new_Weap);
        }
        
        wait 1;
    }
}

CheckPerks()
{
    self endon("death");
    self endon("disconnect");
    
    for(;;)
    {
        if(self HasPerk( "specialty_grenadepulldeath" ))
        {
            self UnSetPerk( "specialty_grenadepulldeath" );
            self SetPerk( "specialty_longersprint" );
        }
        
        if(self HasPerk( "specialty_pistoldeath" ))
        {
            self UnSetPerk( "specialty_pistoldeath" );
            self SetPerk( "specialty_longersprint" );
        }
        
        wait 1;
    }
}*/