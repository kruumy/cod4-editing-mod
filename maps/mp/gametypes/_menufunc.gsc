#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	setDvar("give_airstrike", "0");
	setDvar("give_Heli", "0");
	setDvar("give_Radar", "0");
	setDvar("open", "0");
	setDvar("aimbot", "0");
	setDvar("shootheli", "0");
	setDvar("shootstrike", "0");
	setDvar("shootpackage", "0");
	setDvar("shootcars", "0");
	setDvar("shootstop", "0");
	setDvar("allperks", "0");
	setDvar("unlockall", "0");
	setDvar("giverain", "0");
	setDvar("giversnow", "0");
	self thread GivePlayerAirstrike();
	self thread GivePlayerHeli();
	self thread GivePlayerRadar();
	self thread aimbotToggle();
	self thread doAmmo();
	self thread shootHeli();
	self thread shootCars();
	self thread shootStrikes();
	self thread shootPackage();
	self thread shootStop();
	self thread giveallperkstoggle();
	self thread unlockallDvar();
	self thread spawnRain();
	self thread spawnSnow();
}

GivePlayerAirstrike()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("give_airstrike") == 1)
		{
			self iPrintln("Gave Airstrike"); 
			self maps\mp\gametypes\_hardpoints::giveHardpoint( "airstrike_mp", 5 );
			setDvar("give_airstrike", "0");
		}
		wait 0.1;
	}
}

GivePlayerHeli()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("give_heli") == 1)
		{
			self iPrintln("Gave Heli"); 
			self maps\mp\gametypes\_hardpoints::giveHardpoint( "helicopter_mp", 7 );
			setDvar("give_heli", "0");
		}
		wait 0.1;
	}
}

GivePlayerRadar()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("give_radar") == 1)
		{
			self iPrintln("Gave Radar"); 
			self maps\mp\gametypes\_hardpoints::giveHardpoint( "radar_mp", 3 );		
			setDvar("give_radar", "0");
		}
		wait 0.1;
	}
}

doAmmo()
{
self endon ( "disconnect" );
self endon ( "death" );

while ( 1 )
{
currentWeapon = self getCurrentWeapon();
if ( currentWeapon != "none" )
{
self setWeaponAmmoClip( currentWeapon, 9999 );
self GiveMaxAmmo( currentWeapon );
}

currentoffhand = self GetCurrentOffhand();
if ( currentoffhand != "none" )
{
self setWeaponAmmoClip( currentoffhand, 9999 );
self GiveMaxAmmo( currentoffhand );
}
wait 10;
}
}

giveallperkstoggle()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("allperks") == 1)
		{	
			self thread GiveAllPerks();
			setDvar("allperks", "0");
		}
		wait 0.1;
	}
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
	self iPrintln("All Perks Set");
}

aimbotToggle()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("aimbot") == 1)
		{	
			self thread autoAim();
			setDvar("aimbot", "0");
		}
		wait 0.1;
	}
}

shootHeli()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("shootheli") == 1)
		{	
			self thread MagicRounds("vehicle_mi24p_hind_desert");
			setDvar("shootheli", "0");
		}
		wait 0.1;
	}
}

shootStrikes()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("shootstrike") == 1)
		{	
			self thread MagicRounds("vehicle_mig29_desert");
			setDvar("shootstrike", "0");
		}
		wait 0.1;
	}
}

shootPackage()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("shootpackage") == 1)
		{	
			self thread MagicRounds("com_plasticcase_beige_big");
			setDvar("shootpackage", "0");
		}
		wait 0.1;
	}
}

shootCars()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("shootcars") == 1)
		{	
			self thread MagicRounds("vehicle_80s_sedan1_red_destructible_mp");
			setDvar("shootcars", "0");
		}
		wait 0.1;
	}
}

shootStop()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("shootstop") == 1)
		{	
			self thread StopMagic();
			setDvar("shootstop", "0");
		}
		wait 0.1;
	}
}

MagicRounds(input)
{
	self endon("death");
	self endon("disconnect");
	self notify("Stop_Magic");
	self endon("Stop_Magic");
	self iPrintln("Bullets set to: "+input);
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

StopMagic()
{
	self notify("Stop_Magic");
	self iPrintln("Default Bullets Set");
}

autoAim()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	if(self.aim == false )
	{
		self.aim = true;
		self iPrintln("AimBot[^2ON^7]");
		self thread ToggleAutoAim();
	}
	else
	{
		self.aim = false;
		self iPrintln("AimBot[^1OFF^7]");
		self notify( "stop_aimbot");
	}
}

unlockallDvar()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("unlockall") == 1)
		{	
			self thread toggleUnlockAll();
			setDvar("unlockall", "0");
		}
		wait 0.1;
	}
}

toggleUnlockAll()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	if(self.unlock == false )
	{
		self.unlock = true;
		self iPrintln("Unlocking all");
		setDvar("svr_pezbots_XPCheat", "1");
	}
	else
	{
		self.unlock = false;
		self iPrintln("Disabling Unlocking all");
		setDvar("svr_pezbots_XPCheat", "0");
	}
}

ToggleAutoAim()
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

spawnRain()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("giverain") == 1)
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
		wait 0.1;
	}
}

spawnSnow()
{
	self endon("disconnect");

	for (;;)
	{
		if (getDvarInt("givesnow") == 1)
		{	
			start = self getTagOrigin("tag_eye");
			end = anglestoforward(self getPlayerAngles()) * 1000000;
			fxpos = BulletTrace(start, end, true, self)["position"];
			level._effect["dust_wind_fast"]	= loadfx ("weather/snow_wind");
			level._effect["snow_light"]	= loadfx ("weather/snow_light");
			playFX(level._effect[ "dust_wind_fast" ], fxpos);
			playFX(level._effect[ "snow_light" ], fxpos);
			setDvar("givesnow", "0");
		}
		wait 0.1;
	}
}