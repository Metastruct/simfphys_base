local pressedkeys = {}
local chatopen = false
local spawnmenuopen = false
local contextmenuopen = false

local requests = {
	[KEY_1] = 0,
	[KEY_2] = 1,
	[KEY_3] = 2,
	[KEY_4] = 3,
	[KEY_5] = 4,
	[KEY_6] = 5,
	[KEY_7] = 6,
	[KEY_8] = 7,
	[KEY_9] = 8,
	[KEY_0] = 9,
}

local function lockControls( bLock )
	net.Start("simfphys_blockcontrols")
		net.WriteBool( bLock )
	net.SendToServer()
end

hook.Add( "OnContextMenuOpen", "simfphys_seatswitching_cmenuopen", function()
	contextmenuopen = true
	lockControls( true )
end)

hook.Add( "OnContextMenuClose", "simfphys_seatswitching_cmenuclose", function()
	contextmenuopen = false
	lockControls( false )
end)

hook.Add( "OnSpawnMenuOpen", "simfphys_seatswitching_menuopen", function()
	spawnmenuopen = true
end)

hook.Add( "OnSpawnMenuClose", "simfphys_seatswitching_menuclose", function()
	spawnmenuopen = false
end)

hook.Add( "FinishChat", "simfphys_seatswitching_chatend", function()
	chatopen = false
	lockControls( false )
end)

hook.Add( "StartChat", "simfphys_seatswitching_chatstart", function()
	chatopen = true
	lockControls( true )
end)

hook.Add( "Think", "simfphys_seatswitching", function()
	if chatopen or spawnmenuopen or contextmenuopen then return end
	
	local ply = LocalPlayer()
	local vehicle = ply:GetVehicle()
	if not IsValid( vehicle ) then return end
	
	local vehiclebase = vehicle.vehiclebase
	
	if not IsValid( vehiclebase ) then return end

	for key, request in pairs( requests ) do
		local keydown = input.IsKeyDown( key )
		
		if pressedkeys[key] ~= keydown then
			pressedkeys[key] = keydown
			if keydown then
				net.Start("simfphys_request_seatswitch")
					net.WriteEntity( vehiclebase ) 
					net.WriteEntity( ply ) 
					net.WriteInt( request, 32 )
				net.SendToServer()
			end
		end
	end
end )