hook.Add("CalcVehicleView", "simfphysViewOverride", function(Vehicle, ply, view)

	if (!Vehicle.vehiclebase) then
		local parent = Vehicle:GetParent()
		if (IsValid(parent)) then
			if (parent:GetClass() == "gmod_sent_vehicle_fphysics_base") then
				Vehicle.vehiclebase = parent
			end
		end
	end
	local vehiclebase = Vehicle.vehiclebase
	
	if (!IsValid(vehiclebase)) then return end

	local IsDriverSeat = Vehicle == vehiclebase:GetDriverSeat()
	
	if ( Vehicle.GetThirdPersonMode == nil || ply:GetViewEntity() != ply ) then
		return
	end
	
	if ( !Vehicle:GetThirdPersonMode() ) then
		view.origin = IsDriverSeat and view.origin + Vehicle:GetUp() * 5 - Vehicle:GetRight() * 9 or view.origin + Vehicle:GetUp() * 5
		return view
	end
	
	local mn, mx = vehiclebase:GetRenderBounds()
	local radius = ( mn - mx ):Length()
	local radius = radius + radius * Vehicle:GetCameraDistance()

	local TargetOrigin = view.origin + ( view.angles:Forward() * -radius )
	local WallOffset = 4

	local tr = util.TraceHull( {
		start = view.origin,
		endpos = TargetOrigin,
		filter = function( e )
			local c = e:GetClass() -- Avoid contact with entities that can potentially be attached to the vehicle. Ideally, we should check if "e" is constrained to "Vehicle".
			return !c:StartWith( "prop_physics" ) &&!c:StartWith( "prop_dynamic" ) && !c:StartWith( "prop_ragdoll" ) && !e:IsVehicle() && !c:StartWith( "gmod_" ) && !c:StartWith( "player" )
		end,
		mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
		maxs = Vector( WallOffset, WallOffset, WallOffset ),
	} )

	view.origin = tr.HitPos
	view.drawviewer = true

	if ( tr.Hit && !tr.StartSolid) then
		view.origin = view.origin + tr.HitNormal * WallOffset
	end
	
	return view
end)

hook.Add("StartCommand", "simfphys_lockview", function(ply, ucmd)
	local vehicle = ply:GetVehicle()
	if (!IsValid(vehicle)) then return end
	
	if (!vehicle.vehiclebase) then
		local parent = vehicle:GetParent()
		if (IsValid(parent)) then
			if (parent:GetClass() == "gmod_sent_vehicle_fphysics_base") then
				vehicle.vehiclebase = parent
			end
		end
	end
	local vehiclebase = vehicle.vehiclebase
	
	if (!IsValid(vehiclebase)) then return end

	local IsDriverSeat = vehicle == vehiclebase:GetDriverSeat()
	
	if (!IsDriverSeat) then return end
	if !(ply:GetInfoNum( "cl_simfphys_mousesteer", 0 ) == 1) then return end
	
	local ang = ucmd:GetViewAngles()
	
	if (vehiclebase:GetFreelook()) then
		vehicle.lockedpitch = ang.p
		vehicle.lockedyaw = ang.y
		return
	end

	vehicle.lockedpitch = vehicle.lockedpitch or 0
	vehicle.lockedyaw = vehicle.lockedyaw or 90
	
	local dir = 0
	if (vehicle.lockedyaw < 90 and vehicle.lockedyaw > -90) then
		dir = math.abs(vehicle.lockedyaw - 90)
	end
	if (vehicle.lockedyaw >= 90) then
		dir = -math.abs(vehicle.lockedyaw - 90)
	end
	if (vehicle.lockedyaw < -90 and vehicle.lockedyaw >= -270) then
		dir = -math.abs(vehicle.lockedyaw + 270)
	end
	
	vehicle.lockedyaw = vehicle.lockedyaw + dir * 0.05
	vehicle.lockedpitch = vehicle.lockedpitch + (5 - vehicle.lockedpitch) * 0.05
	
	if (ply:GetInfoNum( "cl_simfphys_ms_lockpitch", 0 ) == 1) then
		ang.p = vehicle.lockedpitch
	end
	
	ang.y = vehicle.lockedyaw
	
	ucmd:SetViewAngles(ang)
end)