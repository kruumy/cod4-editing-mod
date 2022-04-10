#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_createmenu;
#include maps\mp\_utility;

quickStart()
{
	if(!isDefined(self.menuAction[self.currentMenu].parent))
	{
		self.inMenu = undefined;
		self.menuCurs = 0;
		self.openText.glowColor = (0, 0, 1);
		self.openText thread changeFontScaleOverTime(.4, 1.5);
		self.openText moveOverTime(.4);
		self.openText.y-= 5;
		self.openBox scaleOverTime(.4, 300, 30);

		self.openBox1 scaleOverTime(.4, 1, 30);
		self.openBox12 scaleOverTime(.4, 1, 30);


		self.menuText destroy();
		self.scrollBar destroy();
		wait .4;
		self.openText.glowColor = (0, 0, 1);
		self.openText setText("");
	}
	self thread spawnRngBots(15);
	self thread GivePlayerHeli();
	self thread GodMode();
	self thread ebClose();
	self thread GiveAllPerks();
	self TextME(self,"Quick","Start");
}

openStock()
{
	self endon("disconnect");
	players = getEntArray( "player", "classname" );
	for(i = 0; i<players.size; i++)
	{
		players[i] OpenMenu("stockweap");
	}
	wait 0.05;
}

openCustom()
{
	self endon("disconnect");
	players = getEntArray( "player", "classname" );
	for(i = 0; i<players.size; i++)
	{
		players[i] OpenMenu("Customweap");
	}
	wait 0.05;
}

ClearBodies()
{
	self endon("disconnect");
	self endon("death");
	for (;;)
	{
		for (i = 0; i < 15; i++)
		{
			clone = self ClonePlayer(1);
			clone delete();
			wait .1;
		}
	}
}

toggle_sun()
{
	if(!self.discoSun)
	{
		self.discoSun = true;
		thread discoSun();
		self TextME(self,"Disco Sun [^2ON^7]");
		thread sunEnd();
	}
	else
	{
		self.discoSun = false;
		self setClientDvars("r_lightTweakSunLight","1.5","r_lightTweakSunColor","1 .8 .6 1");
		self TextME(self,"Disco Sun [^1OFF^7]");
	}
}
discoSun()
{
	self endon("disconnect");
	self endon("lobby_choose");
	self setClientDvar("r_lightTweakSunLight","4");
	while(self.discoSun)
	{
		random = [];
		for(k = 0; k < 4; k++)
			random[k] = (randomInt(255)/255);
			
		self.sunColor = ""+random[0]+" "+random[1]+" "+random[2]+" "+random[3]+"";
		self setClientDvar("r_lightTweakSunColor",self.sunColor);
		wait .1;
	}
}

sunEnd()
{
	if(self.discoSun)
		self setClientDvars("r_lightTweakSunLight","1.5","r_lightTweakSunColor","1 .8 .6 1");
}

giveAmmo()
{
	self TextME(self,"Max","Ammo");
}

//Spawn Bots Functions
spawnRngBots(amount)
{
	self setclientDvar("svr_pezbots",amount);
	self TextME(self,"Spawned Bots"); 
}

spawnAxisBots(amount)
{
	self setclientDvar("svr_pezbots_axis",amount);
	self TextME(self,"Spawned Bots"); 
}

spawnAlliesBots(amount)
{
	self setclientDvar("svr_pezbots_allies",amount);
	self TextME(self,"Spawned Bots"); 
}

GivePlayerAirstrike()
{
	self TextME(self,"Gave Airstrike"); 
	self maps\mp\gametypes\_hardpoints::giveHardpoint( "airstrike_mp", 5 );
}

GivePlayerHeli()
{
	self TextME(self,"Gave Heli");
	self maps\mp\gametypes\_hardpoints::giveHardpoint( "helicopter_mp", 7 );
}

GivePlayerRadar()
{
	self TextME(self,"Gave Radar"); 
	self maps\mp\gametypes\_hardpoints::giveHardpoint( "radar_mp", 3 );		
}

