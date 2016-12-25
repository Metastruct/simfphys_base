-- Example script for vehicles without valves skeleton / animations / bones
-- Like the ones mainly used by scars

-- DO NOT JUST ADD YOUR VEHICLE HERE, MAKE A NEW FILE IN  LUA/AUTORUN  WITH A DIFFERENT NAME! IF YOU EDIT THIS FILE YOU WILL  OVERWRITE THE ORIGINAL VEHICLES!

local V = {
	Name = "Driveable Couch",
	Model = "models/props_c17/FurnitureCouch002a.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",
	SpawnAngleOffset = 90,

	Members = {
		Mass = 500,
		
		CustomWheels = true,       	 -- You have to set this to "true" in order to define custom wheels
		CustomSuspensionTravel = 10,	--suspension travel limiter length
		
		--FrontWheelRadius = 18,		-- if you set CustomWheels to true then the script will figure the radius out by itself using the CustomWheelModel
		--RearWheelRadius = 20,
		
		--SteerFront = false, 	-- disable front wheel steering
		--SteerRear = true, 	-- enable rear wheel steering
		
		CustomWheelModel = "models/props_phx/wheels/magnetic_small_base.mdl",	-- since we create our own wheels we have to define a model. It has to have a collission model
		--CustomWheelModel_R = "",			-- different model for rear wheels?
		
		CustomWheelPosFL = Vector(12,22,-15),		-- set the position of the front left wheel. 
		CustomWheelPosFR = Vector(12,-22,-15),	-- position front right wheel
		--CustomWheelPosML = Vector(0,22,-15),	-- middle left
		--CustomWheelPosMR = Vector(0,-22,-15),	-- middle right
		CustomWheelPosRL = Vector(-12,22,-15),	-- rear left
		CustomWheelPosRR = Vector(-12,-22,-15),	-- rear right		NOTE: make sure the position actually matches the name. So FL is actually at the Front Left ,  FR Front Right, ...   if you do this wrong the wheels will spin in the wrong direction or the car will drive sideways/reverse
		CustomWheelAngleOffset = Angle(90,0,0),
		
		CustomMassCenter = Vector(0,0,0),		-- custom masscenter offset. The script creates a counter weight to make the masscenter exactly in the center of the wheels. However you can add an offset to this to create more body roll if you really have to...
		
		CustomSteerAngle = 35,				-- max clamped steering angle,
		
		SeatOffset = Vector(-3,-13.5,21),
		SeatPitch = 15,
		SeatYaw = 90,
		
		-- everything below this comment is exactly the same as for normal vehicles. For more info take a look in simfphys_spawnlist.lua
		
		PassengerSeats = {
			{
				pos = Vector(0,-14,-12),
				ang = Angle(0,-90,0)
			}
		},
		
		FrontHeight = 7,			-- you need to finetune this versus CustomWheelPos so the wheels wont end up in space if the suspension gets lowered using C => Edit Properties  
		FrontConstant = 12000,
		FrontDamping = 400,
		FrontRelativeDamping = 50,
		
		RearHeight = 7,
		RearConstant = 12000,
		RearDamping = 400,
		RearRelativeDamping = 50,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 120,
		
		TurnSpeed = 8,
		
		MaxGrip = 20,
		Efficiency = 1,
		GripOffset = 0,
		BrakePower = 5,
		
		IdleRPM = 600,
		LimitRPM = 10000,
		PeakTorque = 40,
		PowerbandStart = 650,
		PowerbandEnd = 700,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		PowerBias = 0,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "",
		Sound_IdlePitch = 0,
		
		Sound_Mid = "vehicles/apc/apc_idle1.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "",
		
		Sound_Throttle = "",
		
		snd_horn = "simulated_vehicles/horn_0.wav",
		
		DifferentialGear = 0.7,
		Gears = {-0.1,0,0.1}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_couch", V )


local V = {
	Name = "HL2 APC",
	Model = "models/props_vehicles/apc001.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Half Life 2 / Synergy",
	SpawnOffset = Vector(0,0,50),

	Members = {
		Mass = 4800,
		MaxHealth = 2800,
		
		LightsTable = "conapc",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",
		CustomWheelPosFL = Vector(-45,77,-22),
		CustomWheelPosFR = Vector(45,77,-22),
		CustomWheelPosRL = Vector(-45,-74,-22),
		CustomWheelPosRR = Vector(45,-74,-22),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(65,-13,50),
		SeatPitch = 15,
		SeatYaw = 0,
		
		PassengerSeats = {
		},
		
		Attachments = {
			{
				model = "models/hunter/plates/plate075x105.mdl",
				material = "lights/white",
				color = Color(0,0,0,255),
				pos = Vector(0.04,57.5,16.74),
				ang = Angle(90,-90,0)
			},
			{
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255),
				pos = Vector(-25.08,91.34,29.46),
				ang = Angle(4.2,-109.19,68.43)
			},
			{
				pos = Vector(-24.63,77.76,8.65),
				ang = Angle(24.05,-12.81,-1.87),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(24.63,77.76,8.65),
				ang = Angle(24.05,-167.19,1.87),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(-30.17,61.36,32.79),
				ang = Angle(-1.21,-92.38,-130.2),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(30.17,61.36,32.79),
				ang = Angle(-1.21,-87.62,130.2),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,72.92,40.54),
				ang = Angle(0,-180,0.79),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(25.08,91.34,29.46),
				ang = Angle(4.2,-70.81,-68.43),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(-29.63,79.02,19.28),
				ang = Angle(90,-18,0),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(29.63,79.02,19.28),
				ang = Angle(90,-162,0),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,75.33,5.91),
				ang = Angle(0,0,0),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,98.02,35.74),
				ang = Angle(63,90,0),
				model = "models/hunter/plates/plate025x025.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,100.55,7.41),
				ang = Angle(90,-90,0),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			}
		},
		
		FrontHeight = 20,
		FrontConstant = 50000,
		FrontDamping = 4000,
		FrontRelativeDamping = 3000,
		
		RearHeight = 20,
		RearConstant = 50000,
		RearDamping = 4000,
		RearRelativeDamping = 3000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 140,
		Efficiency = 1.25,
		GripOffset = -14,
		BrakePower = 120,
		
		IdleRPM = 750,
		LimitRPM = 5500,
		PeakTorque = 180,
		PowerbandStart = 1000,
		PowerbandEnd = 4500,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 0,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/misc/nanjing_loop.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/misc/m50.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "simulated_vehicles/misc/v8high2.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 0.75,
		Sound_HighFadeInRPMpercent = 58,
		Sound_HighFadeInRate = 0.19,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "simulated_vehicles/horn_2.wav",
		
		DifferentialGear = 0.27,
		Gears = {-0.09,0,0.09,0.18,0.28,0.35}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_conscriptapc", V )



