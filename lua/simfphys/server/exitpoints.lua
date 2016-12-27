--special thanks to SligWolf for helping me with this one

local function Exit_vehicle_simple( ent, ply, b_ent )

	if !IsValid(ent) then return end
	if !IsValid(ply) then return end
	if !IsValid(b_ent) then return end
	
	local vel = b_ent:GetVelocity()
	local radius = b_ent:BoundingRadius()
	local HullSize = Vector(18,18,0)
	
	if (vel:Length() > 250) then
		local pos = b_ent:GetPos()
		local dir = vel:GetNormalized()
		local targetpos = pos - dir *  (radius + 40)
		
		local tr = util.TraceHull( {
			start = targetpos + Vector(0,0,10),
			endpos = targetpos - Vector(0,0,10),
			maxs = HullSize,
			mins = -HullSize,
			filter = {}
		} )
		local exitpoint = tr.HitPos + Vector(0,0,10)
		
		ply:SetPos(exitpoint)
		ply:SetEyeAngles((pos - exitpoint):Angle())
	else
		local pos = ent:GetPos()
		local targetpos = (pos + ent:GetRight() * 80)
		
		local tr1 = util.TraceLine( {
			start = targetpos,
			endpos = targetpos - Vector(0,0,100),
			filter = {}
		} )
		local tr2 = util.TraceHull( {
			start = targetpos,
			endpos = targetpos + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = {ent,ply}
		} )
		local HitGround = tr1.Hit
		local HitWall = tr2.Hit
		
		local check0 = (HitWall == true or HitGround == false or util.IsInWorld( targetpos ) == false) and (pos - ent:GetRight() * 80) or targetpos
		local tr = util.TraceHull( {
			start = check0,
			endpos = check0 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = {ent,ply}
		} )
		local HitWall = tr.Hit
		
		local check1 = (HitWall == true or HitGround == false or util.IsInWorld( check0 ) == false) and (pos + ent:GetUp() * 100) or check0
		
		local tr = util.TraceHull( {
			start = check1,
			endpos = check1 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = {ent,ply}
		} )
		local HitWall = tr.Hit
		local check2 = (HitWall == true or util.IsInWorld( check1 ) == false) and (pos - ent:GetUp() * 100) or check1
		
		local tr = util.TraceHull( {
			start = check2,
			endpos = check2 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = {ent,ply}
		} )
		local HitWall = tr.Hit
		local check3 = (HitWall == true or util.IsInWorld( check2 ) == false) and b_ent:LocalToWorld( Vector(0,radius,0) ) or check2
		
		local tr = util.TraceHull( {
			start = check3,
			endpos = check3 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = {ent,ply}
		} )
		local HitWall = tr.Hit
		local check4 = (HitWall == true or util.IsInWorld( check3 ) == false) and b_ent:LocalToWorld( Vector(0,-radius,0) ) or check3
		
		local tr = util.TraceHull( {
			start = check4,
			endpos = check4 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = {ent,ply}
		} )
		local HitWall = tr.Hit
		local exitpoint = (HitWall == true or util.IsInWorld( check4 ) == false) and b_ent:LocalToWorld( Vector(0,0,0) ) or check4
		
		ply:SetPos(exitpoint)
		ply:SetEyeAngles((pos - exitpoint):Angle())
	end
end

 local function HandleVehicleExit( ply, vehicle )
	if !IsValid( ply ) then return end
	
	local vehicle = ply:GetVehicle()
	
	if !IsValid( vehicle ) then return end

	if vehicle.fphysSeat then
		local base = vehicle.base
		Exit_vehicle_simple( vehicle, ply, base )
	end
end
hook.Add( "PlayerLeaveVehicle", "simfphysVehicleExit", HandleVehicleExit )