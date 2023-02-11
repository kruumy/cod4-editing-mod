#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_menufunc;


onPlayerSpawned()
{
    self endon("disconnect");
    self.status = "Client";
    if(self == level.players[0])
        self.status = "Admin";
    for(;;)
    {
        self waittill("spawned_player");

     self.inMenu = undefined;
	self iPrintln("^4PRESS 4 TO OPEN");

     self thread initMenu();
	 
    }
}

TextME(player,text1,text2,text3,glowColor)
{
	player endon("death");
	player endon("disconnect");
	line[0]=createText2("default",2,"BOTTOM","BOTTOM",0,-150,1,10,text1);
	line[1]=createText2("default",2,"BOTTOM","BOTTOM",0,-125,1,10,text2);
	line[2]=createText2("default",2,"BOTTOM","BOTTOM",0,-100,1,10,text3);
	for(k=0;k<line.size;k++)
	{
		line[k].glowAlpha = 1;
		line[k].glowColor = glowColor;
		line[k] setPulseFX(110,4900,1500);
		wait 0.1;
	}
	wait 3;
	for(k = 0; k < 2; k++)
		line[k] destroy();
	wait 0.01;
}
welcomeMove(time,x,y)
{
	self moveOverTime(time);
	if(isDefined(x))
		self.x = x;
		
	if(isDefined(y))
		self.y = y;
}

createText2(font,fontscale,align,relative,x,y,alpha,sort,text)
{
	hudText = createFontString(font,fontscale);
	hudText setPoint(align,relative,x,y);
	hudText.alpha = alpha;
	hudText.sort = sort;
	hudText setText(text);
	self thread destroyElemOnDeath(hudText);
	return hudText;
}
destroyElemOnDeath(elem)
{
    self waittill("death");
    if(isDefined(elem.bar))
        elem destroyElem();
    else
        elem destroy();
}


initMenuOpts()
{
	m = "main";
	self addMenu(m, ">>> MAIN MENU <<<", undefined);
	self addOpt(m, "Quick Start", ::quickStart);
	self addOpt(m, "Bots Menu", ::subMenu, "bots");
	self addOpt(m, "Weapon Menu", ::subMenu, "weapon");
	self addOpt(m, "Kill Streak Menu", ::subMenu, "streak");
	self addOpt(m, "Player Menu", ::subMenu, "player");
	self addOpt(m, "Misc Menu", ::subMenu, "misc");


	m = "bots";
	self addMenu(m, ">>> BOTS <<<", "main");
	self addOpt(m, "Add 5 Random Bots", ::spawnRngBots, "5");
	self addOpt(m, "Add 10 Random Bots", ::spawnRngBots, "10");
	self addOpt(m, "Add 5 Axis Bots", ::spawnAxisBots, "5");
	self addOpt(m, "Add 5 Allies Bots", ::spawnAlliesBots, "5");
	self addOpt(m, "Clear Bodies", ::ClearBodies);
	
	m = "weapon";
	self addMenu(m, ">>> Weapons <<<", "main");
	self addOpt(m, "Stock", ::openStock);
	self addOpt(m, "Custom", ::openCustom);
	self addOpt(m, "Give Ammo", ::giveAmmo);
	
	m = "streak";
	self addMenu(m, ">>> STREAKS <<<", "main");
	self addOpt(m, "Give Radar", ::GivePlayerRadar);
	self addOpt(m, "Give Airstrike", ::GivePlayerAirstrike);
	self addOpt(m, "Give Helicopter", ::GivePlayerHeli);
	self addOpt(m, "Pet Chopper", ::spawnPetChopper);
	self addOpt(m, "Drop Bomb", ::bombLoc);
	self addOpt(m, "AC130", ::doac130);

	m = "player";
	self addMenu(m, ">>> PLAYERS <<<", "main");
	self addOpt(m, "God Mode", ::GodMode);
	self addOpt(m, "Aimbot", ::aimBot);
	self addOpt(m, "Give All Perks", ::GiveAllPerks);
	self addOpt(m, "Explosive Bullets", ::ebClose);
	
	m = "misc";
	self addMenu(m, ">>> MISC <<<", "main");
	self addOpt(m, "Bullet Menu", ::subMenu, "bullets");
	self addOpt(m, "Unlock All", ::unlockall);
	self addOpt(m, "Rain Map", ::spawnRain);
	self addOpt(m, "Forge", ::Forge);
	self addOpt(m, "Teleport", ::Teleport);
	self addOpt(m, "Money Fountain", ::moneyFountain);
	self addOpt(m, "Disco Sun", ::toggle_sun);
	self addOpt(m, "Stair To Heaven", ::StairToHeaven);

	m = "bullets";
	self addMenu(m, ">>> Bullets <<<", "misc");
	self addOpt(m, "Helicopter", ::MagicRounds, "vehicle_mi24p_hind_desert");
	self addOpt(m, "Plane", ::MagicRounds, "vehicle_mig29_desert", "Sub Option");
	self addOpt(m, "Car", ::MagicRounds, "vehicle_80s_sedan1_red_destructible_mp");
	self addOpt(m, "RPG", ::test);
	self addOpt(m, "Default Bullets", ::stopMagic);
	
}
 
