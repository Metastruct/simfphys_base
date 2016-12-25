hook.Add( "VehicleMove", "simfphysmove", function(ply,veh,mv)	
	local vehicle = ply:GetVehicle()
	if (!vehicle) then return end
	
	local vehicle = ply:GetVehicle()
	if (!vehicle) then return end
	
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

	local cmd = ply:GetCurrentCommand()
	
	vehiclebase.GetMouseX = cmd:GetMouseX()
end)