local V = {
	Name = "Alfa Romeo Brera",
	Model = "models/red_hd_brera/red_hd_brera.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1700,
		
		LightsTable = "alfons",
		
		CustomWheels = true,
		CustomSuspensionTravel = 15,
		
		CustomWheelModel = "models/red_hd_brera/red_hd_brera_wheel.mdl",
		CustomWheelPosFL = Vector(54,34.5,9),
		CustomWheelPosFR = Vector(54,-34.5,9),
		CustomWheelPosRL = Vector(-59,34.5,9),	
		CustomWheelPosRR = Vector(-59,-34.5,9),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-11,-19,42),
		SeatPitch = 0,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(-3,-18,10),
				ang = Angle(0,-90,10)
			},
			{
				pos = Vector(-30,-18,10),
				ang = Angle(0,-90,10)
			},
			{
				pos = Vector(-30,18,10),
				ang = Angle(0,-90,10)
			}
		},
		
		Backfire = true,
		ExhaustPositions = {
			{
				pos = Vector(-94.91,24.24,9.65),
				ang = Angle(90,180,0)
			},
			{
				pos = Vector(-96.27,18.81,9.63),
				ang = Angle(90,180,0)
			},
			{
				pos = Vector(-94.91,-24.24,9.65),
				ang = Angle(90,180,0)
			},
			{
				pos = Vector(-96.27,-18.81,9.63),
				ang = Angle(90,180,0)
			}
		},
		
		FrontHeight = 8,
		FrontConstant = 29000,
		FrontDamping = 2500,
		FrontRelativeDamping = 2500,
		
		RearHeight = 8,
		RearConstant = 29000,
		RearDamping = 2500,
		RearRelativeDamping = 2500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 43,
		Efficiency = 1.6,
		GripOffset = 0,
		BrakePower = 50,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		Revlimiter = true,
		PeakTorque = 130,
		PowerbandStart = 2000,
		PowerbandEnd = 7000,
		Turbocharged = true,
		Supercharged = false,
		
		PowerBias = 0,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/alfaromeo/alfons_idle.wav",
		
		snd_low ="simulated_vehicles/alfaromeo/alfons_low.wav",
		snd_low_revdown = "simulated_vehicles/alfaromeo/alfons_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/alfaromeo/alfons_mid.wav",
		snd_mid_gearup = "simulated_vehicles/alfaromeo/alfons_gear.wav",
		snd_mid_geardown = "simulated_vehicles/alfaromeo/alfons_shiftdown.wav",
		snd_mid_pitch = 1,
		
		DifferentialGear = 0.5,
		Gears = {-0.12,0,0.12,0.21,0.32,0.42,0.5}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_alfons", V )