initMenu()
{
    self endon("death");
    self endon("disconnect");
	
    //self.openBox = self createRectangle("TOP", "TOPRIGHT", -160, 10, 300, 30, (0, 0, 0), "white", 1, .7);
	//self.openBox1 = self createRectangle("TOP", "TOPRIGHT", -310, 
	//10, 1, 30, (0, 0, 1), "white", 1, .7);
	//self.openBox12 = self createRectangle("TOP", "TOPRIGHT", -9.60, 
	//10, 1, 30, (0, 0, 1), "white", 1, .7);
	//self.openText = self createText("default", 1.5, "TOP", "TOPRIGHT", -160, 16, 2, 1, ( 0, 0, 1), ">>> MENU BASE <<<"); 

    self.currentMenu = "main";
    self.menuCurs = 0;
    for(;;)
    {
        if(self secondaryOffHandButtonPressed())
        {
            if(!isDefined(self.inMenu))
            {
                self.inMenu = true;
                self thread deleteOffHand();
                self.openText.glowColor = (0, 0, 1);
                self.openText thread changeFontScaleOverTime(.4, 2);
                self.openText moveOverTime(.4);
                self.openText.y+= 5;
                self initMenuOpts();
                menuOpts = self.menuAction[self.currentMenu].opt.size;
                self.openBox scaleOverTime(.4, 300, ((400)+45));
				self.openBox1 scaleOverTime(.4, 1, ((400)+45));
				self.openBox12 scaleOverTime(.4, 1, ((400)+45));


                //wait .4;
                self.openText setText(self.menuAction[self.currentMenu].title);
                string = "";
                for(m = 0; m < menuOpts; m++)
                    string+= self.menuAction[self.currentMenu].opt[m]+"\n";
                self.menuText = self createText("default", 1.5, "LEFT", "TOPRIGHT", -400, 60, 3, 1, undefined, string);
				self.menuText moveOverTime(.2);
				self.menuText.x = ((20)-(320));




                self.scrollBar = self createRectangle("TOP", "TOPRIGHT", -250, ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2))), 111, 15, (0, 0, 1), "white", 2, .7);
            }
        }
        if(isDefined(self.inMenu))
        {
            if(self attackButtonPressed())
            {
                self.menuCurs++;
                if(self.menuCurs > self.menuAction[self.currentMenu].opt.size-1)
                    self.menuCurs = 0;
                self.scrollBar moveOverTime(.15);
                self.scrollBar.y = ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2)));
                wait .15;
            }
            if(self adsButtonPressed())
            {
                self.menuCurs--;
                if(self.menuCurs < 0)
                    self.menuCurs = self.menuAction[self.currentMenu].opt.size-1;
                self.scrollBar moveOverTime(.15);
                self.scrollBar.y = ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2)));
                wait .15;
            }
            if(self useButtonPressed())
            {
                self thread [[self.menuAction[self.currentMenu].func[self.menuCurs]]](self.menuAction[self.currentMenu].inp[self.menuCurs]);
				self playSound( "mouse_click" );
                wait .20;
            }
            if(self meleeButtonPressed())
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
                else
                    self subMenu(self.menuAction[self.currentMenu].parent);
            }
        }
        wait .05;
    }
}
 
