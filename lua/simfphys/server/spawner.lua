
local function MakeLuaVehicle( Player, Pos, Ang, Model, Class, VName, VTable, data )

	if ( !gamemode.Call( "PlayerSpawnVehicle", Player, Model, VName, VTable ) ) then return end

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
	
	timer.Simple( 0.15, function()
		if (IsValid(Ent)) then
			Ent:SetSpawn_List( VName )
		end
	end)

	if ( IsValid( Player ) ) then
		gamemode.Call( "PlayerSpawnedVehicle", Player, Ent )
	end

	return Ent

end

function SpawnSimfphysVehicle( Player, vname, tr )
	if ( !vname ) then return end

	local VehicleList = list.Get( "simfphys_vehicles" )
	local vehicle = VehicleList[ vname ]

	if ( !vehicle ) then return end
	
	if ( !tr ) then
		tr = Player:GetEyeTraceNoCursor()
	end

	local Angles = Player:GetAngles()
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180 + (vehicle.SpawnAngleOffset and vehicle.SpawnAngleOffset or 0)

	local pos = tr.HitPos + Vector(0,0,25) + (vehicle.SpawnOffset or Vector(0,0,0))

	local Ent = MakeLuaVehicle( Player, pos, Angles, vehicle.Model, vehicle.Class, vname, vehicle )
	if ( !IsValid( Ent ) ) then return end

	if ( vehicle.Members ) then
		table.Merge( Ent, vehicle.Members )
		duplicator.StoreEntityModifier( Ent, "VehicleMemDupe", vehicle.Members )
	end
	
	timer.Simple( 0.02, function()
		if (!IsValid(Ent)) then return end
		
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
	end )

	undo.Create( "Vehicle" )
		undo.SetPlayer( Player )
		undo.AddEntity( Ent )
		undo.SetCustomUndoText( "Undone " .. vehicle.Name )
	undo.Finish( "Vehicle (" .. tostring( vehicle.Name ) .. ")" )

	Player:AddCleanup( "vehicles", Ent )
end
concommand.Add( "simfphys_spawnvehicle", function( ply, cmd, args ) SpawnSimfphysVehicle( ply, args[1] ) end )

local function VehicleMemDupe( Player, Entity, Data )
	table.Merge( Entity, Data )
end
duplicator.RegisterEntityModifier( "VehicleMemDupe", VehicleMemDupe )