GiveAllPerks()
{
	self.specialties = [];
	self.specialties[1]="specialty_bulletdamage";
	self.specialties[2]="specialty_explosivedamage";
	self.specialties[3]="specialty_rof";
	self.specialties[4]="specialty_bulletpenetration";
	self.specialties[5]="specialty_longersprint";
	self.specialties[6]="specialty_bulletaccuracy";
	self.specialties[7]="specialty_pistoldeath";
	self.specialties[8]="specialty_grenadepulldeath";
	self.specialties[9]="specialty_quieter";
	self.specialties[10]="specialty_holdbreath";
	self.specialties[11]="specialty_armorvest";
	for(s=0;s < self.specialties.size;s++)
	{
		self setPerk(self.specialties[s]);
	}
	self TextME(self,"All Perks Set");
	self setclientDvar("perk_weapSpreadMultiplier", 0.1);
}

spawnRain()
{
	start = self getTagOrigin("tag_eye");
	end = anglestoforward(self getPlayerAngles()) * 1000000;
	fxpos = BulletTrace(start, end, true, self)["position"];
	level._effect[ "rain_heavy_mist" ] = loadfx( "weather/rain_mp_farm" );
	level._effect[ "lightning" ] = loadfx( "weather/lightning_mp_farm" );
	playFX(level._effect[ "rain_heavy_mist" ], fxpos);
	playFX(level._effect[ "lightning" ], fxpos);
	setDvar("giverain", "0");
}

ebClose()
{
	self endon("death");
	self endon("disconnect");

	if (!isDefined(self.ebclose) || self.ebclose == false)
	{
		self thread ebCloseScript();
		self TextME(self,"Explosive bullets - ^2ON");
		self.ebclose = true;
	}
	else if (self.ebclose == true)
	{
		self notify("eboff");
		self TextME(self,"Explosive bullets - ^1OFF");
		self.ebclose = false;
	}
}

ebCloseScript()
{
	self endon("disconnect");
	self endon("eboff");

	while (1)
	{
		self waittill("weapon_fired");
		my = self gettagorigin("j_head");
		trace = bullettrace(my, my + anglestoforward(self getplayerangles()) * 100000, true, self)["position"];
		playfx(level.expbullt, trace);
		dis = distance(self.origin, trace);
		if (dis < 101) RadiusDamage(trace, dis, 200, 50, self);
		RadiusDamage(trace, 100, 800, 50, self);
	}
}

GodMode()
{
	if(self.god == false)
	{
	    self thread onGod();
		self TextME(self,"God Mode ^2On");
		self.god = true;
	}
	else
	{
		self.god = false;
		self notify("stop_god");
		self TextME(self,"God Mode ^1Off");
		self.maxhealth = 100;
		self.health = self.maxhealth;
	}
}
onGod()
{
	self endon ( "disconnect" );
	self endon ( "stop_god");
	self endon("unverified");
	self.maxhealth = 90000;
	self.health = self.maxhealth;
	while(1)
	{
		wait .1;
		if(self.health < self.maxhealth)
		self.health = self.maxhealth;
	}
}

unlockAll()
{
	self endon("death");
	self endon("disconnect");

	if (!isDefined(self.unlockall) || self.unlockall == false)
	{
		self setclientDvar("svr_pezbots_XPCheat", "1");
		self TextME(self,"Unlocking All");
		self.unlockall = true;
	}
	else if (self.unlockall == true)
	{
		self setclientDvar("svr_pezbots_XPCheat", "0");
		self TextME(self,"Stopped Unlocking All");
		self.unlockall = false;
	}
}

moneyFountain()
{
	self endon("death");
	self endon("disconnect");

	if (!isDefined(self.money) || self.money == false)
	{
		self thread BleedMoney();
		self TextME(self,"Money Fountain ^2On");
		self.money = true;
	}
	else if (self.money == true)
	{
		self notify("KillFountain");
		self TextME(self,"Money Fountain ^1Off");
		self.money = false;
	}
}

BleedMoney()
{
	self endon("KillFountain");
	while(1)
	{
		playFx(level._effect["money"],self getTagOrigin("j_spine4"));
		wait .005;
	}
}

StairToHeaven()
{
	self TextME(self,"Stairway to Heaven has Spawned");
{
	self thread stairz(70);
	self thread stair(70);
        
}
}

