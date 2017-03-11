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
	language.Add( "tool.sphys_duplicator.name", "Vehicle Duplicator" )
	language.Add( "tool.sphys_duplicator.desc", "Copy, Paste, Save or Update your Vehicles" )
	language.Add( "tool.sphys_duplicator.0", "Left click to spawn or update an vehicle. Right click to copy" )
	language.Add( "tool.sphys_duplicator.1", "Left click to spawn or update an vehicle. Right click to copy" )
	
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
							DataString = DataString..k.."="..v.."#"
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
	
	if not IsValid( ply ) then return end
	
	net.Start("sphys_dupe")
		net.WriteTable( TOOLMemory )
	net.Send( ply )
end

function TOOL:LeftClick( trace )
	
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
	
	Ent:SetTireSmokeColor(Vector(180,180,180) / 255)
	
	Ent.Turbocharged = Ent.Turbocharged or false
	Ent.Supercharged = Ent.Supercharged or false
	
	Ent:SetEngineSoundPreset( Ent.EngineSoundPreset )
	Ent:SetSteerSpeed( Ent.TurnSpeed )
	Ent:SetMaxTorque( Ent.PeakTorque )
	Ent:SetDifferentialGear( Ent.DifferentialGear )
	Ent:SetFastSteerConeFadeSpeed( Ent.SteeringFadeFastSpeed )
	Ent:SetEfficiency( Ent.Efficiency )
	Ent:SetMaxTraction( Ent.MaxGrip )
	Ent:SetTractionBias( Ent.GripOffset / Ent.MaxGrip )
	Ent:SetPowerDistribution( Ent.PowerBias )
	
	Ent:SetBackFire( Ent.Backfire or false )
	Ent:SetDoNotStall( Ent.DoNotStall or false )
	
	Ent:SetIdleRPM( Ent.IdleRPM )
	Ent:SetLimitRPM( Ent.LimitRPM )
	Ent:SetRevlimiter( Ent.Revlimiter or false )
	Ent:SetPowerBandEnd( Ent.PowerbandEnd )
	Ent:SetPowerBandStart( Ent.PowerbandStart )
	
	Ent:SetTurboCharged( Ent.Turbocharged )
	Ent:SetSuperCharged( Ent.Supercharged )
	Ent:SetBrakePower( Ent.BrakePower )
	
	Ent:SetLights_List( Ent.LightsTable or "no_lights" )
	
	Ent:SetBulletProofTires( Ent.BulletProofTires or false )
	
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
