// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
    if(isDefined(self.pers["model_price"]) && self.pers["model_price"] == true)
		character\character_mp_sas_urban_price::main();
	else
	if(isDefined(self.pers["model_velinda"]) && self.pers["model_velinda"] == true)
		character\character_mp_usmc_woodland_velinda::main();
	else
	if(isDefined(self.pers["model_sniper"]) && self.pers["model_sniper"] == true)
		character\character_mp_sas_urban_sniper::main();
	else
	if(isDefined(self.pers["model_recon"]) && self.pers["model_recon"] == true)
		character\character_mp_sas_urban_recon::main();
	else
	if(isDefined(self.pers["model_specops"]) && self.pers["model_specops"] == true)
		character\character_mp_sas_urban_specops::main();
	else
	if(isDefined(self.pers["model_assault"]) && self.pers["model_assault"] == true)
		character\character_mp_sas_urban_assault::main();
	else
	character\character_mp_sas_urban_support::main();
}

precache()
{
	character\character_mp_sas_urban_support::precache();
}
