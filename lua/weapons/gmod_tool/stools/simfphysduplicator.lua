TOOL.Category		= "simfphys"
TOOL.Name		= "#Vehicle Duplicator"
TOOL.Command		= nil
TOOL.ConfigName	= ""
local TOOLMemory	= {}

if SERVER then
	util.AddNetworkString( "sphys_dupe" )
	
	net.Receive("sphys_dupe", function( length, ply )
		TOOLMemory = net.ReadTable()
		ply:SelectWeapon( "gmod_tool" )
	end)
end

if CLIENT then
	language.Add( "tool.simfphysduplicator.name", "Vehicle Duplicator" )
	language.Add( "tool.simfphysduplicator.desc", "Copy, Paste, Save or Update your Vehicles" )
	language.Add( "tool.simfphysduplicator.0", "Left click to spawn or update an vehicle. Right click to copy" )
	language.Add( "tool.simfphysduplicator.1", "Left click to spawn or update an vehicle. Right click to copy" )
	
	local selecteditem	= nil
	
	net.Receive("sphys_dupe", function( length )
		TOOLMemory = net.ReadTable()
	end)
	
	local function GetSaves( panel )
		local saved_vehicles = file.Find("saved_vehicles/*.txt", "DATA")
		local index = 0
		local highlight = false
		local offset = 22
		
		for k,v in pairs(saved_vehicles) do
			local printname = v
			
			if !selecteditem then
				selecteditem = printname
			end
			
			local Button = vgui.Create( "DButton", panel )
			Button:SetText( printname )
			Button:SetTextColor( Color( 255, 255, 255 ) )
			Button:SetPos( 0,index * offset)
			Button:SetSize( 280, offset )
			Button.highlight = highlight
			Button.printname = printname
			Button.Paint = function( self, w, h )
				
				local c_selected = Color( 128, 185, 128, 255 )
				local c_normal = self.highlight and Color( 108, 111, 114, 200 ) or Color( 77, 80, 82, 200 )
				local c_hovered = Color( 41, 128, 185, 255 )
				local c_ = (selecteditem == self.printname) and c_selected or (self:IsHovered() and c_hovered or c_normal)
				
				draw.RoundedBox( 5, 1, 1, w - 2, h - 1, c_ )
			end
			Button.DoClick = function( self )
				selecteditem = self.printname
			end
			
			index = index + 1
			highlight = !highlight
		end
	end
	
	function TOOL.BuildCPanel( panel )
		if not file.Exists( "saved_vehicles", "DATA" ) then
			file.CreateDir( "saved_vehicles" )
		end
		
		local Frame = vgui.Create( "DFrame", panel )
		Frame:SetPos( 10, 30 )
		Frame:SetSize( 280, 320 )
		Frame:SetTitle( "" )
		Frame:SetVisible( true )
		Frame:ShowCloseButton( false )
		Frame:SetDraggable( false )
		Frame.Paint = function( self, w, h )
			draw.RoundedBox( 5, 0, 0, w, h, Color( 115, 115, 115, 255 ) )
			draw.RoundedBox( 5, 1, 1, w - 2, h - 2, Color( 234, 234, 234, 255 ) )
		end
		
		local ScrollPanel = vgui.Create( "DScrollPanel", Frame )
		ScrollPanel:SetSize( 280, 320 )
		ScrollPanel:SetPos( 0, 0 )
		
		GetSaves( ScrollPanel )
		
		local Button = vgui.Create( "DButton", panel )
		Button:SetText( "Save" )
		Button:SetPos( 10, 350)
		Button:SetSize( 280, 20 )
		Button.DoClick = function( self )
			if isstring(TOOLMemory.SpawnName) then
				local Frame = vgui.Create( "DFrame" )
					Frame:SetPos( gui.MouseX() - 100,  gui.MouseY() - 30 )
					Frame:SetSize( 280, 50 )
					Frame:SetTitle( "Save As..." )
					Frame:SetVisible( true )
					Frame:ShowCloseButton( true )	
					Frame:MakePopup()
					Frame:SetDraggable( true )
				
				local TextEntry = vgui.Create( "DTextEntry", Frame )
				TextEntry:SetPos( 5, 25 )
				TextEntry:SetSize( 270, 20 )
				
				TextEntry.OnEnter = function()
					local Name = TextEntry:GetValue()
					if Name != "" then						
						local DataString = ""
						
						for k,v in pairs(TOOLMemory) do
							DataString = DataString..k.."="..tostring( v ).."#"
						end
						
						file.Write("saved_vehicles/"..Name..".txt", DataString )
						
						ScrollPanel:Clear() 
						selecteditem = Name..".txt"
						GetSaves( ScrollPanel )
					end
					
					Frame:Close()
				end
			end
		end
		
		local Button = vgui.Create( "DButton", panel )
		Button:SetText( "Load" )
		Button:SetPos( 10, 370)
		Button:SetSize( 280, 20 )
		Button.DoClick = function( self )
			if isstring(selecteditem) then
				local DataString = file.Read( "saved_vehicles/"..selecteditem, "DATA" )
				local Data = string.Explode( "#", DataString )
				
				table.Empty( TOOLMemory )
				
				for _,v in pairs(Data) do
					local Var = string.Explode( "=", v )
					local name = Var[1]
					local variable = Var[2]
					
					if name and variable then
						TOOLMemory[name] = variable
					end
				end
				
				net.Start("sphys_dupe")
					net.WriteTable( TOOLMemory )
				net.SendToServer()
			end
		end
		
		local Button = vgui.Create( "DButton", panel )
		Button:SetText( "Delete" )
		Button:SetPos( 10, 390)
		Button:SetSize( 280, 20 )
		Button.DoClick = function( self )
			
			if isstring(selecteditem) then
				file.Delete( "saved_vehicles/"..selecteditem ) 
			end
			
			ScrollPanel:Clear() 
			selecteditem = nil
			GetSaves( ScrollPanel )
		end
		
		local Button = vgui.Create( "DButton", panel )
		Button:SetText( "Refresh" )
		Button:SetPos( 10, 410)
		Button:SetSize( 280, 20 )
		Button.DoClick = function( self )
			ScrollPanel:Clear() 
			selecteditem = nil
			GetSaves( ScrollPanel )
		end
	end