local V = {
	Name = "GTA 5 Dukes",
	Model = "models/winningrook/gtav/dukes/dukes.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1700,
		
		LightsTable = "dukes",
		
		CustomWheels = true,
		CustomSuspensionTravel = 15,
		
		CustomWheelModel = "models/winningrook/gtav/dukes/dukes_wheel.mdl",
		CustomWheelPosFL = Vector(63.5,36,-13),
		CustomWheelPosFR = Vector(63.5,-36,-13),
		CustomWheelPosRL = Vector(-64,36.5,-9),
		CustomWheelPosRR = Vector(-64,-36.5,-9),
		CustomWheelAngleOffset = Angle(0,-90,0),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-18,-18,19),
		SeatPitch = 0,
		SeatYaw = 90,
		
		--[[
		ModelInfo = {
			Bodygroups = {1,2,0,0,0,0,0,1,1,1},
			Color = Color(0,31,127,255)
		},
		]]--
		
		PassengerSeats = {
			{
				pos = Vector(-3,-19,-13),
				ang = Angle(0,-90,17)
			}
		},
		
		ExhaustPositions = {
			{
				pos = Vector(-122.25,20.93,-7.28),
				ang = Angle(90,165,0)
			},
			{
				pos = Vector(-122.1,-20.95,-7.42),
				ang = Angle(90,195,0)
			}
		},
		
		FrontHeight = 8,
		FrontConstant = 29000,
		FrontDamping = 2500,
		FrontRelativeDamping = 2500,
		
		RearHeight = 9,
		RearConstant = 29000,
		RearDamping = 2500,
		RearRelativeDamping = 2500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 43,
		Efficiency = 1.2,
		GripOffset = -2,
		BrakePower = 40,
		
		IdleRPM = 600,
		LimitRPM = 7700,
		PeakTorque = 250,
		PowerbandStart = 1500,
		PowerbandEnd = 7400,
		Turbocharged = false,
		Supercharged = false,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.8,
		snd_idle = "simulated_vehicles/gta5_dukes/dukes_idle.wav",
		
		snd_low = "simulated_vehicles/gta5_dukes/dukes_low.wav",
		snd_low_revdown = "simulated_vehicles/gta5_dukes/dukes_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/gta5_dukes/dukes_mid.wav",
		snd_mid_gearup = "simulated_vehicles/gta5_dukes/dukes_second.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_3.wav",
		
		DifferentialGear = 0.6,
		Gears = {-0.12,0,0.12,0.21,0.32,0.42,0.5}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_dukes", V )


