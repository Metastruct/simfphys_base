
TOOL.Category		= "simfphys"
TOOL.Name			= "#Transmission Editor"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "numgears" ] = 5
TOOL.ClientConVar[ "gear_r" ] = -0.1
TOOL.ClientConVar[ "gear_1" ] = 0.1
TOOL.ClientConVar[ "gear_2" ] = 0.2
TOOL.ClientConVar[ "gear_3" ] = 0.3
TOOL.ClientConVar[ "gear_4" ] = 0.4
TOOL.ClientConVar[ "gear_5" ] = 0.5
TOOL.ClientConVar[ "gear_6" ] = 0.6
TOOL.ClientConVar[ "gear_7" ] = 0.7
TOOL.ClientConVar[ "gear_8" ] = 0.8
TOOL.ClientConVar[ "gear_9" ] = 0.9
TOOL.ClientConVar[ "gear_10" ] = 1
TOOL.ClientConVar[ "gear_11" ] = 1.1
TOOL.ClientConVar[ "gear_12" ] = 1.2
TOOL.ClientConVar[ "gear_diff" ] = 0.5

local function SetGears( ply, ent, gears)
	if ( SERVER ) then
		ent.Gears = gears
		duplicator.StoreEntityModifier( ent, "gearmod", gears )
	end
end
duplicator.RegisterEntityModifier( "gearmod", SetGears )

if CLIENT then
	language.Add( "tool.simfphysgeareditor.name", "simfphys Transmission Editor" )
	language.Add( "tool.simfphysgeareditor.desc", "A tool used to edit gear ratios on simfphys vehicles" )
	language.Add( "tool.simfphysgeareditor.0", "Left click apply settings. Right click copy settings. Reload to reset" )
	language.Add( "tool.simfphysgeareditor.1", "Left click apply settings. Right click copy settings. Reload to reset" )
	
	language.Add( "tool.simfphysgeareditor.differential", "Differential" )
	language.Add( "tool.simfphysgeareditor.differential.help", "Multiplier for all gears" )
end

function TOOL:LeftClick( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	if (SERVER) then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]
		
		local gears = {tonumber( self:GetClientInfo( "gear_r" ) ),0}
		for i = 1, tonumber( self:GetClientInfo( "numgears" ) ) do
			local index = i + 2
			gears[index] = tonumber( self:GetClientInfo( "gear_"..i ) )
		end
		
		SetGears(self:GetOwner(), ent, gears )
		ent:SetDifferentialGear( tonumber( self:GetClientInfo( "gear_diff" ) ) )
	end
	
	return true
end


function TOOL:RightClick( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	
	if not simfphys.IsCar( ent ) then return false end
	
	if (SERVER) then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]
		
		local gears = ent.Gears
		local diffgear = ent:GetDifferentialGear()
		local num = table.Count( gears ) - 2
		
		for i = 3, 13 do
			ply:ConCommand( "simfphysgeareditor_gear_"..(i - 2).." "..(gears[i] or 0.001))
		end
		ply:ConCommand( "simfphysgeareditor_gear_r "..gears[1])
		ply:ConCommand( "simfphysgeareditor_numgears "..num)
		ply:ConCommand( "simfphysgeareditor_gear_diff "..diffgear)
	end
	
	return true
end

function TOOL:Reload( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	
	if not simfphys.IsCar( ent ) then return false end
	
	if (SERVER) then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]
		
		SetGears(self:GetOwner(), ent, VehicleList.Members.Gears )
		ent:SetDifferentialGear( VehicleList.Members.DifferentialGear )
	end
	
	return true
end

local ConVarsDefault = TOOL:BuildConVarList()
function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#tool.simfphysgeareditor.name", Description = "#tool.simfphysgeareditor.desc" } )
	panel:AddControl( "ComboBox", { MenuButton = 1, Folder = "transeditor", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )
	panel:AddControl( "Label",  { Text = "" } )
	
	panel:AddControl( "Slider", 
	{
		Label 	= "Amount Gears",
		Type 	= "Int",
		Min 	= "1",
		Max 	= "12",
		Command = "simfphysgeareditor_numgears"
	})
	panel:AddControl( "Label",  { Text = "Ratios:" } )
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 1",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_1"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 2",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_2"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 3",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_3"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 4",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_4"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 5",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_5"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 6",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_6"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 7",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_7"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 8",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_8"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 9",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_9"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 10",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_10"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 11",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_11"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Gear 12",
		Type 	= "Float",
		Min 	= "0.001",
		Max 	= "2",
		Command = "simfphysgeareditor_gear_12"
	})
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Slider", 
	{
		Label 	= "Reverse",
		Type 	= "Float",
		Min 	= "-2",
		Max 	= "-0.001",
		Command = "simfphysgeareditor_gear_r"
	})
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Slider", 
	{
		Label 	= "#tool.simfphysgeareditor.differential",
		Type 	= "Float",
		Min 	= "0.2",
		Max 	= "6",
		Command = "simfphysgeareditor_gear_diff",
		Help = true
	})
end