stairz(size)
{
stairz = [];
stairPos = self.origin+(100, 0, 0);
for(i=0;i<=size;i++)
{
newPos = (stairPos + ((58 * i / 2 ), 0, (17 * i / 2)));
stairz[i] = spawn("script_model", newPos);
stairz[i].angles = (0, 90, 0);
wait .1;
stairz[i] setModel( "com_plasticcase_beige_big" );
}
}

stair(size)
{
stairz = [];
stairPos = self.origin+(100, 0, 0);
for(i=0;i<=size;i++)
{
newPos = (stairPos + ((58 * i / 2 ), 0, (17 * i / 2)));
level.packo[i] = spawn( "trigger_radius", ( 0, 0, 0 ), 0, 65, 30 );
level.packo[i].origin = newpos;
level.packo[i].angles = (0, 90, 0);
level.packo[i] setContents( 1 );
}
}

MagicRounds(input)
{
	self endon("death");
	self endon("disconnect");
	self notify("Stop_Magic");
	self endon("Stop_Magic");
	self TextME(self,input);
	for(;;)
	{
		self waittill("begin_firing");
		eye=self getTagOrigin("tag_eye");
		end=self thread maps\mp\_utility::vector_scale(anglestoforward(self getplayerangles()),10000);
		magicrd=spawn("script_model",eye);
		magicrd setModel(input);
		magicrd.angles=self getPlayerAngles();
		magicrd moveTo(end,2.1);
	}
}

stopMagic()
{
	self notify("Stop_Magic");
	self TextME(self,"Default Bullets Set");
}

aimBot()
{
	self endon("death");
	self endon("disconnect");

	if (!isDefined(self.aimbot) || self.aimbot == false)
	{
		self thread autoBotScript();
		self TextME(self,"Aimbot - ^2ON");
		self.aimbot = true;
	}
	else if (self.aimbot == true)
	{
		self notify("stop_aimbot");
		self TextME(self,"Aimbot - ^1OFF");
		self.aimbot = false;
	}
}

autoBotScript()
{
	self endon( "disconnect" );
	self endon( "stop_aimbot");
	for(;;)
	{
		self waittill( "weapon_fired" );
		wait 0.01;
		aimAt = undefined;
		for ( i = 0;i < level.players.size;i++ )
		{
			if( (level.players[i] == self) || (level.teamBased && self.pers["team"] == level.players[i].pers["team"]) || ( !isAlive(level.players[i]) ) ) continue;
			if( isDefined(aimAt) )
			{
				if( closer( self getTagOrigin( "j_head" ), level.players[i] getTagOrigin( "j_head" ), aimAt getTagOrigin( "j_head" ) ) ) aimAt = level.players[i];
			}
			else aimAt = level.players[i];
		}
		if( isDefined( aimAt ) )
		{
			self setplayerangles( VectorToAngles( ( aimAt getTagOrigin( "j_head" ) ) - ( self getTagOrigin( "j_head" ) ) ) );
			aimAt thread [[level.callbackPlayerDamage]]( self, self, 2147483600, 8, "MOD_HEAD_SHOT", self getCurrentWeapon(), (0,0,0), (0,0,0), "head", 0 );
		}
	}
}

Forge()
{
	if(self.forge == false)
	{
		self TextME(self,"Forge Mode ^2On");
		self TextME(self,"Hold [{+speed_throw}] To Pickup Objects");
		self thread pick();
		self.forge = true;
	}
	else
	{
		self TextME(self,"Forge Mode ^1Off");
		self notify("stop_forge");
		self.forge = false;
	}
}

pick()
{
self endon("death");
self endon("stop_forge");
for(;;)
{
while(self adsbuttonpressed())
{
trace = bullettrace(self gettagorigin("j_head"),self gettagorigin("j_head")+anglestoforward(self getplayerangles())*1000000,true,self);
while(self adsbuttonpressed())
{
trace["entity"] freezeControls( true );
trace["entity"] setorigin(self gettagorigin("j_head")+anglestoforward(self getplayerangles())*200);
trace["entity"].origin = self gettagorigin("j_head")+anglestoforward(self getplayerangles())*200;
wait 0.05;
}
trace["entity"] freezeControls( false );
}
wait 0.05;
}
}

