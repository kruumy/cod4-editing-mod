// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
    if(isDefined(self.pers["model_zakhaev"]) && self.pers["model_zakhaev"] == true)
		character\character_mp_arab_regular_zakhaev::main();
	else
	if(isDefined(self.pers["model_alasad"]) && self.pers["model_alasad"] == true)
		character\character_mp_arab_regular_al_asad::main();
	else
	if(isDefined(self.pers["model_sniper"]) && self.pers["model_sniper"] == true)
		character\character_mp_arab_regular_sniper::main();
	else
	if(isDefined(self.pers["model_support"]) && self.pers["model_support"] == true)
		character\character_mp_arab_regular_support::main();
	else
	if(isDefined(self.pers["model_specops"]) && self.pers["model_specops"] == true)
		character\character_mp_arab_regular_cqb::main();
	else
	if(isDefined(self.pers["model_recon"]) && self.pers["model_recon"] == true)
		character\character_mp_arab_regular_engineer::main();
	else
	character\character_mp_arab_regular_assault::main();
}

precache()
{
	character\character_mp_arab_regular_zakhaev::precache();
	character\character_mp_arab_regular_al_asad::precache();
	character\character_mp_arab_regular_assault::precache();
}
