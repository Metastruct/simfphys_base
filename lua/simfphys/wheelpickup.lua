local function PlayerPickup( ply, ent )
	if (ent:GetClass():lower() == "gmod_sent_sim_veh_wheel") then
		return false
	end
end
hook.Add( "GravGunPickupAllowed", "disableWheelPickup", PlayerPickup )