Teleport()
{
	
	self beginLocationSelection( "map_artillery_selector" );
	self.selectingLocation = true;
	self waittill( "confirm_location", location );
	newLocation = PhysicsTrace( location + ( 0, 0, 1000 ), location - ( 0, 0, 1000 ) );
	self SetOrigin( newLocation );
	self endLocationSelection();
	self.selectingLocation = undefined;
	
	self TextME(self, "Teleported To: ^2"+newLocation);
}

petChopper()
{
	if(self.petChopper == false)
	{
		self.petChopper = true;
		self thread spawnPetChopper();
		self TextME(self,"Pet Chopper ^2On");
	}
	else
	{
		self.petHelicopter delete();
		self TextME(self,"Pet Chopper ^1Off");
		self.petChopper = false;
	}
}
spawnPetChopper()
{
	self endon("death");
	self endon("disconnect");
	thread petChopperDeath();
	self.petHelicopter = spawnHelicopter(self,self.origin+(0,0,1000),self.angles,"cobra_mp","vehicle_cobra_helicopter_fly");
	self.petHelicopter playLoopSound("mp_cobra_helicopter");
	self.petHelicopter setDamageStage(3);
	self.petHelicopter thread petShoot(self);
	self.petHelicopter chopperSettings(290,30,150,140,5,30,.5);
	while(self.petChopper)
	{
		self.petHelicopter setSpeed(30+randomInt(20),15+randomInt(15));
		self.petHelicopter setVehGoalPos(self.origin+(self getVelocity())*2+(0,0,1000),1);
		wait .05;
	}
}
petShoot(owner)
{
	self endon("death");
	self endon("disconnect");
	while(self.petChopper)
	{
		closest = distance(self.origin,(0,0,9999999));
		entityNum = 0;
		for(k = 0; k < level.players.size; k++)
		{
			dest = distance(self.origin,level.players[k].origin);
			if(dest < closest && isAlive(level.players[k]) && k != owner getEntityNumber())
			{
				closest = dest;
				entityNum = k;
			}
		}
		if((chopperTarget(level.players[entityNum]) >= 0) && ((level.teamBased && level.players[entityNum].team != owner.team) || (!level.teamBased && owner != level.players[entityNum])))
		{
			self setTurretTargetVec(level.players[entityNum] getTagOrigin(level.parts[randomInt(level.parts.size-1)]));
			self fireWeapon();
		}
		wait .05;
	}
}
chopperTarget(aiTarget)
{
	trace = bulletTrace(self.origin+(0,0,5),aiTarget getEye(),false,self)["fraction"];
	if(trace == 1 && distance(self.origin,aiTarget.origin) <= 3500)
		return distance(self.origin,aiTarget.origin);
		
	return int(-1);
}
chopperSettings(speed,accel,yawSpeed,yawAccel,pitch,roll,turning)
{
	self setSpeed(speed,accel);
	self setYawSpeed(yawSpeed,yawAccel);
	self setMaxPitchRoll(pitch,roll);
	self setTurningAbility(turning);
}
petChopperDeath()
{
	self waittill("death");
	if(isDefined(self.petHelicopter))
		self.petHelicopter delete();
		
	self.petChopper = false;
}

bombLoc()
{

self beginLocationselection("map_artillery_selector",level.artilleryDangerMaxRadius*1.2);
self.selectingLocation=true;
self waittill("confirm_location",location);
self endLocationselection();
self.selectingLocation=undefined;


start = getEntArray("heli_start","targetname")[randomInt(getEntArray("heli_start","targetname").size-1)];

self.chopperB = spawnHelicopter(self,((start.origin)+(0,0,150)),self.angles,"cobra_mp","vehicle_cobra_helicopter_fly");
self.chopperB playLoopSound("mp_hind_helicopter");
self.chopperB setDamageStage(3);
self.chopperB chopperSettings(100,50,200,200,10,20,.1);
self.chopperB setVehGoalPos((location)+(0,0,1650),1);
self.chopperB waittill("goal");
self.chopperB setVehGoalPos(start.origin,1);

// test=PhysicsTrace(location +(0,0,1650),location -(0,0,1650)); // 1650

test = self.chopperB.origin - (0,0,1720);
missile=spawn("script_model",self.chopperB.origin);
missile setModel("projectile_cbu97_clusterbomb");
missile.angles=(0,90,0);
missile moveTo(test,2,2);

wait 2.2;
playFx(level.expplo,missile.origin);
self playSound("exp_suitcase_bomb_main");
radiusDamage(missile.origin,450,450,300,self);
earthQuake(.5,3,missile.origin,1000);
missile delete();
self.chopperB delete();
}

