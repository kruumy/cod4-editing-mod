toggleModel(modeltype)
{
	switch(modeltype)
	{
		case "assault":
			if(self.pers["class"] == "CLASS_ASSAULT") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_assault"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_assault"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_assault"]) && self.pers["model_assault"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "specops":
		    if(self.pers["class"] == "CLASS_SPECOPS") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_specops"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_specops"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_specops"]) && self.pers["model_specops"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "support":
		    if(self.pers["class"] == "CLASS_HEAVYGUNNER") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_support"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_support"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_support"]) && self.pers["model_support"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		
		
		case "demolitions":
		    if(self.pers["class"] == "CLASS_DEMOLITIONS") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_recon"]))
			{
				self.pers["model_assault"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_recon"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_recon"]) && self.pers["model_recon"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "sniper":
		    if(self.pers["class"] == "CLASS_SNIPER") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_sniper"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_sniper"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_sniper"]) && self.pers["model_sniper"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
			
		case "velinda":
		    if(!isDefined(self.pers["model_velinda"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_velinda"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_velinda"]) && self.pers["model_velinda"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
			
		case "price":
		    if(!isDefined(self.pers["model_price"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_price"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_price"]) && self.pers["model_price"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
			
		case "farmer":
		    if(!isDefined(self.pers["model_price"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_farmer"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_farmer"]) && self.pers["model_farmer"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "zakhaev":
		    if(!isDefined(self.pers["model_zakhaev"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_zakhaev"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_zakhaev"]) && self.pers["model_zakhaev"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "alasad":
		    if(!isDefined(self.pers["model_alasad"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_alasad"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_alasad"]) && self.pers["model_alasad"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "ghillie":
		    if(!isDefined(self.pers["model_ghillie"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_ghillie"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_ghillie"]) && self.pers["model_ghillie"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "urbansniper":
		    if(!isDefined(self.pers["model_urbansniper"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_urbansniper"]) && self.pers["model_urbansniper"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		default:
		    self.pers["model_recon"] = undefined;
		    self.pers["model_assault"] = undefined;
			self.pers["model_support"] = undefined;
			self.pers["model_specops"] = undefined;
			self.pers["model_velinda"] = undefined;
			self.pers["model_price"] = undefined;
		    self.pers["model_sniper"] = undefined;
			self.pers["model_farmer"] = undefined;
			self.pers["model_zakhaev"] = undefined;
			self.pers["model_alasad"] = undefined;
			self.pers["model_ghillie"] = undefined;
			self.pers["model_urbansniper"] = undefined;
			if(!isDefined(self.pers["model_default"]) && self.pers["model_default"] != true) self iPrintLnBold( game["strings"]["change_model_default"] );
			self.pers["model_default"] = true;
			break;
	}
}
