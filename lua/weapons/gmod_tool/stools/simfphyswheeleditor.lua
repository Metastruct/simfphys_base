
TOOL.Category		= "simfphys"
TOOL.Name			= "#Wheel Model Editor"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "frontwheelmodel" ] = ""
TOOL.ClientConVar[ "rearwheelmodel" ] = ""
TOOL.ClientConVar[ "sameasfront" ] = 1

if CLIENT then
	language.Add( "tool.simfphyswheeleditor.name", "simfphys wheel model editor" )
	language.Add( "tool.simfphyswheeleditor.desc", "Changes the wheels for simfphys vehicles with CustomWheels Enabled" )
	language.Add( "tool.simfphyswheeleditor.0", "Left click apply wheel model. Reload to reset" )
	language.Add( "tool.simfphyswheeleditor.1", "Left click apply wheel model. Reload to reset" )
end

local function ApplyWheel(ply, ent, data)

	ent.CustomWheelAngleOffset = data[2]
	ent.CustomWheelAngleOffset_R = data[4]
	
	timer.Simple( 0.05, function()
		if (!IsValid(ent)) then return end
		
		for i = 1, table.Count( ent.GhostWheels ) do
			local Wheel = ent.GhostWheels[i]
			
			if (IsValid(Wheel)) then
				local isfrontwheel = (i == 1 or i == 2)
				local swap_y = (i == 2 or i == 4 or i == 6)
				
				local angleoffset = isfrontwheel and ent.CustomWheelAngleOffset or ent.CustomWheelAngleOffset_R
				
				local model = isfrontwheel and data[1] or data[3]
				
				local fAng = ent:LocalToWorldAngles( ent.VehicleData.LocalAngForward )
				local rAng = ent:LocalToWorldAngles( ent.VehicleData.LocalAngRight )
				
				local Forward = fAng:Forward() 
				local Right = swap_y and -rAng:Forward() or rAng:Forward()
				local Up = ent:GetUp()
				
				local ghostAng = Right:Angle()
				local mirAng = swap_y and 1 or -1
				ghostAng:RotateAroundAxis(Forward,angleoffset.p * mirAng)
				ghostAng:RotateAroundAxis(Right,angleoffset.r * mirAng)
				ghostAng:RotateAroundAxis(Up,-angleoffset.y)
				
				Wheel:SetModelScale( 1 )
				Wheel:SetModel( model )
				Wheel:SetAngles( ghostAng )
				
				timer.Simple( 0.05, function()
					if (!IsValid(Wheel) or !IsValid(ent)) then return end
					local wheelsize = Wheel:OBBMaxs() - Wheel:OBBMins()
					local radius = isfrontwheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local size = (radius * 2) / math.max(wheelsize.x,wheelsize.y,wheelsize.z)
					
					Wheel:SetModelScale( size )
				end)
			end
		end
	end)
end

local function GetAngleFromSpawnlist( model )
	if (!model) then print("invalid model") return Angle(0,0,0) end
	
	model = string.lower( model )
	
	local v_list = list.Get( "simfphys_vehicles" )
	for listname, _ in pairs( v_list ) do
		if (v_list[listname].Members.CustomWheels) then
			local FrontWheel = v_list[listname].Members.CustomWheelModel
			local RearWheel = v_list[listname].Members.CustomWheelModel_R
			
			if (FrontWheel) then 
				FrontWheel = string.lower( FrontWheel )
			end
			
			if (RearWheel) then 
				FrontWheel = string.lower( RearWheel )
			end
			
			if (model == FrontWheel or model == RearWheel) then
				local Angleoffset = v_list[listname].Members.CustomWheelAngleOffset
				if (Angleoffset) then
					return Angleoffset
				end
			end
		end
	end
	
	local list = list.Get( "simfphys_Wheels" )[model]
	local output = list and list.Angle or Angle(0,0,0)
	
	return output
end

function TOOL:LeftClick( trace )
	local ent = trace.Entity
	
	if (!IsValid(ent)) then return false end
	
	local IsVehicle = ent:GetClass() == "gmod_sent_vehicle_fphysics_base"
	
	if (!IsVehicle) then return false end
	
	if (SERVER) then
		local front_model = self:GetClientInfo("frontwheelmodel")
		local front_angle = GetAngleFromSpawnlist(front_model)
		
		local sameasfront = self:GetClientInfo("sameasfront") == "1"
		local rear_model = sameasfront and front_model or self:GetClientInfo("rearwheelmodel")
		local rear_angle = GetAngleFromSpawnlist(rear_model)
		
		if (!front_model or !rear_model or !front_angle or !rear_angle) then print("wtf bro how did you do this") return false end
		
		if (ent.CustomWheels) then
			if (ent.GhostWheels) then
				ent.SmoothAng = 0  -- lets make sure we are not steering
				
				for i = 1, table.Count( ent.Wheels ) do
					local Wheel = ent.Wheels[ i ]
					if (IsValid(Wheel)) then
						local physobj = Wheel:GetPhysicsObject()
						physobj:EnableMotion( true ) 
						physobj:Wake() 
					end
				end
				
				ApplyWheel(self:GetOwner(), ent, {front_model,front_angle,rear_model,rear_angle})
			end
		end
	end
	return true
