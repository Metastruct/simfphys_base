hook.Add( "VehicleMove", "simfphysmove", function(ply,veh,mv)	
	local vehicle = ply:GetVehicle()
	if (!vehicle) then return end
	
	local vehicle = ply:GetVehicle()
	if (!vehicle) then return end
	
	local vehiclebase = vehicle.vehiclebase
	
	if (!IsValid(vehiclebase)) then return end
	
	local IsDriverSeat = vehicle == vehiclebase:GetDriverSeat()

	if (!IsDriverSeat) then return end

	local cmd = ply:GetCurrentCommand()
	
	vehiclebase.GetMouseX = cmd:GetMouseX()
end)