end

function TOOL:SpawnVehicle( Player, Pos, Ang, Model, Class, VName, VTable, data )
	if ( !gamemode.Call( "PlayerSpawnVehicle", Player, Model, VName, VTable ) ) then return end

	if (!file.Exists( Model, "GAME" )) then 
		Player:PrintMessage( HUD_PRINTTALK, "ERROR: \""..Model.."\" does not exist! (Class: "..VName..")")
		return
	end
	
	local Ent = ents.Create( "gmod_sent_vehicle_fphysics_base" )
	if ( !Ent ) then return NULL end

	duplicator.DoGeneric( Ent, data )
	
	Ent:SetModel( Model )
	Ent:SetAngles( Ang )
	Ent:SetPos( Pos )

	DoPropSpawnedEffect( Ent )

	Ent:Spawn()
	Ent:Activate()

	Ent.VehicleName = VName
	Ent.VehicleTable = VTable
	Ent.EntityOwner = Player
	Ent:SetSpawn_List( VName )

	if ( IsValid( Player ) ) then
		gamemode.Call( "PlayerSpawnedVehicle", Player, Ent )
	end

	return Ent
end

function TOOL:GetVehicleData( ent, ply )
	if not IsValid(ent) then return end
	if not istable(TOOLMemory) then print("rest in peace") return end
	
	table.Empty( TOOLMemory )
	
	TOOLMemory.SpawnName = ent:GetSpawn_List()
	TOOLMemory.SteerSpeed = ent:GetSteerSpeed()
	TOOLMemory.SteerFadeSpeed = ent:GetFastSteerConeFadeSpeed()
	TOOLMemory.SteerAngFast = ent:GetFastSteerAngle()
	TOOLMemory.SoundPreset = ent:GetEngineSoundPreset()
	TOOLMemory.IdleRPM = ent:GetIdleRPM()
	TOOLMemory.MaxRPM = ent:GetLimitRPM()
	TOOLMemory.PowerStart = ent:GetPowerBandStart()
	TOOLMemory.PowerEnd = ent:GetPowerBandEnd()
	TOOLMemory.PeakTorque = ent:GetMaxTorque()
	TOOLMemory.HasTurbo = ent:GetTurboCharged()
	TOOLMemory.HasBlower = ent:GetSuperCharged()
	TOOLMemory.HasRevLimiter = ent:GetRevlimiter()
	TOOLMemory.HasBulletProofTires = ent:GetBulletProofTires()
	TOOLMemory.MaxTraction = ent:GetMaxTraction()
	TOOLMemory.GripOffset = ent:GetTractionBias()
	TOOLMemory.BrakePower = ent:GetBrakePower()
	TOOLMemory.PowerDistribution = ent:GetPowerDistribution()
	TOOLMemory.Efficiency = ent:GetEfficiency()
	TOOLMemory.HornSound = ent.snd_horn
	TOOLMemory.HasBackfire = ent:GetBackFire()
	TOOLMemory.DoesntStall = ent:GetDoNotStall()
	TOOLMemory.SoundOverride = ent:GetSoundoverride()
	
	TOOLMemory.FrontHeight = ent:GetFrontSuspensionHeight()
	TOOLMemory.RearHeight = ent:GetRearSuspensionHeight()
	
	if ent.CustomWheels then
		if ent.GhostWheels then
			if IsValid(ent.GhostWheels[1]) then
				TOOLMemory.FrontWheelOverride = ent.GhostWheels[1]:GetModel()
			elseif IsValid(ent.GhostWheels[2]) then
				TOOLMemory.FrontWheelOverride = ent.GhostWheels[2]:GetModel()
			end
			
			if IsValid(ent.GhostWheels[3]) then
				TOOLMemory.RearWheelOverride = ent.GhostWheels[3]:GetModel()
			elseif IsValid(ent.GhostWheels[4]) then
				TOOLMemory.RearWheelOverride = ent.GhostWheels[4]:GetModel()
			end
		end
	end
	
	local tsc = ent:GetTireSmokeColor()
	TOOLMemory.TireSmokeColor = tsc.r..","..tsc.g..","..tsc.b
	
	local Gears = ""
	for _,v in pairs(ent.Gears) do
		Gears = Gears..v..","
	end
	
	local c = ent:GetColor()
	TOOLMemory.Color = c.r..","..c.g..","..c.b..","..c.a
	
	local bodygroups = {}
	for k,v in pairs(ent:GetBodyGroups()) do
		bodygroups[k] = ent:GetBodygroup( k ) 
	end
	
	TOOLMemory.BodyGroups = string.Implode( ",", bodygroups)
	
	TOOLMemory.Skin = ent:GetSkin()
	
	TOOLMemory.Gears = Gears
	TOOLMemory.FinalGear = ent:GetDifferentialGear()
	
	if not IsValid( ply ) then return end
	
	net.Start("sphys_dupe")
		net.WriteTable( TOOLMemory )
	net.Send( ply )