end

function TOOL:RightClick( trace )
	return false
end

function TOOL:Reload( trace )
	local ent = trace.Entity
	
	if (!IsValid(ent)) then return false end
	
	local IsVehicle = ent:GetClass() == "gmod_sent_vehicle_fphysics_base"
	
	if (!IsVehicle) then return false end
	
	if (SERVER) then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]

		if (ent.CustomWheels) then
			if (ent.GhostWheels) then
				ent.SmoothAng = 0  -- lets make sure we are not steering
				
				for i = 1, table.Count( ent.Wheels ) do
					local Wheel = ent.Wheels[ i ]
					if (IsValid(Wheel)) then
						local physobj = Wheel:GetPhysicsObject()
						physobj:EnableMotion( true ) 
						physobj:Wake() 
					end
				end
				
				local front_model = VehicleList.Members.CustomWheelModel
				local front_angle = VehicleList.Members.CustomWheelAngleOffset
				local rear_model = VehicleList.Members.CustomWheelModel_R and VehicleList.Members.CustomWheelModel_R or front_model
				local rear_angle = VehicleList.Members.CustomWheelAngleOffset
				
				ApplyWheel(self:GetOwner(), ent, {front_model,front_angle,rear_model,rear_angle})
			end
		end
	end
	
	return true
end

function TOOL.BuildCPanel( panel )
	panel:AddControl( "Label",  { Text = "Front Wheel Model" } )
	panel:AddControl( "PropSelect", { Label = "", ConVar = "simfphyswheeleditor_frontwheelmodel", Height = 0, Models = list.Get( "simfphys_Wheels" ) } )
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "Rear Wheel Model" } )
	panel:AddControl( "Checkbox", 
	{
		Label 	= "same as front",
		Command = "simfphyswheeleditor_sameasfront",
	})	
	panel:AddControl( "PropSelect", { Label = "", ConVar = "simfphyswheeleditor_rearwheelmodel", Height = 0, Models = list.Get( "simfphys_Wheels" ) } )

end

--[[
list.Set( "simfphys_Wheels", "models/props_phx/wheels/magnetic_small_base.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_vehicles/apc_tire001.mdl", {Angle = Angle(0,180,0)} )
list.Set( "simfphys_Wheels", "models/red_hd_brera/red_hd_brera_wheel.mdl", {Angle = Angle(0,90,0)} )
list.Set( "simfphys_Wheels", "models/winningrook/gtav/dukes/dukes_wheel.mdl", {Angle = Angle(0,-90,0)} )
list.Set( "simfphys_Wheels", "models/salza/hatchback/hatchback_wheel.mdl", {Angle = Angle(0,90,0)} )
list.Set( "simfphys_Wheels", "models/salza/van/van_wheel.mdl", {Angle = Angle(0,-90,0)} )
list.Set( "simfphys_Wheels", "models/salza/moskvich/moskvich_wheel.mdl", {Angle = Angle(0,0,0)} )
list.Set( "simfphys_Wheels", "models/salza/trabant/trabant_wheel.mdl", {Angle = Angle(0,0,0)} )
list.Set( "simfphys_Wheels", "models/salza/trabant/trabant02_wheel.mdl", {Angle = Angle(0,0,0)} )
list.Set( "simfphys_Wheels", "models/salza/volga/volga_wheel.mdl", {Angle = Angle(0,-90,0)} )
list.Set( "simfphys_Wheels", "models/salza/zaz/zaz_wheel.mdl", {Angle = Angle(0,90,0)} )
list.Set( "simfphys_Wheels", "models/salza/gaz52/gaz52_wheel.mdl", {Angle = Angle(0,180,0)} )
list.Set( "simfphys_Wheels", "models/salza/skoda_liaz/skoda_liaz_fwheel.mdl", {Angle = Angle(0,180,0)} )
list.Set( "simfphys_Wheels", "models/salza/skoda_liaz/skoda_liaz_rwheel.mdl", {Angle = Angle(0,180,0)} )
list.Set( "simfphys_Wheels", "models/salza/avia/avia_wheel.mdl", {Angle = Angle(0,180,0)} )
]]--

timer.Simple( 0.1, function()
	local v_list = list.Get( "simfphys_vehicles" )
	for listname, _ in pairs( v_list ) do
		if (v_list[listname].Members.CustomWheels) then
			local FrontWheel = v_list[listname].Members.CustomWheelModel
			local RearWheel = v_list[listname].Members.CustomWheelModel_R
			if (FrontWheel) then
				list.Set( "simfphys_Wheels", FrontWheel, {} )
			end
			if (RearWheel) then
				list.Set( "simfphys_Wheels", RearWheel, {} )
			end
		end
	end
end)