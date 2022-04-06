/////////////////////////////////////////////////////////////
// PeZBOT, version: 011p
// Author: PEZZALUCIFER
// Current Team: Lord_Gannondorf
/////////////////////////////////////////////////////////////

init()
{
	if (getdvar("svr_pezbots") == "")			        setdvar("svr_pezbots", 0);
	if (getdvar("svr_pezbots_axis") == "")			    setdvar("svr_pezbots_axis", 0);
	if (getdvar("svr_pezbots_allies") == "")			setdvar("svr_pezbots_allies", 0);
	if (getdvar("svr_pezbots_dewards") == "")			setdvar("svr_pezbots_dewards", 0);
	if (getdvar("svr_pezbots_drawdebug") == "")		setdvar("svr_pezbots_drawdebug", 0);
	if (getdvar("svr_pezbots_skill") == "")			setdvar("svr_pezbots_skill", 1.0);
	if (getdvar("svr_pezbots_mode") == "")				setdvar("svr_pezbots_mode", "normal");
	if (getdvar("svr_pezbots_WPDrawRange") == "")		setdvar("svr_pezbots_WPDrawRange", 1000);
	if (getdvar("svr_pezbots_XPCheat") == "")			setdvar("svr_pezbots_XPCheat", 0);
	if (getdvar("svr_pezbots_grenadepickup") == "")    setdvar("svr_pezbots_grenadepickup", 1);
	if (getdvar("svr_pezbots_roundCount") == "")      	setdvar("svr_pezbots_roundCount", 2);
	if (getdvar("svr_pezbots_playstyle") == "")       	setdvar("svr_pezbots_playstyle", 2);
	if (getdvar("svr_pezbots_useperks") == "")       	setdvar("svr_pezbots_useperks", 1);
	if (getdvar("svr_pezbots_modelchoice") == "")      setdvar("svr_pezbots_modelchoice", 0);
	if (getdvar("g_force_autoassign") == "")           setdvar("g_force_autoassign", 0);
	
	level.maxroundCount = getdvarint("svr_pezbots_roundCount", 2, 0, 32, "int");
	level.roundCount = getdvarint("tdm_roundCount", 0, 0, 32, "int");
	level.botbattlechatter = getdvarint("svr_pezbots_chatter", 1, 0, 1, "int");

	if (getdvar("svr_pezbots_playstyle") == "1")
	{
	    level.botCrouchObj = 500;
		level.botwalkspeed = 6.0;
		level.botRunDist = 600;
	}
	else
	{
	    level.botCrouchObj = 1200;
		level.botwalkspeed = 5.5;
		level.botRunDist = 2000;
	}
	
	setdvar("svr_pezbots_classPicker", 0);
	
	setdvar("sv_punkbuster", 0);
	setdvar("tdm_roundCount", 0);
	
    level.smokeList = [];
    level.smokeListCount = 0;
    level.bDefusingBomb = false;
	level.botTalking = false;
	level.bot_battlechatter = 1;
	level.minDistToObj = undefined;

    //load waypoints for level
	thread Waypoints\select_map::choose();

    if(getdvar("svr_pezbots_mode") == "dev")
    { 
        setdvar("svr_pezbots_drawdebug", 1);
  	    thread waitPlayer();
        thread DrawStaticWaypoints();
    }
    else
    {
  	    thread StartNormal();
  	    thread XPCheat();
  	    thread MonitorPlayerMovement();
  	    thread UpdateSmokeList();
        thread DrawStaticWaypoints();
    }	
}

////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////
waitPlayer()
{
	while(1)
	{
		level waittill("connected", player);
		if (!isDefined(level.plr) || !isPlayer(level.plr))
		{
			level.plr = player;
			if(getDvar("svr_pezbots_mode") == "dev")
			{
			    level.plr thread InitWaypoints();
				level StartDev();
				player waittill("disconnect");
				wait 0.5;
				level.plr = undefined;
				break;
			}
		}
	}
}

////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////
InitWaypoints()
{
	self endon("disconnect");
	
	spawnpointname = "mp_tdm_spawn";
	level.spawnpoints = getentarray(spawnpointname, "classname");
  
	for(i = 0; i < level.waypoints.size; i++)
		level.waypoints[i].selected = false;
  
	if(level.waypoints.size == 0)
	{
		for(i = 0; i < level.spawnpoints.size; i++)
		{
			angle = anglesToForward(level.spawnpoints[i].angles);
			angle = common_scripts\utility::vectorScale(angle, 30);
			origin = level.spawnpoints[i].origin + angle;
      
			level.plr setOrigin(origin);
			AddWaypoint(origin);
		}
	} 
}

/////////////////////////////////////////////////////////////
// monitors player movement for "Obvious" sentient behaviours
// also checks for buggy bots and kills them
/////////////////////////////////////////////////////////////
MonitorPlayerMovement()
{
	while(1)
    {
        if(isDefined(level.players))
        {
            for(i = 0; i < level.players.size; i++)
            {
                player = level.players[i];
	            if(player.sessionstate == "playing")
	            {
	                if(!isdefined(player.lastOrigin))
	                {
	                    player.lastOrigin = player.origin;
	                }
	                else
	                {
	                    player.fVelSquared = DistanceSquared(player.origin, player.lastOrigin);
	                }
	        
	                player.lastOrigin = player.origin;
	        
	                if(isDefined(player.bIsBot) && player.bIsBot)
	                {
	                    if(player.fVelSquared <= 4 && !player IsStunned())
	                    {
	                        player.buggyBotCounter++;
                        }
	                    else
	                    {
	                        player.buggyBotCounter = 0;
	                    }
						
						if(isdefined(level.killpoints))
						{
						    for(k = 0; k < level.killpointCount; k++)
						    {
						        if(DistanceSquared(player.origin, level.killpoints[k].origin) <= 200)
							    {
						            player BotSuicide(k);
							    }
						    }
						}
  	  
                        //stuck so reset
	  	                if(player.buggyBotCounter >= 40)
	  	                {
	  	                    player BotReset();    
		                }
		            }
	            }
            }
        }
        wait 0.05;
    }
}