end

local function ApplyWheel(ent, data)
	--print("applywheel does run")
	ent.CustomWheelAngleOffset = data[2]
	ent.CustomWheelAngleOffset_R = data[4]
	
	timer.Simple( 0.05, function()
		if !IsValid(ent) then return end
		--print("the entity is valid")
		for i = 1, table.Count( ent.GhostWheels ) do
			--print("loop "..i)
			local Wheel = ent.GhostWheels[i]
			
			if (IsValid(Wheel)) then
				--print("wheel is valid")
				local isfrontwheel = (i == 1 or i == 2)
				local swap_y = (i == 2 or i == 4 or i == 6)
				
				local angleoffset = isfrontwheel and ent.CustomWheelAngleOffset or ent.CustomWheelAngleOffset_R
				
				local model = isfrontwheel and data[1] or data[3]
				
				local fAng = ent:LocalToWorldAngles( ent.VehicleData.LocalAngForward )
				local rAng = ent:LocalToWorldAngles( ent.VehicleData.LocalAngRight )
				
				local Forward = fAng:Forward() 
				local Right = swap_y and -rAng:Forward() or rAng:Forward()
				local Up = ent:GetUp()
				
				local Camber = data[5] or 0
				
				local ghostAng = Right:Angle()
				local mirAng = swap_y and 1 or -1
				ghostAng:RotateAroundAxis(Forward,angleoffset.p * mirAng)
				ghostAng:RotateAroundAxis(Right,angleoffset.r * mirAng)
				ghostAng:RotateAroundAxis(Up,-angleoffset.y)
				
				ghostAng:RotateAroundAxis(Forward, Camber * mirAng)
				
				Wheel:SetModelScale( 1 )
				Wheel:SetModel( model )
				Wheel:SetAngles( ghostAng )
				
				timer.Simple( 0.05, function()
					if (!IsValid(Wheel) or !IsValid(ent)) then return end -- print("something is wrong") return end
					local wheelsize = Wheel:OBBMaxs() - Wheel:OBBMins()
					local radius = isfrontwheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local size = (radius * 2) / math.max(wheelsize.x,wheelsize.y,wheelsize.z)
					
					Wheel:SetModelScale( size )
					--print("model is set")
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
	if (SERVER) then
		PrintTable(TOOLMemory)
	end
	
	local ply = self:GetOwner()
	local vname = TOOLMemory.SpawnName
	
	local VehicleList = list.Get( "simfphys_vehicles" )
	local vehicle = VehicleList[ vname ]
	
	if not vehicle then return false end
	if CLIENT then return true end
	
	local SpawnPos = trace.HitPos + Vector(0,0,25) + (vehicle.SpawnOffset or Vector(0,0,0))
	
	local SpawnAng = self:GetOwner():EyeAngles()
	SpawnAng.pitch = 0
	SpawnAng.yaw = SpawnAng.yaw + 180 + (vehicle.SpawnAngleOffset and vehicle.SpawnAngleOffset or 0)
	SpawnAng.roll = 0
	
	local Ent = self:SpawnVehicle( ply, SpawnPos, SpawnAng, vehicle.Model, vehicle.Class, vname, vehicle )
	if not IsValid( Ent ) then return end
	
	if ( vehicle.Members ) then
		table.Merge( Ent, vehicle.Members )
		duplicator.StoreEntityModifier( Ent, "VehicleMemDupe", vehicle.Members )
	end

	if ( Ent.ModelInfo ) then
		if (Ent.ModelInfo.Bodygroups) then
			for i = 1, table.Count( Ent.ModelInfo.Bodygroups ) do
				Ent:SetBodygroup(i, Ent.ModelInfo.Bodygroups[i] ) 
			end
		end
		
		if (Ent.ModelInfo.Skin) then
			Ent:SetSkin( Ent.ModelInfo.Skin )
		end
		
		if (Ent.ModelInfo.Color) then
			Ent:SetColor( Ent.ModelInfo.Color )
			
			local Color = Ent.ModelInfo.Color
			local dot = Color.r * Color.g * Color.b * Color.a
			Ent.OldColor = dot
			
			local data = {
				Color = Color,
				RenderMode = 0,
				RenderFX = 0
			}
			duplicator.StoreEntityModifier( Ent, "colour", data )
		end
	end
	
	local tsc = string.Explode( ",", TOOLMemory.TireSmokeColor )
	Ent:SetTireSmokeColor( Vector( tonumber(tsc[1]), tonumber(tsc[2]), tonumber(tsc[3]) ) )
	
	Ent.Turbocharged = tobool( TOOLMemory.HasTurbo )
	Ent.Supercharged = tobool( TOOLMemory.HasBlower )
	
	Ent:SetEngineSoundPreset( tonumber( TOOLMemory.SoundPreset ) )
	Ent:SetMaxTorque( tonumber( TOOLMemory.PeakTorque ) )
	Ent:SetDifferentialGear( tonumber( TOOLMemory.FinalGear ) )
	
	Ent:SetSteerSpeed( tonumber( TOOLMemory.SteerSpeed ) )
	Ent:SetFastSteerAngle( tonumber( TOOLMemory.SteerAngFast ) )
	Ent:SetFastSteerConeFadeSpeed( tonumber( TOOLMemory.SteerFadeSpeed ) )
	
	Ent:SetEfficiency( tonumber( TOOLMemory.Efficiency ) )
	Ent:SetMaxTraction( tonumber( TOOLMemory.MaxTraction ) )
	Ent:SetTractionBias( tonumber( TOOLMemory.GripOffset ) )
	Ent:SetPowerDistribution( tonumber( TOOLMemory.PowerDistribution ) )
	
	Ent:SetBackFire( tobool( TOOLMemory.HasBackfire ) )
	Ent:SetDoNotStall( tobool( TOOLMemory.DoesntStall ) )
	
	Ent:SetIdleRPM( tonumber( TOOLMemory.IdleRPM ) )
	Ent:SetLimitRPM( tonumber( TOOLMemory.MaxRPM ) )
	Ent:SetRevlimiter( tobool( TOOLMemory.HasRevLimiter ) )
	Ent:SetPowerBandEnd( tonumber( TOOLMemory.PowerEnd ) )
	Ent:SetPowerBandStart( tonumber( TOOLMemory.PowerStart ) )
	
	Ent:SetTurboCharged( Ent.Turbocharged )
	Ent:SetSuperCharged( Ent.Supercharged )
	Ent:SetBrakePower( tonumber( TOOLMemory.BrakePower ) )
	
	Ent:SetSoundoverride( TOOLMemory.SoundOverride or "" )
	
	Ent:SetLights_List( Ent.LightsTable or "no_lights" )
	
	Ent:SetBulletProofTires( tobool( TOOLMemory.HasBulletProofTires ) )
	
	Ent.snd_horn = TOOLMemory.HornSound
	
	local Gears = {}
	local Data = string.Explode( ",", TOOLMemory.Gears  )
	for i = 1, table.Count( Data ) do Gears[i] = tonumber( Data[i] ) end
	Ent.Gears = Gears
	
	
	timer.Simple( 0.5, function()
		if !IsValid(Ent) then return end
		
		Ent:SetFrontSuspensionHeight( tonumber( TOOLMemory.FrontHeight ) )
		Ent:SetRearSuspensionHeight( tonumber( TOOLMemory.RearHeight ) )
		
		local groups = string.Explode( ",", TOOLMemory.BodyGroups)
		for i = 1, table.Count( groups ) do
			Ent:SetBodygroup(i, tonumber(groups[i]) )
		end
		
		Ent:SetSkin( TOOLMemory.Skin )
		
		local c = string.Explode( ",", TOOLMemory.Color )
		local Color =  Color( tonumber(c[1]), tonumber(c[2]), tonumber(c[3]), tonumber(c[4]) )
		
		local dot = Color.r * Color.g * Color.b * Color.a
		Ent.OldColor = dot
		Ent:SetColor( Color )
		
		local data = {
			Color = Color,
			RenderMode = 0,
			RenderFX = 0
		}
		duplicator.StoreEntityModifier( Ent, "colour", data )
	
		--print("entity is valid")
		if Ent.CustomWheels then
			--print("has custom wheels")
			if Ent.GhostWheels then
				--print("and ghostwheels")
				if !TOOLMemory.FrontWheelOverride and !TOOLMemory.RearWheelOverride then return end --print("but there is no wheel model") return end
				
				local front_model = TOOLMemory.FrontWheelOverride or vehicle.Members.CustomWheelModel
				local front_angle = GetAngleFromSpawnlist(front_model)
				
				local camber = 0
				local rear_model = TOOLMemory.RearWheelOverride or (vehicle.Members.CustomWheelModel_R and vehicle.Members.CustomWheelModel_R or front_model)
				local rear_angle = GetAngleFromSpawnlist(rear_model)
				
				if (!front_model or !rear_model or !front_angle or !rear_angle) then return end
				--print("we apply the wheel")
				ApplyWheel(Ent, {front_model,front_angle,rear_model,rear_angle,camber})
			end
		end
	end)
	
	undo.Create( "Vehicle" )
		undo.SetPlayer( ply )
		undo.AddEntity( Ent )
		undo.SetCustomUndoText( "Undone " .. vehicle.Name )
	undo.Finish( "Vehicle (" .. tostring( vehicle.Name ) .. ")" )

	ply:AddCleanup( "vehicles", Ent )
	
	return true
end

function TOOL:RightClick( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	
	if not IsValid(ent) then table.Empty( TOOLMemory ) return false end
	
	if ent:GetClass():lower() != "gmod_sent_vehicle_fphysics_base" then return false end
	
	if SERVER then
		self:GetVehicleData( ent, ply )
	end
	
	return true
end

function TOOL:Reload( trace )
	return false
end
