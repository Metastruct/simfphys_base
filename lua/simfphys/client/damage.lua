local function damagedbackfire( length )
	local veh = net.ReadEntity()
	if not veh:IsValid() or not veh.Backfire then return end
	veh:Backfire( true )
end
net.Receive("simfphys_backfire", damagedbackfire)