/////////////////////////////////////////
// can we debugdraw???
////////////////////////////////////////
CanDebugDraw()
{
    if(getdvarInt("svr_pezbots_drawdebug") >= 1)
        return true;
    else
        return false;
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
PreCache()
{
    precacheItem("ak47_mp_pezbot_stand_walk");
    precacheItem("ak47_mp_pezbot_stand_run");
    precacheItem("ak47_mp_pezbot_crouch_walk");
    precacheItem("ak47_mp_pezbot_climb_up");
	precacheItem("frag_mp_pezbot_stand_grenade");
	precacheItem("smoke_mp_pezbot_stand_grenade");
	precacheItem("concussion_mp_pezbot_stand_grenade");
	precacheItem("flash_mp_pezbot_stand_grenade");
	precacheItem("rpg_mp_pezbot_stand_grenade");
	precacheItem("knife_pezbot_mp");
	
	precachestring(&"DEBUG_AUTO_ON");
	precachestring(&"DEBUG_PEZ_LOADED");
	precachestring(&"DEBUG_PEZ_NOSUPPORT");
	precachestring(&"DEBUG_CHANGE_NORMAL");
	precachestring(&"DEBUG_CHANGE_CLIMB");
	precachestring(&"DEBUG_CHANGE_KILLZONE");
	
	precacheMenu("restart_server");
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
endMap()
{
	map = getDvar("mapname");
	type = getDvar("g_gametype");
 
	loadMap(map, type);
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
loadMap(map, type)
{
    players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		setDvar("tdm_roundCount", (level.roundCount+1));
		
		player = players[index];
		if(getDvarInt("tdm_roundCount") >= level.maxroundCount)
		{ 
	        
		    if(isdefined(player))
			{
				player closeMenu();
				player closeInGameMenu();
				wait 0.1;
				player openMenu("restart_server");
			}
        }
		else
		{
		    if(isdefined(player))
			{
		        player closeMenu();
                player closeInGameMenu();
			}
			
        }
	}
	
	if(getDvarInt("tdm_roundCount") < level.maxroundCount)
	    exitLevel(false);    
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
AddTargetable(name)
{
    i = self.targetables.size;
    self.targetables[i] = spawn("script_origin", (0,0,0));
    wait 0.05;
    self.targetables[i] linkto(self, name, (0,0,0), (0,0,0));
}

////////////////////////////////////////////////////////////
// initialises target positions on bot
////////////////////////////////////////////////////////////
InitTargetables()
{
    if(isdefined(self.bIsBot))
    {
        //clamp to ground on spawn   
        trace = bulletTrace(self.origin + (0,0,50), self.origin + (0,0,-200), false, self);
        if(trace["fraction"] < 1 && !isdefined(trace["entity"]))
        {
            self SetOrigin(trace["position"]);
        }
    
   	    self PickRandomActualWeapon();
        self attach(getWeaponModel(self.actualWeapon), "TAG_WEAPON_RIGHT", true);
    }

    self.targetables = [];
    AddTargetable("j_spine4");
	
	if (getdvar("svr_pezbots_mode") != "normal") self thread Developer();
}

////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////
Developer()
{
   wait 10;
   setdvar("developer_script", 0);
}

////////////////////////////////////////////////////////////
// Destroys target positions on bot
////////////////////////////////////////////////////////////
DeinitTargetables()
{
	if(isdefined(self.targetables))
	{
		for(i = 0; i < self.targetables.size; i++) 
		{
			self.targetables[i] unlink();
			self.targetables[i] delete();
		}
		self.targetables = undefined;
	}	
}

////////////////////////////////////////////////////////////
// gets a target position
////////////////////////////////////////////////////////////
GetTargetablePos()
{
    if(isdefined(self.targetables))
    {
        return self.targetables[randomint(self.targetables.size)] GetOrigin();
    }

    return self GetEye(); 
}

////////////////////////////////////////////////////////////
// resets a bot
////////////////////////////////////////////////////////////
BotSuicide(location)
{
    self notify("BotSuicide");
  
    self StopShooting();
    self BotGoal_ClearGoals();
   
    self.state = "combat";
	self.stance = "stand";
  
    self.isBombCarrier = false;
    self.bombActionTimer = 0;
	self.vMoveDirection = (0,1,0);
	self.fMoveSpeed = 0.0;
	self.bFaceNearestEnemy = true;
	self.buggyBotCounter = 0;
	self.lastOrigin = self.origin;
	self.bIsBot = true;
	self.bSpamAnims = false;

	self.vObjectivePos = self.origin;
    self.bClampToGround = true;
  
	self.commandIssued = "-1";
	self.bFollowTheLeader = false;
 	self.bSuppressingFire = false;
	self.leader = undefined;
	self.currentStaticWp = -1;
	self.vDodgeObjective = undefined;
	self.flankSide = (randomIntRange(0,2) - 0.1) * 2.0;
	self.fTargetMemory = gettime()-15000;
	self.rememberedTarget = undefined;
	self.iShouldCrouch = randomIntRange(0,2);
  
    iprintln("Map violation: " + self.name + ", Killpoint " + location);
	println("Map violation: " + self.name + ", Killpoint " + location);
	self Suicide();
}

////////////////////////////////////////////////////////////
// resets a bot
////////////////////////////////////////////////////////////
BotReset()
{
    self notify("BotReset");
  
    self StopShooting();
    self BotGoal_ClearGoals();
   
    self.state = "combat";
	self.stance = "stand";
  
    self.isBombCarrier = false;
    self.bombActionTimer = 0;
	self.vMoveDirection = (0,1,0);
	self.fMoveSpeed = 0.0;
	self.bFaceNearestEnemy = true;
	self.buggyBotCounter = 0;
	self.lastOrigin = self.origin;
	self.bIsBot = true;
	self.bSpamAnims = false;

	self.vObjectivePos = self.origin;
    self.bClampToGround = true;
  
	self.commandIssued = "-1";
	self.bFollowTheLeader = false;
 	self.bSuppressingFire = false;
	self.leader = undefined;
	self.currentStaticWp = -1;
	self.vDodgeObjective = undefined;
	self.flankSide = (randomIntRange(0,2) - 0.1) * 2.0;
	self.fTargetMemory = gettime()-15000;
	self.rememberedTarget = undefined;
	self.iShouldCrouch = randomIntRange(0,2);
  
    self SetAnim(self.weaponPrefix, self.stance, "walk");
}

////////////////////////////////////////////////////////////
// called when bot connects, restarts threads if they were stopped by disconnect
////////////////////////////////////////////////////////////
Connected()
{
    println("connected called on bot");
  
    if(isdefined(self.pers["team"]) && issubstr(self.name, "bot"))
    {
        if(!isdefined(self.bThreadsRunning) || (isdefined(self.bThreadsRunning) && self.bThreadsRunning == false))
        {
            println("Restarting threads for " + self.name);
            self.selectedClass = true;
            self.weaponPrefix = "ak47_mp";
            self BotReset();
            self thread PeZBOTMainLoop();
        }
    }
}

////////////////////////////////////////////////////////////
// called when bot disconnects
////////////////////////////////////////////////////////////
Disconnected()
{

}

////////////////////////////////////////////////////////////
// kicks all bots
///////////////////////////////////////////////////////////
KickAllBots()
{
	if(getdvar("svr_pezbots_botKickCount") != "")
	{
	    if(getdvarint("svr_pezbots_botKickCount") > 0)
	    {
            return;	  
	    }
	}

    humanPlayerCount = 0;
    botKickCount = 0;
	players = level.players;
	if(players.size > 0)
	{
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if(isDefined(player.bIsBot) && player.bIsBot)
			{
			    entityNumber = player getEntityNumber();
	            kick(entityNumber);
	            if(!isDefined(player.bIsDog))
	            {
	                botKickCount++;
	            }
			}
			else
			{
			    humanPlayerCount++;
			}
		}
	}	

	setDvar("svr_pezbots_botKickCount", botKickCount);
	setDvar("svr_pezbots_humanPlayerCount", humanPlayerCount);
    setDvar("svr_pezbots_botKickProcess", 1);
}

////////////////////////////////////////////////////////////
// kicks all bots
///////////////////////////////////////////////////////////
KickAllAxisBots()
{
	if(getdvar("svr_pezbots_botKickCount_axis") != "")
	{
	    if(getdvarint("svr_pezbots_botKickCount_axis") > 0)
	    {
            return;	  
	    }
	}

    humanAxisPlayerCount = 0;
    botKickCountaxis = 0;
	players = level.players;
	if(players.size > 0)
	{
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if(isDefined(player.bIsBot) && player.bIsBot && player.pers["team"] == "axis")
			{
			    entityNumber = player getEntityNumber();
	            kick(entityNumber);
	            if(!isDefined(player.bIsDog))
	            {
	                botKickCountaxis++;
	            }
			}
			else
			{
			    humanAxisPlayerCount++;
			}
		}
	}	

	setDvar("svr_pezbots_botKickCount_axis", botKickCountaxis);
	setDvar("svr_pezbots_humanAxisPlayerCount", humanAxisPlayerCount);
    setDvar("svr_pezbots_botKickProcess", 1);
}

////////////////////////////////////////////////////////////
// kicks all bots
///////////////////////////////////////////////////////////
KickAllAlliesBots()
{
	if(getdvar("svr_pezbots_botKickCount_allies") != "")
	{
	    if(getdvarint("svr_pezbots_botKickCount_allies") > 0)
	    {
            return;	  
	    }
	}

    humanAlliesPlayerCount = 0;
    botKickCountallies = 0;
	players = level.players;
	if(players.size > 0)
	{
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if(isDefined(player.bIsBot) && player.bIsBot && player.pers["team"] == "allies")
			{
			    entityNumber = player getEntityNumber();
	            kick(entityNumber);
	            if(!isDefined(player.bIsDog))
	            {
	                botKickCountallies++;
	            }
			}
			else
			{
			    humanAlliesPlayerCount++;
			}
		}
	}	

	setDvar("svr_pezbots_botKickCount_allies", botKickCountallies);
	setDvar("svr_pezbots_humanAlliesPlayerCount", humanAlliesPlayerCount);
    setDvar("svr_pezbots_botKickProcess", 1);
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
PrintPlayerPos()
{
    while(1)
    {
        if(isDefined(level.players))
        {
            for(i = 0; i < level.players.size; i++)
            {
                if(!isDefined(level.players[i].bIsBot))
                {
                    iprintln("pos: " + level.players[i].origin[0] + ", " + level.players[i].origin[1] + ", " + level.players[i].origin[2]);
                }
            }
        }
        wait 2.0;
    }
}

////////////////////////////////////////////////////////////
// returns one of the buttons pressed
////////////////////////////////////////////////////////////
GetButtonPressed()
{
    if(isDefined(self))
    {
        if(self attackbuttonpressed())
        {
            return "AddWaypoint";
        }
	    else
	    if(self secondaryoffhandbuttonpressed())
        {
            return "ChangeWaypointType";
        }
        else
        if(self adsbuttonpressed())
        {
            return "DeleteWaypoint";
        }
        else
        if(self usebuttonpressed())
        {
            return "LinkWaypoint";
        }
        else
        if(self fragbuttonpressed())
        {
            return "UnlinkWaypoint";
        }
        else
        if(self meleebuttonpressed())
        {
            return "SaveWaypoints";
        }
    }
  
    return "none";
}

////////////////////////////////////////////////////////////
// Start in dev mode 
///////////////////////////////////////////////////////////
StartDev()
{
	wait 5;
    level.wpToLink = -1;
    level.wpToChange = -1;
    level.linkSpamTimer = gettime();
    level.saveSpamTimer = gettime();
    level.changeSpamTimer = gettime();
	curselwp = undefined;
    lastview = undefined; 
    startorigin = undefined;
    lastwp = undefined;
    autowp = false;
	savewp = false;
	level.viewofs[0] = (16,16,112);
    level.viewofs[1] = (-16,16,112);
    level.viewofs[2] = (16,-16,112);
    level.viewofs[3] = (-16,-16,112);
  
    level.viewofs[4] = (16,16,96);
    level.viewofs[5] = (-16,16,96);
    level.viewofs[6] = (16,-16,96);
    level.viewofs[7] = (-16,-16,96);
	
	level.viewofs[8] = (16,16,80);
    level.viewofs[9] = (-16,16,80);
    level.viewofs[10] = (16,-16,80);
    level.viewofs[11] = (-16,-16,80);
  
    level.viewofs[12] = (16,16,64);
    level.viewofs[13] = (-16,16,64);
    level.viewofs[14] = (16,-16,64);
    level.viewofs[15] = (-16,-16,64);
	
	level.viewofs[16] = (16,16,48);
    level.viewofs[17] = (-16,16,48);
    level.viewofs[18] = (16,-16,48);
    level.viewofs[19] = (-16,-16,48);
  
    level.viewofs[20] = (16,16,32);
    level.viewofs[21] = (-16,16,32);
    level.viewofs[22] = (16,-16,32);
    level.viewofs[23] = (-16,-16,32);
  
    level.viewofs[24] = (16,16,16);
    level.viewofs[25] = (-16,16,16);
    level.viewofs[26] = (16,-16,16);
    level.viewofs[27] = (-16,-16,16);
	setDvar("bot_autowp", "0");
	setDvar("bot_savewp", "0");
	setDvar("bot_deletewp", "0");
	setDvar("bot_addkp", "0");
	setDvar("sp_gotonextsp", "0");
  
    while(1)
    {
        level.players = getentarray("player", "classname");
	    level.playerPos = level.players[0].origin;

	    // Meatbot based auto waypoint function
		dvar = getDvarInt("bot_autowp");
	    if (!autowp && dvar>60)
	    {
		    level.wpToLink = -1;
		    autowp = true;
			thread AutoNotify();
		    if (isdefined(level.curselwp))
		    {

				level.waypoints[level.curselwp].selected = false;
			    level.waypoints[level.curselwp] notify("unselect");
			    wait .1;
		    }

			AddautoWaypoint(level.playerPos);
		    lastwp = level.waypoints.size-1;
		    level.waypoints[lastwp].selected = true;
            level.curselwp = lastwp;
		    lastview = level.waypoints[lastwp].origin;
		    startorigin = lastview;
	    }
	    else
	    if (autowp && (distance(level.playerPos, lastview) > 60 || dvar<60))
	    {
		    
			if (dvar<60) 
		    {
			    autowp = false;
			    startmark = undefined;
				if(isdefined(level.plr.autonotify))
	                level.plr.autonotify destroy();
		    }

		    dist = distance(level.playerPos, startorigin);
		    view = false;
		    for (i=0; i<level.viewofs.size; i++)
		    {
			    view = bullettracepassed(level.playerPos+level.viewofs[i], startorigin+level.viewofs[i], false, self);
			    if (!view)
				    break;
		    }
		
		    if(!view || dist > dvar || (!autowp && dist > 60)) 
		    {
				AddAutoWaypoint(level.playerPos);
			    lastwp = level.curselwp;
			    startorigin = lastview;	
		    }
			
		    lastview = level.playerPos;
	    }
		
		dvar = getDvar("bot_savewp");
        if(dvar != "")
        {
	        SaveStaticWaypoints();
            wait .5;
            setDvar("bot_savewp", "");
        }
		
		dvar = getDvar("bot_deletewp");
        if(dvar != "0")
        {
			if(isdefined(level.players))
			{
				DeleteWaypoint(level.playerPos);
			    wait .5;
                setDvar("bot_deletewp", "0");
			}
        }
		
		dvar = getDvar("bot_addkp");
        if(dvar != "0")
        {
			if(isdefined(level.players))
			{
				AddKillpoint(level.playerPos);
			    wait .5;
                setDvar("bot_addkp", "0");
			}
        }
		
		dvar = getDvar("sp_gotonextsp");
	    if (dvar != "0") 
	    { 
            
			if(isdefined(level.players))
			{
				CurrentSpawnpoint = -1;
				CurrentSpawnpoint = GetNearestSpawnpoint(level.playerPos);
				
				size = level.spawnpoints.size;

				if(CurrentSpawnpoint >= size-1)
				    CurrentSpawnpoint = (size-1) - CurrentSpawnpoint;
				else
                    CurrentSpawnpoint = CurrentSpawnpoint+1;
            
				level.players[0] setplayerangles(level.spawnpoints[CurrentSpawnpoint].angles);
                level.players[0] setOrigin(level.spawnpoints[CurrentSpawnpoint].origin);
				iprintln("Current Spawnpoint is " + CurrentSpawnpoint);
				
				setDvar("sp_gotonextsp", "0");
			}
		}		
			
		level.playerPos = level.players[0].origin;
        switch(level.players[0] GetButtonPressed())
        {
            case "AddWaypoint":
            {
                AddWaypoint(level.playerPos);
                break;
            }
	  
	        case "ChangeWaypointType":
            {
                ChangeWaypointType(level.playerPos);
		        level.wpTochange = -1;
                break;
            }
      
            case "DeleteWaypoint":
            {
                DeleteWaypoint(level.playerPos);
                level.wpToLink = -1;
                break;
            }
      
            case "LinkWaypoint":
            {
                LinkWaypoint(level.playerPos);
                break;
            }
      
            case "UnlinkWaypoint":
            {
                UnLinkWaypoint(level.playerPos);
                break;
            }
      
            case "SaveWaypoints":
            {
                SaveStaticWaypoints();
                break;
            }
    
            default:
            break;
        }
        wait 0.001;  
    }
}

////////////////////////////////////////////////////////////
// Add Hud Text
////////////////////////////////////////////////////////////
AutoNotify()
{
    level.plr.autonotify = newClientHudElem(level.plr);
	level.plr.autonotify.horzAlign = "fullscreen";
	level.plr.autonotify.vertAlign = "fullscreen";
	level.plr.autonotify.alignX = "left";
	level.plr.autonotify.alignY = "middle";
	level.plr.autonotify.color = (1,1,1);
	level.plr.autonotify.x = 220;
	level.plr.autonotify.y = 50;
	level.plr.autonotify.archived = false;
	level.plr.autonotify.font = "default";
	level.plr.autonotify.fontscale = 2;
	level.plr.autonotify setText(&"DEBUG_AUTO_ON");
}

////////////////////////////////////////////////////////////
// returns an index to the nearest spawnpoint
////////////////////////////////////////////////////////////
GetNearestSpawnpoint(pos)
{
    if(!isDefined(level.spawnpoints))
    {
        return -1;
    }

    Spawnpoint = -1;
    nearestDistance = 9999999999;
    for(i = 0; i < level.spawnpoints.size; i++)
    {
        distance = Distance(pos, level.spawnpoints[i].origin);
    
        if(distance < nearestDistance)
        {
            nearestDistance = distance;
            Spawnpoint = i;
        }
    }
  
    return Spawnpoint;
}

////////////////////////////////////////////////////////////
// Changes waypoint type
////////////////////////////////////////////////////////////
ChangeWaypointType(pos)
{
    if((gettime()-level.changeSpamTimer) < 1000)
    {
        return;
    }
    level.changeSpamTimer = gettime();
  
    wpTochange = -1;
  
    for(i = 0; i < level.waypointCount; i++)
    {
        distance = distance(level.waypoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            wpTochange = i;
            break;
        }
    }
  
	if(wpTochange != -1)
    {
        if(level.waypoints[wpTochange].type == "stand")
        { 
            level.waypoints[wpTochange].type = "climb";
            iprintln(&"DEBUG_CHANGE_CLIMB");
			angle = level.plr getplayerangles();
			level.waypoints[wpTochange].angles = angle;
			return;
        }
		
		if(level.waypoints[wpTochange].type == "climb")
        { 
            level.waypoints[wpTochange].type = "stand";
            iprintln(&"DEBUG_CHANGE_NORMAL");
			angle = level.plr getplayerangles();
			level.waypoints[wpTochange].angles = -1;
			return;
        }
    }
}
   
////////////////////////////////////////////////////////////
// Adds a waypoint to the static waypoint list
////////////////////////////////////////////////////////////
AddWaypoint(pos)
{
    for(i = 0; i < level.waypointCount; i++)
    {
        distance = distance(level.waypoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            return;
        }
    }

    level.waypoints[level.waypointCount] = spawnstruct();
    level.waypoints[level.waypointCount].origin = pos;
    level.waypoints[level.waypointCount].type = "stand";
    level.waypoints[level.waypointCount].children = [];
    level.waypoints[level.waypointCount].childCount = 0;
    level.waypointCount++;

    iprintln("Waypoint Added"); 
}

////////////////////////////////////////////////////////////
// Adds a waypoint to the static waypoint list
////////////////////////////////////////////////////////////
AddAutoWaypoint(pos)
{
    for(i = 0; i < level.spawnpoints.size; i++)
    {
        distance = distance(level.spawnpoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            LinkWaypoint(level.playerPos);
	        return;
        }
    }
	
	for(i = 0; i < level.waypointCount; i++)
    {
        distance = distance(level.waypoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            LinkWaypoint(level.playerPos);
	        return;
        }
    }

    level.waypoints[level.waypointCount] = spawnstruct();
    level.waypoints[level.waypointCount].origin = pos;
    level.waypoints[level.waypointCount].type = "stand";
    level.waypoints[level.waypointCount].children = [];
    level.waypoints[level.waypointCount].childCount = 0;
    level.waypointCount++;

    iprintln(&"DEBUG_WAYPOINT_ADD");
    LinkAutoWaypoint(level.playerPos);
    wait .5;
    LinkAutoWaypoint(level.playerPos);
}

////////////////////////////////////////////////////////////
// Adds a kill point to the killpoint list
////////////////////////////////////////////////////////////
AddKillpoint(pos)
{
    if(!isdefined(level.killpointCount)) level.killpointCount = 0;
	else
	{
		for(i = 0; i < level.killpointCount; i++)
		{
			distance = distance(level.killpoints[i].origin, pos);
		
			if(distance <= 50.0)
			{
				return;
			}
		}
	}

    level.killpoints[level.killpointCount] = spawnstruct();
    level.killpoints[level.killpointCount].origin = pos;
    level.killpoints[level.killpointCount].type = "Killzone";
    level.killpoints[level.killpointCount].children = [];
    level.killpoints[level.killpointCount].childCount = 0;
    level.killpointCount++;

    iprintln(&"DEBUG_KILLPOINT_ADD");
}

////////////////////////////////////////////////////////////
// Adds a climbing waypoint to the static waypoint list
////////////////////////////////////////////////////////////
AddClimbWaypoint(pos)
{
    for(i = 0; i < level.waypointCount; i++)
    {
        distance = distance(level.waypoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            return;
        }
    }

    level.waypoints[level.waypointCount] = spawnstruct();
    level.waypoints[level.waypointCount].origin = pos;
    level.waypoints[level.waypointCount].type = "climb";
    level.waypoints[level.waypointCount].children = [];
    level.waypoints[level.waypointCount].childCount = 0;
    level.waypointCount++;

    iprintln("Climb Waypoint Added");
}

////////////////////////////////////////////////////////////
// removes a waypoint from the static waypoint list
////////////////////////////////////////////////////////////
DeleteWaypoint(pos)
{
    for(i = 0; i < level.waypointCount; i++)
    {
        distance = distance(level.waypoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            //remove all links in children
            //for each child c
            for(c = 0; c < level.waypoints[i].childCount; c++)
            {
                //remove links to its parent i
                for(c2 = 0; c2 < level.waypoints[level.waypoints[i].children[c]].childCount; c2++)
                {
                    // child of i has a link to i as one of its children, so remove it
                    if(level.waypoints[level.waypoints[i].children[c]].children[c2] == i)
                    {
                        //remove entry by shuffling list over top of entry
                        for(c3 = c2; c3 < level.waypoints[level.waypoints[i].children[c]].childCount-1; c3++)
                        {
                            level.waypoints[level.waypoints[i].children[c]].children[c3] = level.waypoints[level.waypoints[i].children[c]].children[c3+1];
                        }
                        //removed child
                        level.waypoints[level.waypoints[i].children[c]].childCount--;
                        break;
                    }
                }
            }
      
            //remove waypoint from list
            for(x = i; x < level.waypointCount-1; x++)
            {
                level.waypoints[x] = level.waypoints[x+1];
            }
            level.waypointCount--;
      
            //reassign all child links to their correct values
            for(r = 0; r < level.waypointCount; r++)
            {
                for(c = 0; c < level.waypoints[r].childCount; c++)
                {
                    if(level.waypoints[r].children[c] > i)
                    {
                        level.waypoints[r].children[c]--;
                    }
                }
            }
            iprintln("Waypoint Deleted");
      
            return;
        }
    }
  
    if(isdefined(level.killpoints))
	{
		for(i = 0; i < level.killpointCount; i++)
		{
			distance = distance(level.killpoints[i].origin, pos);
		
			if(distance <= 50.0)
			{
				for(c = 0; c < level.killpoints[i].childCount; c++)
				{
					for(c2 = 0; c2 < level.killpoints[level.killpoints[i].children[c]].childCount; c2++)
					{
						if(level.killpoints[level.killpoints[i].children[c]].children[c2] == i)
						{
							for(c3 = c2; c3 < level.killpoints[level.killpoints[i].children[c]].childCount-1; c3++)
							{
								level.killpoints[level.killpoints[i].children[c]].children[c3] = level.killpoints[level.killpoints[i].children[c]].children[c3+1];
							}
							level.killpoints[level.killpoints[i].children[c]].childCount--;
							break;
						}
					}
				}
		  
				for(x = i; x < level.killpointCount-1; x++)
				{
					level.killpoints[x] = level.killpoints[x+1];
				}
				level.killpointCount--;
		  
				for(r = 0; r < level.killpointCount; r++)
				{
					for(c = 0; c < level.killpoints[r].childCount; c++)
					{
						if(level.killpoints[r].children[c] > i)
						{
							level.killpoints[r].children[c]--;
						}
					}
				}
				iprintln(&"DEBUG_KILLPOINT_DELETE");
				return;
			}
		}
	}
}

////////////////////////////////////////////////////////////
//Links one waypoint to another
////////////////////////////////////////////////////////////
LinkWaypoint(pos)
{
    //dont spam linkage
    if((gettime()-level.linkSpamTimer) < 1000)
    {
        return;
    }
    level.linkSpamTimer = gettime();
  
    wpToLink = -1;
  
    for(i = 0; i < level.waypointCount; i++)
    {
        distance = distance(level.waypoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            wpToLink = i;
            break;
        }
    }
  
    //if the nearest waypoint is valid
    if(wpToLink != -1)
    {
        //if we have already pressed link on another waypoint, then link them up
        if(level.wpToLink != -1 && level.wpToLink != wpToLink)
        {
            level.waypoints[level.wpToLink].children[level.waypoints[level.wpToLink].childcount] = wpToLink;
            level.waypoints[level.wpToLink].childcount++;
      
            level.waypoints[wpToLink].children[level.waypoints[wpToLink].childcount] = level.wpToLink;
            level.waypoints[wpToLink].childcount++;
      
            iprintln("Waypoint " + wpToLink + " Linked to " + level.wpToLink);
            level.wpToLink = -1;
        }
        else //otherwise store the first link point
        {
            level.wpToLink = wpToLink;
            iprintln("Waypoint Link Started");
        }
    }
    else
    {
        level.wpToLink = -1;
        iprintln("Waypoint Link Cancelled");
    }
}

////////////////////////////////////////////////////////////
//Links one waypoint to another
////////////////////////////////////////////////////////////
LinkAutoWaypoint(pos)
{
    //dont spam linkage
    if((gettime()-level.linkSpamTimer) < 50)
    {
        return;
    }
    level.linkSpamTimer = gettime();
  
    wpToLink = -1;
  
    for(i = 0; i < level.waypointCount; i++)
    {
        distance = distance(level.waypoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            wpToLink = i;
            break;
        }
    }
  
    //if the nearest waypoint is valid
    if(wpToLink != -1)
    {
        //if we have already pressed link on another waypoint, then link them up
        if(level.wpToLink != -1 && level.wpToLink != wpToLink)
        {
            level.waypoints[level.wpToLink].children[level.waypoints[level.wpToLink].childcount] = wpToLink;
            level.waypoints[level.wpToLink].childcount++;
      
            level.waypoints[wpToLink].children[level.waypoints[wpToLink].childcount] = level.wpToLink;
            level.waypoints[wpToLink].childcount++;
      
            iprintln("Waypoint " + wpToLink + " Linked to " + level.wpToLink);
            level.wpToLink = -1;
        }
        else //otherwise store the first link point
        {
            level.wpToLink = wpToLink;
            iprintln(&"DEBUG_WAYPOINT_LINK_STARTED");
        }
    }
    else
    {
        level.wpToLink = -1;
        iprintln(&"DEBUG_WAYPOINT_LINK_CANCEL");
    }
}

////////////////////////////////////////////////////////////
//Breaks the link between two waypoints
////////////////////////////////////////////////////////////
UnLinkWaypoint(pos)
{
    //dont spam linkage
    if((gettime()-level.linkSpamTimer) < 1000)
    {
        return;
    }
    level.linkSpamTimer = gettime();
  
    wpToLink = -1;
  
    for(i = 0; i < level.waypointCount; i++)
    {
        distance = distance(level.waypoints[i].origin, pos);
    
        if(distance <= 30.0)
        {
            wpToLink = i;
            break;
        }
    }
  
    //if the nearest waypoint is valid
    if(wpToLink != -1)
    {
        //if we have already pressed link on another waypoint, then break the link
        if(level.wpToLink != -1 && level.wpToLink != wpToLink)
        {
            //do first waypoint
            for(i = 0; i < level.waypoints[level.wpToLink].childCount; i++)
            {
                if(level.waypoints[level.wpToLink].children[i] == wpToLink)
                {
                    //shuffle list down
                    for(c = i; c < level.waypoints[level.wpToLink].childCount-1; c++)
                    {
                        level.waypoints[level.wpToLink].children[c] = level.waypoints[level.wpToLink].children[c+1];
                    }
                    level.waypoints[level.wpToLink].childCount--;
                    break;
                }
            }
      
            //do second waypoint  
            for(i = 0; i < level.waypoints[wpToLink].childCount; i++)
            {
                if(level.waypoints[wpToLink].children[i] == level.wpToLink)
                {
                    //shuffle list down
                    for(c = i; c < level.waypoints[wpToLink].childCount-1; c++)
                    {
                        level.waypoints[wpToLink].children[c] = level.waypoints[wpToLink].children[c+1];
                    }
                    level.waypoints[wpToLink].childCount--;
                    break;
                }
            }
      
            iprintln("Waypoint " + wpToLink + " Broken to " + level.wpToLink);
            level.wpToLink = -1;
        }
        else //otherwise store the first link point
        {
            level.wpToLink = wpToLink;
            iprintln("Waypoint De-Link Started");
        }
    }
    else
    {
        level.wpToLink = -1;
        iprintln("Waypoint De-Link Cancelled");
    }
}

////////////////////////////////////////////////////////////
// Saves waypoints out to a file
////////////////////////////////////////////////////////////
SaveStaticWaypoints()
{
	if((gettime()-level.saveSpamTimer) < 1500)
	{
		return;
	}
	level.saveSpamTimer = gettime();

	setDvar("logfile", 1);

	mapname = tolower(getDvar("mapname"));
	filename = mapname + "_waypoints.gsc";

	info = [];
	info[0] = "// =========================================================================================";
	info[1] = "// File Name = '" + filename + "'";
	info[2] = "// Map Name  = '" + mapname + "'";
	info[3] = "// =========================================================================================";
	info[4] = "// ";
	info[5] = "// This is an auto generated script file created by the PeZBOT Mod - DO NOT MODIFY!";
	info[6] = "// ";
	info[7] = "// =========================================================================================";
	info[8] = "// ";
	info[9] = "// This file contains the waypoints for the map '" + mapname + "'.";	
	info[10] = "// ";
	info[11] = "// You now need to save this file as the file name at the top of this file.";
	info[12] = "// in the 'waypoint.iwd' file in a folder called the same as the map name.";
	info[13] = "// Delete the first two lines of this file and the 'Dvar set logfile 0' at the end of the file.";
	info[14] = "// Create the new folder if you havent already done so and rename it to the map name.";
	info[15] = "// So - new_waypoints.iwd/" + filename;
	info[16] = "// ";
	info[17] = "// you now need to edit the file 'select_map.gsc' in the btd_waypoints folder if you havent already.";
	info[18] = "// just follow the instructions at the top of the file. you will need to add the following code.";
	info[19] = "// I couldnt output double quotes to file so replace the single quotes with double quotes.";
	info[20] = "// Also i couldnt output back slashs to file so replace the forward slashs with back slashs.";
	info[21] = "/*";
	info[22] = " ";
	info[23] = "    else if(mapname == '"+ mapname +"')";
	info[24] = "    {";
	info[25] = "        thread Waypoints/" + mapname + "_waypoints::load_waypoints();";
	info[26] = "    }";
	info[27] = " ";
	info[28] = "*/ ";
	info[29] = "// =========================================================================================";
	info[30] = " ";	
	
	for(i = 0; i < info.size; i++)
	{
		println(info[i]);
	}
	
	scriptstart = [];
	scriptstart[0] = "load_waypoints()";
	scriptstart[1] = "{";
	
	for(i = 0; i < scriptstart.size; i++)
	{
		println(scriptstart[i]);
	}

	for(w = 0; w < level.waypointCount; w++)
	{
		waypointstruct = "    level.waypoints[" + w + "] = spawnstruct();";
		println(waypointstruct);
	
		waypointstring = "    level.waypoints[" + w + "].origin = "+ "(" + level.waypoints[w].origin[0] + "," + level.waypoints[w].origin[1] + "," + level.waypoints[w].origin[2] + ");";
		println(waypointstring);

		waypointtype = "    level.waypoints[" + w + "].type = " + "\"" + level.waypoints[w].type + "\"" + ";";
		println(waypointtype);
		
		waypointchild = "    level.waypoints[" + w + "].childCount = " + level.waypoints[w].childCount + ";";
		println(waypointchild);

		for(c = 0; c < level.waypoints[w].childCount; c++)
		{
			childstring = "    level.waypoints[" + w + "].children[" + c + "] = " + level.waypoints[w].children[c] + ";";
			println(childstring);      
		}
		
		if(level.waypoints[w].type == "climb" || level.waypoints[w].type == "mantle" || level.waypoints[w].type == "jump" || level.waypoints[w].type == "plant")
		{
		    waypointangle = "    level.waypoints[" + w + "].angles = " + level.waypoints[w].angles + ";";
			println(waypointangle);
		}
		
		if(level.waypoints[w].type == "climb" || level.waypoints[w].type == "mantle" || level.waypoints[w].type == "plant")
		{
		waypointusestate = "    level.waypoints[" + w + "].use = true;";
		println(waypointusestate);
		}
	}
	
	scriptmiddle = [];
	scriptmiddle[0] = " ";
	scriptmiddle[1] = "    level.waypointCount = level.waypoints.size;";
	scriptmiddle[2] = " ";
	
	for(i = 0; i < scriptmiddle.size; i++)
	{
		println(scriptmiddle[i]);
	}
	
	if(isdefined(level.killpoints))
	{
		for(x = 0; x < level.killpointCount; x++)
		{
			waypointstruct = "    level.killpoints[" + x + "] = spawnstruct();";
			println(waypointstruct);
		
			waypointstring = "    level.killpoints[" + x + "].origin = "+ "(" + level.killpoints[x].origin[0] + "," + level.killpoints[x].origin[1] + "," + level.killpoints[x].origin[2] + ");";
			println(waypointstring);
	
			waypointtype = "    level.killpoints[" + x + "].type = " + "\"" + level.killpoints[x].type + "\"" + ";";
			println(waypointtype);
			
			waypointchild = "    level.killpoints[" + x + "].childCount = " + level.killpoints[x].childCount + ";";
			println(waypointchild);
			
			for(d = 0; d < level.killpoints[x].childCount; d++)
			{
				childstring = "    level.killpoints[" + x + "].children[" + d + "] = " + level.killpoints[x].children[d] + ";";
				println(childstring);      
			}	
		}
	}
	
	scriptend = [];
	
	if(isdefined(level.killpoints))
	{
	    scriptend[0] = " ";
		scriptend[1] = "    level.killpointCount = level.killpoints.size;";
	    scriptend[2] = "}";
	}
	else
	{
	   scriptend[0] = "}";
	}
	
	for(i = 0; i < scriptend.size; i++)
	{
		println(scriptend[i]);
	}

	setDvar("logfile", 0);
  
	wait 1;
	iprintlnBold("^0Waypoints Outputted To Console Log In Mod Folder");
	wait 1;
	iprintlnBold("^0Close Game & Follow Instructions In File");

}

////////////////////////////////////////////////////////////
// Rank up
///////////////////////////////////////////////////////////
XPCheat()
{
	wait 5;
	
	for(;;)
	{
		if(getdvarInt("svr_pezbots_XPCheat") > 0)
			break;
		wait 1;
	}

	
	for(;;)
	{
	    level.players[0] thread maps\mp\gametypes\_rank::giveRankXP( "kill", 100 );
	    if(level.players[0].pers["rank"] >= 54)
	    break;
	    wait 0.05; 
	}

	keys = getArrayKeys( level.challengeInfo );
	println("challengeInfo keys size = " + keys.size);
	for(i=0; i < keys.size; i++)
	{
		if ( level.challengeInfo[keys[ i ]]["camo"] != "" )
		{
			level.players[0] maps\mp\gametypes\_rank::unlockCamo( level.challengeInfo[keys[ i ]]["camo"] );
		    println("Unlocked - " + keys[ i ] + " camo");
        }
    
		if ( level.challengeInfo[keys[ i ]]["attachment"] != "" )
		{
			level.players[0] maps\mp\gametypes\_rank::unlockAttachment( level.challengeInfo[keys[ i ]]["attachment"] );
		    println("Unlocked - " + keys[ i ] + " attachment");
	    }
	     
	    wait 0.05; 
	}	
	
    setdvar("svr_pezbots_XPCheat", 0);
  
    thread XPCheat();
}

////////////////////////////////////////////////////////////
// start in normal mode
///////////////////////////////////////////////////////////
StartNormal()
{
	wait 5;
    testclients = [];
	for(;;)
	{
		if(getdvarInt("svr_pezbots_axis") > 0 || getdvarInt("svr_pezbots_allies") > 0 || getdvarInt("svr_pezbots") > 0)
			break;
		wait 1;
	}

	testclients = getdvarInt("svr_pezbots");
	
	if(testclients > 0)
	{
		for(i = 0; i < testclients; i++)
		{
			ent[i] = addtestclient();
	
			if (!isdefined(ent[i])) 
			{
				println("Could not add test client");
				wait 1;
				continue;
			}
		
			ent[i].pers["isBot"] = true;
			ent[i].bIsBot = true;
			ent[i] freezecontrols(true);
			ent[i] thread TestClient("autoassign");	
			
			wait randomfloatrange(0.1, 0.3);
		}
	}
	else
	{
		testclients_axis = getdvarInt("svr_pezbots_axis");
		
		for(i = 0; i < testclients_axis; i++)
		{
			ent[i] = addtestclient();
	
			if (!isdefined(ent[i])) 
			{
				println("Could not add test client");
				wait 1;
				continue;
			}
		
			ent[i].pers["isBot"] = true;
			ent[i].bIsBot = true;
			ent[i] freezecontrols(true);
			ent[i] thread TestClient("axis");
			
			wait randomfloatrange(0.1, 0.3);
		}
		
		testclients_allies = getdvarInt("svr_pezbots_allies");
		
		
		for(i = 0; i < testclients_allies; i++)
		{
			ent[i] = addtestclient();
	
			if (!isdefined(ent[i])) 
			{
				println("Could not add test client");
				wait 1;
				continue;
			}
		
			ent[i].pers["isBot"] = true;
			ent[i].bIsBot = true;
			ent[i] freezecontrols(true);
			ent[i] thread TestClient("allies");	
			
			wait randomfloatrange(0.1, 0.3);
		}
	}
	
	setDvar( "svr_pezbots", 0 );
	setDvar( "svr_pezbots_allies", 0 );
	setDvar( "svr_pezbots_axis", 0 );
	thread StartNormal();
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
TestClient(team)
{
	self endon( "disconnect" );

	while(!isdefined(self.pers["team"]))
		wait .05;

	self notify("menuresponse", game["menu_team"], team);
	wait 0.5;
    model = [];
	rnd = [];
	self.pers["model_assault"] = undefined;
	self.pers["model_support"] = undefined;
	self.pers["model_specops"] = undefined;
	self.pers["model_velinda"] = undefined;
	self.pers["model_sniper"] = undefined;
	self.pers["model_recon"] = undefined;
	self.pers["model_price"] = undefined;
	self.pers["model_urbansniper"] = undefined;
	self.pers["model_zakhaev"] = undefined;
	self.pers["model_alasad"] = undefined;
	self.pers["model_farmer"] = undefined;
	
    class = "assault_mp";
    classPicked = getdvarint("svr_pezbots_classPicker");
	switch(randomInt(5))
	{
		case 0:		class = "assault_mp";      break;	
		case 1:		class = "specops_mp";	    break;
		case 2:		class = "heavygunner_mp";	break;
		case 3:		class = "demolitions_mp";	break;
		case 4:		class = "sniper_mp";       break;
	}

	if( self.pers["team"] == "allies")
	{
	    if (getdvar("scr_modeltype") == "desert")
	    {
		    switch(randomInt(5))
			{
				case 0:	    model = "model_assault";	break;	
				case 1:	    model = "model_specops";	break;
				case 2:		model = "model_recon";	    break;
				case 3:		model = "model_support";	break;
				case 4:		model = "model_sniper";	    break;
			}
		}
		if (getdvar("scr_modeltype") == "urban" || getdvar("scr_modeltype") == "woodland")
	    {
		    if(getdvar("svr_pezbots_modelchoice") == "1") rnd = 6;
			else rnd = 5;
			switch(randomInt(rnd))
			{
				case 0:	    model = "model_assault";	break;	
				case 1:	    model = "model_specops";	break;
				case 2:		model = "model_recon";	    break;
				case 3:		model = "model_support";	break;
				case 4:		model = "model_sniper";	    break;
				case 5:		model = "model_price";	    break;
			}
		}
	}
	else
	{
	    if (getdvar("scr_modeltype") == "desert")
	    {
		    if(getdvar("svr_pezbots_modelchoice") == "1") rnd = 7;
			else rnd = 5;
			switch(randomInt(rnd))
			{
				case 0:	    model = "model_assault";	break;	
				case 1:	    model = "model_specops";	break;
				case 2:		model = "model_recon";	    break;
				case 3:		model = "model_support";	break;
				case 4:		model = "model_sniper";	    break;
				case 5:		model = "model_zakhaev";	break;
				case 6:		model = "model_alasad";	    break;
			}
		}
		if (getdvar("scr_modeltype") == "urban")
	    {
		    if(getdvar("svr_pezbots_modelchoice") == "1") rnd = 8;
			else rnd = 5;
			switch(randomInt(rnd))
			{
				case 0:	    model = "model_assault";	break;	
				case 1:	    model = "model_specops";	break;
				case 2:		model = "model_recon";	    break;
				case 3:		model = "model_support";	break;
				case 4:		model = "model_sniper";	    break;
				case 5:		model = "model_urbansniper";break;
				case 6:		model = "model_zakhaev";	break;
				case 7:		model = "model_alasad";	    break;
			}
		}
		if (getdvar("scr_modeltype") == "woodland")
	    {
		    if(getdvar("svr_pezbots_modelchoice") == "1") rnd = 10;
			else rnd = 5;
			switch(randomInt(rnd))
			{
				case 0:	    model = "model_assault";	break;	
				case 1:	    model = "model_specops";	break;
				case 2:		model = "model_recon";	    break;
				case 3:		model = "model_support";	break;
				case 4:		model = "model_sniper";	    break;
				case 5:		model = "model_urbansniper";break;
				case 6:		model = "model_zakhaev";	break;
				case 7:		model = "model_alasad";	    break;
				case 8:		model = "model_farmer";	    break;
			}
		}
	}
	
	self.pers[model] = true;

	classPicked++;
	if(classPicked > 4)
	{
	    classPicked = 0;
	}
	setdvar("svr_pezbots_classPicker", classPicked);
	
	println("Picked Class " + class);
	
    self.weaponPrefix = "ak47_mp";
 	self PickRandomActualWeapon();

    self notify("menuresponse", "changeclass", class);

    self waittill("spawned_player");
	
	self.selectedClass = true;
	
	rank = randomIntRange(1, 55);
	self SetRank(rank);
	self.pers["rank"] = rank;
	
	if(getDvar("scr_game_perks") == "1" )
	if(getDvar("svr_pezbots_useperks") == "1")
	{

		self setPerk("specialty_bulletdamage");						//Give all bots Stopping Power
		
		switch(randomint(5))
		{
			case 0: self setPerk("specialty_bulletaccuracy"); 		//Steady Aim
			case 1: self setPerk("specialty_armorvest"); 			//Juggernaut
			case 2: self setPerk("specialty_gpsjammer"); 			//UAV Jammer
			case 3: self setPerk("specialty_explosivedamage"); 		//Sonic Boom
			case 4: self setPerk("specialty_bulletpenetration");	//Deep Impact
		}
	}
	if (getdvar("svr_pezbots_playstyle") == "2")
	{
	    if(randomInt(3) != 0)
		{
			self.botCrouchObj = 500;
			self.botwalkspeed = 6.0;
			self.botRunDist = 600;
	    }
		else
		{
			self.botCrouchObj = 1200;
			self.botwalkspeed = 5.5;
			self.botRunDist = 2000;
		}
	}
	else
	{
	    self.botCrouchObj = level.botCrouchObj;
		self.botwalkspeed = level.botwalkspeed;
		self.botRunDist = level.botRunDist;
	}
	
	self thread PeZBOTMainLoop();	
}

////////////////////////////////////////////////////////////
// picks a random actual weapon
////////////////////////////////////////////////////////////
PickRandomActualWeapon()
{
    weaponCount = int(TableLookup("weapons/mp/PeZBOT_WeaponDefs.csv", 0, 0, 2));

    randomWeapon = 1 + randomintrange(0, weaponCount+1);
  
    self.actualWeapon = TableLookup("weapons/mp/PeZBOT_WeaponDefs.csv", 0, randomWeapon, 1);
    self.maxEngageRange = int(TableLookup("weapons/mp/PeZBOT_WeaponDefs.csv", 0, randomWeapon, 2));
}

////////////////////////////////////////////////////////////
// this spams weapon changes so they actually take effect.. sheesh!
////////////////////////////////////////////////////////////
AnimSpam()
{
/*	self endon("disconnect");
	while(1)
	{
		if(self.bSpamAnims && self.bShooting == false)
		{
		    self TakeAllWeapons();
	
		    //build actual weapon string name
		    self.pers["weapon"] = self.animWeapon;
		    self giveweapon(self.pers["weapon"]);
	//      self givemaxammo(self.pers["weapon"]);
		    self SetWeaponAmmoClip(self.pers["weapon"], 30);
		    self SetWeaponAmmoStock(self.pers["weapon"], 0);
		    self setspawnweapon(self.pers["weapon"]);
			self switchtoweapon(self.pers["weapon"]);
		}
	
		wait 0.1;
	}
*/
}

////////////////////////////////////////////////////////////
// weapon // current weapon
// stance // stand, crouch, prone
// movementType // idle, walk, run, back, left, right, fire
///////////////////////////////////////////////////////////
SetAnim(weapon, stance, movementType)
{

  if(self.bShooting == true)
  {
    return;
  }

    newWeapon = weapon + "_pezbot_" + stance + "_" + movementType;
    self.animWeapon = newWeapon;
    self.bSpamAnims = true;
    switch(movementType)
    {
        case "melee":
        case "grenade":
        self.bSpamAnims = false;
        break;
      
        default:
        self.bSpamAnims = true;
        break;
    };
  
    if(isdefined(self.pers["weapon"]))
    {
        self takeweapon(self.pers["weapon"]);
    }

    self TakeAllWeapons();

    //build actual weapon string name
    self.pers["weapon"] = newWeapon;
    self giveweapon(self.pers["weapon"]);
	stockMax = WeaponMaxAmmo( self.pers["weapon"] );
    self SetWeaponAmmoClip(self.pers["weapon"], 30);
    if(movementType == "grenade")
    {
        self SetWeaponAmmoStock(self.pers["weapon"], 2);
    }
    else
    {
        self SetWeaponAmmoStock(self.pers["weapon"], stockMax);
    }
    self setspawnweapon(self.pers["weapon"]);
	self switchtoweapon(self.pers["weapon"]);
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
VectorCross( v1, v2 )
{
	return ( v1[1]*v2[2] - v1[2]*v2[1], v1[2]*v2[0] - v1[0]*v2[2], v1[0]*v2[1] - v1[1]*v2[0] );
}

////////////////////////////////////////////////////////////
// offsets the eye pos a bit higher
///////////////////////////////////////////////////////////
GetEyePos()
{
    return (self getEye() + (0,0,20));
}

////////////////////////////////////////////////////////////
// IsFacingAtTarget
///////////////////////////////////////////////////////////
IsFacingAtTarget(target)
{
    if(!isDefined(target))
    {
        return false;
    }
  
    dirToTarget = VectorNormalize(target.origin-self.origin);
  
    forward = AnglesToForward(self GetPlayerAngles());
  
    dot = vectordot(dirToTarget, forward);
  
    if(dot > 0.75)
    {
        return true;
    }
  
  return false;

}

////////////////////////////////////////////////////////////
// CanSeeTarget
///////////////////////////////////////////////////////////
CanSeeTarget()
{
    if(!isDefined(self.bestTarget))
    {
        return false;
    }

    //can't see sh!t  
    if(self maps\mp\_flashgrenades::isFlashbanged())
    {
//      print3d(self.origin, "flashed", (1,0,0), 2);
        return false;
    }
  
    dot = 1.0;
  
    if((gettime()-self.fTargetMemory) < 3000 &&	(isdefined(self.rememberedTarget) && self.rememberedTarget == self.bestTarget && self.rememberedTarget.sessionstate == "playing"))
    {
        return true;
    }
    else
    {
        self.rememberedTarget = undefined;
    }
  
    //if nearest target hasn't attacked me, check to see if it's in front of me
    if(!AttackedMe(self.bestTarget))
    {
        targetPos = self.bestTarget GetEyePos();
        eyePos = self GetEyePos();
        fwdDir = anglestoforward(self getplayerangles());
        dirToTarget = vectorNormalize(targetPos-eyePos);
        dot = vectorDot(fwdDir, dirToTarget);
    }
  
    //try see through smoke
    if(!SmokeTrace(self GetEyePos(), self.bestTarget GetEyePos()))
    {
        return false;
    }
  
    //in front of us and is being obvious
    if(dot > 0.25 && self.bestTarget IsBeingObvious(self))
    {
        //do a ray to see if we can see the target
        visTrace = bullettrace(self GetEyePos(), self.bestTarget GetEyePos(), false, self);
        if(visTrace["fraction"] == 1)
        {
            if(CanDebugDraw())
            {
                line(self GetEyePos(), visTrace["position"], (0,1.0,0));
            }
            self.fTargetMemory = gettime(); //remember target
            self.rememberedTarget = self.bestTarget;
            return true;
        }
        else
        {
            if(CanDebugDraw())
            {
                line(self GetEyePos(), visTrace["position"], (1,0,0));            
            }
            return false;
        }
    }
  
    return false;
}

////////////////////////////////////////////////////////////
// returns true if shooting, moving over a certain speed (depending on skill) etc..
// obviousTo is the player they are being obvious to
// also checks the maxEngageRange of obviousTo, if too far away ignore
////////////////////////////////////////////////////////////
IsBeingObvious(obviousTo)
{
    if(isdefined(self.hasChopperTarget) && self.hasChopperTarget == true)
	{
	    return true;
	}
  
    obviousDist = distance(obviousTo.origin, self.origin);

    //check obvious distance agains maxEnageRange
    if(obviousDist > obviousTo.maxEngageRange)
    {
        return false;
    }

    //close enough already we should definately be obvious
    if(obviousDist < 1600.0)
    {
        return true;    
    }

    if(isdefined(self.bIsBot))
    {
        if(isdefined(self.bThrowingGrenade) && self.bThrowingGrenade || isdefined(self.bShooting) && self.bShooting)
        {
            return true;
        }
    }
    else
    {
        if(self AttackButtonPressed())
        {
            return true;
        }
    }
  
    if(isdefined(self.fVelSquared))
    {
        if(self.fVelSquared > (4.0*4.0))
        {
            return true;
        }
    }

  return false;
}

////////////////////////////////////////////////////////////
// CanSee a player?
///////////////////////////////////////////////////////////
CanSee(target)
{

    if(self maps\mp\_flashgrenades::isFlashbanged())
    {
        return false;
    }


    //do a ray to see if we can see the target
    visTrace = bullettrace(self GetEyePos(), target GetEyePos(), false, self);
    if(visTrace["fraction"] == 1)
    {
        if(CanDebugDraw())
        {
            line(self GetEyePos(), visTrace["position"], (1,7,0));
        }
        return true;
    }
    else
    {
        if(CanDebugDraw())
        {
            line(self GetEyePos(), visTrace["position"], (1,0,0));            
        }
        return false;
    }
}

////////////////////////////////////////////////////////////
// CanSee a position
///////////////////////////////////////////////////////////
CanSeePos(target)
{
    if(self maps\mp\_flashgrenades::isFlashbanged())
    {
        return false;
    }

    //do a ray to see if we can see the target
    visTrace = bullettrace(self GetEyePos(), target, false, self);
    if(visTrace["fraction"] == 1)
    {
        if(CanDebugDraw())
        {
            line(self GetEyePos(), visTrace["position"], (1,7,0));
        }
        return true;
    }
    else
    {
        if(CanDebugDraw())
        {
            line(self GetEyePos(), visTrace["position"], (1,0,0));            
        }
        return false;
    }
}

////////////////////////////////////////////////////////////
// snaffled from gametypes/dom.gsc
///////////////////////////////////////////////////////////
getFlagTeam()
{
	return self.useObj maps\mp\gametypes\_gameobjects::getOwnerTeam();
}

////////////////////////////////////////////////////////////
// process commands from other players
///////////////////////////////////////////////////////////
ProcessCommands()
{
	self endon( "disconnect" );
	
    while(1)
    {
        players = level.players;
    
        bActionTaken = false;
        for(i = 0; i < players.size; i++)
        { 
            takeAction = "none";
            player = players[i];
            if(player != self && self IsEnemy(player) != true && isDefined(player.commandIssued) && player.commandIssued != "-1")
            {
                //work out what action to take
	            switch(player.commandIssued)		
	            {
		            case "1": //"Follow Me!";
		            if(DistanceSquared(self.origin, player.origin) < (2000*2000))
		            {
		                takeAction = "follow";
		            }
		            else
		            {
      	                //self maps\mp\gametypes\_quickmessages::quickresponses("2");
		            }
			        break;

		            case "2": //"Move in!";
		            takeAction = "movein";
			        break;

		            case "3": //"Fall back!";
			        break;

		            case "4": //"Suppressing fire!";
		            //cant change suppressing fire target while suppressing, must stop first
		            if(isDefined(self.bSuppressingFire) && self.bSuppressingFire == false)
		            {
		                if(DistanceSquared(self.origin, player.origin) < (1000*1000))
		                {
  		                    takeAction = "suppress";
  		                }
  		            }
			        break;

		            case "5": //"Attack left flank!";
			        break;

		            case "6": //"Attack right flank!";
			        break;

		            case "7": //"Hold this position!";
                    takeAction = "holdposition";
                    break;
	            }
            }
      
            //do what we're told to do
	        switch(takeAction)
	        {
	            case "follow":
	                self.bFollowTheLeader = true;
 	                self.bSuppressingFire = false;
			        self.bHoldPosition = false;
	                self.leader = player;
	                bActionTaken = true;
                    self BotGoal_ClearGoals();
	                break;
	        
	            case "movein":
	                self.bFollowTheLeader = false;
 	                self.bSuppressingFire = false;
			        self.bHoldPosition = false;
	                bActionTaken = true;
	                self.state = "combat";
                    self BotGoal_ClearGoals();
	                break;
			
		        case "holdposition":
                    self.bFollowTheLeader = false;
                    self.bSuppressingFire = false;
			        self.bHoldPosition = true;
                    bActionTaken = true;
                    self.state = "idle";
                    self BotGoal_ClearGoals();
                    break;
	        
	            case "suppress":
	                self.bFollowTheLeader = false;
	                self.bSuppressingFire = true;
			        self.bHoldPosition = false;
	                self.leader = player;
	                bActionTaken = true;
	                from = self.leader.origin + (0,0,50);
	                to = from + (anglestoforward(self.leader getplayerangles())*5000);
	                trace = bulletTrace(from, to, true, self.leader);
	                self.suppressTarget = trace["position"];
	                if(isDefined(trace["normal"]))
	                {
	                    self.suppressTarget = self.suppressTarget + (trace["normal"] * 30);
	                }

                    self BotGoal_ClearGoals();
	        };
	    
	        if(bActionTaken)
	        {
	            //self maps\mp\gametypes\_quickmessages::quickresponses("1");
	            break;
	        }
        }
        wait 0.000001;
    }
}


////////////////////////////////////////////////////////////
// Try play the current game type
///////////////////////////////////////////////////////////
TryPlayGame()
{

    //clear movein commands from leader if we have called it last frame
    if(isDefined(self.leader) && isDefined(self.bFollowTheLeader))
    {
        if(self.bFollowTheLeader == false && isDefined(self.leader.commandIssued) && self.leader.commandIssued == "2")
        {
            self.leader.commandIssued = "-1";
        }
    }

     //suppressing fire
    if(isDefined(self.bSuppressingFire) && self.bSuppressingFire && isDefined(self.leader) && isDefined(self.suppressTarget))
    {
        //can see the target or close enough to the leader..
        if(self CanSeePos(self.suppressTarget) || DistanceSquared(self.origin, self.leader.origin) <= (300*300))
        {
            self.state = "suppressingFire";
            if(self.state != "suppressingFire")
            {
                self BotGoal_ClearGoals();
            }
        }
        else //cant see target, so move to leader, he must be able to see it to have issued the command
        {
            self.vObjectivePos = self.leader.origin;
            self BotGoal_EnterGoal("DynWaypointFollowGoal");
        }
    }
    else
    //Follow the leader
    if(isDefined(self.bFollowTheLeader) && self.bFollowTheLeader && isDefined(self.leader))
    {
        leaderDistance = DistanceSquared(self.origin, self.leader.origin);
        //too far away from leader
        if(leaderDistance > (1000*1000))
        {
            self.bFollowTheLeader = false;
            self BotGoal_ClearGoals();
        }
        else
        if(leaderDistance > (200*200))
        {
            self.state = "followTheLeader";  
            self.vObjectivePos = self.leader.origin;
            self BotGoal_EnterGoal("DynWaypointFollowGoal");
        }
    }
    else
    //Hold position
    if(isDefined(self.bHoldPosition) && self.bHoldPosition && isDefined(self.leader))
    {
        self.state = "idle";  
        self.vObjectivePos = self.origin;
        self BotGoal_ClearGoals();
    }
    else  
    if(level.gametype == "dom")
    {
        if(self.state != "dom")
        {
            self BotGoal_ClearGoals();
        }
        self.state = "dom";
		level.minDistToObj = 1000;
    }
    else //headquarters
    if(level.gametype == "koth")
    {
        if(self.state != "koth")
        {
            self BotGoal_ClearGoals();
        }
        self.state = "koth";
		level.minDistToObj = 1000;
    }
    else //search and destroy
    if(level.gametype == "sd")
    {
        self.state = "sd";
        if(self.state != "sd")
        {
            self BotGoal_ClearGoals();
        }
		level.minDistToObj = 1000;
    }
    else //sabotage
    if(level.gametype == "sab")
    {
        self.state = "sab";
        if(self.state != "sab")
        {
            self BotGoal_ClearGoals();
        }
		level.minDistToObj = 1000;
    }
    else
    if(level.gametype == "dm" || level.gametype == "war")
    {
        if(isDefined(self.bestTarget))
        {
            //use position of nearest waypoint so not as to go wandering off
            //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
            tempObjectivePos = self.bestTarget.origin;
            if(isDefined(level.waypoints) && level.waypointCount > 0)
            {
                tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
            }
            self SetObjectivePos(tempObjectivePos);
            self PathToObjective();
        }
		level.minDistToObj = 200;
    }
}

////////////////////////////////////////////////////////////
// Decide whether to follow static waypoints or path dynamically
////////////////////////////////////////////////////////////
PathToObjective()
{

    if(self IsStunned())
    {
        return;
    }
    //dist = randomIntRange(300, 700);
    //crouch when closer to objective, otherwise stand
    if(Distance(self.origin, self.vObjectivePos) < self.botCrouchObj && self.iShouldCrouch == 1)
    {
        self.stance = "crouch";
    }
    else
    {
        self.stance = "stand";
    }
  
    //waypoints are closer to our objective so path using waypoints
    if(isDefined(level.waypoints) && level.waypointCount > 0 && self AnyWaypointCloserToObjectiveThanMe(self.vObjectivePos))
    { 
        if(self.currentStaticWp == -1)
        {
            wpPos = level.waypoints[GetNearestStaticWaypoint(self.origin)].origin;
      
            wpPos = (wpPos[0], wpPos[1], self.origin[2]);
 
            distance = Distance(self.origin, wpPos);
//          print3d(self.origin, "Distance: " + distance, (1,0,0), 2);
            if(distance <= (self.fMoveSpeed+5.0)) //close enough to waypoint so start following
            {
                self BotGoal_EnterGoal("StaticWaypointFollowGoal");
            }
            else //too far from waypoint so move over to it
            { 
                self.vObjectivePos = wpPos;
                self BotGoal_EnterGoal("DynWaypointFollowGoal");
            }
        }
    }
    else
    {
        self BotGoal_EnterGoal("DynWaypointFollowGoal");
    }
}

////////////////////////////////////////////////////////////
// allows bots to use hardpoints
///////////////////////////////////////////////////////////
HardpointUpdate()
{
  self endon ("disconnect");
  
    while(1)
    {
	    if(isDefined(self.pers["hardPointItem"]))
	    {
	        if(self maps\mp\gametypes\_hardpoints::triggerHardPoint(self.pers["hardPointItem"]))
	        {
	            self.pers["hardPointItem"] = undefined;
	        }
	    }
	  
	    wait 1;
	}
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
PeZBOTMainLoop()
{
	self endon( "disconnect" );

    self.bThreadsRunning = true;
  
    //wait for playing session state
	while(self.sessionstate != "playing"/* || level.gameEnded || level.inPrematchPeriod*/)
	{
	    wait 0.05;
	}

	self.bShooting = false;
	self.bSpamAnims = false;
	self.animWeapon = "ak47_mp_pezbot_stand_walk";
    self StopShooting();
    self.isBombCarrier = false;
    self.bombActionTimer = 0;
	self.dodgeTimer = gettime();
	self.vDodgeObjective = undefined;
	self setmovespeedscale(0);
	self.bThrowingGrenade = false;
	self.bMeleeAttacking = false;
	self.vObjectivePos = self.origin;
	self.currentGoal = "none";
	self.buggyBotCounter = 0;
	self.lastOrigin = self.origin;
	self.fTargetMemory = gettime()-15000;
	self.bPlantingBomb = false;
	self.hasChopperTarget = false;
	
	self.vMoveDirection = (0,1,0);
	self.fMoveSpeed = 0.0;
	self.bFaceNearestEnemy = true;
	self.currentStaticWp = -1;
    self.bClampToGround = true;
	self.flankSide = (randomIntRange(0,2) - 0.1) * 2.0;
	self.iShouldCrouch = randomIntRange(0,2);
	
  	self.state = "combat";
	self.stance = "stand";
  	self SetAnim(self.weaponPrefix, self.stance, "walk");
  	self thread AnimSpam();
	
    self thread TargetBestEnemy();
    self thread ClampToGround();
    //self thread ProcessCommands();
    self thread HardpointUpdate();
  
	for(;;)
	{
	    while(self.sessionstate != "playing")
	    {
	        wait 0.05;
	    }
	
		switch(self.state)
		{
			case "idle":
			    self.stance = "stand";
                self.bClampToGround = true;
				self.state = "idle";
			    break;
			  
			case "combat":
                if(isDefined(self.bestTarget))
                {
                    if(self CanSeeTarget())
                    {
                        self.bFaceNearestEnemy = true;
            
                        //only shoot if facing target
                        if(self IsFacingAtTarget(self.bestTarget))
                        {
							dist = distance(self.origin, self.bestTarget.origin);
							if(dist < 100)
							{
								self thread StabKnife(dist, self.bestTarget);
								self waittill("StopShooting");
								
							}
							
							//bang bang
                            if(randomint(90) >= 1)
                            {
                                self thread ShootWeapon();
                            }
                            else //NADE!!
                            {
                                self thread ThrowGrenade(dist);
                                self waittill("StopShooting");
                            }
							
							if(level.botbattlechatter)
							{
								self.speak = randomInt(180);
								if(self.speak == 1)
								{
									self thread soundMPChatter();
								}
							}
                        }
  
                        //Dodge
                        if((gettime()-self.dodgeTimer) > randomintrange(1000, 1500) || isdefined(self.vDodgeObjective))
                        {
//                          Print3d(self.origin + (0,0,70), "dodging", (1,0,0), 4);
                            self.dodgeTimer = gettime();
                            if(isDefined(level.waypoints) && level.waypointCount > 0)
                            {
                                nearestWP = GetNearestStaticWaypoint(self.origin);

                                if(isDefined(self.vDodgeObjective))
                                {
                                    wpPos = level.waypoints[nearestWP].origin;
                                    wpPos = (wpPos[0], wpPos[1], self.origin[2]);
                                    //close enough to nearest waypoint
                                    if(distance(self.origin, wpPos) <= (self.fMoveSpeed+5.0))
                                    {
                                        self.vObjectivePos = self.vDodgeObjective;
                                        self.vDodgeObjective = undefined;
                                    }
                                    else //go to nearest wp first
                                    {
                                        self.vObjectivePos = level.waypoints[nearestWP].origin;
                                    }
                                }
                                else
                                {
                                    //dodge to a random child of the nearest waypoint
                                    self.vObjectivePos = level.waypoints[nearestWP].origin;
                                    self.vDodgeObjective = level.waypoints[level.waypoints[nearestWP].children[randomint(level.waypoints[nearestWP].childCount)]].origin;
                                    self BotGoal_ClearGoals();
                                }
                  
                                self PathToObjective();
                            }
                            else
                            {
                                dodgeRange = 100.0;
                                self.vObjectivePos = self.origin + (randomfloatrange(dodgeRange * -1.0, dodgeRange), randomfloatrange(dodgeRange * -1.0, dodgeRange), 0);
                                self BotGoal_EnterGoal("DynWaypointFollowGoal");
                            }
                        }
                    }
					else
					if(isdefined(level.chopper) && !self CanSeeTarget() && self.hasChopperTarget)
					{
					    self.bFaceNearestEnemy = true;
            
                        //only shoot if facing target
                        if(self IsFacingAtTarget(level.chopper))
                        {
                            dist = distance(self.origin, level.chopper.origin);
							//bang bang
                            if(randomint(15) >= 1) // decrease rnd value to increase chance of rpg strike
                            {
                                self thread ShootWeapon();
                            }
                            else //NADE!!
                            {
                                self thread ThrowGrenade(dist);
                                self waittill("StopShooting");
                            }
                        }
					} 
                    else //try see target, etc
                    {
                        self StopShooting();
                        self TryPlayGame();
                    }
                }
			    break;
			
			case "dom":
			
			    //if we can see our target, go into combat
			    if(self CanSeeTarget())
			    {
                    self.bFaceNearestEnemy = true;
			        self.state = "combat";
                    self BotGoal_ClearGoals();
			    }
			    else //otherwise play domination
			    {
		            closestFlag = -1;
		            closestFlagDistance = 9999999999;
		            for(i = 0; i < level.flags.size; i++)
		            {
			            team = level.flags[i] getFlagTeam();
		                if(team != self.pers["team"])
		                {
		                    distance = Distance(self.origin, level.flags[i].origin);
  		        
		                    //check if flag is closer
		                    if(distance < closestFlagDistance)
                            {
		                        closestFlag = i;
		                        closestFlagDistance = distance;
		                    }
		                }
		            }
  		    
		            //found closest flag not on our team, so go capture it
		            if(closestFlag != -1)
		            {
                        self SetObjectivePos(level.flags[closestFlag].origin);
            
//                      println("closest flag at " + level.flags[closestFlag].origin);

                        if(distance(self.vObjectivePos, self.origin) <= (self.fMoveSpeed+5.0))
                        {
                            self.buggyBotCounter = 0;
                        }
  
                        self PathToObjective();
		            }
		            else //hunt and kill enemies
		            {
		                if(isDefined(self.bestTarget))
		                {
                            //use position of nearest waypoint to enemy so not as to go wandering off
                            //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
                            tempObjectivePos = self.bestTarget.origin;
                            if(isDefined(level.waypoints) && level.waypointCount > 0)
                            {
                                tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
                            }
                            self SetObjectivePos(tempObjectivePos);
//                          self BotGoal_EnterGoal("DynWaypointFollowGoal");
                            self PathToObjective();
		                }
		            }
 		            self TryPlayGame();
		        }
			    break;
			
			case "climb":
				    self.movementtype = "climb";
                    self.bFaceNearestEnemy = false;
                    self.bClampToGround = false;
                break;

			case "sd":
			
			    if(level.gametype != "sd") self.state = "combat";
				//if we can see our target and not trying to plant or defuse, go into combat
			    if(self CanSeeTarget() && self.bombActionTimer == 0)
			    {
                    self.bFaceNearestEnemy = true;
			        self.state = "combat";
                    self BotGoal_ClearGoals();
			    }
			    else //otherwise play search and destroy
			    {
			        if(isdefined(level.bombZones) && isdefined(level.sdBomb))
			        {
			            //if i am an attacker
			            if(self.pers["team"] == game["attackers"])
			            {
			                //if bomb is planted, attack nearest enemy
			                if(level.bombPlanted == true)
			                {
 		                        self.bFaceNearestEnemy = true;
								self.bPlantingBomb = false;
								if(isDefined(self.bestTarget))
		                        {
                                    //use position of nearest waypoint to enemy so not as to go wandering off
                                    //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
                                    tempObjectivePos = self.bestTarget.origin;
                                    if(isDefined(level.waypoints) && level.waypointCount > 0)
                                    {
                                        tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
                                    }
                                    self SetObjectivePos(tempObjectivePos);
                                    self PathToObjective();
		                        }
			                }
			                else //if i have the bomb, go to nearest bombsite and plant
			                if(isdefined(self.isBombCarrier) && self.isBombCarrier == true)
			                {
			                    //find closest bombzone
			                    nearestDistance = 9999999999;
			                    nearestBombZone = undefined;
			          
			                    for(b = 0; b < level.bombZones.size; b++)
			                    {
			                        distance = distance(level.bombZones[b].trigger.origin, self.origin);
			                        if(distance < nearestDistance)
			                        {
			                            nearestBombZone = level.bombZones[b];
			                            nearestDistance = distance;
			                        }
			                    }
			          
			                    if(isDefined(nearestBombZone))
			                    {
			                        //close enough so plant
			                        if(nearestDistance <= 60)
			                        {
			                            //planting
			                            if(self.bombActionTimer != 0)
			                            {
											self.bFaceNearestEnemy = false;
											self.bPlantingBomb = true;
											self.buggyBotCounter = 0;
			                                //planted
			                                if((gettime()-self.bombActionTimer) > level.plantTime*1000)
			                                {
												nearestBombZone maps\mp\gametypes\sd::onUsePlantObject(self);
			                                    nearestBombZone maps\mp\gametypes\sd::onEndUse(self.pers["team"], self, true);
			                                    self.bombActionTimer = 0;
                                                self detach("prop_suitcase_bomb", "TAG_WEAPON_LEFT");
			                                }
			                            }
			                            else //not planting yet start planting
			                            {
											self.bombActionTimer = gettime();
			                                nearestBombZone maps\mp\gametypes\sd::onBeginUse(self);
					                        self.bFaceNearestEnemy = false;
			                            }
			                        }
			                        else //too far away, go to bombsite
			                        {
										self SetObjectivePos(nearestBombZone.trigger.origin);
			                            self PathToObjective();
			                        }
			                    }
			                }
			                else //find bomb
			                {
			                    //check if any of my team members has the bomb
			                    protectTarget = undefined;
			                    for(f = 0; f < level.players.size; f++)
			                    {
			                        if(!self IsEnemy(level.players[f]) && isdefined(level.players[f].isBombCarrier) && level.players[f].isBombCarrier == true)
			                        {
			                            protectTarget = level.players[f];
			                            break;
			                        }
			                    }
			          
			                    // if one of my team members has the bomb, protect them
			                    if(isDefined(protectTarget) && isdefined(self.bestTarget))
			                    {
                                    //use position of nearest waypoint to enemy so not as to go wandering off
                                    //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
                                    tempObjectivePos = self.bestTarget.origin;
                                    if(isDefined(level.waypoints) && level.waypointCount > 0)
                                    {
                                        tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
                                    }
                                    self SetObjectivePos(tempObjectivePos);
			                    }
			                    else //none of my team has the bomb, find the bomb
			                    {
			                        self SetObjectivePos(level.sdBomb.trigger.origin);
			                    }
			          
			                    //go to where we need to go
                                self PathToObjective();
			                }
			            }
			            else //defender
			            {
			                if(level.bombPlanted == true)
			                {
			                    self SetObjectivePos(level.defuseObject.trigger.origin);
			                    
								//close enough defuse
			                    if(distance(self.vObjectivePos, self.origin) < 60)
			                    {
									//defusing
			                        if(self.bombActionTimer != 0)
			                        {
										self.buggyBotCounter = 0;
			                            //planted
			                            if((gettime()-self.bombActionTimer) > level.defuseTime*1000)
			                            {
											level.defuseObject maps\mp\gametypes\sd::onUseDefuseObject(self);
			                                level.defuseObject maps\mp\gametypes\sd::onEndUse(self.pers["team"], self, true);
			                                self.bombActionTimer = 0;
			                            }
			                        }
			                        else //not defusing yet, defuse
			                        {
										self.bombActionTimer = gettime();
			                            level.defuseObject maps\mp\gametypes\sd::onBeginUse(self);
			                        }
			                    }
			                    else //go to bomb
			                    {
                                    self PathToObjective();
                                }
			                }
			                else
			                //just find our enemies
		                    if(isDefined(self.bestTarget))
		                    {
                                //use position of nearest waypoint to enemy so not as to go wandering off
                                //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
                                tempObjectivePos = self.bestTarget.origin;
                                if(isDefined(level.waypoints) && level.waypointCount > 0)
                                {
                                    tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
                                }
                                self SetObjectivePos(tempObjectivePos);
                                self PathToObjective();
		                    }
			            }
			        }
 		            self TryPlayGame();
			    }
			    break;

			case "koth":
			
			  //if we can see our target, go into combat
			  if(self CanSeeTarget())
			  {
          self.bFaceNearestEnemy = true;
			    self.state = "combat";
          self BotGoal_ClearGoals();
			  }
			  else //otherwise play headquarters
			  {
			    //if we dont own the radio, cap it
			    if(isDefined(level.radioObject) && level.radioObject maps\mp\gametypes\_gameobjects::getOwnerTeam() != self.pers["team"])
			    {
	          distance = Distance(self.origin, level.radioObject.trigger.origin);

            if(distance > 100.0)
            {  		        
              self SetObjectivePos(level.radioObject.trigger.origin);
            }
            else
            {
              self.vObjectivePos = self.origin;
              self.buggyBotCounter = 0;
            }
            self PathToObjective();
		      }
		      else //attack enemies if we own the radio
		      {
 		        if(isDefined(self.bestTarget))
		        {
              //use position of nearest waypoint to enemy so not as to go wandering off
              //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
              tempObjectivePos = self.bestTarget.origin;
              if(isDefined(level.waypoints) && level.waypointCount > 0)
              {
                tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
              }
              self SetObjectivePos(tempObjectivePos);
              self PathToObjective();
		        }
		      }
		      
		      self TryPlayGame();
		    }
			
			  break;

			case "sab":
			
			    //if we can see our target and not trying to plant or defuse, go into combat
			    if(self CanSeeTarget() && self.bombActionTimer == 0)
			    {
                    self.bFaceNearestEnemy = true;
			        self.state = "combat";
                    self BotGoal_ClearGoals();
			    }
			    else //play sabotage
			    {
			        otherTeam = "axis";
			    
			        if(self.pers["team"] == "axis")
			        {
			            otherTeam = "allies";
			        }
			    
			        //we either own the bomb or have planted the bomb
			        if(self.pers["team"] == level.sabBomb maps\mp\gametypes\_gameobjects::getOwnerTeam())
			        {
			            //if bomb is planted, attack nearest enemy
			            if(level.bombPlanted == true)
			            {
 		                    if(isDefined(self.bestTarget))
		                    {
                                //use position of nearest waypoint to enemy so not as to go wandering off
                                //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
                                tempObjectivePos = self.bestTarget.origin;
                                if(isDefined(level.waypoints) && level.waypointCount > 0)
                                {
                                    tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
                                }
                                self SetObjectivePos(tempObjectivePos);
                                self PathToObjective();
		                    }
			            }
			            else //if i have the bomb, go to nearest bombsite and plant
			            if(isdefined(self.isBombCarrier) && self.isBombCarrier == true)
			            {
			                //get bombzone
			                nearestBombZone = level.bombZones[otherTeam];
			        
			                if(isDefined(nearestBombZone))
			                {
			                    //close enough so plant
  			                    if(distance(nearestBombZone.trigger.origin, self.origin) < 50)
			                    {
//			                        print3d(self.origin + (0,0,80), "In Range", (1,0,0), 2);
			                        //planting
			                        if(self.bombActionTimer != 0)
			                        {
										self.buggyBotCounter = 0;
			                            //planted
			                            if((gettime()-self.bombActionTimer) > level.plantTime*1000)
			                            {
			                                nearestBombZone maps\mp\gametypes\sab::onUse(self);
			                                nearestBombZone maps\mp\gametypes\sab::onEndUse(self.pers["team"], self, true);
			                                self.bombActionTimer = 0;
											//self detach("prop_suitcase_bomb", "TAG_WEAPON_LEFT");
			                            }
			                        }
			                        else //not planting yet start planting
			                        {
			                            //self attach("prop_suitcase_bomb", "TAG_WEAPON_LEFT");
										self.bombActionTimer = gettime();
			                            nearestBombZone maps\mp\gametypes\sab::onBeginUse(self);
										//self.bFaceNearestEnemy = false;
			                        }
			                    }
			                    else //too far away, go to bombsite
			                    {
//  	                            print3d(self.origin + (0,0,110), "GOING TO BOMBSITE", (1,0,0), 2);
			                        self SetObjectivePos(nearestBombZone.trigger.origin);
			                        self PathToObjective();
			                    }
			                }
			            }
			            else //check if any of my team members has the bomb
			            {
			                protectTarget = undefined;
			                for(f = 0; f < level.players.size; f++)
			                {
			                    if(!self IsEnemy(level.players[f]) && isdefined(level.players[f].isBombCarrier) && level.players[f].isBombCarrier == true)
			                    {
			                        protectTarget = level.players[f];
			                        break;
			                    }
			                }
			        
			                // if one of my team members has the bomb, shoot bad guys
			                //fixme, should make target, target nearest protect target
			                if(isDefined(protectTarget))
			                {
                                //use position of nearest waypoint to enemy so not as to go wandering off
                                //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
                                tempObjectivePos = self.bestTarget.origin;
                                if(isDefined(level.waypoints) && level.waypointCount > 0)
                                {
                                    tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
                                }
                                self SetObjectivePos(tempObjectivePos);
			                }
			        
			                //go to where we need to go
                            self PathToObjective();
			            }
			        }
			        else //other team owns the bomb
			        if(otherTeam == level.sabBomb maps\mp\gametypes\_gameobjects::getOwnerTeam())
			        {
			            if(level.bombPlanted == true)
			            {
			                //get bombzone
  		                    nearestBombZone = level.bombZones[self.pers["team"]];

			                self SetObjectivePos(nearestBombZone.trigger.origin);
			        
			                //close enough defuse
			                if(distance(self.vObjectivePos, self.origin) < 50)
			                {
			                    //defusing
			                    if(self.bombActionTimer != 0)
			                    {
			                        //self.bFaceNearestEnemy = false;
									//self thread PlantBomb();
									self.buggyBotCounter = 0;
			                        //planted
			                        if((gettime()-self.bombActionTimer) > level.defuseTime*1000)
			                        {
			                            nearestBombZone maps\mp\gametypes\sab::onUse(self);
			                            nearestBombZone maps\mp\gametypes\sab::onEndUse(self.pers["team"], self, true);
			                            self.bombActionTimer = 0;
										//self detach("prop_suitcase_bomb", "TAG_WEAPON_LEFT");
			                        }
			                    }
			                    else //not defusing yet, defuse
			                    {
			                        //level.bDefusingBomb = true;
									//self attach("prop_suitcase_bomb", "TAG_WEAPON_LEFT");
									self.bombActionTimer = gettime();
			                        nearestBombZone maps\mp\gametypes\sab::onBeginUse(self);
			                    }
			                }
			                else //go to planted bomb
			                {
                                self PathToObjective();
                            }
                        }
                        else //bomb not planted, attack enemies so they die before they can plant
                        { 
 		                    if(isDefined(self.bestTarget))
		                    {
                                //use position of nearest waypoint to enemy so not as to go wandering off
                                //zombie mods probably want to just set the objective pos as self.bestTarget.origin so they can get into melee range
                                tempObjectivePos = self.bestTarget.origin;
                                if(isDefined(level.waypoints) && level.waypointCount > 0)
                                {
                                    tempObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.bestTarget.origin)].origin;
                                }
                                self SetObjectivePos(tempObjectivePos);
                                self PathToObjective();
                            }
                        }
			        }
			        else //nobody has the bomb, go get it
			        {
		                self SetObjectivePos(level.sabBomb.trigger.origin);
                        self PathToObjective();
			        }
   		            self TryPlayGame();
  			    }
			    break;
			  
			case "followTheLeader":

        if(isDefined(self.leader))
        {
          //stop moving if too close
          if(DistanceSquared(self.origin, self.leader.origin) <= (200*200))
          {
            self BotGoal_ClearGoals();
          }
          
          //clear command if it's a follow the leader command
          if(self.leader.commandIssued == "1")
          {
            self.leader.commandIssued = "-1";
            println(self.name + " clearing follow command");
          }
        }
        
        //if we can see bad guys shoot em
			  if(self CanSeeTarget())
			  {
          self.bFaceNearestEnemy = true;
			    self.state = "combat";
          self BotGoal_ClearGoals();
			  }
			  else
			  {
    			self TryPlayGame();
			  }
			
			  break;
			  
			case "suppressingFire":
        if(isDefined(self.leader))
        {
        
          //stop moving if too close
          if(DistanceSquared(self.origin, self.leader.origin) <= (300*300))
          {
            self BotGoal_ClearGoals();
          }
          
          //clear command if it's a suppressingfire command
          if(self.leader.commandIssued == "4")
          {
            self.leader.commandIssued = "-1";
            println(self.name + " clearing suppress command");
          }
        }
        //if we can see bad guys shoot em
			  if(self CanSeeTarget())
			  {
          self.bFaceNearestEnemy = true;
			    self.state = "combat";
          self BotGoal_ClearGoals();
			  }
			  else //face suppress target and shoot
			  {
          self.bFaceNearestEnemy = false;
          
  			  targetDirection = VectorNormalize(self.suppressTarget - self.origin);
  			
			    //turn to face target
          self SetBotAngles(vectorToAngles(VectorNormalize(VectorSmooth(anglesToForward(self getplayerangles()), targetDirection, 0.25))));
          
          self thread ShootWeapon();

          direction = VectorNormalize((randomfloatrange(-1.0, 1.0), randomfloatrange(-1.0, 1.0), 0));
          safeMoveToPos = self FindSafeMoveToPos(direction, randomfloatrange(25.0, 75.0));
          moveSpeed = 3.0;
          
          //move
          self BotMove(safeMoveToPos, moveSpeed);
          
          //dodging so wait a while
          wait randomfloatrange(0.3, 0.6);

    			self TryPlayGame();
			  }
        
		    break;
		    
		   
		    

	  };
	  
    if(CanDebugDraw())
    {
	    //debug
      print3d(self.origin + (0, 0, 75), "STATE: " + self.state, (1,0,0), 2);
      print3d(self.origin + (0, 0, 65), "GOAL: " + self.currentGoal, (1,0,0), 2);
      print3d(self.vObjectivePos, self.name + " ObjectivePos", (1,0,0), 2);
      print3d(self.origin + (0, 0, 85), "weapon: " + self GetCurrentWeapon(), (1,0,0), 2);
      print3d(self.origin + (0, 0, 95), "movespeed: " + self.fMoveSpeed, (1,0,0), 2);
      print3d(self.origin + (0, 0, 105), "currentStaticWP: " + self.currentStaticWp, (1,0,0), 2);
      
      
    }
    
	  wait 0.01;
	}

}


////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
CanMove(from, direction, distance)
{
  //ray cast against everything
  trace = bulletTrace(from, from + (direction * distance), true, self);

  //line to collision is red
//  line(from, trace["position"], (1,0,0));

//  print3d( self.origin + ( 0, 0, 65 ),"Fraction " + trace["fraction"], (1,0,0), 2);
 
  return (trace["fraction"] == 1.0);
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
ClampToGround()
{
	self endon( "disconnect" );

  while(1)
  {
    if(self.bClampToGround)
    {
      trace = bulletTrace(self.origin + (0,0,50), self.origin + (0,0,-200), false, self);

//      line(self.origin + (0,0,50), trace["position"], (1,0,1));
  
      if(trace["fraction"] < 1 && !isdefined(trace["entity"]))
      {
        //smooth clamp
        self SetOrigin(trace["position"]);
//        self.attachmentMover.origin = trace["position"];// + (0.0, 5.0, 0.0);
      }
    }
    wait 0.001;
  }
}

////////////////////////////////////////////////////////////
// stops shooting by freezing controls
////////////////////////////////////////////////////////////
StopShooting()
{
  self notify("StopShooting");
  self freezecontrols(true);
  self.bShooting = false;
  self.bThrowingGrenade = false;
}

////////////////////////////////////////////////////////////
// noob hax, this just lets the test client jiggle happen for a bit so it can shoot
// fix this later, its BAAD MMKAY
///////////////////////////////////////////////////////////
ShootWeapon()
{
	self endon("StopShooting");
	self endon("disconnect");
	self endon("killed_player");
	
  if(self.bShooting || self.state == "climb"/* || level.gameEnded/* || level.inPrematchPeriod*/)
  {
    self.bShooting = false;
	return;
  }
  
//  println("enter shoot");

  self.pers["weapon"] = self.actualWeapon;
  self giveweapon(self.pers["weapon"]);
//      self givemaxammo(self.pers["weapon"]);
  self SetWeaponAmmoClip(self.pers["weapon"], 30);
  self SetWeaponAmmoStock(self.pers["weapon"], 0);
  self setspawnweapon(self.pers["weapon"]);
	self switchtoweapon(self.pers["weapon"]);

  
  if(isDefined(self.pers["weapon"]))
  {
    skill = Clamp(0.0, getdvarFloat("svr_pezbots_skill"), 1.0);
    
//    self givemaxammo(self.pers["weapon"]);
    
    self freezecontrols(false);
    self.bShooting = true;
    wait 0.1+(skill*0.3);
    self freezecontrols(true);
    self.bShooting = false;
  }
  
  self notify("StopShooting");
  
//  println("exit shoot");
  
}

////////////////////////////////////////////////////////////
// noob hax, this just lets the test client jiggle happen for a bit so it can shoot
// fix this later, its BAAD MMKAY
///////////////////////////////////////////////////////////
ThrowGrenade(dist)
{
	self endon("StopShooting");
	self endon("disconnect");
	self endon("killed_player");
	
    if(self.bThrowingGrenade/* || level.gameEnded/* || level.inPrematchPeriod*/)
    {
        return;
    }
  
    self BotGoal_ClearGoals();
  
	if(randomInt(5) == 1)
    {
	    self SetAnim("rpg_mp", "stand", "grenade");
	}
	else if(randomInt(5) == 2)
    {
	    self SetAnim("smoke_mp", "stand", "grenade");
	}
	else if(randomInt(5) == 3)
    {
	    self SetAnim("flash_mp", "stand", "grenade");
	}
	else if(randomInt(5) == 4)
    {
	    self SetAnim("concussion_mp", "stand", "grenade");
	}
	else
    {
	    self SetAnim("frag_mp", "stand", "grenade");
	}

    self.bThrowingGrenade = true;
    self freezecontrols(false);
    wait 0.75;
    self freezecontrols(true);
    self.bThrowingGrenade = false;

    self SetAnim(self.weaponPrefix, "stand", "walk");

    self notify("StopShooting");
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
StabKnife(dist, target)
{
	self endon("StopShooting");
	self endon("disconnect");
	self endon("killed_player");
	self endon("dead");
	
    if(self.bShooting)
    {
		return;
    }
  
    self BotGoal_ClearGoals();

	target.position = target.origin + common_scripts\utility::vectorScale(anglesToForward(target.angles),55);
	self giveweapon("knife_pezbot_mp");
	self SetWeaponAmmoClip("knife_pezbot_mp", 1);
	self setspawnweapon("knife_pezbot_mp");
	self switchtoweapon("knife_pezbot_mp");
	
	self.pers["weapon"] = "knife_pezbot_mp";
    self giveweapon(self.pers["weapon"]);
    self SetWeaponAmmoClip(self.pers["weapon"], 1);
    self SetWeaponAmmoStock(self.pers["weapon"], 0);
    self setspawnweapon(self.pers["weapon"]);
	self switchtoweapon(self.pers["weapon"]);

	self.bShooting = true;
	wait 0.4;
	self playsound("melee_knife_stab");
	wait 0.4;
	if(target.sessionstate == "playing") target thread [[level.callbackPlayerDamage]](self, self, 100, 0, "MOD_MELEE", self.actualWeapon, self.origin, self.origin, "none", 0);

    self freezecontrols(true);
	self.bShooting = false;
    self SetAnim(self.weaponPrefix, "stand", "walk");

    self notify("StopShooting");
}

////////////////////////////////////////////////////////////
// returns true if attacker attacked me
///////////////////////////////////////////////////////////
AttackedMe(attacker)
{
  if(!isDefined(self.attackers))
  {
    return false;
  }
  
  if(isDefined(self.murderer) && self.murderer == attacker)
  {
//    print3d(self.origin + (0,0,100), "Chasing MURDERER", (0,0,1), 4);
    return true;
  }
  
  for(i = 0; i < self.attackers.size; i++)
  {
    if(isDefined(self.attackers[i]) && self.attackers[i] == attacker)
    {
      return true;
    }
  }
  
  return false;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
SetBotAngles(angles)
{
    self setplayerangles(angles);

}

////////////////////////////////////////////////////////////
// will try target nearest enemy
// if someone is attacking the bot, and the bot can see its attacker, it will use that target
///////////////////////////////////////////////////////////
TargetBestEnemy()
{
	self endon( "disconnect" );
  
    while(1)
    {
		players = getentarray("player", "classname");
		nearestTarget = undefined;
		self.hasChopperTarget = undefined;
		nearestDistance = 9999999999;
		
		if(players.size > 0/* && (!level.gameEnded/* || !level.inPrematchPeriod)*/)
		{
		    for(i = 0; i < players.size; i++)
		    {
			    player = players[i];
			    if(self IsEnemy(player) && isdefined(player.sessionstate) && player.sessionstate == "playing")
			    {
			        tempDist = DistanceSquared(self.origin, player.origin);
			        //if closer or attacked me and can see, then set nearest
			        if(tempDist < nearestDistance || (self AttackedMe(player) && self CanSee(player)))
			        {
			            self.hasChopperTarget = false;
						if(isDefined(nearestTarget))
			            {   //if something has shot at me and i can see it, dont wanna go any further
			                if(!(self AttackedMe(nearestTarget) && self CanSee(nearestTarget)))
			                {
			                    nearestDistance = tempDist;
			                    nearestTarget = player;
								self.hasChopperTarget = false;
			                }
			            }
			            else //just set nearest target
			            {
			                nearestDistance = tempDist;
			                nearestTarget = player;
							self.hasChopperTarget = false;
			            }
			        }
					else
					if((!self AttackedMe(player) && !self CanSee(player)) && isdefined(level.chopper) && self CanSee(level.chopper) && (level.chopper.currentstate != "leaving" || level.chopper.currentstate != "crashing"))
					{
					    tempChopperDist = Distance(self.origin, level.chopper.origin);
						if(tempChopperDist < 4000 && self IsEnemyChopper())
						{
						    nearestDistance = tempDist;
			                nearestTarget = player;
							level.chopper.position = level.chopper.origin + common_scripts\utility::vectorScale(anglesToForward(level.chopper.angles),55);
							self.hasChopperTarget = true;
						}
						else //just set nearest target
			            {
			                nearestDistance = tempDist;
			                nearestTarget = player;
							self.hasChopperTarget = false;
			            }
					}
			    }
			}
		  
		    self.bestTarget = nearestTarget;
		
		    //only face if allowed
            if(self.bFaceNearestEnemy && isdefined(self.bestTarget) && !self IsStunned()/*  && (!level.gameEnded || !level.inPrematchPeriod)*/)
            {
                skillBias = 0.0;
				if(self.hasChopperTarget)
				{
				    targetPos = level.chopper.position + (0,0,-15);
					self.hasChopperTarget = false;
					skill = 1;
				}
				else
				{
				    targetPos = self.bestTarget GetTargetablePos();
				
				    //trace to see if we can actually see our target, if not decrease accuracy heaps
                    visTrace = bullettrace(self GetEyePos(), self.bestTarget GetEyePos(), false, self);
                    if(visTrace["fraction"] != 1)
                    {
                        skillBias = 2.0;        

                        //get more innacurate over time
                        if(isDefined(self.rememberedTarget))
                        {
	                        skillBias = 2.0 + ((gettime() - self.fTargetMemory) / 3000) * 10.0;
	                    }
                    }
					skill = ((1.0 - Clamp(0.0, getdvarFloat("svr_pezbots_skill"), 1.0)) * 5.0) + skillBias;
				}
        
		        //calc direction of nearest target
			    targetDirection = VectorNormalize(targetPos - self GetEyePos());
        
                angles = vectorToAngles(VectorNormalize(VectorSmooth(anglesToForward(self getplayerangles()), targetDirection, 0.25)));
                //spray and pray depending on skill
                if(skill > 0 && self.bShooting && self.hasChopperTarget)
				{
				    angles = angles;
				}
				else
				if(skill > 0 && self.bShooting)
                {
                    angles = (angles[0]+randomfloatrange(skill*-1.0, skill), angles[1]+randomfloatrange(skill*-1.0, skill), angles[2]+randomfloatrange(skill*-1.0, skill));
                }
        
                self SetBotAngles(angles);
			}
	    }	
        wait 0.1;
    }
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
BotMove(_vMoveTarget, _fMoveSpeed)
{
  //cancel any previous moves
  self notify( "BotMovementComplete" );

  //regular cheap movement  
	self.vMoveTarget = _vMoveTarget;
	self.fMoveSpeed =  _fMoveSpeed;
	self.fBaseMoveSpeed = self.fMoveSpeed;
	dist = undefined;
	//calc move direction
	moveDirection = VectorNormalize(self.vMoveTarget - self.origin);
	if(isdefined(self.bestTarget) && isdefined(self.bestTarget.origin)) dist = distance(self.bestTarget.origin, self.origin);
	//get forward direction
  forward = anglesToForward(self getplayerangles());	

  //set new anim
  newMoveType = "idle";
  
  //get dot between forward and our move direction
  dot = vectordot(forward, moveDirection);

  if(1)  
  {
	//running
    if(_fMoveSpeed > 8.5 && self.stance != "crouch"  || self.state != "climb")
    {
      if(isdefined(dist) && dist >= self.botRunDist)
	  {
	    newMoveType = "run";
		self.stance = "stand";
	  }
	  else
	  {
	    newMoveType = "walk";
	  }
    
	}
    //else //walking
    //{
    //  newMoveType = "walk";
    //}
	else
	if(self.state == "climb")
    {
        self.stance = "climb";
        newMoveType = "up";
        self.bClampToGround = false;
    }
	else
	if(self.state == "idle")
    {
        self.stance = "stand";
        newMoveType = "craim";
        self.bClampToGround = true;
    }
    else //walking
    {
      newMoveType = "walk";
    }
  }


  //climbing  
  if(self.state == "climb")
  {
    self.stance = "climb";
    newMoveType = "up";
    self.bClampToGround = false;
  }
  
  //play correct anim for movement
	self SetAnim(self.weaponPrefix, self.stance, newMoveType);
	
	//start move thread
  self thread BotMoveThread();
  
  if(self.state != "climb")
  {
    //start movement monitor thread
    self thread MonitorMovement();
  }

}

////////////////////////////////////////////////////////////
// push self out of other players
///////////////////////////////////////////////////////////
PushOutOfPlayers()
{
  //Commented out as of 006p to prevent bots getting stuck
  //zombie mods probably want to re-enable this

/*
  //push out of other players
  players = level.players;
  for(i = 0; i < players.size; i++)
  {
    player = players[i];
    
    if(player == self)
      continue;
      
    distance = distance(player.origin, self.origin);
    minDistance = 30;
    if(distance < minDistance) //push out
    {
      
      pushOutDir = VectorNormalize((self.origin[0], self.origin[1], 0)-(player.origin[0], player.origin[1], 0));
      trace = bulletTrace(self.origin + (0,0,20), (self.origin + (0,0,20)) + (pushOutDir * ((minDistance-distance)+10)), false, self);

      //debug
      if(CanDebugDraw())
      {
        print3d(self.origin + (0, 0, 85), "PUSHOUT " + distance, (1,0,0), 2);
        line(self.origin + (0,0,20), (self.origin + (0,0,20)) + (pushOutDir * ((minDistance-distance)+10)), (1,0,0));
      }
      
      //no collision, so push out
      if(trace["fraction"] == 1)
      {
        pushoutPos = self.origin + (pushOutDir * (minDistance-distance));
        self SetOrigin((pushoutPos[0], pushoutPos[1], self.origin[2])); 
//        self.attachmentMover.origin = (pushoutPos[0], pushoutPos[1], self.origin[2]);
      }
    }
  }
*/
}

////////////////////////////////////////////////////////////
// Monitors the movement speed and anim based on direction
///////////////////////////////////////////////////////////
MonitorMovement()
{
	self endon("BotMovementComplete");
	self endon("disconnect");
	self endon("killed_player");
    self endon("BotReset");

    while(1)
    {
	    //calc move direction
	    moveDirection = VectorNormalize(self.vMoveTarget - self.origin);
  	    dist = undefined;
	    //get forward direction
        forward = anglesToForward(self getplayerangles());	
        if(isdefined(self.bestTarget) && isdefined(self.bestTarget.origin)) dist = distance(self.bestTarget.origin, self.origin);
        //get dot between forward and our move direction
        dot = vectordot(forward, moveDirection);
    
        self.fMoveSpeed = self.fBaseMoveSpeed;
        newMoveType = "walk";

		if(1)    
		{
			if(self.bPlantingBomb)
			{
				self.stance = "stand";
				newMoveType = "plant";
				//wait 0.05;
			}
			else
			if(self.stance == "climb")
			{
			
			}
			
			//running
			else
			if(self.fBaseMoveSpeed > 8.5 && self.stance != "crouch")
			{
				if(isdefined(dist) && dist >= self.botRunDist)
				{
				   newMoveType = "run";
				   self.fMoveSpeed = 9.0;
				}
				else
				{
				   newMoveType = "walk";
				   self.fMoveSpeed = self.botwalkspeed;
				}
			}
			else //walking
			{
				newMoveType = "walk";
				self.fMoveSpeed = self.botwalkspeed;
			}
		}

    //shooting, move sloooow
    if(self.bShooting)
    {
        self.fMoveSpeed = 3.0;
    }    

    if(!self.bThrowingGrenade)
    {
        //play correct anim for movement
	    self SetAnim(self.weaponPrefix, self.stance, newMoveType);
	}

    wait 0.2;
  }

}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
BotMoveThread()
{
	self endon("BotMovementComplete");
	self endon("disconnect");
	self endon("killed_player");
  self endon("BotReset");
  
  if(self.bPlantingBomb)
  {
     self notify( "BotMovementComplete" );
	 //self thread PlantBomb();
  }
  
  while(1)
  {
    if(self IsStunned()/* || level.gameEnded || level.inPrematchPeriod*/)
    {
      self notify( "BotMovementComplete" );
    }
	
  
//    moveTarget = (self.vMoveTarget[0], self.vMoveTarget[1], self.origin[2]);
    moveTarget = self.vMoveTarget;
    distance = Distance(moveTarget, self.origin);
    if(distance <= self.fMoveSpeed)
    {
//      self.attachmentMover.origin = moveTarget;
      self SetOrigin(moveTarget);
      self PushOutOfPlayers();
      self notify( "BotMovementComplete" );
    }
    else
    {
      //move
//      self.attachmentMover.origin = self.origin + (VectorNormalize(moveTarget-self.origin) * self.fMoveSpeed);
      self SetOrigin(self.origin + (VectorNormalize(moveTarget-self.origin) * self.fMoveSpeed));
      self PushOutOfPlayers();
    }
    wait 0.05;
  }
}

////////////////////////////////////////////////////////////
// smooth between two vectors by factor 'fFactor' in the form (vC = (vA * (1-factor)) + (vB * factor));)
///////////////////////////////////////////////////////////
VectorSmooth(vA, vB, fFactor)
{
  fFactorRecip = 1.0-fFactor;
  
  vRVal = ((vA * fFactorRecip) + (vB * fFactor));
  
  return vRVal;
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
IsEnemyChopper()
{

  if(level.chopper.pers["team"] != self.pers["team"])
  {
    return (true);
  }
  
  return (false);
}

////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
IsEnemy(player)
{

  if(player != self && player.sessionteam != "spectator" && player.pers["team"] != "spectator" && (player.pers["team"] != self.pers["team"] || getdvar("g_gametype") == "dm"))
  {
    return (true);
  }
  
  return (false);
}


////////////////////////////////////////////////////////////
// finds a safe spot to move to in the direction specified
///////////////////////////////////////////////////////////
FindSafeMoveToPos(direction, distance)
{
	from = self.origin + (0,0,20);
	bCanMove = false;
	//try move in direction 
  if(CanMove(from, direction, distance))
  {
    bCanMove = true;
  }
  else // try strafe
  {
    //get right direction from cross product
    direction = VectorCross(direction, (0,0,1));
    
    //dont always strafe right
    direction = direction * ((RandomInt(2) - 0.5) * 2.0);
    
    //halve distance for tight areas
    distance = distance * 0.5;
    
    //try strafe 
    if(CanMove(from, direction, distance))
    {
      bCanMove = true;
    }
    else //try strafe opposite direction
    {
      direction = direction * -1.0;
      if(CanMove(from, direction, distance))
      {
        bCanMove = true;
      }
    }
  }

  safePos = self.origin;
  
  //woohoo, i can move
  if(bCanMove)
  {
    safePos = self.origin + (direction*distance);
  }
  
  return (safePos);
}

////////////////////////////////////////////////////////////
// Starts a bot goal thread
///////////////////////////////////////////////////////////
BotGoal_EnterGoal(goal)
{
  if(isdefined(self.currentGoal) && self.currentGoal == goal)
  {
    return;
  }

//  println("Entering Goal" + goal);

  //clear all active goals so they dont fight with eachother (can probably fix this)
  self BotGoal_ClearGoals();

  //make sure we know what goal we are in  
  self.currentGoal = goal;
  
  switch(goal)
  {
    case "MeleeCombatGoal":
      self thread BotGoal_MeleeCombatGoal();
      break;  
      
    case "DynWaypointFollowGoal":
      self thread BotGoal_DynWaypointFollowGoal();
      break;  
      
    case "StaticWaypointFollowGoal":
      self thread BotGoal_StaticWaypointFollowGoal();
      break;  
      
      
  };

}

////////////////////////////////////////////////////////////
// Ends all current goal threads
///////////////////////////////////////////////////////////
BotGoal_ClearGoals()
{
  self notify ( "MeleeCombatGoalComplete" );
  self notify ( "DynWaypointFollowGoalComplete" );
  self notify ( "StaticWaypointFollowGoalComplete" );
  self.currentStaticWp = -1;
  self.currentGoal = "none";
}

////////////////////////////////////////////////////////////
// Melee combat goal for bot (Stabs, keeps in range etc)
///////////////////////////////////////////////////////////
BotGoal_MeleeCombatGoal()
{
  self endon ( "MeleeCombatGoalComplete" );
	self endon( "disconnect" );
	self endon("killed_player");
  
  while(1)
  {
    //stay in range
    if(isDefined(self.bestTarget))
    {
      //FIXME: should do both of these in the one function
      targetRange = Distance(self.bestTarget.origin, self.origin);
      direction = VectorNormalize(self.bestTarget.origin - self.origin);

      safeMoveToPos = self.origin;
      moveSpeed = 12.0;
      
      //too far away get closer
      if(targetRange > 100)
      {
        safeMoveToPos = self FindSafeMoveToPos(direction, 50.0);
        //move
        self BotMove(safeMoveToPos, moveSpeed);
      }
      else //in range, stabbage
      {
           wait randomfloatrange(0.05, 0.10);
			self thread StabKnife();
			//self waittill("StopKnifing");
      }
      
    }
    wait 0.1;
  }
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
ClampWpToGround(wpPos)
{
  trace = bulletTrace(wpPos, wpPos + (0,0,-300), false, undefined);
  
  if(trace["fraction"] < 1)
  {
    return trace["position"] + (0,0,30);
  }
  else
  {
    //probably under the ground, trace up
    trace = bulletTrace(wpPos, wpPos + (0,0,20), false, undefined);
    if(trace["fraction"] < 1)
    {
      return trace["position"] + (0,0,30);
    }
    else
    {
      return wpPos;
    }
  }

}

////////////////////////////////////////////////////////////
// Clamp a in between min and max
////////////////////////////////////////////////////////////
Clamp(min, a, max)
{
  return max(min(a, max), min);
}

////////////////////////////////////////////////////////////
// Builds a dynamic list of waypoints for the bot to follow, uses brute force wall following, 
// looks for exits nearest target direction, HAX!!! etc... ;)
// This function is still kinda bruteforce and dodgy but it will do for now :D
////////////////////////////////////////////////////////////
BuildDynWaypointList()
{

  self.dynWaypointCount = 0;
  self.currDynWaypoint = 0;

  from = self.origin + (0,0,30);
//  direction = anglesToForward(self getplayerangles());
  enemydirection = VectorNormalize(self.vObjectivePos - from);
  direction = enemydirection;
  distance = 30.0;
  self.dynWaypointList = [];
  bCanTurnToTarget = true; // if true we can turn to try go towards our target
  maxWaypointCount = randomintrange(40, 60);
  lastWallDirection = (1,0,0);
  bValidLastWallDirection = false;
  
  while(self.dynWaypointCount < maxWaypointCount)
  {
    
    //add a waypoint
    self.dynWaypointList[self.dynWaypointCount] = ClampWpToGround(from);
    self.dynWaypointCount++;
  
    trace = bulletTrace(from, from + (direction * distance), false, self);

    enemydirection = VectorNormalize(self.vObjectivePos - from);
    
    //didnt hit keep moving
    if(trace["fraction"] == 1)
    {
      from = trace["position"];
      
      //add a waypoint
      self.dynWaypointList[self.dynWaypointCount] = ClampWpToGround(from);
      self.dynWaypointCount++;
      
      //move towards target
      if(bCanTurnToTarget)
      {
        direction = enemydirection;
        bValidLastWallDirection = false;
      }
      else //see if we need to keep following wall
      {
        //try keep following wall
        if(bValidLastWallDirection)
        {
          //trace
          trace = bulletTrace(from, from + (lastWallDirection * distance * 2.0), false, self);
          
          //wall no longer there, head that way
          if(trace["fraction"] == 1)
          {
            direction = lastWallDirection;
            from = trace["position"];
            dot = vectorDot(enemydirection, direction);
            if(dot > 0.5)
            {
              bCanTurnToTarget = true;
            }
            bValidLastWallDirection = false;
          }
        }
        else //still next to wall keep going straight ahead
        {
          bCanTurnToTarget = false;
        }
      }
    }
    else // hit something, navigate around it
    {
      //dont turn to target we need to navigate around collision    
      bCanTurnToTarget = false;
      
      //get collision normal and position    
      colNormal = trace["normal"];
      colPos = trace["position"];
        
      //move out from collision
//      from = colPos + (colNormal * 20.0);
      from = colPos + (VectorNormalize(VectorSmooth(direction * -1.0, colNormal, 0.5)) * 20.0); //normals are dodgy, especially on corrigated iron, use a fake normal
      
      tanDirection = VectorCross(direction * -1.0, (0,0,1));
      //tanDirection = VectorCross(colNormal, (0,0,1));

      //we were already traveling along a wall, pick tangent direction that keeps us going forwards
      if(bValidLastWallDirection)
      {
        dot = vectordot(lastWallDirection * -1.0, tanDirection);
        
        if(dot < 0)
        {
          tanDirection = tanDirection * -1.0;
        }
        
        lastWallDirection = colNormal * -1.0;
        bValidLastWallDirection = true;
        direction = tanDirection;
      }
      else //choose direction that best matches target dir
      {
        dot = vectordot(enemydirection, tanDirection);
        
        if(dot < 0)
        {
          tanDirection = tanDirection * -1.0;
        }
        
        lastWallDirection = colNormal * -1.0;
        bValidLastWallDirection = true;
        direction = tanDirection;
      }
    }
   
    //end of waypoint list
    if(Distance(self.vObjectivePos, from) <= (distance+5.0))
    {
      return true; 
    }
    
  }
    
  return true;
}

////////////////////////////////////////////////////////////
// Dynamic waypoint follow goal, follows a dynamically generated list of waypoints
///////////////////////////////////////////////////////////
BotGoal_DynWaypointFollowGoal()
{
  self endon ( "DynWaypointFollowGoalComplete" );
	self endon( "disconnect" );
	self endon("killed_player");
  
  //build waypoint list
  self BuildDynWaypointList();
  
  while(1)
  {
    tempWp = (self.dynWaypointList[self.currDynWaypoint][0], self.dynWaypointList[self.currDynWaypoint][1], self.origin[2]);

    //prevent enemy facing
    if(self CanSeeTarget())
    {
      self.bFaceNearestEnemy = true;
    }
    else
    {
      self.bFaceNearestEnemy = false;
      //face movement direction        
      self SetBotAngles(vectorToAngles(VectorNormalize(VectorSmooth(anglesToForward(self getplayerangles()), VectorNormalize(tempWp-self.origin), 0.5))));
    }
    
    distToWp = Distance(tempWp, self.origin);

    if(distToWp <= (self.fMoveSpeed+5.0))
    {
      self.currDynWaypoint++;
      
      if(self.currDynWaypoint >= self.dynWaypointCount)
      {
        self.currentGoal = "none";
        self notify ( "DynWaypointFollowGoalComplete" );
      }
      else
      {
        tempWp = (self.dynWaypointList[self.currDynWaypoint][0], self.dynWaypointList[self.currDynWaypoint][1], self.origin[2]);
       

          self BotMove(tempWp, 4.0);

      }
    }
	
    if(level.botbattlechatter && self.pers["team"] == "axis")
	{
	    self.throwg = randomInt(1000);
	    if(self.throwg == 74)
	    {
		    self thread soundIdleChatter();
			self.throwg = [];
	    }
	}
    //draw waypointlist
    self DrawDynWaypointList();
    wait 0.01;
  }
}

////////////////////////////////////////////////////////////
// debug draw dynamic waypoint list
////////////////////////////////////////////////////////////
DrawDynWaypointList()
{
  if(CanDebugDraw())
  {
    for(i = 0; i < self.dynWaypointCount-1; i++)
    {
      line(self.dynWaypointList[i], self.dynWaypointList[i] + (0,0,200), (1,1,0));
      line(self.dynWaypointList[i], self.dynWaypointList[i+1], (0,1,1));
    }

    line(self.dynWaypointList[self.dynWaypointCount-1], self.dynWaypointList[self.dynWaypointCount-1] + (0,0,200), (1,1,0));
  }
}

////////////////////////////////////////////////////////////
// static waypoint implementation
// 1. Array of waypoints, each waypoint has a type (stand, crouch, prone, camp, climb, etc), and a position on the ground.
// 2. Array of connectivity, list of children for each waypoint
// Reasoning: Easy to find closest waypoint, and traverse children using connectivity
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// converts a string into a float
////////////////////////////////////////////////////////////
atof(string)
{
  setdvar("temp_float", string);
  return getdvarfloat("temp_float");
}

////////////////////////////////////////////////////////////
// converts a string into an integer
////////////////////////////////////////////////////////////
atoi(string)
{
  setdvar("temp_int", string);
  return getdvarint("temp_int");
}

////////////////////////////////////////////////////////////
// Loads static waypoint list from file
////////////////////////////////////////////////////////////
LoadStaticWaypoints()
{
  filename = "PeZBOT_" + tolower(getdvar("mapname")) + "_WP.csv";
  
  compiledFilename = "waypoints/PeZBOT_WP_0.csv";
  level.waypointCount = 0;
  level.waypoints = [];
  
  iLineOffset = 0;
  string = TableLookup(compiledFilename, 0, 0, 1);
//  println("read '" + string + "'");
  iWPFileCount = int(string);
  
  for(i = 0; i < iWPFileCount; i++)
  {
    string = TableLookup(compiledFilename, 0, i+1, 3);
//    println("read '" + string + "'");
    
    if(string == filename)
    {
      string = TableLookup(compiledFilename, 0, i+1, 2);
      iLineOffset = int(string);
      break;
    }
  }
  
  if(iLineOffset == 0)
  {
    println("Map does not support PeZBOT waypoints");
    return;
  }
  
  for(i = 0; i < iWPFileCount; i++)
  {
    compiledFilename = "waypoints/PeZBOT_WP_" + i + ".csv";
    println("reading '" + compiledFilename);

    string = TableLookup(compiledFilename, 0, iLineOffset, 1);
//    println("read '" + string + "'");
      
    if(string != "")
    {
      break;
    }
  }
    
  while(1)
  {
    string = TableLookup(compiledFilename, 0, iLineOffset+level.waypointCount, 1);
    
//    println("read '" + string + "'");
    
    if(!isDefined(string) || string == "" || string == "end")
    {
      if(!isDefined(string) || string == "")
      {
        println("Map does not support PeZBOT waypoints");
      }
      else
      {
        println("PeZBOT waypoints loaded successfully");
      }
      return;
    }
    
    //new waypoint
    level.waypoints[level.waypointCount] = spawnstruct();
  
		tokens = strtok(string, " ");

    //read origin
		level.waypoints[level.waypointCount].origin = (atof(tokens[0]), atof(tokens[1]), atof(tokens[2]));

    string = TableLookup(compiledFilename, 0, iLineOffset+level.waypointCount, 2);
//    println("read '" + string + "'");
		tokens = strtok(string, " ");

		
		//read in child connectivity
		level.waypoints[level.waypointCount].children = [];
		level.waypoints[level.waypointCount].childCount = 0;
		level.waypoints[level.waypointCount].childCount = tokens.size;
		for(i = 0; i < level.waypoints[level.waypointCount].childCount; i++)
		{
		  level.waypoints[level.waypointCount].children[i] = atoi(tokens[i]);
		}

    //read Type
    level.waypoints[level.waypointCount].type = TableLookup(compiledFilename, 0, iLineOffset+level.waypointCount, 3);

    //increment waypoint counter
    level.waypointCount++;
  }
}

////////////////////////////////////////////////////////////
// debug draw spawns, domination flags, hqs, bombs etc..
////////////////////////////////////////////////////////////
DrawLOI(pos, code)
{

  line(pos + (20,0,0), pos + (-20,0,0), (1,0.75, 0));
  line(pos + (0,20,0), pos + (0,-20,0), (1,0.75, 0));
  line(pos + (0,0,20), pos + (0,0,-20), (1,0.75, 0));
  
  Print3d(pos, code, (1,0,0), 4);

}

////////////////////////////////////////////////////////////
// debug draw static waypoint list
////////////////////////////////////////////////////////////
DrawStaticWaypoints()
{
  while(1)
  {
    if(CanDebugDraw() && isDefined(level.waypoints) && isDefined(level.waypointCount) && level.waypointCount > 0)
    {
      wpDrawDistance = getdvarint("svr_pezbots_WPDrawRange");
    
      for(i = 0; i < level.waypointCount; i++)
      {
        if(isdefined(level.players) && isdefined(level.players[0]))
        {
          distance = distance(level.players[0].origin, level.waypoints[i].origin);
          if(distance > wpDrawDistance)
          {
            continue;
          }
        }
      
		color = (0,0,1);

        //red for unlinked wps
        if(level.waypoints[i].childCount == 0)
        {
          color = (1,0,0);
        }
        else
        if(level.waypoints[i].childCount == 1) //purple for dead ends
        {
          color = (1,0,1);
        }
        else
		if(level.waypoints[i].type == "climb") //yellow for climbing
        {
          color = (1,1,0);
        }
		else //green for linked
        {
          color = (0,1,0);
        }


        if(isdefined(level.players) && isdefined(level.players[0]))
        {
          distance = distance(level.waypoints[i].origin, level.players[0].origin);
          if(distance <= 30.0)
          {
            strobe = abs(sin(gettime()/10.0));
            color = (color[0]*strobe,color[1]*strobe,color[2]*strobe);
          }
        }

        line(level.waypoints[i].origin, level.waypoints[i].origin + (0,0,80), color);
        
        for(x = 0; x < level.waypoints[i].childCount; x++)
        {
          line(level.waypoints[i].origin + (0,0,5), level.waypoints[level.waypoints[i].children[x]].origin + (0,0,5), (0,0,1));
        }
//        print3d(level.waypoints[i].origin + (0,0,90), "Type: " + level.waypoints[i].type, (1,1,1), 2);
//        print3d(level.waypoints[i].origin + (0,0,100), "Pos: " + level.waypoints[i].origin[0] + ", " + level.waypoints[i].origin[1] + ", " + level.waypoints[i].origin[2], (1,1,1), 2);
//        print3d(level.waypoints[i].origin + (0,0,110), "Index: " + i, (1,1,1), 2);
      }
	  
	    if(isdefined(level.killpoints))
		{
			for(i = 0; i < level.killpointCount; i++)
			{
				if(isdefined(level.players) && isdefined(level.players[0]))
				{
					distance = distance(level.players[0].origin, level.killpoints[i].origin);
					//height = distance(level.players[0].origin[2], level.waypoints[i].origin[2]);
					if(distance > wpDrawDistance)
					{
						continue;
					}
				}
				
				color = (0,0,1);

				//red for unlinked wps
				if(level.killpoints[i].childCount == 0)
				{
					color = (0,0,0);
				}
				else
				if(level.killpoints[i].childCount == 1) //purple for dead ends
				{
					color = (1,0,1);
				}
				else //green for linked
				{
					color = (0,1,0);
				}

				if(isdefined(level.players) && isdefined(level.players[0]))
				{
					distance = distance(level.players[0].origin, level.killpoints[i].origin);
					if(distance <= 50.0)
					{
						strobe = abs(sin(gettime()/10.0));
						color = (color[0]*strobe,color[1]*strobe,color[2]*strobe);
					}
				}

				line(level.killpoints[i].origin, level.killpoints[i].origin + (0,0,80), color);
		
				for(x = 0; x < level.killpoints[i].childCount; x++)
				{
					line(level.killpoints[i].origin + (0,0,5), level.killpoints[level.killpoints[i].children[x]].origin + (0,0,5), (0,0,1));
				}
			}
			//DrawSpawnPoints(getentarray(level.killpoints, "classname"), "Killpoint");
		}
  
      
      //draw spawnpoints  
      DrawSpawnPoints(getentarray("mp_sab_spawn_axis", "classname"), "sabS");
      DrawSpawnPoints(getentarray("mp_sab_spawn_allies", "classname"), "sabS");
      DrawSpawnPoints(getentarray("mp_sab_spawn_axis_start", "classname"), "sabS");
      DrawSpawnPoints(getentarray("mp_sab_spawn_allies_start", "classname"), "sabS");
      DrawSpawnPoints(getentarray("mp_sd_spawn_attacker", "classname"), "sdS");
      DrawSpawnPoints(getentarray("mp_sd_spawn_defender", "classname"), "sdS");
      
      DrawSpawnPoints(getentarray("mp_dm_spawn", "classname"), "dmS");
      DrawSpawnPoints(getentarray("mp_tdm_spawn", "classname"), "tdmS");
      DrawSpawnPoints(getentarray("mp_dom_spawn", "classname"), "domS");

      //draw domination flags
	    DrawSpawnPoints(getEntArray("flag_primary", "targetname"), "F");
	    DrawSpawnPoints(getEntArray("flag_secondary", "targetname"), "F");

      //draw radios
      DrawSpawnPoints(getentarray("hq_hardpoint", "targetname"), "R");

      //draw bombzones
      DrawSpawnPoints(getEntArray("bombzone", "targetname"), "B");
      DrawSpawnPoints(getEntArray("sab_bomb_axis", "targetname"), "B");
      DrawSpawnPoints(getEntArray("sab_bomb_allies", "targetname"), "B");
    }
    wait 0.001;
  }
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
DrawSpawnPoints(spawnpoints, code)
{
  if(isdefined(spawnpoints))
  {
	  for(i = 0; i < spawnpoints.size; i++)
	  {
		  spawnpoint = spawnpoints[i];

      DrawLOI(spawnpoint.origin, code);
    }
  }
}

////////////////////////////////////////////////////////////
// returns an index to the nearest static waypoint
////////////////////////////////////////////////////////////
GetNearestStaticWaypoint(pos)
{
    if(!isDefined(level.waypoints) || level.waypointCount == 0)
    {
        return -1;
    }

    nearestWaypoint = -1;
    nearestDistance = 9999999999;
    for(i = 0; i < level.waypointCount; i++)
    {
        distance = Distance(pos, level.waypoints[i].origin);
    
        if(distance < nearestDistance)
        {
            if(isdefined(level.waypoints[i].use) && level.waypoints[i].use)
			{
			    nearestDistance = distance;
                nearestWaypoint = i;
			}
			else
			{
			    nearestDistance = distance;
                nearestWaypoint = i;
			}
		}
	}
  
    return nearestWaypoint;
}

////////////////////////////////////////////////////////////
// returns true if there is any waypoint closer to pos than wpIndex
////////////////////////////////////////////////////////////
AnyWaypointCloser(pos, wpIndex)
{
  if(!isDefined(level.waypoints) || level.waypointCount == 0)
  {
    return false;
  }
  nearestWaypoint = wpIndex;
  nearestDistance = Distance(pos, level.waypoints[wpIndex].origin);
  for(i = 0; i < level.waypointCount; i++)
  {
    distance = Distance(pos, level.waypoints[i].origin);
    
    if(distance < nearestDistance)
    {
      nearestDistance = distance;
      nearestWaypoint = i;
    }
  }

//  Print3d(level.waypoints[nearestWaypoint].origin, "CLOSEST", (1,0,0), 3);
  
  if(nearestWaypoint == wpIndex)
  {
    return false;
  }
  else
  {
    return true;  
  }
}

////////////////////////////////////////////////////////////
// returns true if there is any waypoint closer to objPos than self.origin
////////////////////////////////////////////////////////////
AnyWaypointCloserToObjectiveThanMe(objPos)
{
  if(!isDefined(level.waypoints) || level.waypointCount == 0)
  {
    return false;
  }

  meToObjPosDistance = Distance(objPos, self.origin);
  for(i = 0; i < level.waypointCount; i++)
  {
    distance = Distance(objPos, level.waypoints[i].origin);
    
    if((distance+50) < meToObjPosDistance)
    {
      return true;
    }
  }

  return false;  
}

////////////////////////////////////////////////////////////
// static waypoint follow goal, follows static waypoints
///////////////////////////////////////////////////////////
BotGoal_StaticWaypointFollowGoal()
{
  self endon("StaticWaypointFollowGoalComplete");
	self endon("disconnect");
	self endon("killed_player");

  if(!isDefined(level.waypoints) || level.waypointCount == 0)
  {
    self.currentGoal = "none";
    self.currentStaticWp = -1;
    self notify("StaticWaypointFollowGoalComplete");
  }  

  //reset flank direction  
	self.flankSide = (randomIntRange(0,2) - 0.1) * randomFloatRange(0.2, 2.0);
  
  while(1)
  {

    //get waypoint nearest to ourselves  
    if(self.currentStaticWp == -1)
    {
//      print3d(self.origin + (0,0,40), "invalid WP", (1,0,0), 2);

      self.currentStaticWp = GetNearestStaticWaypoint(self.origin);
    }
    
    //get waypoint pos    
    tempWp = level.waypoints[self.currentStaticWp].origin;

    //prevent enemy facing
    if(self CanSeeTarget())
    {
      self.bFaceNearestEnemy = true;
    }
    else
    {
      self.bFaceNearestEnemy = false;

      fwdDir = anglesToForward(self getplayerangles());
      moveDir = tempWp-self.origin;
      moveDir = VectorNormalize((moveDir[0], moveDir[1], 0));
      
      
      if(self.state == "climb")
      {
        trace = BulletTrace(self.origin+(moveDir*60.0), self.origin+(moveDir*-60.0), false, self);
        
        line(self.origin+(moveDir*60.0), self.origin+(moveDir*-60.0), (0,1,0));
        
        if(trace["fraction"] < 1)
        {
          moveDir = trace["normal"];
          moveDir = (moveDir[0] * -1.0, moveDir[1] * -1.0, 0);

          line(trace["position"], trace["position"]+(trace["normal"]*100.0), (1,0,0));
          
        }
      }
      
      //face movement direction        
      self SetBotAngles(vectorToAngles(VectorNormalize(VectorSmooth(fwdDir, moveDir, 0.5))));
    }

    //clamp to xz plane    
    distToWp = Distance((tempWp[0], tempWp[1], self.origin[2]), self.origin);
    
//    print3d(tempWp, self.name + " currentWP", (1,0,0), 2);
    //pick next waypoint or end
//    print3d(self.origin, "distToWp: " + distToWp, (1,0,0), 2);
    if(distToWp <= (self.fMoveSpeed+5.0))
    {
//      print3d(self.origin, self.name + " close enough", (1,0,0), 2);
      //if there isn't any waypoint that is closer than our current waypoint then end our goal
      if(!AnyWaypointCloser(self.vObjectivePos, self.currentStaticWp))
      {
        //fixme: should do a check to make sure that one of the child paths doesn't get us closer
        self.currentGoal = "none";
        self.currentStaticWp = -1;
//        print3d(self.origin+(0,0,10), "NONECLOSER!!!", (1,0,0), 2);
        
        self notify("StaticWaypointFollowGoalComplete");
      }
      else
      {
//        print3d(self.origin + (0,0,10), self.name + " searching", (1,0,0), 2);

        //get waypoint nearest our target
        targetWpIdx = GetNearestStaticWaypoint(self.vObjectivePos);
        
        //store last static waypoint
        lastStaticWaypoint = self.currentStaticWp;
        
        //find shortest path to our destination
        self.currentStaticWp = AStarSearch(self.currentStaticWp, targetWpIdx);
        wait 0.01;
        //invalid waypoint, get outta here        
        if(!isdefined(self.currentStaticWp) || self.currentStaticWp == -1)
        {
          self.currentGoal = "none";
          self.currentStaticWp = -1;
          self notify("StaticWaypointFollowGoalComplete");
        }
        
        tempWp = level.waypoints[self.currentStaticWp].origin;
        
        //move there


          //initiate climbing only if LAST WAS a climbing waypoint AND CURRENT IS ALSO.        
          if(lastStaticWaypoint != -1  && self.currentStaticWp != -1 && level.waypoints[self.currentStaticWp].type == "climb" && level.waypoints[lastStaticWaypoint].type == "climb")
          {
            tempWp = level.waypoints[self.currentStaticWp];
			self.stance = "climb";
            self.state = "climb";
            self.bClampToGround = false;
			self.bFaceNearestEnemy = false;
            self BotClimb(tempWp, 1.0); //climb
          }
          else
          {
            if(self.state == "climb" || self.stance == "climb")
            {
              self.stance = "stand";
            }
            
            if(self.bFaceNearestEnemy)
            {
              self BotMove(tempWp, 6.0); //walk
            }
            else
            {
              self BotMove(tempWp, 11.0); //sprint
            }
          
            self.bClampToGround = true;
          }
         

      }
    }
    wait 0.1;
  }
}

///////////////////////////////////////////////////////////
// Initiates climbing
////////////////////////////////////////////////////////////
BotClimb(_vMoveTarget, _fMoveSpeed)
{
    self endon("killed_player");
    
    //cancel any previous moves
    self notify( "BotMovementComplete" );
	self endon("BotClimbComplete");
	
    _vMoveTarget.use = false;
	self.vMoveTarget = _vMoveTarget;
	self.fMoveSpeed =  _fMoveSpeed;
	self.fBaseMoveSpeed = self.fMoveSpeed;
	self.bFaceNearestEnemy = false;
	self setplayerangles(self.vMoveTarget.angles);
	self.attachmentMover = spawn("script_origin", self.origin);
    self linkto(self.attachmentMover);

    if(isdefined(self.bIsBot))
    {
        self.bClampToGround = false;
		self freezecontrols(false);
        self.bShooting = false;
        self.bThrowingGrenade = false;
        height = self.vMoveTarget.origin[2] - self.origin[2] - 10;

        destOrg = self.origin + (0.0, 0.0, height);
        moveTime = distance(self.origin, destOrg)/100;

        self SetAnim(self.weaponPrefix, "climb", "up");
        self.attachmentMover moveto(self.vMoveTarget.origin, moveTime, 0, 0);
		wait moveTime;
        self.attachmentMover unlink();
        self.attachmentMover delete();
		wait 0.01;
		self.state = "combat";
		self.fMoveSpeed =  4.5;
		self SetAnim(self.weaponPrefix, "stand", "walk");
		self freezecontrols(true);
		
    }
    self notify( "BotClimbComplete" );
	self.vMoveTarget.use = true;

	return;
}

////////////////////////////////////////////////////////////
// AStarSearch, performs an astar search
///////////////////////////////////////////////////////////
/*

The best-established algorithm for the general searching of optimal paths is A* (pronounced “A-star”). 
This heuristic search ranks each node by an estimate of the best route that goes through that node. The typical formula is expressed as:

f(n) = g(n) + h(n)

where: f(n)is the score assigned to node n g(n)is the actual cheapest cost of arriving at n from the start h(n)is the heuristic 
estimate of the cost to the goal from n 

priorityqueue Open
list Closed


AStarSearch
   s.g = 0  // s is the start node
   s.h = GoalDistEstimate( s )
   s.f = s.g + s.h
   s.parent = null
   push s on Open
   while Open is not empty
      pop node n from Open  // n has the lowest f
      if n is a goal node 
         construct path 
         return success
      for each successor n' of n
         newg = n.g + cost(n,n')
         if n' is in Open or Closed,
          and n'.g < = newg
	       skip
         n'.parent = n
         n'.g = newg
         n'.h = GoalDistEstimate( n' )
         n'.f = n'.g + n'.h
         if n' is in Closed
            remove it from Closed
         if n' is not yet in Open
            push n' on Open
      push n onto Closed
   return failure // if no path found 
*/
AStarSearch(startWp, goalWp)
{
  pQOpen = [];
  pQSize = 0;
  closedList = [];
  listSize = 0;
  s = spawnstruct();
  s.g = 0; //start node
  s.h = distance(level.waypoints[startWp].origin, level.waypoints[goalWp].origin);
  s.f = s.g + s.h;
  s.wpIdx = startWp;
  s.parent = spawnstruct();
  s.parent.wpIdx = -1;
  
  //push s on Open
  pQOpen[pQSize] = spawnstruct();
  pQOpen[pQSize] = s; //push s on Open
  pQSize++;

  //while Open is not empty  
  while(!PQIsEmpty(pQOpen, pQSize))
  {
    //pop node n from Open  // n has the lowest f
    n = pQOpen[0];
    highestPriority = 9999999999;
    bestNode = -1;
    for(i = 0; i < pQSize; i++)
    {
      if(pQOpen[i].f < highestPriority)
      {
        bestNode = i;
        highestPriority = pQOpen[i].f;
      }
    } 
    
    if(bestNode != -1)
    {
      n = pQOpen[bestNode];
      //remove node from queue    
      for(i = bestNode; i < pQSize-1; i++)
      {
        pQOpen[i] = pQOpen[i+1];
      }
      pQSize--;
    }
    else
    {
      return -1;
    }
    
    //if n is a goal node; construct path, return success
    if(n.wpIdx == goalWp)
    {
     
      x = n;
      for(z = 0; z < 1000; z++)
      {
        parent = x.parent;
        if(parent.parent.wpIdx == -1)
        {
          return x.wpIdx;
        }
//        line(level.waypoints[x.wpIdx].origin, level.waypoints[parent.wpIdx].origin, (0,1,0));
        x = parent;
      }

      return -1;      
    }

    //for each successor nc of n
    for(i = 0; i < level.waypoints[n.wpIdx].childCount; i++)
    {
      //newg = n.g + cost(n,nc)
      newg = n.g + distance(level.waypoints[n.wpIdx].origin, level.waypoints[level.waypoints[n.wpIdx].children[i]].origin);
      
      //if nc is in Open or Closed, and nc.g <= newg then skip
      if(PQExists(pQOpen, level.waypoints[n.wpIdx].children[i], pQSize))
      {
        //find nc in open
        nc = spawnstruct();
        for(p = 0; p < pQSize; p++)
        {
          if(pQOpen[p].wpIdx == level.waypoints[n.wpIdx].children[i])
          {
            nc = pQOpen[p];
            break;
          }
        }
       
        if(nc.g <= newg)
        {
          continue;
        }
      }
      else
      if(ListExists(closedList, level.waypoints[n.wpIdx].children[i], listSize))
      {
        //find nc in closed list
        nc = spawnstruct();
        for(p = 0; p < listSize; p++)
        {
          if(closedList[p].wpIdx == level.waypoints[n.wpIdx].children[i])
          {
            nc = closedList[p];
            break;
          }
        }
        
        if(nc.g <= newg)
        {
          continue;
        }
      }
      
//      nc.parent = n
//      nc.g = newg
//      nc.h = GoalDistEstimate( nc )
//      nc.f = nc.g + nc.h
      
      nc = spawnstruct();
      nc.parent = spawnstruct();
      nc.parent = n;
      nc.g = newg;
      nc.h = distance(level.waypoints[level.waypoints[n.wpIdx].children[i]].origin, level.waypoints[goalWp].origin);
	    nc.f = nc.g + nc.h;
	    nc.wpIdx = level.waypoints[n.wpIdx].children[i];

      //if nc is in Closed,
	    if(ListExists(closedList, nc.wpIdx, listSize))
	    {
	      //remove it from Closed
        deleted = false;
        for(p = 0; p < listSize; p++)
        {
          if(closedList[p].wpIdx == nc.wpIdx)
          {
            for(x = p; x < listSize-1; x++)
            {
              closedList[x] = closedList[x+1];
            }
            deleted = true;
            break;
          }
          if(deleted)
          {
            break;
          }
        }
	      listSize--;
	    }
	    
	    //if nc is not yet in Open, 
	    if(!PQExists(pQOpen, nc.wpIdx, pQSize))
	    {
	      //push nc on Open
        pQOpen[pQSize] = spawnstruct();
        pQOpen[pQSize] = nc;
        pQSize++;
	    }
	  }
	  
	  //Done with children, push n onto Closed
	  if(!ListExists(closedList, n.wpIdx, listSize))
	  {
      closedList[listSize] = spawnstruct();
      closedList[listSize] = n;
	    listSize++;
	  }
  }
}

////////////////////////////////////////////////////////////
// PQIsEmpty, returns true if empty
////////////////////////////////////////////////////////////
PQIsEmpty(Q, QSize)
{
  if(QSize <= 0)
  {
    return true;
  }
  
  return false;
}

////////////////////////////////////////////////////////////
// returns true if n exists in the pQ
////////////////////////////////////////////////////////////
PQExists(Q, n, QSize)
{
  for(i = 0; i < QSize; i++)
  {
    if(Q[i].wpIdx == n)
    {
      return true;
    }
  }
  
  return false;
}

////////////////////////////////////////////////////////////
// returns true if n exists in the list
////////////////////////////////////////////////////////////
ListExists(list, n, listSize)
{
  for(i = 0; i < listSize; i++)
  {
    if(list[i].wpIdx == n)
    {
      return true;
    }
  }
  
  return false;
}

////////////////////////////////////////////////////////////
// Sets a bot's objective position
///////////////////////////////////////////////////////////
SetObjectivePos(pos)
{
  //FIXME: optimize
  dirToObjective = VectorNormalize(pos - self.origin);
  distToObj = distance(pos, self.origin); 
  
  if(isdefined(level.minDistToObj))
        minDistToObj = level.minDistToObj;
	else
	    minDistToObj = 200;
  //if a long way away from our objective, flank it
  if(distToObj >= minDistToObj)
  {
    flankDir = VectorCross((0,0,1), dirToObjective);
    
    //project position out along tangent by distance to target
    self.vObjectivePos = pos + ((flankDir * ((distToObj / minDistToObj) * minDistToObj)) * self.flankSide);
    
    //set to pos of nearest waypoint so that we dont try walk out of the level
    if(isDefined(level.waypoints) && level.waypointCount)
    {
      self.vObjectivePos = level.waypoints[GetNearestStaticWaypoint(self.vObjectivePos)].origin;
    }
  }  
  else
  {
    self.vObjectivePos = pos;
  }

}

////////////////////////////////////////////////////////////
//returns true if stunned
////////////////////////////////////////////////////////////
IsStunned()
{
  if(isdefined(self.concussionEndTime) && self.concussionEndTime > gettime())
  {
//    print3d(self.origin, "stunned", (1,0,0), 2);
    return true;
  }

  return false;
}

////////////////////////////////////////////////////////////
// cast a ray from start to end through smoke, return false if cant see
////////////////////////////////////////////////////////////
SmokeTrace(start, end)
{
  for(g = 0; g < level.smokeListCount; g++)
  {
    if(level.smokeList[g].state == "smoking")
    {
      if(RaySphereIntersect(start, end, level.smokeList[g].origin, 300.0))
      {
//        line(start, end, (1,0,0));
        return false;  
      }
    }
  }

//  line(start, end, (0,1,0));
  
  return true;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
AddToSmokeList()
{
  if(level.smokeListCount+1 > level.smokeList.size)
  {
    level.smokelist[level.smokelist.size] = spawnstruct();
  }

  level.smokeList[level.smokeListCount].grenade = self;
  level.smokeList[level.smokeListCount].state = "moving";
  level.smokeList[level.smokeListCount].stateTimer = gettime();
  level.smokeList[level.smokeListCount].origin = self.origin;
  
  level.smokeListCount++;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
RemoveFromSmokeList(index)
{

  if(level.smokeListCount <= 0 || index >= level.smokeListCount || index < 0)
  {
    return;
  }

  for(i = index; i < level.smokeListCount-1; i++)
  {
    level.smokeList[i] = level.smokeList[i+1];
  }
  
  level.smokeListCount--;

}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
UpdateSmokeList()
{
  while(1)
  {
    for(g = 0; g < level.smokeListCount; g++)
    {
      bGrenadeFound = false;
	    grenades = getentarray("grenade", "classname");
	    //search grenade list for matching grenade entity
	    for(i = 0; i < grenades.size; i++)
	    {
	      grenade = grenades[i];
  	    
	      if(level.smokeList[g].grenade == grenade)
	      {
	        level.smokeList[g].origin = grenade.origin;
	        bGrenadeFound = true;
	        break;
	      }
 	    }

      //grenade not found, so must be smoking or just exploded
 	    if(!bGrenadeFound)
 	    {
 	      switch(level.smokeList[g].state)
 	      {
 	        case "moving":
 	        {
 	          level.smokeList[g].state = "smoking";
 	          level.smokeList[g].stateTime = gettime();
 	          break;
 	        }
 	        
 	        case "smoking":
 	        {
 	          if((gettime()-level.smokeList[g].stateTime) > 11000)
 	          {
    	        RemoveFromSmokeList(g);
    	      }
/*    	      
    	      else
    	      {
    	        print3d(level.smokeList[g].origin, "SMOKING", (1,0,0), 2);
    	        line(level.smokeList[g].origin, level.smokeList[g].origin + (0,0,300.0), (1,0,0));
    	      }
*/
 	          break;
 	        }
 	      }
 	    }
    }
  
    wait 0.05; 
  }
}

/*
   Calculate the intersection of a ray and a sphere
   The line segment is defined from start to end
   The sphere is of radius r and centered at spherePos
   There are potentially two points of intersection given by
   p = start + mu1 (end - start)
   p = start + mu2 (end - start)
   Return FALSE if the ray doesn't intersect the sphere.
*/
////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
RaySphereIntersect(start, end, spherePos, radius)
{

   dp = end - start;
   a = dp[0] * dp[0] + dp[1] * dp[1] + dp[2] * dp[2];
   b = 2 * (dp[0] * (start[0] - spherePos[0]) + dp[1] * (start[1] - spherePos[1]) + dp[2] * (start[2] - spherePos[2]));
   c = spherePos[0] * spherePos[0] + spherePos[1] * spherePos[1] + spherePos[2] * spherePos[2];
   c += start[0] * start[0] + start[1] * start[1] + start[2] * start[2];
   c -= 2.0 * (spherePos[0] * start[0] + spherePos[1] * start[1] + spherePos[2] * start[2]);
   c -= radius * radius;
   bb4ac = b * b - 4.0 * a * c;
//   if(ABS(a) < 0.0001 || bb4ac < 0) 
   if(bb4ac < 0) 
   {
//      *mu1 = 0;
//      *mu2 = 0;
     return false;
   }

//   *mu1 = (-b + sqrt(bb4ac)) / (2 * a);
//   *mu2 = (-b - sqrt(bb4ac)) / (2 * a);

   return true;
}

////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////
soundMPChatter()
{
    wait 0.05;
	if(level.bot_battlechatter != 0)
	{
	    if(self.sessionstate == "playing" && level.botTalking == false)
	    {
			if(self.pers["team"] == "allies")
			{
			    if ( game["allies"] == "sas" )
				{
				    self thread botPlaySound("UK" + "_mp_chatter");
				}
				else
				self thread botPlaySound("US" + "_mp_chatter");
			}
			else
			if(self.pers["team"] == "axis")
			{
			    if ( game["axis"] == "russian" )
				{
				    self thread botPlaySound("RU" + "_mp_chatter");
				}
				else
				self thread botPlaySound("AB" + "_mp_chatter");
			}
	    }
	}
}

////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////
soundIdleChatter()
{
    wait 0.05;
	if(level.bot_battlechatter != 0)
	{
	    if(self.sessionstate == "playing" && level.botTalking == false)
	    {
			if(self.pers["team"] == "allies")
			{
			    if ( game["allies"] == "sas" )
				{
				    self thread botPlaySound("UK" + "_idlechatter");
				}
				else
				self thread botPlaySound("US" + "_idlechatter");
			}
			else
			if(self.pers["team"] == "axis")
			{
			    if ( game["axis"] == "russian" )
				{
				    self thread botPlaySound("RU" + "_idlechatter");
				}
				else
				self thread botPlaySound("AB" + "_idlechatter");
			}
	    }
	}
}

/////////////////////////////////////////////////////////////
// 
/////////////////////////////////////////////////////////////
botPlaySound(sound1, sound2, pause)
{
    if(level.botTalking == true) return;
	level.botTalking = true;
    wait 0.05;
    self playSound(sound1);
    if(isdefined(pause)) wait pause;
	if(isdefined(sound2)) self playSound(sound2);
	wait 0.05;
    level.botTalking = false;
}