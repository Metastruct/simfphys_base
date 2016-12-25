
TOOL.Category		= "simfphys"
TOOL.Name			= "#Wheel Model Editor"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "scale" ] = 1
TOOL.ClientConVar[ "scalerear" ] = 1
TOOL.ClientConVar[ "frontwheelmodel" ] = ""
TOOL.ClientConVar[ "rearwheelmodel" ] = ""
TOOL.ClientConVar[ "pitch" ] = 0
TOOL.ClientConVar[ "yaw" ] = 0
TOOL.ClientConVar[ "roll" ] = 0

if CLIENT then
	language.Add( "tool.simfphyswheeleditor.name", "simfphys wheel model editor" )
	language.Add( "tool.simfphyswheeleditor.desc", "Changes the wheels for simfphys vehicles with CustomWheels Enabled" )
	language.Add( "tool.simfphyswheeleditor.0", "Left click apply wheel model." )
	language.Add( "tool.simfphyswheeleditor.1", "Left click apply wheel model." )
end

function TOOL:LeftClick( trace )
	local ent = trace.Entity
	
	if (!IsValid(ent)) then return false end
	
	local IsVehicle = ent:GetClass() == "gmod_sent_vehicle_fphysics_base"
	
	if (!IsVehicle) then return false end
	
	if (SERVER) then
		if (ent.CustomWheels) then
			if (ent.GhostWheels) then
				local ply = self:GetOwner()
				
				ent.SmoothAng = 0
				
				timer.Simple( 0.05, function()
					if (!IsValid(ply)) then return end
					if (!IsValid(ent)) then return end
					
					for i = 1, table.Count( ent.GhostWheels ) do
						local Wheel = ent.GhostWheels[i]
						
						if (IsValid(Wheel)) then
							local swap_y = (i == 2 or i == 4 or i == 6)
							local Right = swap_y and -ent:LocalToWorldAngles( ent.VehicleData.LocalAngRight ):Forward() or ent:LocalToWorldAngles( ent.VehicleData.LocalAngRight ):Forward() 
							ent.CustomWheelAngleOffset = Angle( tonumber( self:GetClientInfo( "pitch" ) ) , tonumber( self:GetClientInfo( "yaw" ) ) , tonumber( self:GetClientInfo( "roll" ) ) )
							
							local Modelname = (i == 1 or i == 2) and self:GetClientInfo("frontwheelmodel") or (self:GetClientInfo("rearwheelmodel") != "" and self:GetClientInfo("rearwheelmodel") or self:GetClientInfo("frontwheelmodel"))
							
							Wheel:SetModel( Modelname )
							Wheel:SetAngles( Right:Angle() - ent.CustomWheelAngleOffset )
							Wheel:SetModelScale( (i == 1 or i == 2) and self:GetClientInfo( "scale" ) or self:GetClientInfo( "scalerear" )  )
						end
					end
				end)
			end
		end
	end
	
	return true
end

function TOOL:RightClick( trace )
	return false
end


local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#tool.simfphyswheeleditor.name", Description = "#tool.simfphyswheeleditor.desc" } )
	panel:AddControl( "ComboBox", { MenuButton = 1, Folder = "simfphys_wheel", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	panel:AddControl( "Textbox", 
	{
		Label 	= "Wheel Model",
		Command = "simfphyswheeleditor_frontwheelmodel"
	})	
	panel:AddControl( "Textbox", 
	{
		Label 	= "Override Rear Model",
		Command = "simfphyswheeleditor_rearwheelmodel"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Front Scale",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "5",
		Command = "simfphyswheeleditor_scale"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Rear Scale",
		Type 	= "Float",
		Min 	= "0",
		Max 	= "5",
		Command = "simfphyswheeleditor_scalerear"
	})
	
	panel:AddControl( "Slider", 
	{
		Label 	= "Pitch",
		Type 	= "Float",
		Min 	= "-180",
		Max 	= "180",
		Command = "simfphyswheeleditor_pitch"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Yaw",
		Type 	= "Float",
		Min 	= "-180",
		Max 	= "180",
		Command = "simfphyswheeleditor_yaw"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Roll",
		Type 	= "Float",
		Min 	= "-180",
		Max 	= "180",
		Command = "simfphyswheeleditor_roll"
	})
end
