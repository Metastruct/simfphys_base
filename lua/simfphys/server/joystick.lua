simfphys.jcon = {}

hook.Add("JoystickInitialize", "simfphys_joystick", function()
	simfphys.jcon.steer_left = jcon.register{
		uid = "joystick_steer_left",
		type = "analog",
		description = "Steer Left",
		category = "Simfphys",
	}
	
	simfphys.jcon.steer_right = jcon.register{
		uid = "joystick_steer_right",
		type = "analog",
		description = "Steer Right",
		category = "Simfphys",
	}
	
	simfphys.jcon.throttle = jcon.register{
		uid = "joystick_throttle",
		type = "analog",
		description = "Throttle",
		category = "Simfphys",
	}
	
	simfphys.jcon.brake = jcon.register{
		uid = "joystick_brake",
		type = "analog",
		description = "Brake",
		category = "Simfphys",
	}
	
	simfphys.jcon.gearup = jcon.register{
		uid = "joystick_gearup",
		type = "digital",
		description = "Gear Up",
		category = "Simfphys",
	}
	
	simfphys.jcon.geardown = jcon.register{
		uid = "joystick_geardown",
		type = "digital",
		description = "Gear Down",
		category = "Simfphys",
	}
	
	simfphys.jcon.handbrake = jcon.register{
		uid = "joystick_handbrake",
		type = "digital",
		description = "Handbrake",
		category = "Simfphys",
	}
	
	simfphys.jcon.clutch = jcon.register{
		uid = "joystick_clutch",
		type = "analog",
		description = "Clutch",
		category = "Simfphys",
	}
	
	simfphys.jcon.air_forward = jcon.register{
		uid = "joystick_air_w",
		type = "analog",
		description = "Air (forward)",
		category = "Simfphys",
	}
	
	simfphys.jcon.air_reverse = jcon.register{
		uid = "joystick_air_s",
		type = "analog",
		description = "Air (backward)",
		category = "Simfphys",
	}
	
	simfphys.jcon.air_left = jcon.register{
		uid = "joystick_air_a",
		type = "analog",
		description = "Air (left)",
		category = "Simfphys",
	}
	
	simfphys.jcon.air_right = jcon.register{
		uid = "joystick_air_d",
		type = "analog",
		description = "Air (right)",
		category = "Simfphys",
	}
	
	hook.Add("VehicleMove","simfphys_joystickhandler",function(ply, vehicle)
		--[[
		for i,ply in pairs( player.GetAll() ) do
			if ply:IsConnected() then
				local vehicle = ply:GetVehicle()
				if IsValid( vehicle ) then
		--]]
					if vehicle.fphysSeat then
						if vehicle.base:GetDriverSeat() == vehicle then
							for k,v in pairs( simfphys.jcon ) do
								if istable(v) and v.IsJoystickReg then
									local val = joystick.Get( ply, v.uid )
									
									if v.type == "analog" then
										vehicle.base.PressedKeys[v.uid] = val and val / 255 or 0
									else
										vehicle.base.PressedKeys[v.uid] = val and 1 or 0
									end
								end
							end
						end
					end
		--[[
				end
			end
		end
		--]]
	end)
end)
