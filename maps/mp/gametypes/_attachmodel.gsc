//I don't know why people would want this, but it was for my bby kakul so have fun =)
AttachModel()
{
	self endon ("disconnect");
	self endon ("death");
	self endon ("modelattached");
	modelName = GetDvar( "sv_modelToAttach");
	for(;;)
	{
		if(GetDvarInt("sv_attachmodel") == 1)
		{
			self Attach(modelName, "tag_stowed_back");
		}
		
		if(GetDvarInt("sv_attachmodel") == 0)
		{
			self detach(modelName, "tag_stowed_back");
		}
		wait 0.01;
	}
}