deleteOffHand()
{
    self endon("death");
    self endon("disconnect");
    self waittill("grenade_fire", flash);
    flash delete();
}
 
subMenu(menu)
{
    self.menuCurs = 0;
    self.currentMenu = menu;
    self.scrollBar moveOverTime(.2);
    self.scrollBar.y = ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2)));
    self.menuText destroy();
    self initMenuOpts();
    self.openText setText(self.menuAction[self.currentMenu].title);
    menuOpts = self.menuAction[self.currentMenu].opt.size;
    self.openBox scaleOverTime(.2, 300, ((400)+45));
   self.openBox1 scaleOverTime(.2, 1, ((400)+45));
  self.openBox12 scaleOverTime(.2, 1, ((400)+45));


    wait .2;
    string = "";
    for(m = 0; m < menuOpts; m++)
        string+= self.menuAction[self.currentMenu].opt[m]+"\n";
    self.menuText = self createText("default", 1.5, "LEFT", "TOPRIGHT", -400, 60, 3, 1, undefined, string);
    self.menuText moveOverTime(.2);
    self.menuText.x = ((20)-(320));
    wait .2;
}
 
test()
{
    self iPrintln("^4MENU BASE TEST");
}


setStatus(guy, status)
{
    guy.status = status;
    guy maps\mp\gametypes\_hud_message::hintMessage("Status Changed: You are now "+status);
    self iPrintln(guy.name+" Is Now "+status);
    guy suicide();
}
 
addMenu(menu, title, parent)
{
    if(!isDefined(self.menuAction))
        self.menuAction = [];
    self.menuAction[menu] = spawnStruct();
    self.menuAction[menu].title = title;
    self.menuAction[menu].parent = parent;
    self.menuAction[menu].opt = [];
    self.menuAction[menu].func = [];
    self.menuAction[menu].inp = [];
}
 
addOpt(menu, opt, func, inp)
{
    m = self.menuAction[menu].opt.size;
    self.menuAction[menu].opt[m] = opt;
    self.menuAction[menu].func[m] = func;
    self.menuAction[menu].inp[m] = inp;
}
 
changeFontScaleOverTime(time, scale)
{
    start = self.fontscale;
    frames = (time/.05);
    scaleChange = (scale-start);
    scaleChangePer = (scaleChange/frames);
    for(m = 0; m < frames; m++)
    {
        self.fontscale+= scaleChangePer;
        wait .05;
    }
}
 
createText(font, fontScale, align, relative, x, y, sort, alpha, glow, text)
{
    textElem = self createFontString(font, fontScale, self);
    textElem setPoint(align, relative, x, y);
    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.glowColor = glow;
    textElem.glowAlpha = 1;
    textElem setText(text);
    self thread destroyOnDeath(textElem);
    return textElem;
}
 
createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
    boxElem = newClientHudElem(self);
    boxElem.elemType = "bar";
    if(!level.splitScreen)
    {
        boxElem.x = -2;
        boxElem.y = -2;
    }
    boxElem.width = width;
    boxElem.height = height;
    boxElem.align = align;
    boxElem.relative = relative;
    boxElem.xOffset = 0;
    boxElem.yOffset = 0;
    boxElem.children = [];
    boxElem.sort = sort;
    boxElem.color = color;
    boxElem.alpha = alpha;
    boxElem setParent(level.uiParent);
    boxElem setShader(shader, width, height);
    boxElem.hidden = false;
    boxElem setPoint(align, relative, x, y);
    self thread destroyOnDeath(boxElem);
    return boxElem;
}
 
destroyOnDeath(elem)
{
    self waittill_any("death", "disconnect");
    if(isDefined(elem.bar))
        elem destroyElem();
    else
        elem destroy();
    if(isDefined(elem.model))
        elem delete();;
}

//HERE