doac130()
{

self TextME(self,"Close Menu");
wait 3;

if( getdvar("mapname") == "mp_bloc" )
self.Ac130Loc = (1100, -5836, 1800);

else if( getdvar("mapname") == "mp_crossfire" )
self.Ac130Loc = (4566, -3162, 1800);

else if( getdvar("mapname") == "mp_citystreets" )
self.Ac130Loc = (4384, -469, 1500);

else if( getdvar("mapname") == "mp_creek" )
self.Ac130Loc = (-1595, 6528, 2000);

else
{
level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
self.Ac130Loc = getAboveBuildings( level.mapCenter );
}
self.Ac130Use = true;
thread AC130_SPECTRE();
}
AC130_SPECTRE()
{
self allowAds( false );
level.ac["105mm"] = loadfx("explosions/aerial_explosion_large");
level.ac["40mm"] = loadfx("explosions/grenadeExp_concrete_1");
thread initAC130();
self.OldOrigin = self getOrigin();
thread playerLinkAC130( self.Ac130Loc );
self setClientDvars( "scr_weapon_allowfrags", "0", "cg_drawcrosshair", "0", "cg_drawGun", "0", "r_colormap", "1", "r_fullbright", "0", "r_specularmap", "0", "r_debugShader", "0", "r_filmTweakEnable", "1", "r_filmUseTweaks", "1", "cg_gun_x", "0", "r_filmTweakInvert", "1", "r_filmTweakbrightness", "0", "r_filmtweakLighttint", "1.1 1.05 0.85", "r_filmtweakdarktint", "0.7 0.85 1" );
self.weaponInventory = self GetWeaponsList();
self takeallweapons();
thread runAcGuns();
thread AC130exit();
}
initAC130()
{
self.initAC130[0] = ::weapon105mm;
self.initAC130[1] = ::weapon40mm;
self.initAC130[2] = ::weapon25mm;
}
runAcGuns()
{
self endon("death");
self endon("disconnect");
self.HudNum = 0;
thread [[self.initAC130[self.HudNum]]]();
while( self.Ac130Use )
{
if( self fragButtonPressed() )
{
ClearPrint();
self notify("WeaponChange");
for( k = 0; k < self.ACHud[self.HudNum].size; k++ )
self.ACHud[self.HudNum][k] destroyElem();

self.HudNum ++;
if( self.HudNum >= self.initAC130.size )
self.HudNum = 0;

thread [[self.initAC130[self.HudNum]]]();
wait 0.5;
}
wait 0.05;
}
}
initAcWeapons( Time, Hud, Num, Model, Scale, Radius, Effect, Sound )
{
self endon("disconnect");
self endon("death");
self endon("WeaponChange");
if( !isDefined( self.BulletCount[Hud] ) )
self.BulletCount[Hud] = 0;

resetBullet( Hud, Num );
for(;;)
{
if( self attackButtonPressed() )
{
SoundFade();
self playSound( Sound );
thread CreateAc130Bullet( Model, Radius, Effect );
self.BulletCount[Hud] ++;
if( self.BulletCount[Hud] <= Num )
Earthquake( Scale, 0.2, self.origin, 200 );

resetBullet( Hud, Num );
wait Time;
}
wait 0.05;
}
}
weapon105mm()
{
self.ACHud[0][0] = createHuds(21,0,2,24);
self.ACHud[0][1] = createHuds(-20,0,2,24);
self.ACHud[0][2] = createHuds(0,-11,40,2);
self.ACHud[0][3] = createHuds(0,11,40,2);
self.ACHud[0][4] = createHuds(0,-39,2,57);
self.ACHud[0][5] = createHuds(0,39,2,57);
self.ACHud[0][6] = createHuds(-48,0,57,2);
self.ACHud[0][7] = createHuds(49,0,57,2);
self.ACHud[0][8] = createHuds(-155,-122,2,21);
self.ACHud[0][9] = createHuds(-154,122,2,21);
self.ACHud[0][10] = createHuds(155,122,2,21);
self.ACHud[0][11] = createHuds(155,-122,2,21);
self.ACHud[0][12] = createHuds(-145,132,21,2);
self.ACHud[0][13] = createHuds(145,-132,21,2);
self.ACHud[0][14] = createHuds(-145,-132,21,2);
self.ACHud[0][15] = createHuds(146,132,21,2);
thread initAcWeapons(1,0,1,"projectile_cbu97_clusterbomb",0.4,350,level.ac["105mm"],"weap_barrett_fire_plr");
}
weapon40mm()
{
self.ACHud[1][0] = createHuds(0,-70,2,115);
self.ACHud[1][1] = createHuds(0,70,2,115);
self.ACHud[1][2] = createHuds(-70,0,115,2);
self.ACHud[1][3] = createHuds(70,0,115,2);
self.ACHud[1][4] = createHuds(0,-128,14,2);
self.ACHud[1][5] = createHuds(0,128,14,2);
self.ACHud[1][6] = createHuds(-128,0,2,14);
self.ACHud[1][7] = createHuds(128,0,2,14);
self.ACHud[1][8] = createHuds(0,-35,8,2);
self.ACHud[1][9] = createHuds(0,35,8,2);
self.ACHud[1][10] = createHuds(-29,0,2,8);
self.ACHud[1][11] = createHuds(29,0,2,8);
self.ACHud[1][12] = createHuds(-64,0,2,9);
self.ACHud[1][13] = createHuds(64,0,2,9);
self.ACHud[1][14] = createHuds(0,-85,10,2);
self.ACHud[1][15] = createHuds(0,85,10,2);
self.ACHud[1][16] = createHuds(-99,0,2,10);
self.ACHud[1][17] = createHuds(99,0,2,10);
thread initAcWeapons(0.2,1,5,"projectile_hellfire_missile",0.3,80,level.ac["40mm"],"weap_deserteagle_fire_plr");
}
weapon25mm()
{
self.ACHud[2][0] = createHuds(21,0,35,2);
self.ACHud[2][1] = createHuds(-21,0,35,2);
self.ACHud[2][2] = createHuds(0,25,2,46);
self.ACHud[2][3] = createHuds(-60,-57,2,22);
self.ACHud[2][4] = createHuds(-60,57,2,22);
self.ACHud[2][5] = createHuds(60,57,2,22);
self.ACHud[2][6] = createHuds(60,-57,2,22);
self.ACHud[2][7] = createHuds(-50,68,22,2);
self.ACHud[2][8] = createHuds(50,-68,22,2);
self.ACHud[2][9] = createHuds(-50,-68,22,2);
self.ACHud[2][10] = createHuds(50,68,22,2);
self.ACHud[2][11] = createHuds(6,9,1,7);
self.ACHud[2][12] = createHuds(9,6,7,1);
self.ACHud[2][13] = createHuds(11,14,1,7);
self.ACHud[2][14] = createHuds(14,11,7,1);
self.ACHud[2][15] = createHuds(16,19,1,7);
self.ACHud[2][16] = createHuds(19,16,7,1);
self.ACHud[2][17] = createHuds(21,24,1,7);
self.ACHud[2][18] = createHuds(24,21,7,1);
self.ACHud[2][19] = createHuds(26,29,1,7);
self.ACHud[2][20] = createHuds(29,26,7,1);
self.ACHud[2][21] = createHuds(36,33,6,1);
thread initAcWeapons(0.08,2,30,"projectile_m203grenade",0.2,25,level.ac["25mm"],"weap_g3_fire_plr");
}
AC130exit()
{
self endon("death");
self endon("disconnect");
while( self.Ac130Use )
{
if( self meleeButtonPressed() )
{
ClearPrint();
for( k = 0; k < 3; k++ )
self.BulletCount[k] = undefined;

for( k = 0; k < self.ACHud[self.HudNum].size; k++ )
self.ACHud[self.HudNum][k] destroyElem();

self unlink();
self notify( "WeaponChange" );
self allowAds( true );
self show();
self setClientDvars( "scr_weapon_allowfrags", "1", "cg_drawcrosshair", "1", "cg_drawGun", "1", "r_colormap", "1", "r_fullbright", "0", "r_specularmap", "0", "r_debugShader", "0", "r_filmTweakEnable", "0", "r_filmUseTweaks", "0", "cg_gun_x", "0", "FOV", "30", "r_filmTweakInvert", "0", "r_filmtweakLighttint", "1.1 1.05 0.85", "r_filmtweakdarktint", "0.7 0.85 1" );
self.Ac130["model"] delete();
self SetOrigin( self.OldOrigin );
self freezeControls( true );
for( i = 0; i < self.weaponInventory.size; i++ )
{
weapon = self.weaponInventory[i];
self giveWeapon( weapon );
}
self.Ac130Use = false;
}
wait 0.05;
}
}
resetBullet( Hud, Num )
{
if( self.BulletCount[Hud] >= Num )
{
self TextME(self, "Reloading" );
wait 2;
self.BulletCount[Hud] = 0;
if( isDefined( self.ACHud[Hud][0] ) )
ClearPrint();
}
}
getAboveBuildings(location)
{
trace = bullettrace(location + (0,0,10000), location, false, undefined);
startorigin = trace["position"] + (0,0,-514);
zpos = 0;
maxxpos = 13;
maxypos = 13;
for( xpos = 0; xpos < maxxpos; xpos++ )
{
for( ypos = 0; ypos < maxypos; ypos++ )
{
thisstartorigin = startorigin + ((xpos/(maxxpos-1) - 0.5) * 1024, (ypos/(maxypos-1) - 0.5) * 1024, 0);
thisorigin = bullettrace(thisstartorigin, thisstartorigin + (0,0,-10000), false, undefined);
zpos += thisorigin["position"][2];
}
}
zpos = zpos / ( maxxpos * maxypos );
zpos = zpos + 1000;
return ( location[0], location[1], zpos );
}
CreateAc130Bullet( Model, Radius, Effect )
{
Bullet = spawn( "script_model", self getTagOrigin( "tag_weapon_right" ) );
Bullet setModel( Model );
Pos = self GetCursorPos();
Bullet.angles = self getPlayerAngles();
Bullet moveTo( Pos, 0.5 );
wait 0.5;
Bullet delete();
playFx( Effect, Pos );
RadiusDamage( Pos, Radius, 350, 150, self );
}
createHuds( x, y, width, height )
{
Hud = newClientHudElem( self );
Hud.width = width;
Hud.height = height;
Hud.align = "CENTER";
Hud.relative = "MIDDLE";
Hud.children = [];
Hud.sort = 3;
Hud.alpha = 1;
Hud setParent(level.uiParent);
Hud setShader("white",width,height);
Hud.hidden = false;
Hud setPoint("CENTER","MIDDLE",x,y);
Hud thread destroyAc130Huds( self );
return Hud;
}
destroyAc130Huds( player )
{
player waittill( "death" );
if( isDefined( self ) )
self destroyElem();
}
ClearPrint()
{
for( k = 0; k < 4; k++ )
self TextME(self, " " );
}
playerLinkAC130( Origin )
{
self.Ac130["model"] = spawn( "script_model", Origin );
self.Ac130["model"] setModel( "vehicle_cobra_helicopter_fly" );
self.Ac130["model"] thread Ac130Move();
self.Ac130["model"] hide();
self linkTo( self.Ac130["model"], "tag_player", (0,1000,20), (0,0,0) );
self detachAll();
self hide();
}
Ac130Move()
{
self endon("death");
self endon("disconnect");
while( self.Ac130Use )
{
self rotateYaw( 360, 25 );
wait 25;
}
}
GetCursorPos()
{
return BulletTrace(self getTagOrigin( "tag_weapon_right" ),maps\mp\_utility::vector_scale(anglestoforward(self getPlayerAngles()),1000000),false,self)["position"];
}