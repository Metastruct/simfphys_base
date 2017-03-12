util.AddNetworkString( "simfphys_request_seatswitch" )
util.AddNetworkString( "simfphys_mousesteer" )
	
net.Receive( "simfphys_mousesteer", function( length, ply )
	local vehicle = net.ReadEntity()
	local Steer = net.ReadFloat()
	
	if not IsValid(vehicle) then return end
	
	vehicle.ms_Steer = Steer
end)

local function handleseatswitching( length, ply )
	local vehicle = net.ReadEntity()
	local ply = net.ReadEntity()
	local req_seat = net.ReadInt( 32 )
	
	if !IsValid(vehicle) then return end
	if !IsValid(ply) then return end
	
	ply.NextSeatSwitch = ply.NextSeatSwitch or 0
	
	if (ply.NextSeatSwitch < CurTime()) then
		ply.NextSeatSwitch = CurTime() + 0.5
		
		if (req_seat == 0) then
			if !IsValid(vehicle:GetDriver()) then
				ply:ExitVehicle()
				
				if (IsValid(vehicle.DriverSeat)) then
					timer.Simple( 0.05, function()
						if !IsValid(vehicle) then return end
						if !IsValid(ply) then return end
						if IsValid(vehicle:GetDriver()) then return end
						
						ply:EnterVehicle( vehicle.DriverSeat )
						ply:SetAllowWeaponsInVehicle( false ) 
						local angles = Angle(0,90,0)
						ply:SetEyeAngles( angles )
					end)
				end
			end
		else
			if (!vehicle.pSeat) then return end
			local seat = vehicle.pSeat[req_seat]
			if (IsValid(seat) and !IsValid(seat:GetDriver())) then
				ply:ExitVehicle()
				
				timer.Simple( 0.05, function()
					if !IsValid(vehicle) then return end
					if !IsValid(ply) then return end
					if IsValid(seat:GetDriver()) then return end
					
					ply:EnterVehicle( seat )
					local angles = Angle(0,90,0)
					ply:SetEyeAngles( angles )
				end)
			end
		end
	end
end
net.Receive("simfphys_request_seatswitch", handleseatswitching)
